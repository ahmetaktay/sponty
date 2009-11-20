function history=practiceFeedback(params, history, nTrials)

    % Set TextSize
    oldTextSize = Screen('TextSize', params.wPtr, 48);

    % See if gave response
    if history.response(nTrials) == 0
        txt = 'No Response';
        txtDim = Screen('TextBounds', params.wPtr, txt);
        Screen('DrawText', params.wPtr, txt, params.x0-RectWidth(txtDim)/2, params.y0-RectHeight(txtDim)/2, [255 0 0]);
    else
        if history.correct(nTrials)
            txt = 'Correct';
            txtDim = Screen('TextBounds', params.wPtr, txt);
            Screen('DrawText', params.wPtr, txt, params.x0-RectWidth(txtDim)/2, params.y0-RectHeight(txtDim)/2, [0 0 255]);
        else
            txt = 'Incorrect';
            txtDim = Screen('TextBounds', params.wPtr, txt);
            Screen('DrawText', params.wPtr, txt, params.x0-RectWidth(txtDim)/2, params.y0-RectHeight(txtDim)/2, [255 0 0]);
        end
    end
    
    % Give feedback
    Screen('Flip', params.wPtr);
    Screen('TextSize', params.wPtr, oldTextSize);
    WaitSecs(params.feedbackDuration);

    % Set contrast for next trial
    history.contrast = [history.contrast history.contrast(nTrials)];

    % Adjust end of trial
    history.endTrial(nTrials) = GetSecs;
    