function blockBreak(params, breakTime)
    if nargin < 2
        breakTime = params.breakTime;
    end
    
    % Give break
    readyScreen(params, 'Please Take A Break!', false, breakTime);
    % Create a Ready screen
    readyScreen(params, 'Ready', false, 3);
    % Remind person to focus on fixation
    readyScreen(params, params.instructions, true, 1);
    readyScreen(params, params.extraInstructions, false, 5);
    % Put up the fixation and wait 3 seconds
    Screen('DrawTexture', params.wPtr, params.fixation);
    Screen('Flip', params.wPtr);
    WaitSecs(3);
