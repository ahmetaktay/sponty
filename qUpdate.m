function q = qUpdate(q, contrast, response)
% function q = qUpdate(q, contrast, response)
    
    for ii=1:length(contrast);
        q = QuestUpdate(q, log10(contrast(ii)), response(ii));
    end
    
