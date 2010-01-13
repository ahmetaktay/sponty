    function params=getParams(basicLoad)
    
    % function params=spontyParams
    % Creates parameters and initializes the display for visual perception experiment
    
    if nargin < 1
        basicLoad = false;
    end
    
    % % EEG constants
    params.fixHeader = 1;
    samplingRate = 250; % Hz
    interSample = 1/samplingRate;
    params.interSample = interSample*1.5;
    %% keys
    params.eegStart = 255;
    params.eegStop = 253;
    params.eegTarget = 11;
    params.eegNoTarget = 12;
    params.eegCorrect = 21;
    params.eegIncorrect = 22;
    params.eegNoResponse = 23;
    %params.eegResponse = 24;
    params.eegBlockStart = 101;
    params.eegBlockEnd = 102;
    params.eegCalibrateStart = 111;
    params.eegCalibrateEnd = 112;
    
    % stimulus specific (physical qualities)
    params.bgContrast = 0.5;    % range is 0-1
    params.stimulusRadius = 200;    % in pixels
    params.stimulusOuterRadius = 140;   % in pixels
    params.outerFixationSize = 10; % in pixels
    params.innerFixationSize = 4; % in pixels
    params.pixelsPerPeriod = 33; % How many pixels will each period/cycle occupy?
    params.beep = 0.5 * tukeywin(199,10) .* transpose(sin(1:0.5:100));
    
    % Real Task
    params.wrap = 30;
    params.fontSize = 60;
    params.instructions = 'Focus on the square in the center for the whole time. \nPress j if you see the pattern and k if you do not. \nPress any key to continue.';
    params.percentNonTarget = 0.2;
    params.numBlocks = 4;
    params.numTrialsPerBlock = 36;
    %params.numBlocks = 3;
    %params.numTrialsPerBlock = 6;

    
    % TODO
    % -- when know the number of degrees in a pixel,
    % -- then want 2 * degrees for one period or .5 cycles per period
    % -- also want to set stimulus size properly
    
    % stimulus timing
    params.ITI = 1.5; % average number of seconds to wait till start of next trial
    params.ITIjitterRange = 0.25; % range in seconds
    params.firstTone = 0.1; % seconds before stimulus onset that tone is presented
    params.startTime = 1.0;  % wait on average this many seconds before showing stimulus
    % params.startJitterRange = 0.5; % +/- number of seconds to jitter starting of stimulus
    params.startJitterSet = [0.2 0.4 0.6 0.8 1.0]; % set of +/- number of seccond of jitter to pick randomly from
    params.stimulusDuration = 0.007;  % seconds
    params.endTime = 3; % number of seconds to wait from start of trial to end trial and ask participant their response
    params.responseTime = 2;  % seconds given to respond
    params.breakTime = 60; % minimum number of seconds between blocks as break
    
    if params.endTime < (params.firstTone + params.startTime + max(params.startJitterSet) + params.stimulusDuration)
       error('The end time for the trial is smaller than other elements of the trial combined!')
    end
    
    % staircase settings
    params.stairCaseChange = 0.005;
    params.maxContrast = 0.3;
    params.minContrast = 0.001;
    params.maxTrials = 60;
    
    % quest settings
    params.startContrast = 0.03;
    params.startVariance = 3;
    params.pThreshold = 0.63;   % this should correspond to 1 up and 1 down or 50% threshold
    params.numRecalibrateTrials = 12;
    
    % other
    params.yesKey = 'j';
    params.noKey = 'k';
    params.screenNum = 0;
    
    % practice info
    params.feedbackDuration = 1;
    params.practiceNumTrials = 8;
    
    % visual perception (just present perceptible thing and see response)
    params.visualNumTrials = 36;
    params.visualPercentNonTarget = 0.2;
    params.visualContrast = 0.1;
    
    if basicLoad == true
        return
    end
    
    % user defined params:
    % -- task type
    params.taskType = input('What type of run is this? 1=practice or 2=test or 3=staircase or 4=task or 5=visual-response [1]: ');
    if isempty(params.taskType)
        params.taskType = 1;
    end
    
    params.subjectID = 0;
    
    % If practice then ask about contrast
    if params.taskType == 1
        % Contrast
        params.startFgContrast = input('What contrast (0-1) do you want to use for this practice task? [0.1]: ');
        if isempty(params.startFgContrast)
            params.startFgContrast = 0.1;
        end
        params.fgContrast = params.startFgContrast;
    elseif params.taskType == 2
        params.startFgContrast = 0;
    % If not practice or test than ask additional questions
    elseif params.taskType == 3 || params.taskType == 4 || params.taskType == 5
        % -- subject id
        params.subjectID= input('What is the subject ID (input 0 to not save response data)? [0]: ');
        if isempty(params.subjectID)
            params.subjectID = 0;
        end
        
        % -- session number
        if params.subjectID
            params.sessionID = input('What is the session number? [1]: ');
            if isempty(params.sessionID)
                params.sessionID = 1;
            end
        end
        
        % Additional things for staircase
        if params.taskType == 3
            % -- starting contrast
            params.startFgContrast = input(sprintf('What starting contrast do you want to use (note: max contrast is %s)? 0-1 [0.03]: ', params.maxContrast));
            if isempty(params.startFgContrast)
                params.startFgContrast = 0.03;
            end
            params.fgContrast = params.startFgContrast;
        % Additional things for actual task
        elseif params.taskType == 4
            % -- contrast to use
            params.startFgContrast = input('What contrast do you want to use? ');
        elseif params.taskType == 5
            params.startFgContrast = params.visualContrast;
        end
    end
    
    % Ask if EEG
    params.eeg = input('Is this an EEG experiment (0=No, 1=Yes)? [0]: ');
    if isempty(params.eeg)
        params.eeg = 0;
    end
    
    % Create the main parts of the stimulus
    [params.gratings params.annulus params.fixationRect] = makeStim(params);
    
    %Initialize display params and open the display:
    [params.black params.white params.wPtr params.rect] = ...
        getDisplay(params.screenNum, params.bgContrast);
        
    % Get center coordinates
    [params.x0, params.y0] = RectCenter(params.rect);
    
    % Get fixation
    params.fixDim = [params.x0-params.outerFixationSize/2, params.y0-params.outerFixationSize/2, params.x0+params.outerFixationSize/2, params.y0+params.outerFixationSize/2];
    params.fixation = Screen('MakeTexture', params.wPtr, params.fixationRect*params.white, 0, 0, 1);
    
    % Get stimulus dimensions
    params.stimDim = [params.x0-params.stimulusRadius, params.y0-params.stimulusRadius, params.x0+params.stimulusRadius, params.y0+params.stimulusRadius];
    
    % Deal with eeg
    if params.eeg
        params.dio = digitalio('nidaq', 1);
        addline(params.dio, 0:7, 'out');
        putvalue(params.dio, 0);
    end

    