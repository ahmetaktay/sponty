function mipRecode(inputFile, outputFile)
   % function mipRecode(inputFile, outputFile)
   %
   % inputFile = foobar.eeg file from mip
   % outputFile = recode text file with 2 columns 
   %   1st column are old codes, 2nd column are new codes
   %   this will be input for mipavg3

   % Get old codes
   eeg = MIPRead(inputFile);
   trigChan = squeeze(eeg.data(eeg.nChannels+1,:));
   oldCodes = trigChan(trigChan~=0);
   oldCodes = oldCodes(2:end-1);
   numCodes = length(oldCodes);
   fprintf('There are %i different codes\n', numCodes);

   % Get params
   params = getParams(true);

   % New Codes
   hit = 1;
   miss = 2;
   falseAlarm = 3;
   correctReject = 4;
   noResponse = 5;

   % Create new codes
   newCodes = oldCodes;
   isBlock = false;
   for ii=1:length(oldCodes)
      switch oldCodes(ii)
         case params.eegBlockStart
           isBlock = true;
         case params.eegBlockEnd
           isBlock = false;
         otherwise
            if isBlock
               switch oldCodes(ii)
                  % Target
                  case params.eegTarget
                        switch oldCodes(ii+1)
                           case params.eegCorrect
                              newCodes(ii) = hit;
                           case params.eegIncorrect
                              newCodes(ii) = miss;
                           case params.eegNoResponse
                              newCodes(ii) = noResponse;
                        end
                  % No Target
                  case params.eegNoTarget
                     switch oldCodes(ii+1)
                        case params.eegCorrect
                           newCodes(ii) = correctReject;
                        case params.eegIncorrect
                           newCodes(ii) = falseAlarm;
                        case params.eegNoResponse
                           newCodes(ii) = noResponse;
                     end
               end
            end
      end
    end
    
    % Save new codes
    fprintf('Saving file %s\n', outputFile);
    dlmwrite(outputFile, [oldCodes' newCodes'], '\t');

    return
