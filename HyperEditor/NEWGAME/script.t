% Contains script parsers and stuff
% The core scripting framework was never finished...
module pervasive ScriptUtils

    export all

    % Make sure a script command has the right amount of arguments
    procedure assertLength(s : pointer to StringArrayList, minArgs : int, maxArgs : int)
	var size : int := s -> getSize
	if size < minArgs then
	    Debug.fatal("ScriptAssert", "Invalid script, not enough arguments! (Expected: '" + intstr(minArgs) + "' but got: '" + intstr(size) + "'!")
	    quit <
	elsif size > maxArgs then
	    Debug.fatal("ScriptAssert", "Invalid script, too many arguments! (Expected: '" + intstr(maxArgs) + "' but got: '" + intstr(size) + "'!")
	    quit <
	end if
    end assertLength

    % Make sure that a script param is an int!
    procedure assertInt(s : string)
	if not strintok(s) then
	    Debug.fatal("ScriptAssert", "Invalid script, expected integer but got: '" + s + "'!")
	    quit <
	end if
    end assertInt

    % Make sure that a script param is an real!
    procedure assertReal(s : string)
	if not strrealok(s) then
	    Debug.fatal("ScriptAssert", "Invalid script, expected real but got: '" + s + "'!")
	    quit <
	end if
    end assertReal

    % Make sure that a script param is an real!
    procedure assertBoolean(s : string)
	if not (s = "TRUE" or s = "FALSE" or s = "True" or s = "False" or s = "true" or s = "false") then
	    Debug.fatal("ScriptAssert", "Invalid script, expected boolean but got: '" + s + "'!")
	    quit <
	end if
    end assertBoolean

    % Make sure that a script param is an real!
    function isComment(s : string) : boolean
	if Utils.startsWith(s, "[") and Utils.endsWith(s, "]") then
	    result true
	elsif Utils.startsWith(s, "%") then
	    result true
	else
	    result false
	end if
    end isComment

end ScriptUtils
Debug.lm("ScriptUtils")

% Storage for flags and varaibles used in scripts
class pervasive ScriptStorage

    export all

    var intFlags : pointer to IntHM
    var booleanFlags : pointer to BooleanHM

    procedure setup
	intFlags := HMFactory.newIntHM()
	booleanFlags := HMFactory.newBooleanHM()
    end setup

    procedure setIntFlag(key : string, value : int)
	Debug.info("ScriptStorage", "Integer flag '" + key + "' set to: '" + intstr(value) + "'!")
	if intFlags -> containsKey(key) then
	    intFlags -> removeObj(key)
	end if
	intFlags -> putObj(key, value)
    end setIntFlag

    function getIntFlag(key : string) : int
	if not intFlags -> containsKey(key) then
	    result -1
	end if
	result intFlags -> getObj(key)
    end getIntFlag

    procedure setBooleanFlag(key : string, value : boolean)
	if value then
	    Debug.info("ScriptStorage", "Boolean flag '" + key + "' set to: 'true'!")
	else
	    Debug.info("ScriptStorage", "Boolean flag '" + key + "' set to: 'false'!")
	end if
	if booleanFlags -> containsKey(key) then
	    booleanFlags -> removeObj(key)
	end if
	booleanFlags -> putObj(key, value)
    end setBooleanFlag

    function getBooleanFlag(key : string) : boolean
	if not booleanFlags -> containsKey(key) then
	    result false
	end if
	result booleanFlags -> getObj(key)
    end getBooleanFlag

    procedure fullFree
	intFlags -> fullFree
	free intFlags
	booleanFlags -> fullFree
	free booleanFlags
    end fullFree

end ScriptStorage
var scriptStorage : pointer to ScriptStorage
new ScriptStorage, scriptStorage
scriptStorage -> setup()
Debug.lm("[DEPRECATED] ScriptStorage")

