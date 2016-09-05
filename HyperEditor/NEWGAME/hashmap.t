% Core hashmaps code, allows storing data in a <KEY, VALUE> pair (by: Andy Bao)
% The key is a string, and the value, well, it depends
% This data structure is quite complex, if you are confused see: https://en.wikipedia.org/wiki/Hash_table
% PLEASE NOTE: THE CODE IN THIS FILE DEPENDS ON THE NATIVE OpenTuring HASHMAPS, DO NOT TRY TO RUN THIS IN REGULAR TURING!
% These HashMaps are blazing fast, since they almost entirely implemented natively, we don't have to worry about performance
% Put and remove operations are also run in the background!
% Oh yeah, and don't manually construct the hashmaps, just use the factory

% This is not a full implementation of hashmaps, it is simply a wrapper around the OpenTuring hashmaps

% Int
class pervasive IntHM

    export all

    var internalHM : int
    var usedKeys : pointer to FastStringArrayList
    var usedObjects : pointer to FastIntArrayList
    var size : int := 0

    procedure setup
        internalHM := IntHashMap.New()
        new FastStringArrayList, usedKeys
        new FastIntArrayList, usedObjects
    end setup

    procedure putObj(key : string, value : int)
        IntHashMap.Put(internalHM, key, value)
        usedKeys -> addElement(key)
        usedObjects -> addElement(value)
        size += 1
    end putObj

    function getObj(key : string) : int
        var value : int
        var garbage := IntHashMap.Get(internalHM, key, value)
        result value
    end getObj

    procedure removeObj(key : string)
        var value : int
        var garbage := IntHashMap.Get(internalHM, key, value)
        IntHashMap.Remove(internalHM, key)
        usedKeys -> removeElement(key)
        usedObjects -> removeElement(value)
        size -= 1
    end removeObj

    function containsKey(key : string) : boolean
        result usedKeys -> contains(key)
    end containsKey

    function containsValue(value : int) : boolean
        result usedObjects -> contains(value)
    end containsValue

    procedure fullFree
        free usedKeys
        free usedObjects
        IntHashMap.Free(internalHM)
    end fullFree

end IntHM
Debug.lm("IntHashMap")

% Boolean (Wrapper for IntHashMap)
class pervasive BooleanHM

    export all

    var internalHM : pointer to IntHM

    procedure setup
        new IntHM, internalHM
        internalHM -> setup()
    end setup


    function booleanToInt(b : boolean) : int
        if b then
            result 1
        else
            result 0
        end if
    end booleanToInt

    function intToBoolean(i : int) : boolean
        result i = 1
    end intToBoolean

    procedure putObj(key : string, value : boolean)
        internalHM -> putObj(key, booleanToInt(value))
    end putObj

    function getObj(key : string) : boolean
        result intToBoolean(internalHM -> getObj(key))
    end getObj

    procedure removeObj(key : string)
        internalHM -> removeObj(key)
    end removeObj

    function containsKey(key : string) : boolean
        result internalHM -> containsKey(key)
    end containsKey

    function containsValue(value : boolean) : boolean
        result internalHM -> containsValue(booleanToInt(value))
    end containsValue

    procedure fullFree
        internalHM -> fullFree
        free internalHM
    end fullFree

end BooleanHM
Debug.lm("BooleanHashMap")

