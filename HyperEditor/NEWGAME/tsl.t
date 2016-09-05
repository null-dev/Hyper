% Loads tilesets from a directory
% PLEASE NOTE THIS FILE FORMAT:
%: [Hyper Tile File]
%: filename
%: rotation (in degrees)
%: mirror (boolean, whether or not to mirror the image horizontally)
%: isWalkable (boolean, whether or not the player can walk over this tile)
%: isWater (boolean, whether or no this tile is made of water)
%: tryWalkTrigger (string, event to trigger when the player tries to walk over the tile, can be triggered even on a non-walkable tile)
%: walkTrigger (string, what event to trigger then the player walks over the tile, useless on non-walkable tiles)
%: transparentColor (int, transparent color)

% USE ONE INSTANCE ONLY OR THE CACHE WILL NOT FUNCTION PROPERLY
% Fast cache which helps save memory (reduces memory usage by up to 8x)
var texCache : pointer to IntHM := HMFactory.newIntHM ()

class pervasive TilesetLoader

    import texCache

    export all

    function listTilesets : pointer to StringArrayList
        result Utils.listFiles (TILEDIR)
    end listTilesets

    function constructDir (name : string) : string
        result TILEDIR + "/" + name + "/"
    end constructDir

    function constructPath (tileset : string, name : string) : string
        result constructDir (tileset) + name
    end constructPath

    function listTiles (name : string) : pointer to StringArrayList
        var dir : string := constructDir (name)
        var toRemove : pointer to StringArrayList
        new StringArrayList, toRemove
        var listed : pointer to StringArrayList := Utils.listFiles (dir)
        for i : 1 .. listed -> getSize ()
            var element : string := listed -> getElement (i)
            if not Utils.endsWith (element, TILEEXT) then
                toRemove -> addElement (element)
            end if
        end for
            for i : 1 .. toRemove -> getSize ()
            listed -> removeElement (toRemove -> getElement (i))
        end for
            Debug.info ("TilesetLoader", "Found " + intstr (listed -> getSize ()) + " tiles in tileset '" + name + "'!")
        Debug.info ("TilesetLoader", "Sorting tiles alphabetically!")
        result Sort.alphabetically (listed)
    end listTiles

    function processTileSetFile (tileset : string, filename : string, list : pointer to StringArrayList) : pointer to GameTile
        var texFile : string
        var rotation : int
        var mirror : boolean
        var isWalkable : boolean
        var isWater : boolean
        var tryWalkTrigger : string
        var walkTrigger : string
        var transparentColor : int
        var ri : int := 1
        for i : 1 .. list -> getSize ()
            var line := list -> getElement (i)
            if not ScriptUtils.isComment (line) then
                case ri of
                label 1 :
                    texFile := line
                label 2 :
                    ScriptUtils.assertInt (line);
                    rotation := strint (line)
                label 3 :
                    ScriptUtils.assertBoolean (line);
                    mirror := Utils.strbool (line)
                label 4 :
                    ScriptUtils.assertBoolean (line);
                    isWalkable := Utils.strbool (line)
                label 5 :
                    ScriptUtils.assertBoolean (line);
                    isWater := Utils.strbool (line)
                label 6 :
                    tryWalkTrigger := line
                label 7 :
                    walkTrigger := line
                label 8 :
                    transparentColor := ColorUtils.getColor (line)
                label :
                    Debug.fatal ("ScriptAssert", "Invalid script, expected EOF but got: '" + line + "'!");
                    quit <
                end case
                ri += 1
            end if
        end for
            var path : string := constructPath (tileset, texFile)
        var openedTex : int
        % Do some cache juggling
        if texCache -> containsKey (path) then
            %Debug.info ("TilesetLoader", "Texture cached, using cached version!")
            openedTex := texCache -> getObj (path)
        else
            openedTex := Pic.FileNew (path)
            texCache -> putObj (path, openedTex)
        end if
        % Construct the gametile
        var gt : pointer to GameTile
        new GameTile, gt
        gt -> setup (openedTex, rotation, mirror, isWalkable, isWater, tryWalkTrigger, walkTrigger, transparentColor)
        gt -> setFilename (filename)
        gt -> setTextureSet(tileset)
        result gt
    end processTileSetFile

    var tileCache : pointer to ObjectHM := HMFactory.newObjectHM ()

    function processTile (tileset : string, filename : string) : pointer to GameTile
        Debug.info ("TilesetLoader", "Loading: '" + filename + "' from tileset: '" + tileset + "'!")
        var key : string := tileset + filename
        if tileCache -> containsKey (key) then
            %Debug.info ("TilesetLoader", "Tile cached, using cached version!")
            result tileCache -> getObj (key)
        else
            var content : pointer to StringArrayList := Utils.readFileToArray (constructPath (tileset, filename))
            var tile : pointer to GameTile := processTileSetFile (tileset, filename, content)
            tileCache -> putObj (key, tile)
            free content
            result tile
        end if
    end processTile

    function load (name : string) : pointer to ObjectArrayList
        var list : pointer to ObjectArrayList
        new ObjectArrayList, list
        var tileList : pointer to StringArrayList := listTiles (name)
        for i : 1 .. tileList -> getSize ()
            list -> addElement (processTile (name, tileList -> getElement (i)))
        end for
            Debug.info ("TilesetLoader", "Loaded tileset: '" + name + "'!")
        result list
    end load

end TilesetLoader
var tilesetLoader : pointer to TilesetLoader
new TilesetLoader, tilesetLoader
Debug.lm ("TilesetLoader")
