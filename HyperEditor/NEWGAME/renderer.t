% Everything that has to do with graphics are in this class

% Splits screen into grid
% Advanced version of the original renderer used in the map editor
    class pervasive GridRenderer
    
    export all
    
    var beginX : int := 0
    var beginY : int := 0
    
    procedure setBeginX(newX : int)
	beginX := newX
    end setBeginX
    
    procedure setBeginY(newY : int)
	beginY := newY
    end setBeginY
    
    % Calculate the location of x to draw (from the block coordinates)
    function calculateX(x : int) : int
	result beginX + (BLOCKSIZE * x)
    end calculateX
    
    % Calculate the location of x to draw (from the block coordinates)
    function calculateY(y : int) : int
	result beginY + (BLOCKSIZE * y)
    end calculateY
    
    % Calculate the bounds of a tile image, returns an array in this format: [x1, y1, x2, y2]
    function calculateBounds(x : int, y : int) : array 1 .. 4 of int
	var realX := calculateX(x)
	var realY := calculateY(y)
	var res : array 1 .. 4 of int
	res(1) := realX
	res(2) := realY
	res(3) := realX + BLOCKSIZE
	res(4) := realY + BLOCKSIZE
	result res
    end calculateBounds
    
    % Draw a picture as a tile
    procedure drawAt(picID : int, x : int, y : int)
	var realX := calculateX(x)
	var realY := calculateY(y)
	Pic.Draw(picID, realX, realY, picMerge)
    end drawAt
    
    % Draw a tile as a fixed, pure color
	procedure drawColorAt(theColor : int, x : int, y : int)
	var bounds := calculateBounds(x, y)
	%put "D: " + intstr(bounds(1)) + ", " + intstr(bounds(2)) + ", " + intstr(bounds(3)) + ", " + intstr(bounds(4))
	drawfillbox(bounds(1), bounds(2), bounds(3), bounds(4), theColor)
    end drawColorAt
    
    % Draw an outline around a set of coordinates
    procedure twiceAsThickBox(x1 : int, y1 : int, x2 : int, y2 : int, theColor : int)
	drawbox(x1, y1, x2, y2, theColor)
	% Make it twice as thick
	drawbox(x1+1, y1+1, x2-1, y2-1, theColor)
    end twiceAsThickBox
    
    % Draw an outline around a tile
    procedure drawOutlineAt(theColor : int, x : int, y : int)
	var bounds := calculateBounds(x, y)
	twiceAsThickBox(bounds(1), bounds(2), bounds(3), bounds(4), theColor)
    end drawOutlineAt
    
    % Draw a box around a multiple tiles
    procedure boxTiles(theColor : int, x1 : int, y1 : int, x2 : int, y2 : int)
	var realX := calculateX(x1)
	var realY := calculateY(y1)
	var diffX := x2-x1 + 1
	var diffY := y2-y1 + 1
	twiceAsThickBox(realX, realY, realX + (diffX*(BLOCKSIZE)), realY + (diffY*(BLOCKSIZE)), theColor)
    end boxTiles
    
end GridRenderer
Debug.lm("GridRenderer")

class pervasive CutsceneRenderer
    
    export all
    
    procedure fadeInImage(pic : int, x : int, y : int, duration : int)
	Pic.DrawSpecial (pic, x, y, picCopy, picFadeIn, duration)
    end fadeInImage
    
    procedure parseAndPlayCutsceneLine(line : string)
	var list : pointer to StringArrayList := Utils.split(line, " ", true)
	% Check the script line
	ScriptUtils.assertLength(list, 5, 5)
	ScriptUtils.assertInt(list -> getElement(3))
	ScriptUtils.assertInt(list -> getElement(4))
	ScriptUtils.assertInt(list -> getElement(5))
	var x := strint(list -> getElement(3))
	var y := strint(list -> getElement(4))
	var duration := strint(list -> getElement(5))
	% Execute the command
	    if list -> getElement(1) = "FADEIN" then
	    Debug.info("CutsceneRenderer", "Rendering fade-in...")
	    var file : int := Pic.FileNew(CUTSCENEDIR + "/" + list -> getElement(2))
	    fadeInImage(file, x, y, duration)
	    Pic.Free(file)
	elsif list -> getElement(1) = "FADEOUT" then
	    Debug.info("CutsceneRenderer", "Rendering fade-out...")
	    var file : int := Pic.FileNew(INTERNALDIR + "/" + INTERNAL_WHITEIMG)
	    fadeInImage(file, x, y, duration)
	    Pic.Free(file)
	elsif list -> getElement(1) = "WAIT" then
	    delay(duration)        
	end if
	free list
    end parseAndPlayCutsceneLine
    
end CutsceneRenderer
var cutsceneRenderer : pointer to CutsceneRenderer
new CutsceneRenderer, cutsceneRenderer
Debug.lm("CutsceneRenderer")
