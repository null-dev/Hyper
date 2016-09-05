% The Hyper Map Editor, full map editor written in Turing!
% Supports layers and commands!

put "Hyper Map Editor v1.0"

include "debug.t"
include "constants.t"
include "array.t"
include "arraylist.t"
include "hashmap.t"
include "stack.t"
include "util.t"
include "sort.t"
include "api.t"
include "script.t"
include "renderer.t"
include "gamecomponent.t"
include "maprender.t"
include "tsl.t"
include "osl.t"
include "postload-script.t"

var MAXTILEPAGE : int := 266

var openIndex : int := 1
var tilesOpenened : boolean := true
var openedComponentArray : pointer to ObjectArrayList
new ObjectArrayList, openedComponentArray
var realOpenedTileArray : pointer to ObjectArrayList
var realOpenedObjectArray : pointer to ObjectArrayList
new ObjectArrayList, realOpenedTileArray
new ObjectArrayList, realOpenedObjectArray
var tileset : string
var objectset : string
var totalTiles : int := 0
var totalObjects : int := 0
var tilePageArray : pointer to ObjectArrayList
var objectPageArray : pointer to ObjectArrayList
new ObjectArrayList, tilePageArray
new ObjectArrayList, objectPageArray

procedure askTiles
    openIndex := 1
    free openedComponentArray
    free realOpenedTileArray
    totalTiles := 0
    free tilePageArray
    put "Retrieving tile data...\n"

    var foundTilesets : pointer to StringArrayList := tilesetLoader -> listTilesets ()
    for i : 1 .. foundTilesets -> getSize ()
        put "Found tileset: ", foundTilesets -> getElement (i)
    end for

    put "\nPlease enter the tileset to use:"
    loop
        get tileset
        exit when foundTilesets -> contains(tileset)
        put "Invalid tileset! Please try again:"
    end loop

    free foundTilesets
    put "Opening tiles..."
    realOpenedTileArray := tilesetLoader -> load (tileset)
    totalTiles := realOpenedTileArray -> getSize ()
    Debug.info ("Editor", "Processing loaded tile sets...")
    new ObjectArrayList, tilePageArray
    % Split tiles into pages
    for i : 1 .. realOpenedTileArray -> getSize ()
        var tempArrayList : pointer to ObjectArrayList
        if (i mod 266) = 1 then
            new ObjectArrayList, tempArrayList
            tilePageArray -> addElement (tempArrayList)
        else
            tempArrayList := tilePageArray -> getElement (tilePageArray -> getSize ())
        end if
        tempArrayList -> addElement (realOpenedTileArray -> getElement (i))
    end for
        openedComponentArray := tilePageArray -> getElement (1)
    tilesOpenened := true

    Debug.info ("Editor", "Tile set split into " + intstr (tilePageArray -> getSize ()) + " pages!")
end askTiles

procedure askObjects
    openIndex := 1
    free openedComponentArray
    free realOpenedObjectArray
    totalObjects := 0
    free objectPageArray
    put "Retrieving object data...\n"

    var foundObjectsets : pointer to StringArrayList := objectsetLoader -> listObjectsets ()
    for i : 1 .. foundObjectsets -> getSize ()
        put "Found objectset: ", foundObjectsets -> getElement (i)
    end for

    put "\nPlease enter the objectset to use:"
    loop
        get objectset
        exit when foundObjectsets -> contains(objectset)
        put "Invalid objectset! Please try again:"
    end loop

    free foundObjectsets
    put "Opening objects..."
    realOpenedObjectArray := objectsetLoader -> load (objectset)
    totalObjects := realOpenedObjectArray -> getSize ()
    Debug.info ("Editor", "Processing loaded object sets...")
    new ObjectArrayList, objectPageArray
    % Split tiles into pages
    for i : 1 .. realOpenedObjectArray -> getSize ()
        var tempArrayList : pointer to ObjectArrayList
        if (i mod 266) = 1 then
            new ObjectArrayList, tempArrayList
            objectPageArray -> addElement (tempArrayList)
        else
            tempArrayList := objectPageArray -> getElement (objectPageArray -> getSize ())
        end if
        tempArrayList -> addElement (realOpenedObjectArray -> getElement (i))
    end for
        openedComponentArray := objectPageArray -> getElement (1)
    tilesOpenened := false

    Debug.info ("Editor", "Object set split into " + intstr (objectPageArray -> getSize ()) + " pages!")
