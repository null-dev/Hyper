% Pure Turing ArrayList implementations (by Andy Bao)
% WARNING, THESE CLASSES ARE NOT BOUNDS CHECKED!

% ======[FastArrayList]======
% Order is usually preserved UNLESS A REMOVAL HAS BEEN PREFORMED
% Many times faster than regular ArrayList on write methods, slower in get methods
% No longer used
% String
class pervasive FastStringArrayList

    export getSize, addElement, getElement, indexOf, removeElement, removeElementAtIndex, contains

    var core : flexible array 1 .. 0 of string
    var coreTracker : flexible array 1 .. 0 of boolean
    var size : int := 0
    
    Debug.warning("FastStringArrayList", "This implementation of ArrayList is slow on get operations. It is reccommended to use StringArrayList instead!")

    function getSize : int
	result size
    end getSize

    % Get a free position in the ArrayList
    function allocateNew : int
	var freeSlot : int := -1
	for i : 1 .. upper (coreTracker)
	    if coreTracker (i) = false then
		freeSlot := i
		exit
	    end if
	end for
	% If we couldn't find a free slot, allocate one!
	if freeSlot = -1 then
	    freeSlot := upper (core) + 1
	    new core, freeSlot
	    new coreTracker, freeSlot
	end if
	coreTracker (freeSlot) := true
	size += 1
	result freeSlot
    end allocateNew

    % Get the real index
    function getRealIndex (theIndex : int) : int
	var target : int := 0
	for i : 1 .. upper (core)
	    % Only count filled slots
	    if coreTracker (i) then
		target += 1
		if target = theIndex then
		    result i
		end if
	    end if
	end for
	Debug.fatal ("FastStringArrayList", "Index out of bounds error! (" + intstr (theIndex) + "/" + intstr (target) + ")")
	quit
    end getRealIndex

    % Add an element to the arraylist
    procedure addElement (element : string)
	var allocated : int := allocateNew ()
	core (allocated) := element
    end addElement

    % Get an element from the arraylist
    function getElement (theIndex : int) : string
	result core (getRealIndex (theIndex))
    end getElement

    % Get the location of an object in the arraylist
    function indexOf (object : string) : int
	var target : int := 0
	for i : 1 .. upper (core)
	    % Only count filled slots
	    if coreTracker (i) then
		target += 1
		if core (i) = object then
		    result target
		end if
	    end if
	end for

	result - 1
    end indexOf

    % Check if the list contains an object
    function contains (object : string) : boolean
	result indexOf (object) not= -1
    end contains

    % Remove an element at index
    procedure removeElementAtIndex (theIndex : int)
	var realIndex : int := getRealIndex (theIndex)
	core (realIndex) := ""
	coreTracker (realIndex) := false
	size -= 1
    end removeElementAtIndex

    % Remove an object
    procedure removeElement (object : string)
	var realIndex := indexOf (object)
	if realIndex not= -1 then
	    removeElementAtIndex (realIndex)
	end if
    end removeElement
    
    % Clear the arraylist
    procedure clear
	for i : getSize () .. 1
	    removeElementAtIndex (i)
	end for
    end clear

end FastStringArrayList
Debug.lm ("[DEPRECATED] FastStringArrayList")
% Int
class pervasive FastIntArrayList

    export getSize, addElement, getElement, indexOf, removeElement, removeElementAtIndex, contains

    var core : flexible array 1 .. 0 of int
    var coreTracker : flexible array 1 .. 0 of boolean
    var size : int := 0
    
    Debug.warning("FastIntArrayList", "This implementation of ArrayList is slow on get operations. It is reccommended to use IntArrayList instead!")

    function getSize : int
	result size
    end getSize

    % Get a free position in the ArrayList
    function allocateNew : int
	var freeSlot : int := -1
	for i : 1 .. upper (coreTracker)
	    if coreTracker (i) = false then
		freeSlot := i
		exit
	    end if
	end for
	% If we couldn't find a free slot, allocate one!
	if freeSlot = -1 then
	    freeSlot := upper (core) + 1
	    new core, freeSlot
	    new coreTracker, freeSlot
	end if
	coreTracker (freeSlot) := true
	size += 1
	result freeSlot
    end allocateNew

    % Get the real index
    function getRealIndex (theIndex : int) : int
	var target : int := 0
	for i : 1 .. upper (core)
	    % Only count filled slots
	    if coreTracker (i) then
		target += 1
		if target = theIndex then
		    result i
		end if
	    end if
	end for
	Debug.fatal ("FastIntegerArrayList", "Index out of bounds error! (" + intstr (theIndex) + "/" + intstr (target) + ")")
	quit
    end getRealIndex

    % Add an element to the arraylist
    procedure addElement (element : int)
	var allocated : int := allocateNew ()
	core (allocated) := element
    end addElement

    % Get an element from the arraylist
    function getElement (theIndex : int) : int
	result core (getRealIndex (theIndex))
    end getElement

    % Get the location of an object in the arraylist
    function indexOf (object : int) : int
	var target : int := 0
	for i : 1 .. upper (core)
	    % Only count filled slots
	    if coreTracker (i) then
		target += 1
		if core (i) = object then
		    result target
		end if
	    end if
	end for

	result - 1
    end indexOf

    % Check if the list contains an object
    function contains (object : int) : boolean
	result indexOf (object) not= -1
    end contains

    % Remove an element at index
    procedure removeElementAtIndex (theIndex : int)
	var realIndex : int := getRealIndex (theIndex)
	core (realIndex) := -1
	coreTracker (realIndex) := false
	size -= 1
    end removeElementAtIndex

    % Remove an object
    procedure removeElement (object : int)
	var realIndex := indexOf (object)
	if realIndex not= -1 then
	    removeElementAtIndex (realIndex)
	end if
    end removeElement
    
    % Clear the arraylist
    procedure clear
	for i : getSize () .. 1
	    removeElementAtIndex (i)
	end for
    end clear

