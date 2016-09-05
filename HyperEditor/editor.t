put "Hyper Map Editor v1.0"

include "debug.t"
include "constants.t"
include "array.t"
include "arraylist.t"
include "hashmap.t"
include "stack.t"
include "util.t"
include "api.t"
include "script.t"
include "renderer.t"
include "gamecomponent.t"
include "maprender.t"
include "tsl.t"
include "postload-script.t"

put "Retrieving tile data...\n"

const TEXDIR : string := "TEX"
const pervasive WIDTH : int := 15
const pervasive HEIGHT : int := 15

var dirStream : int
var fileName : string
dirStream := Dir.Open (TEXDIR)
assert dirStream > 0
loop
    fileName := Dir.Get (dirStream)
    exit when fileName = ""
    if fileName not = "." and fileName not = ".." and fileName not = "convert.sh" then
        put "Found tileset: ", fileName
    end if
end loop
Dir.Close (dirStream)

put "\nPlease enter the tileset to use:"
var tileset : string
get tileset
put "Loading tileset... (",tileset,")"
var tilesetIndexFile : string := TEXDIR + "/" + tileset + "/" + tileset + ".png.txt"
put "Loading tileset index: ", tilesetIndexFile
var tilesetIndexStream : int
var tilesetArray : flexible array 1..0 of string
open : tilesetIndexStream, tilesetIndexFile, get
loop
    exit when eof(tilesetIndexStream)
    var targetIndex : int := upper(tilesetArray)+1
    new tilesetArray, targetIndex
    var line : string
    get : tilesetIndexStream, line : *
    var builder : string := ""
    var builderIndex : int := 0
    loop
        builderIndex += 1
        exit when line(builderIndex) = " "
        builder += line(builderIndex)
    end loop
    tilesetArray(targetIndex) := builder
end loop
put "Found ", upper(tilesetArray), " tiles!"

% TODO RELOAD TILESETS ON MAP LOAD
var openedTileArray : array 1..upper(tilesetArray) of int
for i : 1..upper(tilesetArray)
    openedTileArray(i) := Pic.FileNew(TEXDIR + "/" + tileset + "/" + tileset + tilesetArray(i))
end for
    put "Opening tiles..."

put "Preparing game..."

setscreen ("graphics:max;max,")
put "[LM] Fullscreen"

const pervasive BLOCKSIZE : int := 32

% Splits screen into 32x32 sized grid
class pervasive GridRenderer
    export calculateX, calculateY, drawAt, drawColorAt, drawOutlineAt, boxTiles
    
    function calculateX(x : int) : int
        result BLOCKSIZE * x
    end calculateX
    
    function calculateY(y : int) : int
        result BLOCKSIZE * y
    end calculateY
    
    procedure drawAt(picID : int, x : int, y : int)
        var realX := calculateX(x) + 1
        var realY := calculateY(y) + 1
        Pic.Draw(picID, realX, realY, picCopy)
    end drawAt
    
    procedure drawColorAt(theColor : int, x : int, y : int)
        var realX := calculateX(x)
        var realY := calculateY(y)
        drawfillbox(realX, realY, realX + BLOCKSIZE, realY + BLOCKSIZE, theColor)
    end drawColorAt
    
    procedure twiceAsThickBox(x1 : int, y1 : int, x2 : int, y2 : int, theColor : int)
        drawbox(x1, y1, x2, y2, theColor)
        % Make it twice as thick
        drawbox(x1+1, y1+1, x2-1, y2-1, theColor)
    end twiceAsThickBox
    
    procedure drawOutlineAt(theColor : int, x : int, y : int)
        var realX := calculateX(x)
        var realY := calculateY(y)
        twiceAsThickBox(realX, realY, realX + BLOCKSIZE, realY + BLOCKSIZE, theColor)
    end drawOutlineAt
    
    procedure boxTiles(theColor : int, x1 : int, y1 : int, x2 : int, y2 : int)
        var realX := calculateX(x1)
        var realY := calculateY(y1)
        var diffX := x2-x1 + 1
        var diffY := y2-y1 + 1
        twiceAsThickBox(realX, realY, realX + (diffX*(BLOCKSIZE)), realY + (diffY*(BLOCKSIZE)), theColor)
    end boxTiles
    