end askObjects

% TODO RELOAD TILESETS ON MAP LOAD
put "To begin editing, please open a tileset:"
askTiles ()
put "Preparing game..."

setscreen ("graphics:max;max,")
put "[LM] Fullscreen"

class pervasive GameMap

    inherit MapRenderer

    import openedComponentArray, tileset

    export all

    var p1ViewingAreaTopLeftCornerX : int := 0
    var p1ViewingAreaTopLeftCornerY : int := 0
    var p1ViewingAreaBtmRightCornerX : int := WIDTH - 5
    var p1ViewingAreaBtmRightCornerY : int := HEIGHT
    var tilesetRenderer : pointer to GridRenderer
    new GridRenderer, tilesetRenderer

    body procedure draw
        View.Set ("offscreenonly")
        var tileMax : int := openedComponentArray -> getSize ()
        var incrementor : int := p1ViewingAreaTopLeftCornerX
        for x : p1ViewingAreaTopLeftCornerX .. p1ViewingAreaBtmRightCornerX
            for y : p1ViewingAreaTopLeftCornerY .. p1ViewingAreaBtmRightCornerY
                incrementor += 1
                if incrementor <= tileMax then
                    tilesetRenderer -> drawColorAt (white, x - p1ViewingAreaTopLeftCornerX, y)
                    var casted : pointer to GameComponent := openedComponentArray -> getElement (incrementor)
                    casted -> drawAt (tilesetRenderer, x - p1ViewingAreaTopLeftCornerX, y)
                end if
            end for
        end for
            MapRenderer.draw ()
    end draw

end GameMap
put "[LM] GameMap"

include "map.t"
var mapLoader : pointer to MapIOManager
new MapIOManager, mapLoader
put "[LM] MapLoader"

var map : pointer to GameMap
new GameMap, map
map -> setup ()
map -> setBeginX (544)

% TODO REPLACE WITH MODULOUS
procedure outlineTile (grenderer : pointer to GridRenderer, tileID : int)
    var incrementor : int := 0
    var tileMax : int := openedComponentArray -> getSize ()
    for x : 0 .. WIDTH
        for y : 0 .. HEIGHT
            incrementor += 1
            if incrementor = tileID then
                map -> tilesetRenderer -> drawOutlineAt (brightred, x, y)
                exit
            end if
        end for
    end for
end outlineTile

procedure outlineMT (grenderer : pointer to GridRenderer, x : int, y : int)
    grenderer -> drawOutlineAt (brightred, x, y)
end outlineMT

procedure realOutlineMT (theMap : pointer to GameMap, grenderer : pointer to GridRenderer, x : int, y : int, theColor : int)
    var realX := x - theMap -> viewportX1
    var realY := y - theMap -> viewportY1
    if realX >= 0 and realY >= 0 and realX <= WIDTH and realY <= HEIGHT then
        grenderer -> drawOutlineAt (theColor, realX, realY)
    end if
end realOutlineMT

function calcXFromRelative (theMap : pointer to GameMap, x : int) : int
    result theMap -> viewportX1 + x
end calcXFromRelative

function calcYFromRelative (theMap : pointer to GameMap, y : int) : int
    result theMap -> viewportY1 + y
end calcYFromRelative

procedure realPlaceTile (theMap : pointer to GameMap, x : int, y : int, layer : int, gameTile : pointer to GameComponent)
    theMap -> setMapObject (x, y, layer, gameTile)
end realPlaceTile

procedure placeTile (theMap : pointer to GameMap, x : int, y : int, layer : int, gameTile : pointer to GameComponent)
    var cx := calcXFromRelative (theMap, x)
    var cy := calcYFromRelative (theMap, y)
    realPlaceTile (theMap, cx, cy, layer, gameTile)
end placeTile