end FastIntArrayList
Debug.lm ("[DEPRECATED] FastIntArrayList")
% anyclass
class pervasive FastObjectArrayList

    export getSize, addElement, getElement, indexOf, removeElement, removeElementAtIndex, contains

    var core : flexible array 1 .. 0 of pointer to anyclass
    var coreTracker : flexible array 1 .. 0 of boolean
    var size : int := 0
    
    Debug.warning("FastObjectArrayList", "This implementation of ArrayList is slow on get operations. It is reccommended to use ObjectArrayList instead!")

    function getSize : int
	result size
    end getSize

    % Get a free position in the ArrayList
    function allocateNew : int
	var freeSlot : int := -1
	for i : 1 .. upper (coreTracker)
	    if coreTracker (i) = false then
		freeSlot := i
		exit
	    end if
	end for
	% If we couldn't find a free slot, allocate one!
	if freeSlot = -1 then
	    freeSlot := upper (core) + 1
	    new core, freeSlot
	    new coreTracker, freeSlot
	end if
	coreTracker (freeSlot) := true
	size += 1
	result freeSlot
    end allocateNew

    % Get the real index
    function getRealIndex (theIndex : int) : int
	var target : int := 0
	for i : 1 .. upper (core)
	    % Only count filled slots
	    if coreTracker (i) then
		target += 1
		if target = theIndex then
		    result i
		end if
	    end if
	end for
	Debug.fatal ("FastObjectArrayList", "Index out of bounds error! (" + intstr (theIndex) + "/" + intstr (target) + ")")
	quit
    end getRealIndex

    % Add an element to the arraylist
    procedure addElement (element : pointer to anyclass)
	var allocated : int := allocateNew ()
	core (allocated) := element
    end addElement

    % Get an element from the arraylist
    function getElement (theIndex : int) : pointer to anyclass
	result core (getRealIndex (theIndex))
    end getElement

    % Get the location of an object in the arraylist
    function indexOf (object : pointer to anyclass) : int
	var target : int := 0
	for i : 1 .. upper (core)
	    % Only count filled slots
	    if coreTracker (i) then
		target += 1
		if core (i) = object then
		    result target
		end if
	    end if
	end for

	result - 1
    end indexOf

    % Check if the list contains an object
    function contains (object : pointer to anyclass) : boolean
	result indexOf (object) not= -1
    end contains

    % Remove an element at index
    procedure removeElementAtIndex (theIndex : int)
	var realIndex : int := getRealIndex (theIndex)
	core (realIndex) := nil (anyclass)
	coreTracker (realIndex) := false
	size -= 1
    end removeElementAtIndex

    % Remove an object
    procedure removeElement (object : pointer to anyclass)
	var realIndex := indexOf (object)
	if realIndex not= -1 then
	    removeElementAtIndex (realIndex)
	end if
    end removeElement
    
    % Clear the arraylist
    procedure clear
	for i : getSize () .. 1
	    removeElementAtIndex (i)
	end for
    end clear

end FastObjectArrayList
Debug.lm ("[DEPRECATED] FastObjectArrayList")

