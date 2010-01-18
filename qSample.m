function q = qSample(oldQ, trials)
% Creates a new Quest structure
% based on subsample of old
% 
% function q = qSample(oldQ, trials)
    
    q = QuestCreate(oldQ.tGuess, oldQ.tGuessSd, oldQ.pThreshold, oldQ.beta, oldQ.delta, oldQ.gamma);
    
    contrasts = oldQ.intensity;
    responses = oldQ.response;
    
    for ii=1:length(trials);
        q = QuestUpdate(q, contrasts(ii), responses(ii));
    end
