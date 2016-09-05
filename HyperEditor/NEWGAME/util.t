% Master utilites module, for everything that doesn't fit anywhere else
module pervasive Utils

    export all

    % Check if a string ends with another string
    function endsWith(theString : string, target : string) : boolean
	if length(theString) < length(target) then
	    result false
	end if
	var builder : string := ""
	for decreasing i : length(theString) .. length(theString) - length(target) + 1
	    builder := theString(i) + builder
	end for
	    result builder = target
    end endsWith

    % Check if a string begins with another string
    function beginsWith(theString : string, target : string) : boolean
	if length(theString) < length(target) then
	    result false
	end if
	var builder : string := ""
	for i : 1 .. length(target)
	    builder += theString(i)
	end for
	    result builder = target
    end beginsWith

    % Check if a string contains another string
    function contains(theString : string, target : string) : boolean
	result not index(theString, target) = 0
    end contains

    % Replace the first match of a string with another string inside a string
    function replaceFirst(theString : string, target : string, replacement : string) : string
	var indexOf : int := index(theString, target)
	if indexOf not = 0 then
	    result theString(1 .. indexOf - 1) + replacement + theString(indexOf + length(target) .. *)
	end if
	result theString
    end replaceFirst

    % Replace all occurances of a string inside a string
    function replace(theString : string, target : string, replacement : string) : string
	var res : string := theString
	loop
	    exit when not contains(res, target)
	    res := replaceFirst(res, target, replacement)
	end loop
	result res
    end replace

    % Alias to beginsWith
    function startsWith(theString : string, target : string) : boolean
	result beginsWith(theString, target)
    end startsWith

    % Split a string into many peices by a character
    function split(theString : string, delimeter : string(1), includeEmptySegments : boolean) : pointer to StringArrayList
	var list : pointer to StringArrayList
	new StringArrayList, list

	var builder : string := ""
	for i : 1 .. length(theString)
	    var theChar := theString(i)
	    if theChar not = delimeter then
		builder += theString(i)
	    else
		if length(builder) not = 0 or includeEmptySegments then
		    list -> addElement(builder)
		end if
		builder := ""
	    end if
	end for
	    if length(builder) not = 0 or includeEmptySegments then
	    list -> addElement(builder)
	end if
	result list
    end split

    % List all the files in a directory (Returns a boxed array that MUST be freed with 'free array')
    function listFiles(dir : string) : pointer to StringArrayList

	var list : pointer to StringArrayList
	new StringArrayList, list

	var dirStream : int
	dirStream := Dir.Open (dir)
	assert dirStream > 0
	loop
	    var fileName : string := Dir.Get (dirStream)
	    exit when fileName = ""
	    if fileName not = "." and fileName not = ".." then
		% Assign value
		list -> addElement(fileName)
	    end if
	end loop
	Dir.Close (dirStream)

	result list

    end listFiles

    % Boolean to string
    function strbool(b : string) : boolean
	result b = "TRUE" or b = "true" or b = "True"
    end strbool

    % Read a file to array
    function readFileToArray(file : string) : pointer to StringArrayList

	var stream : int
	var list : pointer to StringArrayList
	new StringArrayList, list

	open : stream, file, get

	loop
	    exit when eof(stream)
	    var line : string
	    get : stream, line : *
	    list -> addElement(line)
	end loop

	close : stream

	result list

    end readFileToArray

end Utils
Debug.lm("Utils")

% Color cache for rapid color resolving
module pervasive ColorUtils
export getColor
var colorCache : pointer to ObjectHM := HMFactory.newObjectHM ()
function getColor(s : string) : int
if not colorCache -> containsKey(s) then
var split : pointer to StringArrayList := Util.split(s, " ", false)
colorCache -> addElement(RGB.AddColor(strreal(split(1)),strreal(split(2)),strreal(split(3))))
end if
result colorCache -> getElement(s)
end getColor
end ColorUtils
Debug.lm("ColorUtils")
