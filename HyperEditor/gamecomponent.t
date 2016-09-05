% Master file containing all game components
% Core GameObject, parent of all other game objects
class pervasive GameObject
    export drawAt
    var objName : string
    var x : int
    var y : int
    % All objects must override this method, usage of this method directly will crash the program
    procedure drawAt(grenderer : pointer to GridRenderer, x : int, y : int)
        Debug.fatal("FATAL INTERNAL ERROR: Unexpected inheritance failure!")
        quit <
    end drawAt
    
    procedure setX(theX : int)
        x := theX
    end setX
    
    procedure setY(theY : int)
        y := theY
    end setY
    
    procedure setup(name : int)
        objName := name
    end setX
    
    % Any objects requiring resources to free must override this method and super call this
    procedure fullFree
    end fullFree
    
end GameObject
Debug.lm("GameObject")

% Game tile, rendered below everything, can trigger actions
% Please note that tileID is a stream
class pervasive GameTile
    inherit GameObject
    
    export tileID, setTileID
    
    var tileID : int
    var isWalkable : boolean
    var isWater : boolean
    var isHidden : boolean
    var tryWalkTrigger : string
    var walkTrigger : string
    var transparentColor : int
    
    body procedure drawAt(grenderer : pointer to GridRenderer, x : int, y : int)
        grenderer -> drawAt(tileID, x, y)
    end drawAt
    
    % CALL THIS BEFORE DOING ANYTHING WITH THE TILE!
    procedure setup(newTileID : int,
            newIsWalkable : boolean,
            newIsWater : boolean,
            newIsHidden : boolean,
            newTryWalkTrigger : boolean,
            newWalkTrigger : string,
            newTransColor : int)
        tileID := newTileID
        isWalkable := newIsWalkable
        isWater := newIsWater
        isHidden := newIsHidden
        tryWalkTrigger := newTryWalkTrigger
        walkTrigger := newWalkTrigger
        transparentColor := newTransColor
            Pic.SetTransparentColor (tileID, newTransColor)
    end setup
    
end GameTile
Debug.lm("GameTile")

% Empty Game tile, rendered below everything, pure black, should not be visible to player, uses little to zero memory
class pervasive EmptyGameTile
    inherit GameObject
    body procedure drawAt(grenderer : pointer to GridRenderer, x : int, y : int)
        grenderer -> drawColorAt(black, x, y)
    end drawAt
end EmptyGameTile
Debug.lm("EmptyGameTile")