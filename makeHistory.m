function history=makeHistory (params, startContrast)

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
    history.startStimulus = [];
    history.stimulusDuration = [];
    history.startTrial = [];
    history.endTrial = [];
    history.eegSignalStart = [];
    history.eegSignalEnd = [];