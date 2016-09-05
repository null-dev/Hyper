% Master file containing all game components

% A game component is basically just a renderable (or invisible) object, they can be layered on top of each other and interacted with

% Core GameComponent, parent of all other game components
% Don't instantiate this GameComponent

class pervasive GameComponent
    export all
    var filename : string
    var x : int
    var y : int
    var textureSet : string

    % All objects must override this method, usage of this method directly WILL crash the program
    deferred procedure drawAt(grenderer : pointer to GridRenderer, tX : int, tY : int)

    procedure setX(theX : int)
        x := theX
    end setX

    procedure setY(theY : int)
        y := theY
    end setY

    procedure setFilename(theFilename : string)
        filename := theFilename
    end setFilename

    procedure setTextureSet(theTextureSet : string)
        textureSet := theTextureSet
    end setTextureSet

    % All objects MUST override this if they need be sent over the network
    function serialize : string
    end serialize

    % All objects MUST override this if they need be received over the network
    function deserialize : string
    end deserialize

    % Any objects requiring resources to free must override this method and super call this
    procedure fullFree
    end fullFree

    % Any objects requiring a tick, must override this
    procedure tick
    end tick

end GameComponent
Debug.lm("GameComponent")

% Game tile, can trigger actions
% Please note that tileID is a stream
% Also note that mirror is called first, then rotate, mirror also always mirrors horizontally
class pervasive GameTile
    inherit GameComponent

    export all

    var texID : int
    var rot : int
    var mirror : boolean
    var isWalkable : boolean
    var isWater : boolean
    var tryWalkTrigger : string
    var walkTrigger : string
    var transparentColor : int

    body procedure drawAt(grenderer : pointer to GridRenderer, tX : int, tY : int)
        grenderer -> drawAt(texID, tX, tY)
    end drawAt

    % CALL THIS BEFORE DOING ANYTHING WITH THE TILE!
    procedure setup(newTexID : int,
            newRot : int,
            newMirror : boolean,
            newIsWalkable : boolean,
            newIsWater : boolean,
            newTryWalkTrigger : string,
            newWalkTrigger : string,
            newTransColor : int)
        texID := newTexID
        rot := newRot
        mirror := newMirror
            isWalkable := newIsWalkable
        isWater := newIsWater
        tryWalkTrigger := newTryWalkTrigger
        walkTrigger := newWalkTrigger
        transparentColor := newTransColor
            if mirror then
            % This is a key point where a memory leak may occur, the following code patches that
            var tmpTexID := Pic.Mirror(texID)
            texID := Pic.Rotate(tmpTexID, rot, -1, -1)
            Pic.Free(tmpTexID)
        else
            texID := Pic.Rotate(texID, rot, -1, -1)
        end if
        Pic.SetTransparentColor(texID, transparentColor)
    end setup

    body procedure fullFree
        GameComponent.fullFree()
        Pic.Free(texID)
    end fullFree

end GameTile
Debug.lm("GameTile")

% Empty Game object, fully transparent, uses very little memory
class pervasive EmptyGameComponent
    inherit GameComponent
    body procedure drawAt(grenderer : pointer to GridRenderer, tX : int, tY : int)
    end drawAt
end EmptyGameComponent
Debug.lm("EmptyGameComponent")

% Empty Game tile, rendered below everything, pure black, should not be visible to player, uses very little memory
class pervasive EmptyGameTile
    inherit EmptyGameComponent
    body procedure drawAt(grenderer : pointer to GridRenderer, tX : int, tY : int)
        grenderer -> drawColorAt(black, tX, tY)
        EmptyGameComponent.drawAt(grenderer, tX, tY)
    end drawAt
end EmptyGameTile
Debug.lm("EmptyGameTile")

% PLEASE NOTE THAT FOR OBJECTS BELOW THIS POINT:
% These objects are dynamically manipulatable which requires we know where they are at all times
% We don't want to have to scan through the entire map just to know where one object is so we store the coordinates in the object itself and update both the map and the object when we want to set the object's location