% Parser that can reliable parse math expressions
class pervasive ExprParser

    import scriptStorage

    export eval

    var expr : string

    function fillFlags(s : string) : string
	var ns : string := s
	for i : 1 .. scriptStorage -> intFlags -> usedKeys -> getSize()
	    var key : string := scriptStorage -> intFlags -> usedKeys -> getElement(i)
	    ns := Utils.replace(s, "INT_FLAG:" + key, intstr(scriptStorage -> getIntFlag(key)))
	end for
	    result ns
    end fillFlags

    function isOperator(s : string) : boolean
	case s of
	label "+" : result true
	label "-" : result true
	label "*" : result true
	label "/" : result true
	label "\^" : result true
	label : result false
	end case
    end isOperator

    function getCloseBracketIndex(e : string) : int
	var nest : int := 0
	for i : 1 .. length(e)
	    var c := e(i)
	    if c = "(" then
		nest += 1
	    elsif c = ")" and nest = 0 then
		result i
	    elsif c = ")" then
		nest -= 1
	    end if
	end for
	    Debug.fatal("ScriptAssert", "Invalid script, expected close bracket in math expression '" + e + "' but reached end of line!")
	quit <
    end getCloseBracketIndex

    function getOperatorIndexBehind(e : string, c : int) : int
	for decreasing i : c - 1 .. 1
	    if isOperator(e(i)) then
		result i
	    end if
	end for
	    result 1
    end getOperatorIndexBehind

    function getOperatorIndexAfter(e : string, c : int) : int
	for i : c + 1 .. length(e)
	    if isOperator(e(i)) then
		result i - 1
	    end if
	end for
	    result length(e)
    end getOperatorIndexAfter

    function eval(e : string) : real
	var s := Utils.replace(e, " ", "") % Eat spaces, yum!
	s := fillFlags(s)
	% Eval all stuff in brackets
	loop
	    exit when not Utils.contains(s, "(")
	    for i : 1 .. length(s)
		if s(i) = "(" then
		    var ne := s(i .. i + getCloseBracketIndex(s(i + 1 .. *)))
		    s := Utils.replace(s, ne, realstr(eval(ne(2 .. * - 1)), 1))
		    exit
		end if
	    end for
	end loop

	% Eval exponents
	loop
	    exit when not Utils.contains(s, "\^")
	    for i : 1 .. length(s)
		if s(i) = "\^" then
		    var start := getOperatorIndexBehind(s, i)
		    var finish := getOperatorIndexAfter(s, i)
		    var arg1 := s(start .. i - 1)
		    var arg2 := s(i + 1 .. finish)
		    % Make sure idiots don't put stupid shit in
		    ScriptUtils.assertReal(arg1)
		    ScriptUtils.assertReal(arg2)
		    var arg1real := strreal(arg1)
		    var arg2real := strreal(arg2)
		    var res := arg1real ** arg2real % Actual math
		    s := s(1 .. start - 1) + realstr(res, 1) + s(finish + 1 .. *)
		    exit
		end if
	    end for
	end loop

	% Eval multiplication and division
	loop
	    exit when not Utils.contains(s, "/") and not Utils.contains(s, "*")
	    for i : 1 .. length(s)
		if s(i) = "/" then
		    var start := getOperatorIndexBehind(s, i)
		    var finish := getOperatorIndexAfter(s, i)
		    var arg1 := s(start .. i - 1)
		    var arg2 := s(i + 1 .. finish)
		    % Make sure idiots don't put stupid shit in
		    ScriptUtils.assertReal(arg1)
		    ScriptUtils.assertReal(arg2)
		    var arg1real := strreal(arg1)
		    var arg2real := strreal(arg2)
		    var res := arg1real / arg2real % Actual math
		    s := s(1 .. start - 1) + realstr(res, 1) + s(finish + 1 .. *)
		    exit
		elsif s(i) = "*" then
		    var start := getOperatorIndexBehind(s, i)
		    var finish := getOperatorIndexAfter(s, i)
		    var arg1 := s(start .. i - 1)
		    var arg2 := s(i + 1 .. finish)
		    % Make sure idiots don't put stupid shit in
		    ScriptUtils.assertReal(arg1)
		    ScriptUtils.assertReal(arg2)
		    var arg1real := strreal(arg1)
		    var arg2real := strreal(arg2)
		    var res := arg1real * arg2real % Actual math
		    s := s(1 .. start - 1) + realstr(res, 1) + s(finish + 1 .. *)
		    exit
		end if
	    end for
	end loop

	% Eval addition and subtraction
	loop
	    exit when not Utils.contains(s, "+") and not Utils.contains(s, "-")
	    for i : 1 .. length(s)
		if s(i) = "+" then
		    var start := getOperatorIndexBehind(s, i)
		    var finish := getOperatorIndexAfter(s, i)
		    var arg1 := s(start .. i - 1)
		    var arg2 := s(i + 1 .. finish)
		    % Make sure idiots don't put stupid shit in
		    ScriptUtils.assertReal(arg1)
		    ScriptUtils.assertReal(arg2)
		    var arg1real := strreal(arg1)
		    var arg2real := strreal(arg2)
		    var res := arg1real + arg2real % Actual math
		    s := s(1 .. start - 1) + realstr(res, 1) + s(finish + 1 .. *)
		    exit
		elsif s(i) = "-" then
		    var start := getOperatorIndexBehind(s, i)
		    var finish := getOperatorIndexAfter(s, i)
		    var arg1 := s(start .. i - 1)
		    var arg2 := s(i + 1 .. finish)
		    % Make sure idiots don't put stupid shit in
		    ScriptUtils.assertReal(arg1)
		    ScriptUtils.assertReal(arg2)
		    var arg1real := strreal(arg1)
		    var arg2real := strreal(arg2)
		    var res := arg1real - arg2real % Actual math
		    s := s(1 .. start - 1) + realstr(res, 1) + s(finish + 1 .. *)
		    exit
		end if
	    end for
	end loop

	ScriptUtils.assertReal(s)

	result strreal(s)
    end eval

