% TODO FIX THIS
% THIS DOC IS INCORRECT :P
% Loads objectsets from a directory
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
class pervasive ObjectsetLoader

    import texCache

    export all

    function listObjectsets : pointer to StringArrayList
	result Utils.listFiles(OBJECTDIR)
    end listObjectsets

    function constructDir(name : string) : string
	result OBJECTDIR + "/" + name + "/"
    end constructDir

    function constructPath(objectset : string, name : string) : string
	result constructDir(objectset) + name
    end constructPath

    function listObjects(name : string) : pointer to StringArrayList
	var dir : string := constructDir(name)
	var toRemove : pointer to StringArrayList
	new StringArrayList, toRemove
	var listed : pointer to StringArrayList := Utils.listFiles(dir)
	for i : 1 .. listed -> getSize()
	    var element : string := listed -> getElement(i)
	    if not Utils.endsWith(element, OBJECTEXT) then
		toRemove -> addElement(element)
	    end if
	end for
	    for i : 1.. toRemove -> getSize()
	    listed -> removeElement(toRemove -> getElement(i))
	end for
	    Debug.info("ObjectsetLoader", "Found " + intstr(listed -> getSize()) + " tiles in objectset '" + name + "'!")
	Debug.info ("ObjectsetLoader", "Sorting objects alphabetically!")
	result Sort.alphabetically (listed)
    end listObjects

    function processObjectsetFile(objectset : string, filename : string, list : pointer to StringArrayList) : pointer to GameObject
	var texIDs : array 1 .. 4 of string
	var facing : int
	var isWalkable : boolean
	var isHidden : boolean
	var isItem : boolean % Allows the object to be picked up
	var tryWalkTrigger : string
	var walkTrigger : string
	var transparentColor : int
	var ri : int := 1
	for i : 1 .. list -> getSize()
	    var line := list -> getElement(i)
	    if not ScriptUtils.isComment(line) then
		case ri of
		label 1 : texIDs(1) := line
		label 2 : texIDs(2) := line
		label 3 : texIDs(3) := line
		label 4 : texIDs(4) := line
		label 5 : ScriptUtils.assertInt(line); facing := strint(line)
		label 6 : ScriptUtils.assertBoolean(line); isWalkable := Utils.strbool(line)
		label 7 : ScriptUtils.assertBoolean(line); isHidden := Utils.strbool(line)
		label 8 : ScriptUtils.assertBoolean(line); isItem := Utils.strbool(line)
		label 9 : tryWalkTrigger := line
		label 10 : walkTrigger := line
		label 11 : transparentColor := ColorUtils.getColor (line)
		label : Debug.fatal("ScriptAssert", "Invalid script, expected EOF but got: '" + line + "'!"); quit <
		end case
		ri += 1
	    end if
	end for
	    var openedTexIDs : array 1 .. 4 of int
	for i : 1 .. upper(texIDs)
	    var path : string := constructPath(objectset, texIDs(i))
	    % Do some cache juggling
	    if texCache -> containsKey(path) then
		openedTexIDs(i) := texCache -> getObj(path)
	    else
		openedTexIDs(i) := Pic.FileNew(path)
		texCache -> putObj(path, openedTexIDs(i))
	    end if
	end for
	    % Construct the gametile
	var go : pointer to GameObject
	new GameObject, go
	go -> setup(0, 0, openedTexIDs, facing, isWalkable, isHidden, isItem, tryWalkTrigger, walkTrigger, transparentColor)
	go -> setFilename(filename)
	go -> setTextureSet(objectset)
	result go
    end processObjectsetFile

    var objectCache : pointer to ObjectHM := HMFactory.newObjectHM()

    function processObject(objectset : string, filename : string) : pointer to GameObject
	Debug.info("ObjectsetLoader", "Loading: '" + filename + "' from objectset: '" + objectset + "'!")
	var key : string := objectset + filename
	if objectCache -> containsKey(key) then
	    result objectCache -> getObj(key)
	else
	    var content : pointer to StringArrayList := Utils.readFileToArray(constructPath(objectset, filename))
	    var object : pointer to GameObject := processObjectsetFile(objectset, filename, content)
	    free content
	    result object
	end if
    end processObject

    function load(name : string) : pointer to ObjectArrayList
	var list : pointer to ObjectArrayList
	new ObjectArrayList, list
	var objectList : pointer to StringArrayList := listObjects(name)
	for i : 1 .. objectList -> getSize()
	    list -> addElement(processObject(name, objectList -> getElement(i)))
	end for
	    Debug.info("ObjectsetLoader", "Loaded objectset: '" + name + "'!")
	result list
    end load

end ObjectsetLoader
var objectsetLoader : pointer to ObjectsetLoader
new ObjectsetLoader, objectsetLoader
Debug.lm("ObjectsetLoader")