% Triggerable object, rendered above tiles, can be sometimes picked up, can be dynamically manipulated
% Can face different directions
class pervasive GameObject

    inherit GameComponent

    export all

    var texIDs : array 1 .. 4 of int
    var facing : int
    var isWalkable : boolean
    var isHidden : boolean
    var isItem : boolean % Allows the object to be picked up
    var tryWalkTrigger : string
    var walkTrigger : string
    var transparentColor : int

    body procedure drawAt(grenderer : pointer to GridRenderer, tX : int, tY : int)
        if not isHidden then
            grenderer -> drawAt(texIDs(facing), x, y)
        end if
    end drawAt

    % CALL THIS BEFORE DOING ANYTHING WITH THE OBJECT!
    procedure setup(newX : int,
            newY : int,
            newTexIDs : array 1 .. 4 of int,
            newFacing : int,
            newIsWalkable : boolean,
            newIsHidden : boolean,
            newIsItem : boolean,
            newTryWalkTrigger : string,
            newWalkTrigger : string,
            newTransColor : int)
        x := newX
        y := newY
        texIDs := newTexIDs
        facing := newFacing
        isWalkable := newIsWalkable
        isHidden := newIsHidden
        isHidden := newIsHidden
        tryWalkTrigger := newTryWalkTrigger
        walkTrigger := newWalkTrigger
        transparentColor := newTransColor
            for i : 1 .. upper(texIDs)
            Pic.SetTransparentColor (texIDs(i), newTransColor)
        end for
    end setup

    body procedure fullFree
        GameComponent.fullFree()
        for i : 1 .. upper(texIDs)
            Pic.Free(texIDs(i))
        end for
    end fullFree

end GameObject
Debug.lm("GameObject")

% Movable entity in the game, usually a monster or living thing, can be dynamically moved very easily
% Rendered above everything else
% Can NOT overlap no matter what
% Can also be assigned AIs for full automation
class pervasive GameEntity

    inherit GameComponent

    export all

    var texIDs : array 1 .. 4 of int
    var facing : int
    var isHidden : boolean
    var tryWalkTrigger : string
    var transparentColor : int
    var ai : string

    body procedure drawAt(grenderer : pointer to GridRenderer, tX : int, tY : int)
        if not isHidden then
            grenderer -> drawAt(texIDs(facing), tX, tY)
        end if
    end drawAt

    % CALL THIS BEFORE DOING ANYTHING WITH THE ENTITY!
    procedure setup(newX : int,
            newY : int,
            newTexIDs : array 1 .. 4 of int,
            newFacing : int,
            newIsHidden : boolean,
            newTryWalkTrigger : string,
            newTransColor : int,
            newAi : string)
        x := newX
        y := newY
        texIDs := newTexIDs
        facing := newFacing
        isHidden := newIsHidden
        tryWalkTrigger := newTryWalkTrigger
        transparentColor := newTransColor
            ai := newAi
        for i : 1 .. upper(texIDs)
            Pic.SetTransparentColor (texIDs(i), newTransColor)
        end for
    end setup

    body procedure fullFree
        GameComponent.fullFree()
        for i : 1 .. upper(texIDs)
            Pic.Free(texIDs(i))
        end for
    end fullFree

end GameEntity
Debug.lm("GameEntity")

% A game character
% Does everything a gameentity can do except it is player controlled (most of the time)
% Really doesn't have any extra code right now
class pervasive GameCharacter
    inherit GameEntity

    export all
end GameCharacter
Debug.lm("GameCharacter")

module pervasive GCManager
    export all
    var emptyGameTile : pointer to EmptyGameTile
    new EmptyGameTile, emptyGameTile
    var emptyGameComponent : pointer to EmptyGameComponent
    new EmptyGameComponent, emptyGameComponent
end GCManager
Debug.lm("GCManager")