procedure realDelTile (theMap : pointer to GameMap, x : int, y : int, layer : int)
    if layer = 1 then
        theMap -> setMapObject (x, y, layer, GCManager.emptyGameTile)
    else
        theMap -> setMapObject (x, y, layer, GCManager.emptyGameComponent)
    end if
end realDelTile

procedure delTile (theMap : pointer to GameMap, x : int, y : int, layer : int)
    var cx := calcXFromRelative (theMap, x)
    var cy := calcYFromRelative (theMap, y)
    realDelTile (theMap, cx, cy, layer)
end delTile

put "[LM] Editor"

var highlightedTile : int := 1
var highlightedMTX : int := 0
var highlightedMTY : int := 0
var selectedLayer : int := 1
var highlightObjectsOnLayer : boolean := false
var clipboard : flexible array 1 .. 0, 1 .. 0 of pointer to GameComponent

var fsX : int := -1
var fsY : int := -1
var feX : int := -1
var feY : int := -1

function getBiggest (first : int, last : int) : int
    if first > last then
        result first
    else
        result last
    end if
end getBiggest

function getSmallest (first : int, last : int) : int
    if first < last then
        result first
    else
        result last
    end if
end getSmallest

function inBoardRange (c : int) : boolean
    result c >= 0 and c <= upper (map -> map, 1)
end inBoardRange

var showSelections : boolean := true

