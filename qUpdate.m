function q = qUpdate(q, contrast, response)
% Given a set of contrasts and responses, will create a new quest structure
% function q = qUpdate(q, contrast, response)
    
    for ii=1:length(contrast);
        q = QuestUpdate(q, log10(contrast(ii)), response(ii));
    end
    