end GridRenderer
put "[LM] GridRenderer"

class pervasive GameObject
    export drawAt
    var objName : string
    % All objects must override this method
    procedure drawAt(grenderer : pointer to GridRenderer, x : int, y : int)
        put "[GameObject] FATAL INTERNAL ERROR: Unexpected inheritance failure!"
        quit <
    end drawAt
end GameObject
put "[LM] GameObject"

class pervasive GameTile
    inherit GameObject
    
    import openedTileArray
    export openedPicture, tileID, setTileID
    
    var openedPicture : int
    var tileID : int
    
    body procedure drawAt(grenderer : pointer to GridRenderer, x : int, y : int)
        grenderer -> drawAt(openedTileArray(tileID), x, y)
    end drawAt
    
    procedure setTileID(newTileID : int)
        tileID := newTileID
    end setTileID
    
end GameTile
put "[LM] GameTile"

class pervasive EmptyGameTile
    inherit GameObject
    body procedure drawAt(grenderer : pointer to GridRenderer, x : int, y : int)
        grenderer -> drawColorAt(black, x, y)
    end drawAt
end EmptyGameTile
put "[LM] EmptyGameObject"

type pervasive ScrollType : enum (UP, DOWN, LEFT, RIGHT)
put "[LM] ScrollType"