% ======[ArrayList]======
% Order is always preserved
% Can be very slow when removing
% Why is this slow? Well when a removal is performed, we shift the entire list using an array copy
%   Array copying in turing is fucking slow as hell
% String
class pervasive StringArrayList

    export getSize, addElement, getElement, indexOf, removeElement, removeElementAtIndex, contains

    var core : flexible array 1 .. 1 of string
    var size : int := 0

    function getSize : int
	result size
    end getSize

    % Allocate a new position in the array
    function allocateNew () : int
	size += 1
	% Double the size of the array until we have enough space to allocate an element
	loop
	    exit when size <= upper (core)
	    new core, upper (core) * 2
	end loop
	result size
    end allocateNew

    % Add an element to the arraylist
    procedure addElement (element : string)
	var allocated : int := allocateNew ()
	core (allocated) := element
    end addElement

    % Get an element from the arraylist
    function getElement (theIndex : int) : string
	result core (theIndex)
    end getElement

    % Get the location of an object in the arraylist
    function indexOf (object : string) : int
	for i : 1 .. size
	    if core (i) = object then
		result i
	    end if
	end for

	result - 1
    end indexOf

    % Check if the list contains an object
    function contains (object : string) : boolean
	result indexOf (object) not= -1
    end contains

    % Remove an element at index
    procedure removeElementAtIndex (theIndex : int)
	core (theIndex) := ""
	% Shift the entire core array back an entry (very slow on large arrays)
	for i : theIndex + 1 .. size
	    core (i - 1) := core (i)
	end for
	size -= 1
    end removeElementAtIndex

    % Remove an object
    procedure removeElement (object : string)
	var realIndex := indexOf (object)
	if realIndex not= -1 then
	    removeElementAtIndex (realIndex)
	end if
    end removeElement
    
    % Clear the arraylist
    procedure clear
	for i : getSize () .. 1
	    removeElementAtIndex (i)
	end for
    end clear

end StringArrayList
Debug.lm ("StringArrayList")
% Int
class pervasive IntArrayList

    export getSize, addElement, getElement, indexOf, removeElement, removeElementAtIndex, contains

    var core : flexible array 1 .. 1 of int
    var size : int := 0

    function getSize : int
	result size
    end getSize

    % Allocate a new position in the array
    function allocateNew () : int
	size += 1
	% Double the size of the array until we have enough space to allocate an element
	loop
	    exit when size <= upper (core)
	    new core, upper (core) * 2
	end loop
	result size
    end allocateNew

    % Add an element to the arraylist
    procedure addElement (element : int)
	var allocated : int := allocateNew ()
	core (allocated) := element
    end addElement

    % Get an element from the arraylist
    function getElement (theIndex : int) : int
	result core (theIndex)
    end getElement

    % Get the location of an object in the arraylist
    function indexOf (object : int) : int
	for i : 1 .. size
	    if core (i) = object then
		result i
	    end if
	end for

	result - 1
    end indexOf

    % Check if the list contains an object
    function contains (object : int) : boolean
	result indexOf (object) not= -1
    end contains

    % Remove an element at index
    procedure removeElementAtIndex (theIndex : int)
	core (theIndex) := -1
	% Shift the entire core array back an entry (very slow on large arrays)
	for i : theIndex + 1 .. size
	    core (i - 1) := core (i)
	end for
	size -= 1
    end removeElementAtIndex

    % Remove an object
    procedure removeElement (object : int)
	var realIndex := indexOf (object)
	if realIndex not= -1 then
	    removeElementAtIndex (realIndex)
	end if
    end removeElement
    
    % Clear the arraylist
    procedure clear
	for i : getSize () .. 1
	    removeElementAtIndex (i)
	end for
    end clear

end IntArrayList
Debug.lm ("IntArrayList")
% Object
class pervasive ObjectArrayList

    export getSize, addElement, getElement, indexOf, removeElement, removeElementAtIndex, contains

    var core : flexible array 1 .. 1 of pointer to anyclass
    var size : int := 0

    function getSize : int
	result size
    end getSize

    % Allocate a new position in the array
    function allocateNew () : int
	size += 1
	% Double the size of the array until we have enough space to allocate an element
	loop
	    exit when size <= upper (core)
	    new core, upper (core) * 2
	end loop
	result size
    end allocateNew

    % Add an element to the arraylist
    procedure addElement (element : pointer to anyclass)
	var allocated : int := allocateNew ()
	core (allocated) := element
    end addElement

    % Get an element from the arraylist
    function getElement (theIndex : int) : pointer to anyclass
	result core (theIndex)
    end getElement

    % Get the location of an object in the arraylist
    function indexOf (object : pointer to anyclass) : int
	for i : 1 .. size
	    if core (i) = object then
		result i
	    end if
	end for

	result - 1
    end indexOf

    % Check if the list contains an object
    function contains (object : pointer to anyclass) : boolean
	result indexOf (object) not= -1
    end contains

    % Remove an element at index
    procedure removeElementAtIndex (theIndex : int)
	core (theIndex) := nil (anyclass)
	% Shift the entire core array back an entry (very slow on large arrays)
	for i : theIndex + 1 .. size
	    core (i - 1) := core (i)
	end for
	size -= 1
    end removeElementAtIndex

    % Remove an object
    procedure removeElement (object : pointer to anyclass)
	var realIndex := indexOf (object)
	if realIndex not= -1 then
	    removeElementAtIndex (realIndex)
	end if
    end removeElement
    
    % Clear the arraylist
    procedure clear
	for i : getSize () .. 1
	    removeElementAtIndex (i)
	end for
    end clear

end ObjectArrayList
Debug.lm ("ObjectArrayList")
