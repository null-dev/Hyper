% THESE ARE THE ONLY SETTING NOTS IN 'constants.t' (because of initialization order)
% DO NOT TRY TO MOVE THEM, THEY WON'T WORK

% This module isn't really a debug framework, it's more like an advanced logging framework. All logging is done in a separate window!

const pervasive DEBUG : boolean := true % Are we debugging?
const pervasive DEBUGWINDOWARGS : string := "title:Hyper Debug Console,text:200;200" % Debug window args
const pervasive NODEBUGWINDOWARGS : string := "invisible" % Debug args when debug is off

module pervasive Debug

    export info, warning, error, fatal, wtf, lm

    var debugWindow : int := -2
    var masterWindow : int := -2

    % Open a new window if necessary to output debug info
    procedure selectDebugWindow
        if masterWindow = -2 then
            masterWindow := Window.GetSelect()
        end if
        if debugWindow = -2 then
            if DEBUG then
                debugWindow := Window.Open (DEBUGWINDOWARGS)
            else
                debugWindow := Window.Open (NODEBUGWINDOWARGS)
            end if
        end if
        Window.Select(debugWindow)
    end selectDebugWindow

    % Go back to main window
    procedure deSelectDebugWindow
        Window.Select(masterWindow)
    end deSelectDebugWindow

    % The following methods are debug levels, use them accordingly
    procedure info(c : string, s : string)
        selectDebugWindow()
        put "[",c,"][INFO] ", s
        deSelectDebugWindow()
    end info
    procedure warning(c : string, s : string)
        selectDebugWindow()
        put "[",c,"][WARN] ", s
        deSelectDebugWindow()
    end warning
    procedure error(c : string, s : string)
        selectDebugWindow()
        put "[",c,"][ERR] ", s
        deSelectDebugWindow()
    end error
        procedure fatal(c : string, s : string)
        selectDebugWindow()
        put "[",c,"][FATAL] ", s
        deSelectDebugWindow()
    end fatal
    % If you are wondering what this stands for, it means 'What a Terrible Failure'
    procedure wtf(c : string, s : string)
        selectDebugWindow()
        put "[",c,"][WTF] ", s
        deSelectDebugWindow()
    end wtf
    % Report that a module has been loaded
    procedure lm(theModule : string)
        selectDebugWindow()
        put "[LoadModule] ", theModule
        deSelectDebugWindow()
    end lm

end Debug
Debug.lm("Debug")
