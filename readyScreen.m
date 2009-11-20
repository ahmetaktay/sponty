function readyScreen(params, txt, toWaitResponse, toWaitTime)

    if nargin < 2
        txt = 'READY';
    end
    
    if nargin < 3
        toWaitResponse = true;
    end
    
    if nargin < 4
        toWaitTime = 0;
    end

    % Save old text size
    Screen(params.wPtr, 'TextFont', 'Arial');
    oldTextSize = Screen('TextSize', params.wPtr, params.fontSize);
    
    % Draw text centered on screen
    DrawFormattedText(params.wPtr, WrapString(txt, params.wrap), 'center', 'center');
    
    % Display text
    Screen('Flip', params.wPtr);
    
    % Return textsize to normal
    Screen('TextSize', params.wPtr, oldTextSize);
    
    % Wait for anything to continue
    if toWaitResponse
        KbWait;
        Screen('FillRect', params.wPtr, params.white*params.bgContrast);
        Screen('Flip', params.wPtr);
    end
    
    % Wait for a number of seconds
    if toWaitTime
        WaitSecs(toWaitTime);
        Screen('FillRect', params.wPtr, params.white*params.bgContrast);
        Screen('Flip', params.wPtr);
    end

    FlushEvents('keyDown');
