function [black white wPtr rect] = getDisplay (screenNum, bgContrast)
    % function [black white wPtr rect] = getDisplay
    %
    % opens the display defined by the input <screenNum> and background contrast (0-1),
    % returns the size of the screen (in pixels!) and the pointer to that screen.
    %
    
    PsychImaging('PrepareConfiguration');
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    [wPtr, rect] = PsychImaging('OpenWindow', screenNum);
    
    % We use a normalized color range from now on. All color values are
    % specified as numbers between 0.0 and 1.0, instead of the usual 0 to
    % 255 range. This is more intuitive:
    Screen('ColorRange', wPtr, 1, 0);
    HideCursor;
    
    black=BlackIndex(wPtr);
    white=WhiteIndex(wPtr);
    
    Screen('FillRect', wPtr, white*bgContrast);
