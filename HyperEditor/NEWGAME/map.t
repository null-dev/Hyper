% Map reader and writer

class pervasive MapIOManager

    import tilesetLoader, objectsetLoader

    export loadMap, saveMap

    function loadMap(fileName : string) : pointer to GameMap
        put "Setting up empty map..."
        var theMap : pointer to GameMap
        new GameMap, theMap
        theMap -> setup()
        theMap -> setBeginX(544)
        put "Reading save from file..."

        var stream : int
        open : stream, fileName, get

        var line : int := 1
        var loaded : int := 0
        loop
            exit when eof(stream)
            var input : string
            get : stream, input : *

            if input not = "[Hyper Save File]" and length(input) > 0 then
                var compSet : string := "nil"
                var obj : string := "nil"
                var x : int := -1
                var y : int := -1
                var layer : int := -1
                var builder : string := ""
                for i : 1 .. length(input)
                    var theChar := input(i)
                    if theChar = "," then
                        if compSet = "nil" then
                            compSet := builder
                        elsif obj = "nil" then
                            obj := builder
                        else
                            if strintok(builder) then
                                if x = -1 then
                                    x := strint(builder)
                                elsif y = -1 then
                                    y := strint(builder)
                                elsif layer  = -1 then
                                    layer := strint(builder)
                                end if
                            else
                                put "Invalid component entry on line ", line, "! (STRINTOK ERROR)"
                                exit
                            end if
                        end if
                        builder := ""
                    else
                        builder += theChar
                    end if
                end for
                    if compSet = "nil" or obj = "nil" or x = -1 or y = -1 then
                    put "Invalid component entry on line ", line, "! (MISSING DATA)"
                else
                    %put "Loaded tile ", tid, " @ (", x, ", ", y, ")!"
                    if Utils.endsWith(obj, TILEEXT) then
                        var gameTile : pointer to GameTile := tilesetLoader -> processTile(compSet, obj)
                        theMap -> setMapObject(x, y, layer, gameTile)
                        loaded += 1
                    elsif Utils.endsWith(obj, OBJECTEXT) then
                        var gameObject : pointer to GameObject := objectsetLoader -> processObject(compSet, obj)
                        gameObject -> setX(x)
                        gameObject -> setY(y)
                        theMap -> setMapObject(x, y, layer, gameObject)
                        loaded += 1
                    else
                        put "Invalid component entry on line ", line, "! (UNKNOWN TYPE)"
                    end if
                end if
            end if
            line += 1
        end loop

        close : stream

        put "Loaded ", loaded, " from disk!"

        result theMap
    end loadMap

    procedure saveMap(fileName : string, theMap : pointer to GameMap)

        var stream : int
        open : stream, fileName, put

        put : stream, "[Hyper Save File]"

        for x : 0 .. upper(theMap -> map, 1)
            for y : 0 .. upper(theMap -> map, 2)
                for layer : 1 .. upper(theMap -> map, 3)
                    var object : pointer to GameComponent := theMap -> map(x, y, layer)
                    % Not a gamecomponent
                    if not objectclass(object) >= EmptyGameComponent then
                        var castObject : pointer to GameComponent := object
                        put : stream, castObject -> textureSet, ",", castObject -> filename, ",", x, ",", y, ",", layer, ","
                    end if
                end for
            end for
        end for

        close : stream

        put "Map saved to disk!"

    end saveMap

end MapIOManager
