% Implementation of stacks in pure Turing (by: Andy Bao)
% Fast and neat
% String
class StringStack
    
    export push, pop, size
    
    var core : flexible array 1 .. 0 of string
    
    procedure push(o : string)
        new core, upper(core) + 1
        core(upper(core)) := o
    end push
    
    function pop : string
        var res : string := core(upper(core))
        new core, upper(core) - 1         
        result res
    end pop
    
    function size : int
        result upper(core)
    end size
    
end StringStack
Debug.lm("StringStack")
% Int
class IntStack
    
    export push, pop, size
    
    var core : flexible array 1 .. 0 of int
    
    procedure push(o : int)
        new core, upper(core) + 1
        core(upper(core)) := o
    end push
    
    function pop : int
        var res : int := core(upper(core))
        new core, upper(core) - 1         
        result res
    end pop
    
    function size : int
        result upper(core)
    end size
    
end IntStack
Debug.lm("IntStack")
% Real
class RealStack
    
    export push, pop, size
    
    var core : flexible array 1 .. 0 of real
    
    procedure push(o : real)
        new core, upper(core) + 1
        core(upper(core)) := o
    end push
    
    function pop : real
        var res : real := core(upper(core))
        new core, upper(core) - 1         
        result res
    end pop
    
    function size : int
        result upper(core)
    end size
    
end RealStack
Debug.lm("RealStack")
% Boolean
class BooleanStack
    
    export push, pop, size
    
    var core : flexible array 1 .. 0 of boolean
    
    procedure push(o : boolean)
        new core, upper(core) + 1
        core(upper(core)) := o
    end push
    
    function pop : boolean
        var res : boolean := core(upper(core))
        new core, upper(core) - 1         
        result res
    end pop
    
    function size : int
        result upper(core)
    end size
    
end BooleanStack
Debug.lm("BooleanStack")