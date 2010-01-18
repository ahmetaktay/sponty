function q = qCreate(oldQ, contrast, response)
% Creates a new Quest structure
% based on old Quest structure as well as given contrasts and responses
% 
% function q = qCreate(oldQ, contrast, response)
    
    q = QuestCreate(oldQ.tGuess, oldQ.tGuessSd, oldQ.pThreshold, oldQ.beta, oldQ.delta, oldQ.gamma);
    
    for ii=1:length(contrast);
        q = QuestUpdate(q, log10(contrast(ii)), response(ii));
    end
