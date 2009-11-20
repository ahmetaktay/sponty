function history=checkOneUpDown(params, history, nTrials, adjustThresh)
    % history=checkOneUpDown(params, history, nTrials)
    % will change threshold down if right or up if wrong
    
    if nargin < 4
       adjustThresh = true;
    end
    
    % Defaults
    isReversal = 0;
    isUp = 0;
    isDown = 0;
    
    % There was a target so maybe move threshold up or down
    if history.isTarget(nTrials)
        isReversal = 1;
        % Correct - Move Down Threshold
        if history.correct(nTrials)
            isDown = 1;
        % Incorrect - Move Up Threshold
        else
            isUp = 1;
        end
    end

    % Set history
    history.isReversal = [history.isReversal isReversal];
    history.isUp = [history.isUp isUp];
    history.isDown = [history.isDown isDown];
    
    % Change threshold
    if adjustThresh
        history = changeThreshold(params, history, nTrials);
    end
