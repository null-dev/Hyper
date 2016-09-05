%  Hyper is a GAME ENGINE, it is not the game, you design the game!

%  You do not write code, instead you write scripts
%  These scripts are similar to code but are much easier to understand and use
%  They allow setting up thousands of different types of tiles and entities without bloating the main program
%  This document will describe the formats used in the scripting process
%  Any line in this document that starts with '%:' indicates it is script code

%  There are two base types of scripts: Flow and Object
%  A flow script describes a series of events to be execute in order
%  An object script describes the properties of an object in game

%  Flags can also be used in scripts, to replace an argument with the value of a flag, use this format:
%: INT_FLAG:[FLAGNAME]
%: BOOLEAN_FLAG:[FLAGNAME]
%  Flagnames can only consist of letters and can only contain booleans or ints

%  Math expresssions with flags inside of them can also be parsed:
%: INT_FLAG:[FLAGNAME]*10+2-(3^(3*(2+INT_FLAG:[FLAGNAME])/2))
%  Division by zero will crash the program, try not to do this :P
%  Math expressions do not necessarily have to have an operation inside them or a flag (some valid examples below):
%  Math expressions must not evaluate to a negative number, all operations inside the math expression must also never evaluate to a negative number
%: INT_FLAG:[FLAGNAME]
%: 3
%  For the rest of this document, math expessions will be represented by: {MATH-EXPR}

%  There are many types of scripts they are listed below along with any documentation

%  The "CUTSCENE SCRIPT"
%  Allows cutscenes to be animated quickly and efficiently
%  This scripts base type is: Flow
%  The format is:
%: <TRANSITION TYPE> <FILENAME> <X> <Y> <DURATION IN MS>
%  Available transitions are:
%    - FADEIN: Fade in the image
%    - FADEOUT: Fade out the current image, use "nil" as the filename
%    - WAIT: Fade out the current image, use "nil" as the filename and (0, 0) as 'x' and 'y'

%  The "ACTION SCRIPT"
%  Executes the actions listed in the script file in order
%  If statements can also be evaluated
%  Available if statements are: (order is important)
%: IF_FLAG_SET INT_FLAG:[FLAGNAME]
%: IF_FLAG_SET BOOLEAN_FLAG:[FLAGNAME]

%: IF BOOLEAN_FLAG:[FLAGNAME]
%: IF NOT BOOLEAN_FLAG:[FLAGNAME]

%: IF BOOLEAN_FLAG:[FLAGNAME] = BOOLEAN_FLAG:[FLAGNAME]
%: IF NOT BOOLEAN_FLAG:[FLAGNAME] = BOOLEAN_FLAG:[FLAGNAME]

%: IF {MATH-EXPR} = {MATH-EXPR}
%: IF {MATH-EXPR} <= {MATH-EXPR}
%: IF {MATH-EXPR} >= {MATH-EXPR}
%: IF {MATH-EXPR} < {MATH-EXPR}
%: IF {MATH-EXPR} > {MATH-EXPR}

%: IF NOT {MATH-EXPR} = {MATH-EXPR}
%: IF NOT {MATH-EXPR} <= {MATH-EXPR}
%: IF NOT {MATH-EXPR} >= {MATH-EXPR}
%: IF NOT {MATH-EXPR} < {MATH-EXPR}
%: IF NOT {MATH-EXPR} > {MATH-EXPR}

% If statements must end in:
%: ENDIF
% If statements can also have 'else' statements:
%: ELSE