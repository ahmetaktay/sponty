function history=doTrialSponty(params, history, nTrials, percentNoTarget, isTarget)

    %function history=doTrialSponty(params,history,nTrials)
    %
    %Executes the trial of the detection experiment. Receives as input,
    %<params>, a struct with various parameters, 
    %<history>, a struct with the history of the experiment so far, this same
    %struct is then updated as the function proceeds and is the output of the
    %function. <nTrials> is simply a counter that tells us what trial we are
    %at.
    
    % Put up the fixation:
    Screen('DrawTexture', params.wPtr, params.fixation);
    showTime = Screen('Flip', params.wPtr);
    
    % Get timing difference since end of last trial to now
    if nTrials > 1
        elapsedTime = showTime - history.endTrial(nTrials-1);
    else
        elapsedTime = 0;
    end
    
    % Set percentage non-target stimuli
    if nargin < 4
       percentNoTarget = 0; 
    end
    
    % Determine whether to show a target in this trial, record as you go
    if nargin < 5
        isTarget = rand > percentNoTarget;
    end
    history.isTarget = [history.isTarget isTarget];
    
    % Prepare stimulus for next trial
    params.fgContrast = history.contrast(nTrials);
    if isTarget == 1
        % Create the contrast adjusted stimulus
        stim = adjustStim(params);
        t = Screen('MakeTexture', params.wPtr, stim, 0, 0, 1);
    end
    
    % Jitter intertrial interval
    jitterITI = (params.ITIjitterRange * rand()) * ((2 * round(rand)) - 1);
    % current trial jitter in secs = ...
    %   (range of jittering in secs * random number 0-1) * (random -1 or 1)
    
    % Wait
    interTrialInterval = params.ITI - (GetSecs - showTime) - elapsedTime + jitterITI;
    history.interTrialInterval = [history.interTrialInterval interTrialInterval];
    WaitSecs(interTrialInterval);
    
    % Deal with EEG
    if params.eeg
        putvalue(params.dio, params.eegStartTrial);
        history.eegSignalStart = [history.eegSignalStart GetSecs];
        WaitSecs(params.interSample);
        putvalue(params.dio, 0);
    end
    
    % Tell participant that stimulus coming
    startTrialTime = GetSecs;
    sound(params.beep);
    history.startTrial = [history.startTrial startTrialTime];
    
    % Have some jittered interval between start of trial and stimulus presentation
    % jitterStart = (params.startJitterRange * rand()) * ((2 * round(rand)) - 1);
    jitterStart = Sample(params.startJitterSet);
    
    % Prepare display stimulus if target and prepare eeg code
    if isTarget==1
        Screen('DrawTexture', params.wPtr, t);
        eegCode = params.eegTarget;
    else
        eegCode = params.eegNoTarget;
    end
    % Prepare display of new fixation
    Screen('DrawTexture', params.wPtr, params.fixation);
    
    % Deal with EEG
    if params.eeg
        putvalue(params.dio, eegCode);
    end
    
    % Present stimulus
    stimulusStartTime = startTrialTime + params.firstTone + params.startTime + jitterStart;
    startStimulusTime = Screen('Flip', params.wPtr, stimulusStartTime);
    history.startStimulus = [history.startStimulus startStimulusTime-startTrialTime];
    
    % Put back only grey background + the fixation
    if isTarget==1
        Screen('Close', t)
    end
    Screen('FillRect', params.wPtr, params.white*params.bgContrast);
    Screen('DrawTexture', params.wPtr, params.fixation);
    endStimulusTime = Screen('Flip', params.wPtr, startStimulusTime + params.stimulusDuration);
    %%% fix for when contrast is actually zero
    if params.fgContrast == 0
        isTarget = 0;
    end
    
    % Deal with EEG
    if params.eeg
        putvalue(params.dio, 0);
    end
    
    history.stimulusDuration = [history.stimulusDuration endStimulusTime-startStimulusTime];
    
    % Give second sound indicating response
%    jitterSecondTone = (params.secondToneJitterRange * rand()) * ((2 * round(rand)) - 1);
%    endTime = endStimulusTime + (params.secondTone + jitterSecondTone);
%    while GetSecs < endTime
       % wait
%    end
%    sound(params.beep);
    
    % Show question mark to indicate that a response is needed
    Screen('FillRect', params.wPtr, params.white*params.bgContrast);
    %%% Save old text size
    Screen(params.wPtr, 'TextFont', 'Arial');
    oldTextSize = Screen('TextSize', params.wPtr, params.fontSize);
    %%% Draw text centered on screen
    DrawFormattedText(params.wPtr, WrapString('?', params.wrap), 'center', 'center');
    %%% Display text
    startResponseTime = Screen('Flip', params.wPtr, startTrialTime + params.endTime);
    %%% Return textsize to normal
    Screen('TextSize', params.wPtr, oldTextSize);
    
    % Get Response
    [thisCorrect thisResponseTime] = getResponse(isTarget, params.yesKey, params.noKey, startResponseTime + params.responseTime, true);
    endTrialTime = GetSecs;
    
    % End of Trial
    history.endTrial = [history.endTrial endTrialTime];
    history.trialDuration = [history.trialDuration endTrialTime-startTrialTime];
    
    % Take away question mark and replace with fixation
    Screen('FillRect', params.wPtr, params.white*params.bgContrast);
    Screen('DrawTexture', params.wPtr, params.fixation);
    Screen('Flip', params.wPtr, startTrialTime + params.endTime + params.responseTime);
    
    % Code Response (correct and rxn-time)
    history.correct = [history.correct thisCorrect];
    if thisResponseTime == 0
        history.response = [history.response thisResponseTime];
        if params.eeg
            eegCode = params.eegNoResponse;
        end
    else
        history.response = [history.response thisResponseTime-startResponseTime];
        if params.eeg
            if thisCorrect
                eegCode = params.eegCorrect;
            else
                eegCode = params.eegIncorrect;
            end
        end
    end
    
    % Deal with EEG
    if params.eeg
        putvalue(params.dio, eegCode);
        history.eegSignalEnd = [history.eegSignalEnd GetSecs];
        WaitSecs(params.interSample);
        putvalue(params.dio, 0);
    end
    
    