class pervasive GameMap
    
    import tilesetArray, TEXDIR, tileset, openedTileArray
    
    export setup, update, grenderer, scrollP2, p2ViewingAreaTopLeftCornerX, p2ViewingAreaTopLeftCornerY, p2ViewingAreaBtmRightCornerX, p2ViewingAreaBtmRightCornerY, masterMap, setMasterMapObject, freeMasterMapObject, fullFree, jumpTo
    
    var p1ViewingAreaTopLeftCornerX : int := 0
    var p1ViewingAreaTopLeftCornerY : int := 0
    var p1ViewingAreaBtmRightCornerX : int := WIDTH
    var p1ViewingAreaBtmRightCornerY : int := HEIGHT
    
    var p2ViewingAreaTopLeftCornerX : int := 0
    var p2ViewingAreaTopLeftCornerY : int := 0
    var p2ViewingAreaBtmRightCornerX : int := WIDTH
    var p2ViewingAreaBtmRightCornerY : int := HEIGHT
    var masterMap : array 0 .. 999, 0 .. 999 of pointer to GameObject
    var grenderer : pointer to GridRenderer
    
    procedure fullFree
        for x : 0 .. upper(masterMap, 1)
            for y : 0 .. upper(masterMap, 2)
                free masterMap(x, y)
            end for
        end for
            free grenderer
    end fullFree
    
    procedure update
        % Draw player 2
        var tileMax : int := upper(tilesetArray)
        var incrementor : int := 0
        for x : p1ViewingAreaTopLeftCornerX .. p1ViewingAreaBtmRightCornerX
            for y : p1ViewingAreaTopLeftCornerY .. p1ViewingAreaBtmRightCornerY
                incrementor += 1
                if incrementor <= tileMax then
                    grenderer -> drawAt(openedTileArray(incrementor), x, y)
                end if
            end for
        end for
            %Draw seperator
            %for y : p1ViewingAreaTopLeftCornerY .. p1ViewingAreaBtmRightCornerY
        %grenderer -> drawColorAt(y+104, p1ViewingAreaBtmRightCornerX+1, y)
        %end for
            % Draw player 2
        var screenX := WIDTH+2
        for x : p2ViewingAreaTopLeftCornerX .. p2ViewingAreaBtmRightCornerX
            var screenY := 0
            for y : p2ViewingAreaTopLeftCornerY.. p2ViewingAreaBtmRightCornerY
                masterMap(x, y) -> drawAt(grenderer, screenX, screenY)
                screenY += 1
            end for
                screenX += 1
        end for
    end update
    
    procedure setup
        new GridRenderer, grenderer
        for x : 0 .. upper(masterMap, 1)
            for y : 0 .. upper(masterMap, 2)
                new EmptyGameTile, masterMap(x, y)
            end for
        end for
    end setup
    
    procedure scrollP2(st : ScrollType)
        if st = ScrollType.UP then
            if p2ViewingAreaBtmRightCornerY not = 999 then
                p2ViewingAreaTopLeftCornerY += 1
                p2ViewingAreaBtmRightCornerY += 1
            end if
        elsif st = ScrollType.DOWN then
            if p2ViewingAreaTopLeftCornerY not = 0 then
                p2ViewingAreaTopLeftCornerY -= 1
                p2ViewingAreaBtmRightCornerY -= 1
            end if
        elsif st = ScrollType.RIGHT then
            if p2ViewingAreaBtmRightCornerX not = 999 then
                p2ViewingAreaTopLeftCornerX += 1
                p2ViewingAreaBtmRightCornerX += 1
            end if
        elsif st = ScrollType.LEFT then
            if p2ViewingAreaTopLeftCornerX not = 0 then
                p2ViewingAreaTopLeftCornerX -= 1
                p2ViewingAreaBtmRightCornerX -= 1
            end if
        end if
    end scrollP2
    
    procedure jumpTo(x : int, y : int)
        if x > p2ViewingAreaBtmRightCornerX then
            loop
                scrollP2(ScrollType.RIGHT)
                exit when x = p2ViewingAreaBtmRightCornerX
            end loop
        elsif x < p2ViewingAreaTopLeftCornerX then
            loop
                scrollP2(ScrollType.LEFT)
                exit when x = p2ViewingAreaTopLeftCornerX
            end loop
        end if
        if y > p2ViewingAreaBtmRightCornerY then
            loop
                scrollP2(ScrollType.UP)
                exit when x = p2ViewingAreaBtmRightCornerY
            end loop
        elsif y < p2ViewingAreaTopLeftCornerY then
            loop
                scrollP2(ScrollType.DOWN)
                exit when x = p2ViewingAreaTopLeftCornerY
            end loop
        end if
    end jumpTo
    
    procedure setMasterMapObject(x : int, y : int, theObject : pointer to GameObject)
        masterMap(x, y) := theObject
    end setMasterMapObject
    
    procedure freeMasterMapObject(x : int, y : int)
        free masterMap(x, y)
    end freeMasterMapObject
    
end GameMap
put "[LM] GameMap"

include "map.t"
var mapLoader : pointer to MapIOManager
new MapIOManager, mapLoader
put "[LM] MapLoader"

% TODO REPLACE WITH MODULOUS
procedure outlineTile(grenderer : pointer to GridRenderer, tileID : int)
    var incrementor : int := 0
    var tileMax : int := upper(tilesetArray)
    for x : 0 .. WIDTH
        for y : 0 .. HEIGHT
            incrementor += 1
            if incrementor = tileID then
                grenderer -> drawOutlineAt(brightred, x, y)
                exit
            end if
        end for
    end for
end outlineTile

procedure outlineMT(grenderer : pointer to GridRenderer, x : int, y : int)
    grenderer -> drawOutlineAt(brightred, x+WIDTH+2, y)
end outlineMT

procedure realOutlineMT(theMap : pointer to GameMap, grenderer : pointer to GridRenderer, x : int, y : int, theColor : int)
    var realX := x - theMap -> p2ViewingAreaTopLeftCornerX
    var realY := y - theMap -> p2ViewingAreaTopLeftCornerY
    if realX >= 0 and realY >= 0 and realX <= WIDTH and realY <= HEIGHT then
        grenderer -> drawOutlineAt(theColor, realX+WIDTH+2, realY)
    end if
end realOutlineMT

function calcXFromRelative(theMap : pointer to GameMap, x : int) : int
    result theMap -> p2ViewingAreaTopLeftCornerX + x
end calcXFromRelative

