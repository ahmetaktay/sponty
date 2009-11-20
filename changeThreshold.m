function history=changeThreshold(params, history, nTrials)

    % Check if up
    if history.isUp(nTrials) == 1
        nextContrast = history.contrast(nTrials) + params.stairCaseChange;
    % Check if down
    elseif history.isDown(nTrials) == 1
        nextContrast = history.contrast(nTrials) - params.stairCaseChange;
    % Keep contrast same
    else
        nextContrast = history.contrast(nTrials);
    end

    % Put limits on the contrasts (i.e. so don't go below 0)
    nextContrast = max(params.minContrast, nextContrast);
    nextContrast = min(params.maxContrast, nextContrast);

    history.contrast = [history.contrast nextContrast];
