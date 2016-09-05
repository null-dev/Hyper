% Loads tilesets from a directory

const TEXDIR : string := "TEX"

class TilesetLoader
    
    function load(name : string) : array 1 .. * of int
    end load
    
    function listTiles(name : string)
        var dir : string := constructDir(name)
        
        var dirStream : int := Dir.Open (TEXDIR)
        var fileName : string
    end listTiles
    
    function constructDir(name : string) : string
        result TEXDIR + "/" + name + "/"
    end constructPath
    
    function constructPath(name : string) : string
        result constructDir(name) + name + ".hts.txt"
    end constructPath
    
end TilesetLoader