function calcYFromRelative(theMap : pointer to GameMap, y : int) : int
    result theMap -> p2ViewingAreaTopLeftCornerY + y
end calcYFromRelative

procedure realPlaceTile(theMap : pointer to GameMap, x : int, y : int, theTileID : int)
    var gameTile : pointer to GameTile
    new GameTile, gameTile
    gameTile -> setTileID(theTileID)
    theMap -> freeMasterMapObject(x, y)
    theMap -> setMasterMapObject(x, y, gameTile)
end realPlaceTile

procedure placeTile(theMap : pointer to GameMap, x : int, y : int, theTileID : int)
    var cx := calcXFromRelative(theMap, x)
    var cy := calcYFromRelative(theMap, y)
    realPlaceTile(theMap, cx, cy, theTileID)
end placeTile

procedure realDelTile(theMap : pointer to GameMap, x : int, y : int)
    var gameTile : pointer to EmptyGameTile
    new EmptyGameTile, gameTile
    theMap -> freeMasterMapObject(x, y)
    theMap -> setMasterMapObject(x, y, gameTile)
end realDelTile

procedure delTile(theMap : pointer to GameMap, x : int, y : int)
    var cx := calcXFromRelative(theMap, x)
    var cy := calcYFromRelative(theMap, y)
    realDelTile(theMap, cx, cy)
end delTile

var map : pointer to GameMap
new GameMap, map
map -> setup()
put "[LM] Editor"

var highlightedTile : int := 1
var highlightedMTX : int := 0
var highlightedMTY : int := 0

var fsX : int := -1
var fsY : int := -1
var feX : int := -1
var feY : int := -1

function getBiggest(first : int, last : int) : int
    if first > last then
        result first
    else
        result last
    end if
end getBiggest

function getSmallest(first : int, last : int) : int
    if first < last then
        result first
    else
        result last
    end if
end getSmallest

function inBoardRange(c : int) : boolean
    result c >= 0 and c <= upper(map -> masterMap, 1)
end inBoardRange

var showSelections : boolean := true

