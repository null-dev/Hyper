% Holds main script run engines, initialized last
module pervasive ScriptEngine
    
    import cutsceneRenderer
    
    export all
    
    procedure runCutscene(filename : string)
	var content : pointer to StringArrayList := Utils.readFileToArray(CUTSCENEDIR + "/" + filename)
	for l : 1 .. content -> getSize()
	    var line : string := content -> getElement(l)
	    if not ScriptUtils.isComment(line) then
		cutsceneRenderer -> parseAndPlayCutsceneLine(line)
	    end if
	end for
	free content
    end runCutscene
    
end ScriptEngine
Debug.lm("ScriptEngine")
