% Some sorting algorithms implemented in Turing by: Andy Bao
module pervasive Sort
    export all
    
    const ALPHABET : string := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    
    function toComparableOrd(s : string(1)) : int
	if Utils.contains(ALPHABET, s) then
	    result index(ALPHABET, s)
	else
	    result length(ALPHABET) + ord(s)
	end if
    end toComparableOrd
    
    function compareString(string1 : string, string2 : string) : boolean
	var i : int := 1
	loop
	    var c1 : int := toComparableOrd(string1(i))
	    var c2 : int := toComparableOrd(string2(i))
	    % Compare the chars
	    if c1 > c2 then
		result true
	    elsif c2 > c1 then
		result false
	    else
		i += 1
	    end if
	    exit when i > length(string1) or i > length(string2)
	end loop
	% Use the string lengths now
	if length(string1) > length(string2) then
	    result true
	else
	    result false
	end if
    end compareString
    
    % Bubble sort an array of strings alphabetically (pretty slow algorithm)
    % Algorithm details: https://en.wikipedia.org/wiki/Bubble_sort
    % Would do QuickSort but I have no idea how to do that on letters :(
    function alphabetically(list : pointer to StringArrayList) : pointer to StringArrayList
	% Copy the list to an array
	var theArray : array 1 .. list -> getSize() of string
	for i : 1 .. list -> getSize()
	    theArray(i) := list -> getElement(i)
	end for
	    var n := upper(theArray)
	loop
	    exit when n = 1
	    var newn : int := 1
	    for i : 2 .. n
		if compareString(theArray(i - 1), theArray(i)) then
		    var tmpString := theArray(i - 1)
		    theArray(i - 1) := theArray(i)
		    theArray(i) := tmpString
		    newn := i
		end if
	    end for
		n := newn
	end loop
	var outList : pointer to StringArrayList
	new StringArrayList, outList
	for i : 1 .. upper(theArray)
	    outList -> addElement(theArray(i))
	end for
	    result outList
    end alphabetically
end Sort
Debug.lm("Sort")
