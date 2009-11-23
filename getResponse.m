function [correct response] = getResponse(isTarget, keyYes, keyNo, timeLimit, lastForLimit, keyEnd)
    % function [correct response] = getResponse(isTarget, keyYes, keyNo, timeLimit, [lastForlimit, keyEnd])
    % 
    % Input:
    %   - isTarget = was a target stimulus presented?
    %   - keyYes = participant thought there was a target stimulus?
    %   - keyNo = participant did not think there was a target stimulus?
    %   - timeLimit = time limit for checking for response
    %   - lastForLimit =  should I continue checking for the whole time period or stop when I get the first response (default: false or stop when get response)
    %   - keyEnd = is there a key that will kill the script (default: ESCAPE)
    %
    % Output:
    %   - correct: was the participant correct
    %   - response: did they respond (0=no) and what was the response time (anything besides 0 indicates they had a response and the time it took)
    %
    
    KbName('UnifyKeyNames');
    
    keyIsDown=0;
    
    if nargin < 5
        lastForLimit = false;
    end
    
    if nargin < 6
       keyEnd = KbName('ESCAPE');
    end
    
    % Loop through checking for keypress up to time limit of response
    if lastForLimit == true
        while GetSecs < timeLimit
            [tmpKeyIsDown tmpSecs tmpKeyCode] = KbCheck;
            if tmpKeyIsDown == 1
                keyIsDown = tmpKeyIsDown;
                secs = tmpSecs;
                keyCode = tmpKeyCode;
                %if params.eeg
                %    eegsignal(params.eegResponse);
                %end
            end
        end
    else
        while GetSecs < timeLimit && keyIsDown == 0
            [keyIsDown, secs, keyCode] = KbCheck;
        end
        %if keyIsDown ~= 0 && params.eeg ~= 0
        %    eegsignal(params.eegResponse)
        %end
    end
    
    % If no key press, wrong answer and no response
    if keyIsDown == 0
       correct = 0;
       response = 0;
    else
        keyCode = find(keyCode);
        
        % Check if want to quit
        if keyCode == keyEnd
            error('%s key pressed, quitting', KbName(keyEnd))
        end
        
        % Save reaction-time in response variable
        response = secs;
         
        % Target was shown
        if isTarget
            if keyCode == KbName(keyYes)
                correct = 1;
            else
                correct = 0;
            end
        % Target was not shown
        else
            if keyCode == KbName(keyNo)
                correct = 1;
            else
                correct = 0;
            end
        end
    end