% Process commands
procedure beginCommand
        locate (3, 1)
    put "/" ..
    var command : string
    get command
        % Clear command output
    locate (4, 1)
    put ""
    locate (4, 1)
    if command = "ss" or command = "selstart" then
        fsX := calcXFromRelative (map, highlightedMTX)
        fsY := calcYFromRelative (map, highlightedMTY)
        put "Selection start setup!"
    elsif command = "se" or command = "selend" then
        feX := calcXFromRelative (map, highlightedMTX)
        feY := calcYFromRelative (map, highlightedMTY)
        put "Selection end setup!"
    elsif command = "f" or command = "fill" then
        if fsX not= -1 and fsY not= -1 and feX not= -1 and feY not= -1 then
            var tID : int := 0
            for x : getSmallest (fsX, feX) .. getBiggest (fsX, feX)
                for y : getSmallest (fsY, feY) .. getBiggest (fsY, feY)
                    tID += 1
                    realPlaceTile (map, x, y, selectedLayer, openedComponentArray -> getElement (highlightedTile))
                end for
            end for
                put "Filled ", tID, " tiles with ", highlightedTile, "!"
        else
            put "Nothing selected (use /ss and /se)!"
        end if
    elsif command = "ds" or command = "desel" or command = "deselect" then
        fsX := -1
        fsY := -1
        feX := -1
        feY := -1
        put "Selection deselected!"
    elsif command = "d" or command = "del" or command = "delete" then
        if fsX not= -1 and fsY not= -1 and feX not= -1 and feY not= -1 then
            var tID : int := 0
            for x : getSmallest (fsX, feX) .. getBiggest (fsX, feX)
                for y : getSmallest (fsY, feY) .. getBiggest (fsY, feY)
                    tID += 1
                    realDelTile (map, x, y, selectedLayer)
                end for
            end for
                put "Deleted ", tID, " tiles!"
        else
            put "Nothing selected (use /ss and /se)!"
        end if
    elsif command = "fl" or command = "filllayer" then
        cls
        put "Are you sure you want to fill the entire layer with tile ", highlightedTile, "? (Yes/No)"
        loop
            var tempInput : string
            get tempInput
            if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                put "Filling layer..."
                for x : 0 .. upper (map -> map, 1)
                    for y : 0 .. upper (map -> map, 2)
                        realPlaceTile (map, x, y, selectedLayer, openedComponentArray -> getElement (highlightedTile))
                    end for
                end for
                    exit
            elsif tempInput = "No" or tempInput = "n" or tempInput = "no" then
                exit
            end if
            put "Invalid option!"
        end loop
        cls
    elsif command = "cl" or command = "dl" or command = "dellayer" or command = "clearlayer" then
        cls
        put "Are you sure you want to clear the entire layer? (Yes/No)"
        loop
            var tempInput : string
            get tempInput
            if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                put "Clearing layer..."
                for x : 0 .. upper (map -> map, 1)
                    for y : 0 .. upper (map -> map, 2)
                        realDelTile (map, x, y, selectedLayer)
                    end for
                end for
                    exit
            elsif tempInput = "No" or tempInput = "n" or tempInput = "no" then
                exit
            end if
            put "Invalid option!"
        end loop
        cls
    elsif command = "cs" or command = "ds" or command = "delsel" or command = "clearsel" then
        if fsX not= -1 and fsY not= -1 and feX not= -1 and feY not= -1 then
            for x : getSmallest (fsX, feX) .. getBiggest (fsX, feX)
                for y : getSmallest (fsY, feY) .. getBiggest (fsY, feY)
                    realDelTile (map, x, y, selectedLayer)
                end for
            end for
                put "Cleared selection!"
        else
            put "Nothing selected (use /ss and /se)!"
        end if
    elsif command = "cw" or command = "dw" or command = "delworld" or command = "clearworld" then
        cls
        put "Are you sure you want to clear the entire world? (Yes/No)"
        loop
            var tempInput : string
            get tempInput
            if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                put "Clearing world..."
                for x : 0 .. upper (map -> map, 1)
                    for y : 0 .. upper (map -> map, 2)
                        for layer : 1 .. upper (map -> map, 3)
                            realDelTile (map, x, y, layer)
                        end for
                    end for
                end for
                    exit
            elsif tempInput = "No" or tempInput = "n" or tempInput = "no" then
                exit
            end if
            put "Invalid option!"
        end loop
        cls
    elsif command = "s" or command = "save" then
        cls
        put "Enter the file to save to (or type cancel to cancel):"
        var fileName : string
        loop
            get fileName
            if File.Exists (fileName) then
                put "File already exists, overwrite? (Yes/No)"
                loop
                    var tempInput : string
                    get tempInput
                    if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                        put "Deleting old file..."
                        File.Delete (fileName)
                        exit
                    elsif tempInput = "No" or tempInput = "n" or tempInput = "no" then
                        put "Overwrite cancled, enter the file to save to (or type cancel to cancel):"
                        exit
                    end if
                    put "Invalid option!"
                end loop
            else
                exit
            end if
            exit when fileName = "cancel" or not File.Exists (fileName)
        end loop
        if fileName not= "cancel" then
            put "Saving map..."
            mapLoader -> saveMap (fileName, map)
        else
            put "Operation canceled!"
        end if
        cls
    elsif command = "l" or command = "load" then
        cls
        put "Enter the file to load from (or type cancel to cancel):"
        var fileName : string
        loop
            get fileName
            exit when fileName = "cancel" or File.Exists (fileName)
            put "File does not exist!"
        end loop
        if fileName not= "cancel" then
            put "Loading map..."
            var loadedMap : pointer to GameMap
            loadedMap := mapLoader -> loadMap (fileName)
            map -> fullFree ()
            map := loadedMap
        else
            put "Operation canceled!"
        end if
        cls
    elsif command = "jump" or command = "tp" or command = "goto" or command = "jumpto" or command = "cp" then
        cls
        var xString : string
        var yString : string
        put "Jump to coordinates (type cancel to cancel): "
        loop
            put "X: " ..
            get xString
            if strintok (xString) and inBoardRange (strint (xString)) then
                exit
            elsif xString = "cancel" then
                exit
            end if
            put "Invalid coordinate!"
        end loop
        if xString not= "cancel" then
            loop
                put "Y: " ..
                get yString
                if strintok (yString) and inBoardRange (strint (yString)) then
                    exit
                elsif yString = "cancel" then
                    exit
                end if
                put "Invalid coordinate!"
            end loop
            if yString not= "cancel" then
                var x : int := strint (xString)
                var y : int := strint (yString)
                % Jumpity jump
                map -> jumpTo (x, y)
                % Move the cursor to the correct position
                highlightedMTX := x - map -> viewportX1
                highlightedMTY := y - map -> viewportY1
            else
                put "Operation canceled!"
            end if
        else
            put "Operation canceled!"
        end if
        cls
    elsif command = "copy" or command = "c" then
        if fsX not= -1 and fsY not= -1 and feX not= -1 and feY not= -1 then
            % Resize clipboard
            new clipboard, 0, 0
            new clipboard, getBiggest (fsX, feX) - getSmallest (fsX, feX) + 1, 0
            new clipboard, upper (clipboard, 1), getBiggest (fsY, feY) - getSmallest (fsY, feY) + 1
            var tID : int := 0
            var minX : int := getSmallest (fsX, feX)
            var maxX : int := getBiggest (fsX, feX)
            var minY : int := getSmallest (fsY, feY)
            var maxY : int := getBiggest (fsY, feY)
            for rx : minX .. maxX
                for ry : minY .. maxY
                    clipboard (rx - minX + 1, ry - minY + 1) := map -> map (rx, ry, selectedLayer)
                    tID += 1
                end for
            end for
                put "Copied ", tID, " tiles to clipboard!"
        else
            put "Nothing selected (use /ss and /se)!"
        end if
    elsif command = "paste" or command = "p" then
        if upper (clipboard, 1) = 0 or upper (clipboard, 2) = 0 then
            put "Clipboard is empty! Try copying something (use /copy)!"
        else
            var realX := calcXFromRelative (map, highlightedMTX)
            var realY := calcYFromRelative (map, highlightedMTY)
            if realX + upper (clipboard, 1) > upper (map -> map, 1) + 1 or realY + upper (clipboard, 2) > upper (map -> map, 2) + 1 then
                put "Invalid paste location!"
            else
                var tID : int := 0
                for rx : 1 .. upper (clipboard, 1)
                    for ry : 1 .. upper (clipboard, 2)
                        realPlaceTile (map, realX + rx - 1, realY + ry - 1, selectedLayer, clipboard (rx, ry))
                        tID += 1
                    end for
                end for
                    put "Pasted ", tID, " tiles!"
            end if
        end if
    elsif command = "quit" or command = "leave" or command = "close" or command = "exit" then
        cls
        put "Are you sure you want to exit? Any unsaved changes (if you have any) will be lost! (Yes/No)"
        loop
            var tempInput : string
            get tempInput
            if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                put "Bye!"
                quit

            elsif tempInput = "No" or tempInput = "n" or tempInput = "no" then
                exit
            end if
            put "Invalid option!"
        end loop
        put "Operation canceled!"
        cls
    elsif command = "tileset" then
        cls
        askTiles ()
        cls
    elsif command = "objectset" then
        cls
        askObjects ()
        cls
    elsif command = "togglesels" or command = "togglesel" or command = "hidesels" or command = "hidesel" or command = "hs" or command = "ts" then
        showSelections := not showSelections
        put "Show selections set to: ", showSelections, "!"
    elsif command = "h" or command = "help" then
        cls
        put "/ss, /selstart : Starts the selection at your current cursor position."
        put "/ss, /selstart : Starts a selection at your current cursor position."
        put "/ds, /desel, /deselect : Clears your selection."
        put "/f, /fill : Fills the current selection with the currently selected object."
        put "/fl, /filllayer : Fills the entire world with the currently selected object."
        put "/cs, /ds, /delsel, /clearsel : Deletes all the objects in the selection."
        put "/cw, /dw, /delworld, /clearworld : Deletes all the objects in the entire world."
        put "/cl, /dl, /dellayer, /clearlayer : Deletes all the object in the entire layer."
        put "/jump, /tp, /goto, /jumpto, /cp : Moves your cursor to a specified coordinate."
        put "/togglesels, /togglesel, /hidesels, /hidesel, /hs, /ts : Toggles the slow backup renderer for selections (for selecting big areas)."
        put "/d, /del : Deletes all tiles in the current selection."
        put "/s, /save : Save a world to file."
        put "/l, /load : Load a world from file."
        put "/c, /copy : Copy the selection to clipboard."
        put "/p, /paste : Paste the clipboard onto the selected layer using the cursor as the bottom left."
        put "/tileset : Switch to another tileset."
        put "/objectset : Switch to another objectset."
        put "/quit, /leave, /close, /exit : Exit the map editor!"
        put "\nKeybinds:"
        put "w,a,s,d: Move the tile/object selection cursor."
        put "Up Arrow, Down Arrow, Left Arrow, Right Arrow: Move the map cursor."
        put "Space: Place tile/object."
        put "q: Display previous tile page."
        put "e: Display next tile page."
        put "Page Up: Move up one layer."
        put "Page Down: Move down one layer."
        put "h: Highlight all tiles/objects on current layer in blue."
        put "Tab: Switch between objectset and tileset."
        put "\nSelection Information:"
        put "Selections are active globally however any changes applied to a selection with commands will be only applied within the selected layer."
        put "\nType 'exit' to leave help!"
        loop
            var tempInput : string
            get tempInput
            exit when tempInput = "exit"
        end loop
        cls
    else
        put "Invalid command! (Try /help)"
    end if
