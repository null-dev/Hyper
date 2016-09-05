% Core settings file, change any settings here

% Rendering
const pervasive SCRWIDTH : int := 800 % How wide is the screen?
const pervasive SCRHEIGHT : int := 600 % How high is the screen?
const pervasive BLOCKSIZE : int := 32 % How much pixels is each block of the screen?
const pervasive WIDTH : int := 18 % How many blocks wide is the screen?
const pervasive HEIGHT : int := 18 % How many blocks tall is the screen?

% IO
const pervasive INTERNALDIR : string := "INTERNAL" % Where are internal graphics stored?
const pervasive TILEDIR : string := "TILE" % Where are tiles stored?
const pervasive TILEEXT : string := ".htf.txt" % Hyper tile file
const pervasive CUTSCENEDIR : string := "CUTSCENE" % Where are cutscenes stored?
const pervasive CUTSCENEEXT : string := ".hcf.txt" % Hyper cutscene file
const pervasive OBJECTDIR : string := "OBJECT" % Where are objects stored?
const pervasive OBJECTEXT : string := ".hof.txt" % Hyper object file

% Internal Graphics Files
const pervasive INTERNAL_WHITEIMG : string := "white.jpg" % Pure white JPG to fade out images into

% LOADED
Debug.lm("Constants")