include "array.t"
% Master utilites module, for everything that doesn't fit anywhere else
module Utils
    
    export endsWith, beginsWith, listFiles
    
    % Check if a string ends with another string
    function endsWith(theString : string, target : string) : boolean
        var builder : string := ""
        for decreasing i : length(theString) .. length(theString) - length(target) + 1
            builder := theString(i) + builder
        end for
            result builder = target
    end endsWith
    
    % Check if a string begins with another string
    function beginsWith(theString : string, target : string) : boolean
        var builder : string := ""
        for i : 1 .. length(target)
            builder += theString(i)
        end for
            result builder = target
    end beginsWith
    
    % List all the files in a directory (Returns a boxed array that MUST be freed with 'free array')
    function listFiles(dir : string) : pointer to BoxedStringArray
        
        var box : pointer to BoxedStringArray
        new BoxedStringArray, box
        
        var dirStream : int
        dirStream := Dir.Open (dir)
        assert dirStream > 0
        loop
            var fileName : string := Dir.Get (dirStream)
            exit when fileName = ""
            if fileName not = "." and fileName not = ".." then
                % Expand return array by one
                box -> setRealSize(box -> realSize + 1)
                % Assign value
                var theArray : array 1 .. 9999 of string := box -> getArray()
                theArray(box -> realSize) := fileName
                box -> setArray(theArray)
            end if
        end loop
        Dir.Close (dirStream)
        
        result box
        
    end listFiles
end Utils

for a : 1.. 9999
    var box : pointer to BoxedStringArray := Utils.listFiles("TEX")
    for i : 1.. box -> realSize
        %put box -> getArray()(i)
    end for
    free box
end for