% String (Partially based on FastStringArrayList)
class pervasive StringHM

    export setup, putObj, getObj, removeObj, containsKey, containsValue, fullFree

    var internalHM : int
    var core : flexible array 1 .. 0 of string
    var usedKeys : pointer to FastStringArrayList
    var usedObjects : pointer to FastStringArrayList
    var coreTracker : flexible array 1 .. 0 of boolean
    var size : int := 0

    procedure setup
        internalHM := IntHashMap.New()
        new FastStringArrayList, usedKeys
        new FastStringArrayList, usedObjects
    end setup

    % Get a free position in the core array
    function allocateNew : int
        var freeSlot : int := -1
        for i : 1 .. upper(core)
            if coreTracker(i) = false then
                freeSlot := i
                exit
            end if
        end for
            % If we couldn't find a free slot, allocate one!
        if freeSlot = -1 then
            freeSlot := upper(core) + 1
            new core, freeSlot
            new coreTracker, freeSlot
        end if
        coreTracker(freeSlot) := true
        size += 1
        result freeSlot
    end allocateNew

    procedure putObj(key : string, value : string)
        var intValue : int := allocateNew()
        IntHashMap.Put(internalHM, key, intValue)
        usedKeys -> addElement(key)
        usedObjects -> addElement(value)
        core(intValue) := value
        size += 1
    end putObj

    function getObj(key : string) : string
        var value : int
        var garbage := IntHashMap.Get(internalHM, key, value)
        result core(value)
    end getObj

    procedure removeObj(key : string)
        var value : int
        var garbage := IntHashMap.Get(internalHM, key, value)
        IntHashMap.Remove(internalHM, key)
        usedKeys -> removeElement(key)
        usedObjects -> removeElement(core(value))
        coreTracker(value) := false
        core(value) := ""
        size -= 1
    end removeObj

    function containsKey(key : string) : boolean
        result usedKeys -> contains(key)
    end containsKey

    function containsValue(value : string) : boolean
        result usedObjects -> contains(value)
    end containsValue

    procedure fullFree
        free usedKeys
        free usedObjects
        IntHashMap.Free(internalHM)
    end fullFree

end StringHM
Debug.lm("StringHashMap")

% object (Partially based on FastStringArrayList)
class pervasive ObjectHM

    export setup, putObj, getObj, removeObj, containsKey, containsValue, fullFree

    var internalHM : int
    var core : flexible array 1 .. 0 of pointer to anyclass
    var usedKeys : pointer to FastStringArrayList
    var usedObjects : pointer to FastObjectArrayList
    var coreTracker : flexible array 1 .. 0 of boolean
    var size : int := 0

    procedure setup
        internalHM := IntHashMap.New()
        new FastStringArrayList, usedKeys
        new FastObjectArrayList, usedObjects
    end setup

    % Get a free position in the core array
    function allocateNew : int
        var freeSlot : int := -1
        for i : 1 .. upper(core)
            if coreTracker(i) = false then
                freeSlot := i
                exit
            end if
        end for
            % If we couldn't find a free slot, allocate one!
        if freeSlot = -1 then
            freeSlot := upper(core) + 1
            new core, freeSlot
            new coreTracker, freeSlot
        end if
        coreTracker(freeSlot) := true
        size += 1
        result freeSlot
    end allocateNew

    procedure putObj(key : string, value : pointer to anyclass)
        var intValue : int := allocateNew()
        IntHashMap.Put(internalHM, key, intValue)
        usedKeys -> addElement(key)
        usedObjects -> addElement(value)
        core(intValue) := value
        size += 1
    end putObj

    function getObj(key : string) : pointer to anyclass
        var value : int
        var garbage := IntHashMap.Get(internalHM, key, value)
        result core(value)
    end getObj

    procedure removeObj(key : string)
        var value : int
        var garbage := IntHashMap.Get(internalHM, key, value)
        IntHashMap.Remove(internalHM, key)
        usedKeys -> removeElement(key)
        usedObjects -> removeElement(core(value))
        coreTracker(value) := false
        core(value) := nil(anyclass)
        size -= 1
    end removeObj

    function containsKey(key : string) : boolean
        result usedKeys -> contains(key)
    end containsKey

    function containsValue(value : pointer to anyclass) : boolean
        result usedObjects -> contains(value)
    end containsValue

    procedure fullFree
        free usedKeys
        free usedObjects
        IntHashMap.Free(internalHM)
    end fullFree

end ObjectHM
Debug.lm("ObjectHashMap")

% HashMap factory
module pervasive HMFactory

    export all

    % Make an integer hashmap
    function newIntHM : pointer to IntHM
        var hm : pointer to IntHM
        new IntHM, hm
        hm -> setup()
        result hm
    end newIntHM

    % Make an boolean hashmap
    function newBooleanHM : pointer to BooleanHM
        var hm : pointer to BooleanHM
        new BooleanHM, hm
        hm -> setup()
        result hm
    end newBooleanHM

    % Make a string hashmap
    function newStringHM : pointer to StringHM
        var hm : pointer to StringHM
        new StringHM, hm
        hm -> setup()
        result hm
    end newStringHM

    % Make a string hashmap
    function newObjectHM : pointer to ObjectHM
        var hm : pointer to ObjectHM
        new ObjectHM, hm
        hm -> setup()
        result hm
    end newObjectHM

end HMFactory
Debug.lm("HashMapFactory")