% Process commands
procedure beginCommand
        locate(3, 1)
    put "/"..
    var command : string
    get command
        % Clear command output
    locate(4, 1)
    put ""
    locate(4, 1)
    if command = "ss" or command = "selstart" then
        fsX := calcXFromRelative(map, highlightedMTX)
        fsY := calcYFromRelative(map, highlightedMTY)
        put "Selection start setup!"
    elsif command = "se" or command = "selend" then
        feX := calcXFromRelative(map, highlightedMTX)
        feY := calcYFromRelative(map, highlightedMTY)
        put "Selection end setup!"
    elsif command = "f" or command = "fill" then
        if fsX not = -1 and fsY not = -1 and feX not = -1 and feY not = -1 then
            var tID : int := 0
            for x : getSmallest(fsX, feX) .. getBiggest(fsX, feX)
                for y : getSmallest(fsY, feY) .. getBiggest(fsY, feY)
                    tID += 1
                    realPlaceTile(map, x, y, highlightedTile)
                end for
            end for
                put "Filled ", tID, " tiles with ", highlightedTile, "!"
        else
            put "Nothing selected (use /ss and /se)!"
        end if
    elsif command = "sc" or command = "selclear" then
        fsX := -1
        fsY := -1
        feX := -1
        feY := -1
        put "Selection cleared!"
    elsif command = "d" or command = "del" or command = "delete" then
        if fsX not = -1 and fsY not = -1 and feX not = -1 and feY not = -1 then
            var tID : int := 0
            for x : getSmallest(fsX, feX) .. getBiggest(fsX, feX)
                for y : getSmallest(fsY, feY) .. getBiggest(fsY, feY)
                    tID += 1
                    realDelTile(map, x, y)
                end for
            end for
                put "Deleted ", tID, " tiles!"
        else
            put "Nothing selected (use /ss and /se)!"
        end if
    elsif command = "fw" or command = "fillworld" then
        cls
        put "Are you sure you want to fill the entire world with tile ", highlightedTile, "? (Yes/No)"
        loop
            var tempInput : string
            get tempInput
            if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                put "Filling world..."
                for x : 0 .. upper(map -> masterMap, 1)
                    for y : 0 .. upper(map -> masterMap, 2)
                        realPlaceTile(map, x, y, highlightedTile)
                    end for
                end for
                    exit
            elsif tempInput = "No" or tempInput = "n" or tempInput = "no" then
                exit
            end if
            put "Invalid option!"
        end loop
        cls
    elsif command = "cw" or command = "dw" or command = "delworld" or command = "clearworld" then
        cls
        put "Are you sure you want to clear the entire world? (Yes/No)"
        loop
            var tempInput : string
            get tempInput
            if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                put "Clearing world..."
                for x : 0 .. upper(map -> masterMap, 1)
                    for y : 0 .. upper(map -> masterMap, 2)
                        realDelTile(map, x, y)
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
            if File.Exists(fileName) then
                put "File already exists, overwrite? (Yes/No)"
                loop
                    var tempInput : string
                    get tempInput
                    if tempInput = "Yes" or tempInput = "y" or tempInput = "yes" then
                        put "Deleting old file..."
                        File.Delete(fileName)
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
            exit when fileName = "cancel" or not File.Exists(fileName)
        end loop
        if fileName not = "cancel" then
            put "Saving map..."
            mapLoader -> saveMap(fileName, tileset, map)
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
            exit when fileName = "cancel" or File.Exists(fileName)
            put "File does not exist!"
        end loop
        if fileName not = "cancel" then
            put "Loading map..."
            var loadedMap : pointer to GameMap
            loadedMap := mapLoader -> loadMap(fileName)
            tileset := mapLoader -> lastLoadedTileset
            map -> fullFree()
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
            put "X: "..
            get xString
            if strintok(xString) and inBoardRange(strint(xString)) then
                exit
            elsif xString = "cancel" then
                exit
            end if
            put "Invalid coordinate!"
        end loop
        if xString not = "cancel" then
            loop
                put "Y: "..
                get yString
                if strintok(yString) and inBoardRange(strint(yString)) then
                    exit
                elsif yString = "cancel" then
                    exit
                end if
                put "Invalid coordinate!"
            end loop
            if yString not = "cancel" then
                var x : int := strint(xString)
                var y : int := strint(yString)
                % Jumpity jump
                map -> jumpTo(x, y)
                % Move the cursor to the correct position
                highlightedMTX := x - map -> p2ViewingAreaTopLeftCornerX
                highlightedMTY := y - map -> p2ViewingAreaTopLeftCornerY
            else
                put "Operation canceled!"
            end if
        else
            put "Operation canceled!"
        end if
        cls
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
    elsif command = "togglesels" or command = "togglesel" or command = "hidesels" or command = "hidesel" or command = "hs" or command = "ts" then
        showSelections := not showSelections
        put "Show selections set to: ", showSelections, "!"
    elsif command = "h" or command = "help" then
        cls
        put "/ss, /selstart : Starts the selection at your current cursor position."
        put "/ss, /selstart : Starts a selection at your current cursor position."
        put "/sc, /selclear : Clears your selection."
        put "/f, /fill : Fills the current selection with the currently selected tile."
        put "/fw, /fillworld : Fills the entire world with the currently selected tile."
        put "/cw, /dw, /delworld, /clearworld : Deletes all the tiles in the entire world."
        put "/jump, /tp, /goto, /jumpto, /cp : Moves your cursor to a specified coordinate."
        put "/togglesels, /togglesel, /hidesels, /hidesel, /hs, /ts : Toggles the slow backup renderer for selections (for selecting big areas)."
        put "/d, /del : Deletes all tiles in the current selection."
        put "/s, /save : Save a world to file."
        put "/l, /load : Load a world from file."
        put "/quit, /leave, /close, /exit : Exit the map editor!"
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
    locate(2, 1)
    put ""
    put ""
    locate(1, 1)
    put "--------=[Developer Information]=--------"
    put "TileID: ", highlightedTile, ", X: ", calcXFromRelative(map, highlightedMTX), ", Y: ", calcYFromRelative(map, highlightedMTY)..
    % Render tiles
    map -> update()
    % Draw selection
    if fsX not = -1 and fsY not = -1 and feX not = -1 and feY not = -1 then
        % New ultrafast neat selection renderer
        var realSX := getSmallest(fsX, feX) - map -> p2ViewingAreaTopLeftCornerX
        var realSY :=  getSmallest(fsY, feY) - map -> p2ViewingAreaTopLeftCornerY
        var realBX := getBiggest(fsX, feX) - map -> p2ViewingAreaTopLeftCornerX
        var realBY :=  getBiggest(feY, fsY) - map -> p2ViewingAreaTopLeftCornerY
        if realSX >= 0
            and realSY >= 0
            and realSX <= WIDTH
            and realSY <= HEIGHT 
            and realBX >= 0
            and realBY >= 0
            and realBX <= WIDTH
            and realBY <= HEIGHT then
            map -> grenderer -> boxTiles(purple,
                realSX+WIDTH+2,
                realSY,
                realBX+WIDTH+2,
                realBY)
        elsif showSelections then
        % TODO REPLACE WITH CUSTOM RECTANGLE RENDERER
            % Serve up the backup renderer if a portion of the selection is off screen (VERY SLOW)
            for x : getSmallest(fsX, feX) .. getBiggest(fsX, feX)
                for y : getSmallest(fsY, feY) .. getBiggest(fsY, feY)
                    realOutlineMT(map, map -> grenderer, x, y, purple)
                end for
            end for
        end if
    end if
    if fsX not = -1 and fsY not = -1 then
        put ", Selection Start: (", fsX, ", ", fsY, ")"..
        realOutlineMT(map, map -> grenderer, fsX, fsY, green)
    end if
    if feX not = -1 and feY not = -1 then
        put ", Selection End: (", feX, ", ", feY, ")"..
        realOutlineMT(map, map -> grenderer, feX, feY, yellow)
    end if
    % Outline cursor
        outlineTile(map -> grenderer, highlightedTile)
    outlineMT(map -> grenderer, highlightedMTX, highlightedMTY)
    var theChar : string(1)
    locate(3, 1)
    getch(theChar)
    var tempHighlightedTile : int := highlightedTile
    % Could have used a switch but too lazy
    if ord(theChar) = 200 then
        if highlightedMTY not = HEIGHT then
            highlightedMTY += 1
        else
            map -> scrollP2(ScrollType.UP)
        end if
    elsif ord(theChar) = 203 then
        if highlightedMTX not = 0 then
            highlightedMTX -= 1
        else
            map -> scrollP2(ScrollType.LEFT)
        end if
    elsif ord(theChar) = 208 then
        if highlightedMTY not = 0 then
            highlightedMTY -= 1
        else
            map -> scrollP2(ScrollType.DOWN)
        end if
    elsif ord(theChar) = 205 then
        if highlightedMTX not = WIDTH then
            highlightedMTX += 1
        else
            map -> scrollP2(ScrollType.RIGHT)
        end if
    elsif theChar = "w" then
        tempHighlightedTile += 1
    elsif theChar = "a" then
        tempHighlightedTile -= WIDTH + 1
    elsif theChar = "s" then
        tempHighlightedTile -= 1
    elsif theChar = "d" then
        tempHighlightedTile += WIDTH + 1
    elsif theChar = " " then
        % PLACE A TILE!!! (Finally I get to write this code)
        placeTile(map, highlightedMTX, highlightedMTY, highlightedTile)
    elsif theChar = "\b" then
        delTile(map, highlightedMTX, highlightedMTY)
    elsif theChar = "/" then
        beginCommand()
    end if
    % Deal with the highlighted entry on the left
    if tempHighlightedTile >= 1 and tempHighlightedTile <= upper(tilesetArray) then
        highlightedTile := tempHighlightedTile
    end if
end loop