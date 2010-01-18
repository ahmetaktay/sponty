function [meanCorrect correctTrials] = getMeanCorrect(history, trialIndices, blockNum)
% Will find the mean number of correct responses
% can restrict by block number otherwise will get mean of everything
% Does not include non-target trials and no response trials in calculation
%
% function [meanCorrect correctTrials] = getMeanCorrect(history, [trialIndices], [blockNum])
%
% note the function will use either blockNum instead of trialIndices if
% specefied
    
    if nargin < 2
        trialIndices = 1:length(history.correct);
    elseif nargin == 3
        history.startBlockTrials = [history.startBlockTrials (length(history.correct)+1)];
        trialIndices = history.startBlockTrials(blockNum):(history.startBlockTrials(blockNum+1)-1);
    end
    
    isTarget = history.isTarget(trialIndices);
    response = history.response(trialIndices);
    correct = history.correct(trialIndices);
    
    correctTrials = correct(isTarget==1 & response~=0);
    
    meanCorrect = mean(correctTrials);
