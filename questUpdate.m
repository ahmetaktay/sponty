function q = questUpdate(q, contrast, response)
% function q = questUpdate(q, contrast, response)
    
    for ii=1:length(intensity);
        q = QuestUpdate(q, log10(contrast(ii)), response(ii));
    end
    