end ExprParser
Debug.lm("[DEPRECATED] ExprParser")

% Core script parser
% Uses recursion to efficiently parse scripts
class pervasive ScriptParser

    import scriptStorage

    var fileName : string
    var exprParser : pointer to ExprParser

    function getElse(content : pointer to StringArrayList, start : int, finish : int) : int
	var nest : int := 0
	for i : start .. finish
	    if Utils.startsWith(content -> getElement(i), "IF") then
		nest += 1
	    elsif content -> getElement(i) = "ENDIF" then
		nest -= 1
	    elsif content -> getElement(i) = "ELSE" and nest = 0 then
		result i
	    end if
	end for
	    % No else
	result -1
    end getElse

    function getEndIf(content : pointer to StringArrayList, start : int, finish : int) : int
	var nest : int := 0
	for i : start .. finish
	    if Utils.startsWith(content -> getElement(i), "IF") then
		nest += 1
	    elsif content -> getElement(i) = "ENDIF" and nest = 0 then
		result i
	    elsif content -> getElement(i) = "ENDIF" then
		nest -= 1
	    end if
	end for
	    % WTF? If statement not closed!
	Debug.fatal("ScriptAssert", "Invalid script, expected 'ENDIF' but left scope! (File: '" + fileName + "', Line: " + intstr(finish) + ")")
	quit <
    end getEndIf

    type pervasive FlagType : enum(INT, BOOLEAN)
    function checkFlagType(s : string) : FlagType
	if Utils.startsWith(s, "INT_FLAG:") then
	    result FlagType.INT
	end if
	if Utils.startsWith(s, "BOOLEAN_FLAG:") then
	    result FlagType.BOOLEAN
	end if
	% WTF? Invalid flag
	Debug.fatal("ScriptAssert", "Expected flag type but got: '" + s + "'!")
	quit <
    end checkFlagType

    function splitFlagForName(s : string) : string
	var split : pointer to StringArrayList := Utils.split(s, ":", false)
	result split -> getElement(2)
    end splitFlagForName

    function considerReverse(b : boolean, r : boolean) : boolean
	if r then
	    result not b
	else
	    result b
	end if
    end considerReverse

    function checkIf(args : pointer to StringArrayList) : boolean
	var cmd : string := args -> getElement(1)
	var reverse : boolean := false
	if cmd = "IF_FLAG_SET" then
	    var flag := args -> getElement(2)
	    var flagType : FlagType := checkFlagType(flag)
	    var flagName : string := splitFlagForName(flag)
	    if flagType = FlagType.INT then
		result scriptStorage -> intFlags -> containsKey(flagName)
	    elsif flagType = FlagType.BOOLEAN then
		result scriptStorage -> booleanFlags -> containsKey(flagName)
	    end if
	    % WTF? Like honestly WTF.
	    Debug.fatal("ScriptAssert", "Unexpected internal program type error!")
	    quit <
	elsif cmd = "IF" then
	    var sce : int := 2
	    if args -> getElement(2) = "NOT" then
		sce += 1
		reverse := true
	    end if
	    var argsSize : int := args -> getSize() - sce
	    if Utils.startsWith(args -> getElement(sce), "BOOLEAN_FLAG:") and argsSize = 1 then
		result considerReverse(Utils.strbool(splitFlagForName(args -> getElement(sce))), reverse)
	    elsif Utils.startsWith(args -> getElement(sce), "BOOLEAN_FLAG:") and argsSize = 3 then
		result considerReverse(Utils.strbool(splitFlagForName(args -> getElement(sce))) =
		Utils.strbool(splitFlagForName(args -> getElement(sce + 2))), reverse)
	    elsif argsSize = 3 then
		var arg1 : real := exprParser -> eval(args -> getElement(sce))
		var arg2 : real := exprParser -> eval(args -> getElement(sce + 2))
		var op : string := args -> getElement(sce + 1)
		if op = "=" then
		    result considerReverse(arg1 = arg2, reverse)
		elsif op = "<=" then
		    result considerReverse(arg1 <= arg2, reverse)
		elsif op = ">=" then
		    result considerReverse(arg1 >= arg2, reverse)
		elsif op = "<" then
		    result considerReverse(arg1 < arg2, reverse)
		elsif op = ">" then
		    result considerReverse(arg1 > arg2, reverse)
		end if
	    end if
	end if
	% WTF? Wierd if statement
	Debug.fatal("ScriptAssert", "Invalid if statement type: '" + cmd + "'!")
	quit <
    end checkIf

    function doParse(content : pointer to StringArrayList, start : int, finish : int) : boolean
	for i : start .. finish
	    var list : pointer to StringArrayList := Utils.split(content -> getElement(i), " ", true)
	    var cmd : string := list -> getElement(1)
	    % Parse flag set if
	    if Utils.startsWith(cmd, "IF") then
		var continue : boolean := true
		var success : boolean := checkIf(list)
		var endIf : int := getEndIf(content, i, finish)
		var elseMarker : int := getElse(content, i, finish)
		if elseMarker = -1 then
		elseMarker := endIf
		end if
		if success then
		    % Run content inside if statement
		    continue := doParse(content, i + 1, elseMarker - 1)
		    % Run else
		elsif endIf - elseMarker > 0 then
		    continue := doParse(content, elseMarker + 1, endIf - 1)
		end if
		if continue then
		    continue := doParse(content, endIf + 1, finish)
		end if
		result continue
	    else
		% Invoke command normall
		var copiedList : pointer to StringArrayList
		new StringArrayList, copiedList
		for a : 2 .. list -> getSize()
		    copiedList -> addElement(list -> getElement(a))
		end for
		    var garbage := FlowScriptAPI.try(cmd, copiedList)
	    end if
	end for
    end doParse

    procedure beginParse
	% Read the script to an array
	var content : pointer to StringArrayList := Utils.readFileToArray(fileName)

	var garbage : boolean := doParse(content, 1, content -> getSize())

    end beginParse

    procedure setup
	new ExprParser, exprParser
    end setup

    procedure fullFree
	free exprParser
    end fullFree

end ScriptParser
Debug.lm("[DEPRECATED] ScriptParser")
