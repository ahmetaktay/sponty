function history=makeHistory (params, startContrast, q)

    if nargin < 2
       startContrast = params.startFgContrast;
    end

    history.contrast = [startContrast]; 
    history.isTarget = [];
    history.isUp = [];
    history.isDown = [];
    history.isReversal = [];
    
    % Participant response info
    history.correct = [];
    history.response = [];
    
    % Timing info
    history.interTrialInterval = [];
    history.startStimulus = [];
    history.stimulusDuration = [];
    history.startTrial = [];
    history.endTrial = [];
    history.trialDuration = [];
    history.eegSignalStart = [];
    history.eegSignalEnd = [];
    
    % Quest settings
    if nargin < 3
        tGuess = log10(params.startContrast);
        tGuessSd = params.startVariance;
        beta = 3.5; delta = 0.01; gamma = 0;
        history.q = QuestCreate(tGuess, tGuessSd, params.pThreshold, beta, delta, gamma);
        history.q.normalizePdf = 1;
    else
        history.q = q;
    end
    