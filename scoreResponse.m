function history=scoreResponse(params, history, nTrials)

    if history.correct(nTrials)
        % Will decrease the contrast if the number of correct is big enough
        if history.nUp(nTrials) >= params.nBeforeDecrease
            history.isDecrease = [history.isDecrease 1];
            history.nUp = [history.nUp 0];
            nextContrast = history.contrast(nTrials) - params.stairCaseDecrements;
        else
            history.isDecrease = [history.isDecrease 0];
            history.nUp = [history.nUp history.nUp(nTrials)+1];
            nextContrast = history.contrast(nTrials);
        end
    else
        history.isDecrease = [history.isDecrease 0];
        history.nUp = [history.nUp 0];
        nextContrast = history.contrast(nTrials);
    end

    % Set contrast for next trial
    history.contrast = [history.contrast nextContrast];
