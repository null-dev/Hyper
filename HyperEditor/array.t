% Boxed versions of arrays of different types
class pervasive BoxedStringArray

    export theArray, realSize, setRealSize, getArray, setArray
    var theArray : array 1 .. 9999 of string
    var realSize : int := 0
    
    procedure setRealSize( a : int)
        realSize := a
    end setRealSize
    
    function getArray : array 1 .. 9999 of string
        result theArray
    end getArray
    
    procedure setArray(a : array 1 .. 9999 of string)
        theArray := a
    end setArray
    
end BoxedStringArray