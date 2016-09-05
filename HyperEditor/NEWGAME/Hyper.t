% Very basic example of a Hyper game

% Fullscreen comes first
setscreen ("title:Hyper,graphics:800;600,")

% Load modules
put "Please wait while Hyper loads the required modules..."
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
include "osl.t"
include "postload-script.t"

cls
ScriptEngine.runCutscene("startup.hcf.txt")
