% Map renderer (based on original renderer from editor.t)

% Renders a square, scrollable 500x500 map with 9 layers using square tiles

% Scroll type
type pervasive ScrollType : enum (UP, DOWN, LEFT, RIGHT)
Debug.lm ("ScrollType")

% Renderer
class MapRenderer

    export all

    var beginX : int
    var beginY : int
    var map : array 0 .. 499, 0 .. 499, 1 .. 9 of pointer to GameComponent
    var grenderer : pointer to GridRenderer
    var viewportX1 : int := 0
    var viewportY1 : int := 0
    var viewportX2 : int := WIDTH
    var viewportY2 : int := HEIGHT

    procedure setBeginX (newX : int)
	beginX := newX
	grenderer -> setBeginX (beginX)
    end setBeginX

    procedure setBeginY (newY : int)
	beginY := newY
	grenderer -> setBeginY (beginY)
    end setBeginY


    function getMapWidth : int
	result upper (map, 1)
    end getMapWidth

    function getMapHeight : int
	result upper (map, 2)
    end getMapHeight

    % TODO MAP TICKER
    procedure update
    end update

    procedure draw
	View.Set ("offscreenonly")
	var totalLayers : int := upper (map, 3)
	for x : viewportX1 .. viewportX2
	    for y : viewportY1 .. viewportY2
		for layer : 1 .. totalLayers
		    map (x, y, layer) -> drawAt (grenderer, x - viewportX1, y - viewportY1)
		end for
	    end for
	end for
	View.Update
	View.Set ("nooffscreenonly")
    end draw

    procedure setup
	Debug.info ("MapRenderer", "Setting up empty map...")
	var totalLayers : int := upper (map, 3)
	new GridRenderer, grenderer
	% Fill tiles with empty tiles and all other layers with empty components
	for x : 0 .. getMapWidth ()
	    for y : 0 .. getMapHeight ()
		for layer : 2 .. totalLayers
		    map (x, y, layer) := GCManager.emptyGameComponent
		end for
		map (x, y, 1) := GCManager.emptyGameTile
	    end for
	end for
	Debug.info ("MapRenderer", "Setup OK!")
    end setup

    procedure fullFree
	free grenderer
    end fullFree

    procedure scroll (st : ScrollType)
	if st = ScrollType.UP then
	    if viewportY2 not= getMapHeight () then
		viewportY1 += 1
		viewportY2 += 1
	    end if
	elsif st = ScrollType.DOWN then
	    if viewportY1 not= 0 then
		viewportY1 -= 1
		viewportY2 -= 1
	    end if
	elsif st = ScrollType.RIGHT then
	    if viewportX2 not= getMapWidth () then
		viewportX1 += 1
		viewportX2 += 1
	    end if
	elsif st = ScrollType.LEFT then
	    if viewportX1 not= 0 then
		viewportX1 -= 1
		viewportX2 -= 1
	    end if
	end if
    end scroll

    procedure jumpTo (x : int, y : int)
	if x > viewportX2 then
	    loop
		scroll (ScrollType.RIGHT)
		exit when x = viewportX2
	    end loop
	elsif x < viewportX1 then
	    loop
		scroll (ScrollType.LEFT)
		exit when x = viewportX1
	    end loop
	end if
	if y > viewportY2 then
	    loop
		scroll (ScrollType.UP)
		exit when x = viewportY2
	    end loop
	elsif y < viewportY1 then
	    loop
		scroll (ScrollType.DOWN)
		exit when x = viewportY1
	    end loop
	end if
    end jumpTo

    procedure setMapObject (x : int, y : int, layer : int, theObject : pointer to GameComponent)
	map (x, y, layer) := theObject
    end setMapObject

end MapRenderer
Debug.lm ("MapRenderer")
