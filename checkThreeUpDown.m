function history=checkThreeUpDown(params, history, nTrials)
    % history=checkOneUpDown(params, history, nTrials)
    % will change threshold down if right or up if wrong
    
    % Default is to not do anything
    isReversal = 0;
    isUp = 0;
    isDown = 0;
    
    % Require minimum of 3 trials for any change
    if nTrials > 2
        % Look at current and last trial (only if not reversal)
        if history.isReversal(nTrials-1) == 0
            correctTwoTrials = sum(history.correct((nTrials-1):nTrials));
            % Find 2 correct
            if correctTwoTrials == 2
                isReversal = 1;
                isDown = 1;
            % Find 2 incorrect
            elseif correctTwoTrials == 0
                isReversal = 1;
                isUp = 1;
            % Look at current and past 2 trials (only if those not reversal)
            elseif history.isReversal(nTrials-2) == 0
                correctThreeTrials = sum(history.correct((nTrials-2):nTrials));
                % Find 2 correct
                if correctThreeTrials == 2
                    isReversal = 1;
                    isDown = 1;
                % Find 2 incorrect
                elseif correctThreeTrials == 1
                    isReversal = 1;
                    isUp = 1;
                end
            end
        end
    end

    % Set history
    history.isReversal = [history.isReversal isReversal];
    history.isUp = [history.isUp isUp];
    history.isDown = [history.isDown isDown];

    % Change threshold
    history = changeThreshold(params, history, nTrials);
