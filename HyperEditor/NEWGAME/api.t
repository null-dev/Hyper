% API Allows command hooking (DEPRECATED)
% Deprecated when the scripting framework was abandoned...

Debug.warning("ScriptAPI", "Please note that 'Flow' scripting is no longer supported due to implementation difficulties!")
class pervasive CustomCommand

    export run, name

    var name : string

    procedure run(args : pointer to StringArrayList)
    end run

    procedure setName(n : string)
	name := n
    end setName

end CustomCommand
Debug.lm("[DEPRECATED] CustomCommand")

module pervasive FlowScriptAPI

export hook, try

    var core : flexible array 1 .. 0 of pointer to CustomCommand

    procedure hook(c : pointer to CustomCommand)
	new core, upper(core) + 1
	core(upper(core)) := c
	Debug.info("API", "Successfully hooked command '" + c -> name + "'!")
    end hook

    function try(c : string, args : pointer to StringArrayList) : boolean
	for i : 1 .. upper(core)
	    if core(i) -> name = c then
		core(i) -> run(args)
		result true
	    end if
	end for
	    result false
    end try
end FlowScriptAPI
Debug.lm("[DEPRECATED] FlowScriptAPI")

include "CUSTOM/include.t"