end beginCommand

cls
put "EDITOR OK! READY TO GO!\n"
% Main input loop
loop
    % Clear stats
    locate (2, 1)
    put ""
    put ""
    locate (1, 1)
    put "--------=[Developer Information]=--------"
    put "TileID: ", highlightedTile, "/", totalTiles, ", X: ", calcXFromRelative (map, highlightedMTX), ", Y: ", calcYFromRelative (map, highlightedMTY), ", Layer: ", selectedLayer, "/9"..
    if tilesOpenened then
        put ", Selected Set: Tileset, Tile Page: ", openIndex, "/", tilePageArray -> getSize()..
    else
        put ", Selected Set: Objectset, Object Page: ", openIndex, "/", objectPageArray -> getSize()..
    end if
    put ", Tileset: ", tileset..
    if totalObjects > 0 then
        put ", Objectset: ", objectset..
    end if
    % Render tiles
    map -> draw ()
    % Draw highlight
    if highlightObjectsOnLayer then
        View.Set ("offscreenonly")
        for x : map -> viewportX1 .. map -> viewportX2
            for y : map -> viewportY1 .. map -> viewportY2
                if not objectclass (map -> map (x, y, selectedLayer)) >= EmptyGameComponent then
                    realOutlineMT (map, map -> grenderer, x, y, blue)
                end if
            end for
        end for
            View.Update
        View.Set ("nooffscreenonly")
    end if
    % Draw selection
    if fsX not= -1 and fsY not= -1 and feX not= -1 and feY not= -1 then
        % New ultrafast neat selection renderer
        var realSX := getSmallest (fsX, feX) - map -> viewportX1
        var realSY := getSmallest (fsY, feY) - map -> viewportY1
        var realBX := getBiggest (fsX, feX) - map -> viewportX1
        var realBY := getBiggest (feY, fsY) - map -> viewportY1
        if realSX >= 0
            and realSY >= 0
            and realSX <= WIDTH
            and realSY <= HEIGHT
            and realBX >= 0
            and realBY >= 0
            and realBX <= WIDTH
            and realBY <= HEIGHT then
            map -> grenderer -> boxTiles (purple,
                realSX,
                realSY,
                realBX,
                realBY)
        elsif showSelections then
            % TODO REPLACE WITH CUSTOM RECTANGLE RENDERER
            % Serve up the backup renderer if a portion of the selection is off screen (VERY SLOW)
            for x : getSmallest (fsX, feX) .. getBiggest (fsX, feX)
                for y : getSmallest (fsY, feY) .. getBiggest (fsY, feY)
                    realOutlineMT (map, map -> grenderer, x, y, purple)
                end for
            end for
        end if
    end if
    if fsX not= -1 and fsY not= -1 then
        put ", Selection Start: (", fsX, ", ", fsY, ")" ..
        realOutlineMT (map, map -> grenderer, fsX, fsY, green)
    end if
    if feX not= -1 and feY not= -1 then
        put ", Selection End: (", feX, ", ", feY, ")" ..
        realOutlineMT (map, map -> grenderer, feX, feY, yellow)
    end if
    % Outline cursor
        outlineTile (map -> grenderer, highlightedTile)
    outlineMT (map -> grenderer, highlightedMTX, highlightedMTY)
    var theChar : string (1)
    locate (3, 1)
    getch (theChar)
    var tempHighlightedTile : int := highlightedTile
    % Could have used a switch but too lazy
    if ord (theChar) = 200 then
        if highlightedMTY not= HEIGHT then
            highlightedMTY += 1
        else
            map -> scroll (ScrollType.UP)
        end if
    elsif ord (theChar) = 203 then
        if highlightedMTX not= 0 then
            highlightedMTX -= 1
        else
            map -> scroll (ScrollType.LEFT)
        end if
    elsif ord (theChar) = 208 then
        if highlightedMTY not= 0 then
            highlightedMTY -= 1
        else
            map -> scroll (ScrollType.DOWN)
        end if
    elsif ord (theChar) = 205 then
        if highlightedMTX not= WIDTH then
            highlightedMTX += 1
        else
            map -> scroll (ScrollType.RIGHT)
        end if
    elsif theChar = "w" then
        tempHighlightedTile += 1
    elsif theChar = "a" then
        tempHighlightedTile -= WIDTH + 1
    elsif theChar = "s" then
        tempHighlightedTile -= 1
    elsif theChar = "d" then
        tempHighlightedTile += WIDTH + 1
    elsif theChar = "h" then
        highlightObjectsOnLayer := not highlightObjectsOnLayer
    elsif theChar = "q" then
        if openIndex > 1 then
            View.Set ("offscreenonly")
            cls
            openIndex -= 1
            if tilesOpenened then
                openedComponentArray := tilePageArray -> getElement (openIndex)
            else
                openedComponentArray := objectPageArray -> getElement (openIndex)
            end if
            if highlightedTile > openedComponentArray -> getSize () then
                highlightedTile := openedComponentArray -> getSize ()
            end if
        end if
        % TODO PAGE SCROLL LEFT
    elsif theChar = "e" then
        if (tilesOpenened and openIndex < tilePageArray -> getSize ())
            or (not tilesOpenened and openIndex < objectPageArray -> getSize ()) then
            View.Set ("offscreenonly")
            cls
            openIndex += 1
            if tilesOpenened then
                openedComponentArray := tilePageArray -> getElement (openIndex)
            else
                openedComponentArray := objectPageArray -> getElement (openIndex)
            end if
            if highlightedTile > openedComponentArray -> getSize () then
                highlightedTile := openedComponentArray -> getSize ()
            end if
        end if
        % TODO PAGE SCROLL RIGHT
    elsif ord (theChar) = 201 then
        if selectedLayer < 9 then
            selectedLayer += 1
        end if
    elsif ord (theChar) = 209 then
        if selectedLayer > 1 then
            selectedLayer -= 1
        end if
    elsif theChar = " " then
        % PLACE A TILE!!! (Finally I get to write this code)
        placeTile (map, highlightedMTX, highlightedMTY, selectedLayer, openedComponentArray -> getElement (highlightedTile))
    elsif theChar = "\t" then
        tilesOpenened := not tilesOpenened
        if tilesOpenened then
            openIndex := 1
            View.Set ("offscreenonly")
            openedComponentArray := tilePageArray -> getElement (openIndex)
            cls
            Debug.info("Editor", "Switched to tileset!")
        else
            if totalObjects > 0 then
                openIndex := 1
                View.Set ("offscreenonly")
                openedComponentArray := objectPageArray -> getElement (openIndex)
                cls
                Debug.info("Editor", "Switched to objectset!")
            else
                locate (4, 1)
                put "No objectset loaded!"
                tilesOpenened := true
            end if
        end if
    elsif theChar = "\b" then
        delTile (map, highlightedMTX, highlightedMTY, selectedLayer)
    elsif theChar = "/" then
        beginCommand ()
    end if
    % Deal with the highlighted entry on the left
    if tempHighlightedTile >= 1 and tempHighlightedTile <= openedComponentArray -> getSize () then
        highlightedTile := tempHighlightedTile
    end if
end loop
