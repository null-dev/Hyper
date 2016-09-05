module Debug
    export info, lm
    % The following methods are debug levels, use them accordingly
    procedure info(s : string)
        put "[INFO] ", s
    end log
    procedure warning(s : string)
        put "[WARN] ", s
    end log
    procedure error(s : string)
        put "[ERR] ", s
    end log
    procedure fatal(s : string)
        put "[FATAL] ", s
    end log
    % If you are wondering what this stands for, it means 'What a Terrible Failure'
    procedure wtf(s : string)
        put "[WTF] ", s
    end log
    % Report that a module has been loaded
    procedure lm(theModule : string)
        put "[LoadModule] ", theModule
    end lm
end Debug