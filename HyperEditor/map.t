class pervasive MapIOManager
    
    export loadMap, saveMap, lastLoadedTileset
    
    var lastLoadedTileset : string
    
    function loadMap(fileName : string) : pointer to GameMap
        put "Setting up empty map..."
        var theMap : pointer to GameMap
        new GameMap, theMap
        theMap -> setup()
        put "Reading save from file..."
        var tileSet : string := "-1"
        
        var stream : int
        open : stream, fileName, get
        
        var line : int := 1
        var loaded : int := 0
        loop
            exit when eof(stream)
            var input : string
            get : stream, input : *
            
            if input not = "[Hyper Save File]" and length(input) > 0 then
                if tileSet = "-1" then
                    tileSet := input
                else
                    var tid : int := -1
                    var x : int := -1
                    var y : int := -1
                    var builder : string := ""
                    for i : 1 .. length(input)
                        var theChar := input(i)
                        if theChar = "," then
                            if strintok(builder) then
                                if tid = -1 then
                                    tid := strint(builder)
                                elsif x = -1 then
                                    x := strint(builder)
                                elsif y = -1 then
                                    y := strint(builder)
                                end if
                            else
                                put "Invalid tile entry on line ", line, "! (STRINTOK ERROR)"
                                exit
                            end if
                            builder := ""
                        else
                            builder += theChar
                        end if
                    end for
                        if tid = -1 or x = -1 or y = -1 then
                        put "Invalid tile entry on line ", line, "! (MISSING DATA)"
                    else
                        %put "Loaded tile ", tid, " @ (", x, ", ", y, ")!"
                        var gameTile : pointer to GameTile
                        new GameTile, gameTile
                        gameTile -> setTileID(tid)
                        theMap -> freeMasterMapObject(x, y)
                        theMap -> setMasterMapObject(x, y, gameTile)
                        loaded += 1
                    end if
                end if
            end if
            line += 1
        end loop
        
        % Assign tileset
        lastLoadedTileset := tileSet
        
        close : stream
        
        put "Loaded ", loaded, " from disk!"
        
        result theMap
    end loadMap
    
    procedure saveMap(fileName : string, tileset : string, theMap : pointer to GameMap)
        
        var stream : int
        open : stream, fileName, put
        
        put : stream, "[Hyper Save File]"
        % Save tileset
        put : stream, tileset
        
        for x : 0 .. upper(theMap -> masterMap, 1)
            for y : 0 .. upper(theMap -> masterMap, 2)
                var object : pointer to GameObject := theMap -> masterMap(x, y)
                
                if objectclass(object) >= GameTile then
                    var castObject : pointer to GameTile
                    castObject := object
                    put : stream, castObject -> tileID, ",", x, ",", y, ","
                end if
                
            end for
        end for
            
        close : stream
        
        put "Map saved to disk!"
        
    end saveMap
    
end MapIOManager