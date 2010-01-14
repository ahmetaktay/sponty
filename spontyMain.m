function [history params]=spontyMain(q, history)
    
    % spontyMain.m 
    %
    % TODO: add details of this 50% threshold
    %
    % TODO: add note about where code is taken from
    
    % Start by removing anything you had left over in the memory:
    close all;
    % Set DebugLevel to 3:
    Screen('Preference', 'VisualDebuglevel', 3);
    
    try
        % Get the params of the experiment (this also opens the display):
        params = getParams;
        
        % Initialize the struct where data will be recorded:
        if nargin < 1
            history = makeHistory(params, params.startFgContrast);
        elseif nargin < 2
            history = makeHistory(params, params.startFgContrast, q);
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

            history.startBlockTimes = [];
            history.startBlockTrials = [];

            % Set calibration specific values
            calibrationHistory = makeHistory(params, history.contrast(nTrials), history.q);
            calibrationTrial = 1;
            history.calibrationHistory.startTrials = [];
            calibrationHistory.startTrials = [calibrationTrial];

            % Loop through blocks

            for ib=1:params.numBlocks;

                % Recalibrate 50% Threshold

                %%% Tell EEG that this is a calibration
                if params.eeg
                    eegsignal(params.dio, params.interSample, params.eegCalibrateStart)
                end
                
                %%% Do an additional set if this is the first trial
                if ib == 1
                   params.qTrials = params.numRecalibrateTrials;
                   [calibrationHistory, calibrationTrial] = staircase(params, calibrationHistory, calibrationTrial, 'Quest', params.percentNonTarget/2);
                   blockBreak(params, round(params.breakTime/1.5));
                end

                %%% Carry out QUEST
                params.qTrials = round(params.numRecalibrateTrials * 2/3);
                [calibrationHistory, calibrationTrial] = staircase(params, calibrationHistory, calibrationTrial, 'Quest', params.percentNonTarget/2);
                
                %%% Save quest struct
                history.q = calibrationHistory.q;

                %%% Tell EEG that done calibration
                if params.eeg
                    eegsignal(params.dio, params.interSample, params.eegCalibrateEnd);
                end


                % Run task block

                %%% Set trials that are target and non-targets
                numTargets = round(params.numTrialsPerBlock*(1-params.percentNonTarget)) + 1;
                numNonTargets = params.numTrialsPerBlock - numTargets;
                trialTargets = Shuffle([repmat(1, 1, numTargets) repmat(0, 1, numNonTargets)]);

                %%% Set contrast for block
                blockContrast = 10^QuestQuantile(history.q, 0.5);
                history.contrast(end) = blockContrast;

                %%% Save info for start of block
                history.startBlockTrials = [history.startBlockTrials nTrials];
                history.startBlockTimes = [history.startBlockTimes GetSecs];

                %%% Tell EEG that block starting
                if params.eeg
                    eegsignal(params.dio, params.interSample, params.eegBlockStart);
                end

                for ii=1:params.numTrialsPerBlock
                    % Present Trial
                    history = doTrialSponty(params, history, nTrials, params.percentNonTarget, trialTargets(ii));

                    % Update Quest
                    history.q = QuestUpdate(history.q, log10(history.contrast(nTrials)), history.correct(nTrials));

                    % Set contrast for next trial
                    history.contrast = [history.contrast blockContrast];

                    % Update number of trials
                    nTrials = nTrials + 1;
                end

                %%% End block
                if params.eeg
                    eegsignal(params.dio, params.interSample, params.eegBlockEnd);
                end


                % What next?

                if ib == params.numBlocks
                    % do you need to do something?, you are done!
                    % save calibration to history
                    history.calibrations = calibrationHistory;
                else
                    % Set contrast
                    calibrationHistory.contrast(end) = history.contrast(end);
                    % Get trial number
                    calibrationHistory.startTrials = [calibrationHistory.startTrials calibrationTrial];
                    % Update quest struct
                    calibrationHistory.q = history.q;
                    % Do brief Quest
                    params.qTrials = round(params.numRecalibrateTrials * 1/3);
                    [calibrationHistory, calibrationTrial] = staircase(params, calibrationHistory, calibrationTrial, 'Quest', params.percentNonTarget/2);
                    
                    % Give break
                    blockBreak(params);
                end
            end

        % Staircase    
        elseif params.taskType == 3
            %% Staircase
            stairTrialStarts = [];
            nTrials = 1;
            
            % 1. Rough Estimate: 1-Up and 1-Down Strategy 
            
            % 1.0. Use large stair-case gap
            % -- stop when have 4 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.01
            %%% parameters
            %stairTrialStarts = [stairTrialStarts, nTrials];
            %params.stairCaseChange = 0.01;
            %params.nTrialsCheck = 4;
            %[history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');
            
            % 1.1. Use medium stair-case gap
            % -- stop when have 8 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.001
            %%% parameters
            stairTrialStarts = [stairTrialStarts, nTrials];
            params.stairCaseChange = 0.001;
            params.nTrialsCheck = 8;
            [history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');
            
            % Give break for 30 seconds
            blockBreak(params, 30);
            
            % 1.2. Use smaller stair-case gap
            % -- stop when have 10 trials with 50% up+down
            % -- or stop if reach maximum number of trials
            % -- stair-case gap: 0.0001
            %%% parameters
            %stairTrialStarts = [stairTrialStarts, nTrials];
            %params.stairCaseChange = 0.0001;
            %params.nTrialsCheck = 6;
            %[history,nTrials] = staircase(params, history, nTrials, 'OneUpDown');
            
            % Give break for 30 seconds
            %blockBreak(params, 30);
            
            % 2. QUEST Algorithm
            
            %%% take starting contrast from qStartContrast
            qStartContrast = mean(history.contrast((end-7):end));
            
            %%% create new q struct
            oldq = history.q;
            history.q = QuestCreate(qStartContrast, oldq.tGuessSd, oldq.pThreshold, oldq.beta, oldq.delta, oldq.gamma);
            
            %%% if old q struct has items in it, then add to new q struct
            if isempty(oldq.intensity) == 0
                history.q = qUpdate(history.q, oldq.intensity, oldq.response);
            end
            
            %%% add trials from one up and one down staircase
            history.q = qUpdate(history.q, history.contrast(2:(end-1)), history.correct(2:end));
            
            %%% run 60 trials of quest (in 2 parts)
            params.qTrials = 30;
            
            % part 1
            stairTrialStarts = [stairTrialStarts, nTrials];
            [history, nTrials] = staircase(params, history, nTrials, 'Quest', params.percentNonTarget/2);
            
            % break for 30 secs
            blockBreak(params, 30);
            
            % part 2
            stairTrialStarts = [stairTrialStarts, nTrials];
            [history, nTrials] = staircase(params, history, nTrials, 'Quest', params.percentNonTarget/2);
            
            history.stairTrialStarts = stairTrialStarts;
            
            % todo: add false alarm rate check!
            
%            %% Testing
%            
%            % break for 30 secs
%            blockBreak(params, 30);
%            
%            % setup contrast
%            blockContrast = 10^QuestQuantile(history.q, 0.5);
%            history.contrast(end) = blockContrast;
%            
%            % setup trials
%            trialTargets = Shuffle([repmat(1, 1, round(params.numTrialsPerBlock*(1-params.percentNonTarget))) repmat(0, 1, round(params.numTrialsPerBlock*params.percentNonTarget))]);
%            
%            for ii=1:params.numTrialsPerBlock
%                % Present Trial
%                history = doTrialSponty(params, history, nTrials, params.percentNonTarget, trialTargets(ii));
%
%                % Update Quest
%                history.q = QuestUpdate(history.q, log10(history.contrast(nTrials)), history.correct(nTrials));
%
%                % Set contrast for next trial
%                history.contrast = [history.contrast blockContrast];
%
%                % Update number of trials
%                nTrials = nTrials + 1;
%            end
        end
        
        % Go through history and set start and end trials relative to
        % beginning of study
        %history.startTrial = history.startTrial - startStudyTime;
        %history.endTrial = history.endTrial - startStudyTime;
        
        history.endStudyTime = GetSecs;
        history.studyDuration = (history.endStudyTime - history.startStudyTime)/60;
        history.contrast = history.contrast(1:end-1);
        
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
