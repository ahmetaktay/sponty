function blockBreak(params)
    % Give break
    readyScreen(params, 'Please Take A Break!', false, params.breakTime);
    % Create a Ready screen
    readyScreen(params, 'Ready', true, 1);
    % Remind person to focus on fixation
    readyScreen(params, params.instructions, true, 1);
    % Put up the fixation and wait 3 seconds
    Screen('DrawTexture', params.wPtr, params.fixation);
    Screen('Flip', params.wPtr);
    WaitSecs(3);
