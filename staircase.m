function [history,nTrials] = staircase(params, history, nTrials, typeStaircase, percentNonTarget)
    
    if nargin < 5
        percentNonTarget = params.percentNonTarget;
    end
    
    if strcmp(typeStaircase, 'OneUpDown')
        
        if mod(params.nTrialsCheck, 2)
            error('param.nTrialsCheck must be an even number')
        end
        
        startTrialCheck = params.nTrialsCheck + 4 + nTrials;
        maxTrials = nTrials + params.maxTrials;
        
        while nTrials < maxTrials
            history = doTrialSponty(params, history, nTrials, percentNonTarget);
            history = checkOneUpDown(params, history, nTrials);
            if nTrials > startTrialCheck
                trialsTarget = find(history.isTarget==1);
                percentUp = mean(history.isUp(trialsTarget(end-params.nTrialsCheck+1:end)));
                if percentUp == 0.5
                    nTrials = nTrials + 1;
                    break
                end
            end
            nTrials = nTrials + 1;
        end
    
    % DON'T USE THIS TYPE OF STAIRCASE
    % NEED TO FIX THAT NOT SAVING TEMPORARY VARIABLES
    elseif strcmp(typeStaircase, 'ThreeUpDown')
        
        nReversals = params.nReversals + sum(history.isReversal);
        maxTrials = nTrials + params.maxTrials;
        reversals = 0;
        
        while nTrials < maxTrials && reversals < nReversals
            tmp = doTrialSponty(params, history, nTrials, percentNonTarget);
            if tmp.isTarget(nTrials) == 1
                history = tmp;
                history = checkThreeUpDown(params, history, nTrials);
                reversals = sum(history.isReversal);
                nTrials = nTrials + 1;
            end
        end
    elseif strcmp(typeStaircase, 'Quest')
        
        % Set the number of trials to test
        qTrials = nTrials + params.qTrials;
        maxTrials = qTrials * 2;
        
        while nTrials < qTrials && nTrials < maxTrials
            % Do trial
            history = doTrialSponty(params, history, nTrials, percentNonTarget);
            % Update Quest
            if history.isTarget(nTrials) && history.response(nTrials) ~= 0
                history.q = QuestUpdate(history.q, log10(history.contrast(nTrials)), history.correct(nTrials));
                trialTheta = QuestQuantile(history.q);
                history = changeThreshold(params, history, nTrials, 10^trialTheta);
            else
                history = changeThreshold(params, history, nTrials, history.contrast(nTrials));
                % Do more trials if a no response
                if history.response(nTrials) == 0
                    qTrials = qTrials + 1;
                end
            end
            % Update number of trials
            nTrials = nTrials + 1;
        end
    end
    