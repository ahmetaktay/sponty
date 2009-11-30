function [history params]=spontyMain(history)
    
    % spontyMain.m 
    %
    % TODO: add details of this 50% threshold
    %
    % TODO: add note about where code is taken from
    
    % Start by removing anything you had left over in the memory:
    clear all; close all;
    % Set DebugLevel to 3:
    Screen('Preference', 'VisualDebuglevel', 3);
    
    try
        % Get the params of the experiment (this also opens the display):
        params = getParams;
        
        % Initialize the struct where data will be recorded: 
        if nargin < 1
            history = makeHistory(params);
        end

        % Instructions
        readyScreen(params, params.instructions, true, 1);
        
        % Create a Ready screen
        readyScreen(params);

        % Needed variables
        nTrials = 0; 
        startStudyTime = GetSecs;
        history.startStudyTime = startStudyTime;
        
        % Deal with EEG
        if params.eeg
            putvalue(params.dio, 0);
            WaitSecs(params.interSample);
            eegsignal(params.dio, params.interSample, params.eegStart)
        end

        % Practice Task
        if params.taskType == 1
            while nTrials < params.practiceNumTrials
                nTrials = nTrials + 1;
                
                history = doTrialSponty(params, history, nTrials, params.percentNonTarget);
                history = practiceFeedback(params, history, nTrials);
            end
        % Test Task
        elseif params.taskType == 2
            % Trial Loop (give predetermined thresholds to measure)
            history.contrast = [.2 .1 .3 .1 .04 0.035 0.03 .025 .02 0.015 .01];

            % Trial to go through each contrast
            for ii=1:length(history.contrast)
                nTrials = ii;
                history = doTrialSponty(params, history, nTrials);
            end
        % Simple visual task
        elseif params.taskType == 5
            history.contrast = repmat(params.startFgContrast, 1, params.visualNumTrials);
            
            for ii=1:params.visualNumTrials
                nTrials = ii;
                history = doTrialSponty(params, history, nTrials, params.visualPercentNonTarget);
            end
        % Actual Task
        elseif params.taskType == 4
            nTrials = 1;
            
            % Set calibration specific values
            calibrationHistory = makeHistory(params, history.contrast(nTrials));
            history.calibrationHistory.startTrials = [];
            calibrationTrial = 1;
            calibrationHistory.startTrials = [calibrationTrial];

            % Recalibrate baseline
            %% Tell EEG that this is a calibration
            if params.eeg
                eegsignal(params.dio, params.interSample, params.eegCalibrateStart)
            end
            %% Rough estimate
            params.stairCaseChange = 0.0001;
            params.nTrialsCheck = 4;
            [calibrationHistory,calibrationTrial] = staircase(params, calibrationHistory, calibrationTrial, 'OneUpDown');
            %% Finer estimate
            params.stairCaseChange = 0.00005;
            params.nTrialsCheck = 6;
            [calibrationHistory,calibrationTrial] = staircase(params, calibrationHistory, calibrationTrial, 'OneUpDown');
            % Finest estimate
            params.stairCaseChange = 0.00001;
            params.nTrialsCheck = 6;
            [calibrationHistory,calibrationTrial] = staircase(params, calibrationHistory, calibrationTrial, 'OneUpDown');
            %% Done
            calibrationHistory.contrast = calibrationHistory.contrast(1:end-1);
            calContrasts = calibrationHistory.contrast(calibrationHistory.isTarget==1);
            history.contrast(nTrials) = mean(calContrasts(end-4:end));
            if params.eeg
                eegsignal(params.dio, params.interSample, params.eegCalibrateEnd);
                eegsignal(params.dio, params.interSample, params.eegBlockStart);
            end
            
            history.startBlockTimes = [];
            history.startBlockTrials = [];
                        
            for ib=1:params.numBlocks
                
                history.startBlockTrials = [history.startBlockTrials nTrials];
                history.startBlockTimes = [history.startBlockTimes GetSecs];
                
                if ib ~= 1
                    % Recalibrate baseline
                    calibrationHistory.contrast(end+1) = history.contrast(end);
                    %% Tell EEG that this is a calibration
                    if params.eeg
                        eegsignal(params.dio, params.interSample, params.eegCalibrateStart)
                    end
                    %% Get trial number
                    calibrationHistory.startTrials = [calibrationHistory.startTrials calibrationTrial];
                    %% Finest estimate
                    params.stairCaseChange = 0.00001;
                    params.nTrialsCheck = 6;
                    [calibrationHistory,calibrationTrial] = staircase(params, calibrationHistory, calibrationTrial, 'OneUpDown');
                    %% Done
                    calibrationHistory.contrast = calibrationHistory.contrast(1:end-1);
                    calContrasts = calibrationHistory.contrast(calibrationHistory.isTarget==1);
                    history.contrast(nTrials) = mean(calContrasts(end-5:end));
                    if params.eeg
                        eegsignal(params.dio, params.interSample, params.eegCalibrateEnd);
                        eegsignal(params.dio, params.interSample, params.eegBlockStart);
                    end
                end
                
                % Set targets
                trialTargets = Shuffle([repmat(1, 1, round(params.numTrialsPerBlock*.8)) repmat(0, 1, round(params.numTrialsPerBlock*.2))]);
                
                % Present trials
                checkInterval = params.numTrialsPerBlock/2;
                for ii=1:params.numTrialsPerBlock
                    % Present trial
                    history = doTrialSponty(params, history, nTrials, params.percentNonTarget, trialTargets(ii));
                    
                    % Save information about whether got right or wrong
                    history = checkOneUpDown(params, history, nTrials, false);
                    % Check at certain intervals if need to adjust contrast
                    if mod(ii,checkInterval) == 0
                        %%% get trials in the interval
                        curCorrect = history.correct(end-floor(checkInterval)+1:end);
                        curIsTarget = history.isTarget(end-floor(checkInterval)+1:end);
                        checkTrials =  curCorrect(curIsTarget==1);
                        percentCorrect = mean(checkTrials);
                        history.isUp(nTrials) = 0;
                        history.isDown(nTrials) = 0;
                        if percentCorrect > 0.7
                           history.isDown(nTrials) = 1;
                           if percentCorrect > 0.85
                              params.stairCaseChange = 0.00002;
                           else
                              params.stairCaseChange = 0.00001;
                           end
                        elseif percentCorrect < 0.3
                           history.isUp(nTrials) = 1;
                           if percentCorrect < 0.15
                              params.stairCaseChange = 0.00002;
                           else
                              params.stairCaseChange = 0.00001;
                           end
                        end
                        history = changeThreshold(params, history, nTrials);
                    else
                        history.contrast = [history.contrast history.contrast(nTrials)];
                    end
                    
                    % Set next trial num
                    nTrials = nTrials + 1;
                end
                
                % End block
                if params.eeg
                    eegsignal(params.dio, params.interSample, params.eegBlockEnd);
                end
                
                if ib == params.numBlocks
                    % do you need to do something?, you are done!
                    % save calibration to history
                    history.calibrations = calibrationHistory;
                else
                    % Give break
                    blockBreak(params);
                end
            end
        % Staircase
        elseif params.taskType == 3
            %% Staircase
            stairTrialStarts = [];
            
            % 1. Rough Estimate: 1-Up and 1-Down Strategy 
            
            % 1.0. Use large stair-case gap
            % -- stop when have 4 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.01
            %%% parameters
            nTrials = 1;
            stairTrialStarts = [stairTrialStarts, nTrials];
            params.stairCaseChange = 0.01;
            params.nTrialsCheck = 4;
            [history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');
            
            % 1.1. Use medium stair-case gap
            % -- stop when have 10 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.001
            %%% parameters
            stairTrialStarts = [stairTrialStarts, nTrials];
            params.stairCaseChange = 0.001;
            params.nTrialsCheck = 6;
            [history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');
            
            % Give break
            blockBreak(params);
            
            % 1.2. Use smaller stair-case gap
            % -- stop when have 10 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.0001
            %%% parameters
            stairTrialStarts = [stairTrialStarts, nTrials];
            params.stairCaseChange = 0.0001;
            params.nTrialsCheck = 6;
            [history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');
            
            % Give break
            %blockBreak(params);
            
            % 1.3. Use smaller stair-case gap
            % -- stop when have 10 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.00005
            %%% parameters
            %stairTrialStarts = [stairTrialStarts, nTrials];
            %params.stairCaseChange = 0.00005;
            %params.nTrialsCheck = 6;
            %[history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');
            
            % Give break
            %blockBreak(params);
            
            % 1.4. Use smaller stair-case gap
            % -- stop when have 10 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.00001
            %%% parameters
            %stairTrialStarts = [stairTrialStarts, nTrials];
            %params.stairCaseChange = 0.00001;
            %params.nTrialsCheck = 6;
            %[history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');

            % Give break
            %blockBreak(params);
            
            % 2. Finer Estimate: 2/3-Up and 2/3-Down Strategy

            % 2.1. Use 1.2. stair-case level changes
            % -- stop after 6 reversals
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.00002
            %%% parameters
            %stairTrialStarts = [stairTrialStarts, nTrials];
            %params.nReversals = 6;
            %params.stairCaseChange = 0.00001;
            %history = staircase(params, history, nTrials, 'ThreeUpDown');
            
            history.stairTrialStarts = stairTrialStarts;

            fprintf('Mean of last 20 trials: %1.7f\n', mean(history.contrast((size(history.contrast,2)-20):end)));
            fprintf('Mean of last 10 trials: %1.7f\n', mean(history.contrast((size(history.contrast,2)-10):end)));
            fprintf('Mean of last 5 trials: %1.7f\n', mean(history.contrast((size(history.contrast,2)-5):end)));
            fprintf('Mean of last 2 trials: %1.7f\n', mean(history.contrast((size(history.contrast,2)-2):end)));
            
        end
        
        % Go through history and set start and end trials relative to
        % beginning of study
        %history.startTrial = history.startTrial - startStudyTime;
        %history.endTrial = history.endTrial - startStudyTime;
        
        history.endStudyTime = GetSecs;
        history.studyDuration = (history.endStudyTime - history.startStudyTime)/60
        history.contrast = history.contrast(1:end-1)
        
        % Save data (using save): 
        % File name includes the subject id and the time of the end of the
        % experiment:
        if params.subjectID ~= 0
            now = fix(clock);
            fileName = ['sponty', sprintf('%02i', params.subjectID), '-', num2str(params.sessionID), '_', num2str(now(2), '%02i'), '-', ...
                num2str(now(3), '%02i'), '-', num2str(now(1)), '_', ...
                num2str(now(4), '%02i'), num2str(now(5), '%02i'), '_type', num2str(params.taskType, '%02i')];
            save(fileName, 'history', 'params');
        end
        
        % Tell the person they are done
        readyScreen(params, 'You are all done!', true, 2);
        
       % Done
       Screen('CloseAll');
       ShowCursor;
       
        % Deal with eeg
        if params.eeg
            FlushEvents('keyDown');
            putvalue(params.dio, params.eegStop);
            WaitSecs(params.interSample);
            putvalue(params.dio, 0);
        end
        
    catch
        % Get screen back to normal
        Screen('CloseAll');
        ShowCursor;
        
        psychrethrow(psychlasterror);
        
        % Deal with eeg
        if params.eeg
            FlushEvents('keyDown');
            putvalue(params.dio, params.eegStop);
            WaitSecs(params.interSample);
            putvalue(params.dio, 0);
        end
                
        % Save data (using save): 
        % File name includes the subject id and the time of the end of the
        % experiment:
        if params.subjectID ~= 0
            now = fix(clock);
            fileName = ['sponty', sprintf('%02i', params.subjectID), '-', num2str(params.sessionID), '_', num2str(now(2), '%02i'), '-', ...
                num2str(now(3), '%02i'), '-', num2str(now(1)), '_', ...
                num2str(now(4), '%02i'), num2str(now(5), '%02i', '_type', num2str(params.taskType, '%02i'))];
            save(fileName, 'history', 'params');
        end
    end
