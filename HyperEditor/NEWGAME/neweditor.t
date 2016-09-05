% New editor (unfinished)
% This program was intended to replace the old editor but it was never finished

import GUI
% Fullscreen comes first
setscreen ("title:[HyperEditor] Main,graphics:800;600,")

% Load modules
put "Please wait while HyperEditor loads the required modules..."
% DO NOT ATTEMPT TO REPLACE THESE STRINGS WITH CONSTANTS OR VARIABLES, IT WILL NOT WORK!
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

cls
ScriptEngine.runCutscene("startup_editor.hcf.txt")

% Current tileset
var tileset : string
var mainWindow : int := Window.GetSelect
var tilesets : pointer to StringArrayList := tilesetLoader -> listTilesets()
var openedTiles : pointer to ObjectArrayList
new ObjectArrayList, openedTiles

function resolveTilesetFromNumber(n : int) : string
    result tilesets -> getElement(n)
end resolveTilesetFromNumber

% Opens the editor on tileset choose
var texWindow : int := -1
procedure updateTileset (line : int)
    tileset := resolveTilesetFromNumber(line)
    Debug.info("TilesetGUI", "Tileset chosen: " + tileset + "!")
    GUI.Quit()
end updateTileset

procedure addAllToTextBoxChoice(box : int, s : pointer to StringArrayList)
    for i : 1 .. s -> getSize()
        GUI.AddLine (box, s -> getElement(i))
    end for
end addAllToTextBoxChoice

% Choose tileset
procedure requestOpenTileset
    free tilesets
    tilesets := tilesetLoader -> listTilesets()
    Debug.info("TilesetGUI", "Opening new tileset loader window!")
    texWindow := Window.Open("title:[HyperEditor] Choose Tileset,graphics:200;200")
    Window.Select(texWindow)
    GUI.SetBackgroundColor (gray)
    var actionLabel := GUI.CreateLabelFull (0, 0, "Choose Tileset", maxx, maxy,
        GUI.TOP + GUI.CENTER, 0)
    var tilesetList : int := GUI.CreateTextBoxChoice (20, 40, maxx - 40, 120, 0, 0, updateTileset)
    addAllToTextBoxChoice(tilesetList, tilesets)
    loop
        exit when GUI.ProcessEvent or texWindow = -1
    end loop
    GUI.CloseWindow(texWindow)
    GUI.ResetQuit()
    Window.Select(mainWindow)
end requestOpenTileset

% Fork a procedure
process forkProcedure(p : procedure x())
    p()
end forkProcedure

procedure openTileset(name : string)
    for i : 1 .. openedTiles -> getSize()
        var p : pointer to anyclass := openedTiles -> getElement(i)
        free p
    end for
        free openedTiles
    openedTiles := tilesetLoader -> load(name)
end openTileset

class ComponentListRenderer

    export all

    var grenderer : pointer to GridRenderer
    new GridRenderer, grenderer
    var objects : array 1 .. 100, 1 .. 10 of pointer to GameComponent
    var viewportX1 : int := 1
    var viewportX2 : int := 10

    procedure draw
        for x : viewportX1 .. viewportX2
            for y : 1 .. upper(objects, 2)
                objects(x, y) -> drawAt(grenderer, x, y)
            end for
        end for
    end draw

    procedure setObjects(newObjects : array 1.. 100, 1 .. 10 of pointer to GameComponent)
        objects := newObjects
    end setObjects

    procedure addObject(object : pointer to GameComponent)
        var die : boolean := false
        for x : 1 .. upper(objects, 1)
            for y : 1 .. upper(objects, 2)
                if objectclass(objects(x, y)) >= EmptyGameComponent then
                    die := true
                    objects(x, y) := object
                    exit
                end if
            end for
                exit when die
        end for
    end addObject

    % Fill it with crap
    for x : 1 .. upper(objects, 1)
        for y : 1 .. upper(objects, 2)
            new EmptyGameComponent, objects(x, y)
        end for
    end for

end ComponentListRenderer

% ACTUAL PROGRAM
requestOpenTileset()
cls
setscreen ("title:[HyperEditor] Main,graphics:max;max,")

openTileset(tileset)

put "Creating empty map..."
var mapRenderer : pointer to MapRenderer
new MapRenderer, mapRenderer
mapRenderer -> setup()
mapRenderer -> setBeginX(500)
cls
var componentRenderer : pointer to ComponentListRenderer
new ComponentListRenderer, componentRenderer
% Add all tiles
for i : 1 .. openedTiles -> getSize()
    componentRenderer -> addObject(openedTiles -> getElement(i))
end for
    loop
    mapRenderer -> draw()
    componentRenderer -> draw()
end loop
