% function [] = Face_Task()
%
% Version 1
%
% Created: Jun. 19 09
% Last modified:
% Written by:  Yi He
% 
% Purpose: Present faces and record decisions
%
% ***EEG experiment***

clear all;
clc;

prompt = {'Enter subject number:', 'Doing an EEG expt? (Y)es or (N)o', 'Number of Blocks:'};
defaults = {'99', 'N', '1'}; 
answer = inputdlg(prompt, 'Experimental setup information',1,defaults);
[subjectNumber eeg numBlocks ] = deal(answer{:}); 
subjectNumber = str2num(subjectNumber); 
numBlocks = str2num(numBlocks);

% system-specific variables
seed = ClockRandSeed;
keys = [49 50 32 122];

% experiment and timing parameters
stimDur = 1.5; % face presentation time
stimMinIti = 1.25; % test ITI between shapes
respDur = 2; % collecting responses 
jitterMax = .3;
numConds = 2; 
%numBlocks = 4; %grabbed from experimenter input
numTrials = 60;

% % EEG constants
fixHeader = 1;
samplingRate = 250; % Hz
interSample = 1/samplingRate; interSample = interSample*1.5;

% open and set-up files
dataFile = fopen(['Face_Task' num2str(subjectNumber) '.txt'], 'w');
fprintf(dataFile,['*********************************************\n']);
fprintf(dataFile,['* Date/Time: ' datestr(now, 0) '\n']);
fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
fprintf(dataFile,['* Subject Number: ' num2str(subjectNumber) '\n']);
fprintf(dataFile,['*********************************************\n\n']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up displays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% screen locations
%Screen('Preference','Tick0Secs',nan);
Screen_X = 1280; % change this for other screen resolutions
Screen_Y = 1024; % change this for other screen resolutions
Center_X = (Screen_X/2);
Center_Y = (Screen_Y/2);
ScreenRect = [0 0 Screen_X Screen_Y];

% stimulus sizes
targetSize = [400 500];

% stimulus presentation locations
targetRect = genCorners(Center_X, Center_Y, targetSize(1), targetSize(2), 1);

% color information
backColor = [254 254 254]; %white
fixColor = [0 0 0]; % black
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];

% initiating the screens
w = Screen(0,'OpenWindow',backColor,ScreenRect,32);

% font stuff
 Screen(w, 'TextFont', 'Arial');
fontSize=Screen( w, 'TextSize', 32);

% fixation cross Screen
fixationCross = Screen(w,'OpenOffScreenWindow',backColor,ScreenRect);
Screen(fixationCross,'DrawLine',fixColor,Center_X,(Center_Y-50),Center_X,(Center_Y+50),5);
Screen(fixationCross,'DrawLine',fixColor,(Center_X-50),Center_Y,(Center_X+50),Center_Y,5);

% label Screen
blackScreen = Screen(w, 'OpenOffScreenWindow', backColor, ScreenRect);
Screen(blackScreen, 'TextFont', 'Arial');
Screen(blackScreen, 'TextSize', 48);
Screen(blackScreen, 'DrawText', 'Black', (Center_X-70), (Center_Y-45), fixColor); 

whiteScreen = Screen(w, 'OpenOffScreenWindow', backColor, ScreenRect);
Screen(whiteScreen, 'TextFont', 'Arial');
Screen(whiteScreen, 'TextSize', 48);
Screen(whiteScreen, 'DrawText', 'White', (Center_X-70), (Center_Y-45), fixColor); 

% question Screen
questionScreen = Screen(w, 'OpenOffScreenWindow', backColor, ScreenRect);
Screen(questionScreen, 'TextFont', 'Arial');
Screen(questionScreen, 'TextSize', 42);
Screen(questionScreen, 'DrawText', 'Male or Female?', (Center_X-160), (Center_Y-45), fixColor); 

% blank Screen
blankScreen = Screen(w,'OpenOffScreenWindow',backColor,ScreenRect);
Scratch = Screen(w, 'OpenOffScreenWindow', backColor, ScreenRect);

% import faces
%   
Dir = 'V:\Morphed_faces\stimuli\'; % where are the stimuli?
rootDir = 'C:\tasks\RMFeeg_Yi\stimuli\'; % where are the stimuli?
picFmt = 'jpg'; 
cd(rootDir);
faceLists = {'v1_B' 'v1_W'}; 
for condInd = 1:2   % change this for your number of conditions
	cd(deblank([rootDir faceLists{condInd} '\']));
	d = dir; 
    [numFaces junk] = size(d); 
    % [facelist{1:numFaces}] = deal(d.name);
	[facelistWithJunk{1:numFaces}] = deal(d.name);
    for f=1:numFaces-2
        facelist{f} = facelistWithJunk{f+2};
    end
    numFaces = length(facelist);
    faceLimit(condInd) = numFaces;
	faceNums{condInd} = randperm(numFaces);
	
	for faceInd = 1:numFaces
		faceFile = facelist{faceInd};
		image = imread(faceFile, picFmt);
		facePics{faceInd} = image;
		clear image;
    end
    disp('Loaded faces');
    facePicLists{condInd} = facePics;
	clear facePics facelistWithJunk facelist;
end
cd(rootDir);
% curface = ones(1,30);

% put up first screen
[ifi nvalid stddev]= Screen('GetFlipInterval', w, 100, 0.00005, 3);
Screen(w,'FillRect',backColor);
Screen('Flip',w);

if eeg == 'Y'
    dio = digitalio('nidaq','Dev1');
    addline(dio,0:7,0,'out');
    putvalue(dio,0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READY SCREENS HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HideCursor;

InstructionScreen = Screen(w,'OpenOffScreenWindow', backColor, ScreenRect);
img = imread('instruction.jpg', 'jpg');       % read in image
imageSize = size(img);                  % gets image size
% location = genCorners(Center_X, Center_Y, imageSize(1)-100, imageSize(2)-100, 1);         
Screen('PutImage', InstructionScreen, img, ScreenRect);
Screen('CopyWindow', InstructionScreen, w);
Screen('Flip', w);  
kbWait; WaitSecs(1);

ReadyScreen = Screen(w, 'OpenOffScreenWindow', backColor, ScreenRect);
Screen(ReadyScreen, 'TextFont', 'Arial');
Screen(ReadyScreen, 'TextSize', 36);
Screen(ReadyScreen, 'DrawText', 'Ready?', (Center_X-85), (Center_Y-45), fixColor); 
Screen(ReadyScreen, 'DrawText','Please press space bar to begin.', (Center_X-300), (Center_Y), fixColor);
Screen('CopyWindow', ReadyScreen, w);
Screen('Flip', w);
kbWait;
WaitSecs(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STARTING EXPERIMENT!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize any variables here
% for examples: 
initTime = GetSecs; response = 0; faceRT = 0; acc = 0; placeholderA = 1; placeholderB = 1;

for block=1:numBlocks
    
    trialOrder = randperm(numTrials);
    condOrder = (mod(trialOrder, numConds)+1);    % so that condOrder is randomized
    
    for trial = 1:numTrials
        
         curCond = condOrder(trial);
         
         if curCond == 1
             placeholder = placeholderA;
             placeholderA = placeholderA + 1;
         else
             placeholder = placeholderB;
             placeholderB = placeholderB + 1;
         end
            
         % prepare target             
         thisface = faceNums{curCond}(placeholder);
         Screen('PutImage', Scratch, facePicLists{curCond}{thisface}, targetRect);
         
        if eeg == 'Y'                                                   %begins EEG parameters
            
            putvalue(dio,0);
            if trial == 1
                putvalue(dio,255);
            end
            WaitSecs(interSample);
            putvalue(dio,0);
            
            Screen('CopyWindow', fixationCross, w);            
                Screen('Flip', w); 
                WaitSecs(1);
                
            % put label screen up
            if curCond == 1
                
                Screen('CopyWindow', blackScreen, w);            
                Screen('Flip', w); 
                putvalue(dio, curCond+4);
                WaitSecs(0.75);
                putvalue(dio,0);

            elseif curCond == 2
                
                Screen('CopyWindow', whiteScreen, w);            
                Screen('Flip', w); 
                putvalue(dio, curCond+4);
                WaitSecs(0.75);
                putvalue(dio,0);

            end
            
            % put blank screen between the label and face
            curISI = 0.5 + jitterMax*rand(1,1); % stimDur + stimMinIti +
        
            Screen('CopyWindow', blankScreen, w);  
            Screen('Flip', w); 
            WaitSecs(curISI);
            
            % put face onscreen
            Screen('CopyWindow', Scratch, w);
%             
            [initTime faceOn finishTime] = Screen('Flip', w); 
            putvalue(dio, curCond);          % sends codes to MIP based on condition type; 
            
            WaitSecs(interSample);
            putvalue(dio,0);
            
            % put question onscreen
            Screen('CopyWindow', questionScreen, w);            
            [initTime stimOn finishTime] = Screen('Flip', w, faceOn + stimDur); 
            putvalue(dio, curCond+2);          % sends codes to MIP based on condition type; 
%             curISI = stimDur + stimMinIti + jitterMax*rand(1,1);
            WaitSecs(interSample);
            putvalue(dio,0);
            
            %get key press
            while true % GetSecs < initTime + respDur 
                  [keyIsDown, secs, keyCodes] = KbCheck; 
                  if keyIsDown
                      keyPressTime = GetSecs;
                        faceRT = keyPressTime - stimOn; 
                        response = find(keyCodes);
                        if sum(find(response == keys))
                            break;
                        end
                  end
            end
            
            kbWait; % wait for key press
            waitSecs(.25); % delay for half a second
            
                % Quick Abort option
        if (response == keys(4))  % bails out of script if bail-out key is pressed (here: F11)
          %clear all;
          return;
        end

            
        else % if EEG == 'N'
            
                Screen('CopyWindow', fixationCross, w);            
                Screen('Flip', w); 
                WaitSecs(1);
                
            % put label screen up
            if curCond == 1
                
                Screen('CopyWindow', blackScreen, w);            
                Screen('Flip', w); 
                WaitSecs(0.75);

            elseif curCond == 2
                
                Screen('CopyWindow', whiteScreen, w);            
                Screen('Flip', w); 
                WaitSecs(0.75);

            end
            
            % put blank screen between the label and face
            curISI = 0.5 + jitterMax*rand(1,1); % stimDur + stimMinIti +
        
            Screen('CopyWindow', blankScreen, w);  
            Screen('Flip', w); 
            WaitSecs(curISI);
            
            % put face onscreen
            Screen('CopyWindow', Scratch, w);
%             
            [initTime faceOn finishTime] = Screen('Flip', w); 
%             curISI = stimDur + stimMinIti + jitterMax*rand(1,1);
            
            % put question onscreen
            Screen('CopyWindow', questionScreen, w);            
            [initTime stimOn finishTime] = Screen('Flip', w, faceOn + stimDur); 
        
            %get key press
            while true % GetSecs < initTime + respDur 
                  [keyIsDown, secs, keyCodes] = KbCheck; 
                  if keyIsDown
                      keyPressTime = GetSecs;
                        faceRT = keyPressTime - stimOn; 
                        response = find(keyCodes);
                        if sum(find(response == keys))
                            break;
                        end
                  end
            end
            
            kbWait; % wait for key press
            waitSecs(.25); % delay for half a second
            
            
        % Quick Abort option
        if (response == keys(4))  % bails out of script if bail-out key is pressed (here: F11)
          %clear all;
          return;
        end

        end  % EEG check 
        
        % Write data here
        if (trial == 1) && (block == 1)
        fprintf(dataFile, ['Subject\tBlock\tTrial\tCondition' ...
				'\tStimulusNumber\tRT\tResponse\n']);
        end
        fprintf(dataFile,['%d\t%d\t%d\t%d\t%s\t%4.0f\t%d\n'], subjectNumber, block, trial, curCond, num2str(thisface), faceRT*1000, response);
        
        WaitSecs(.5);
        
    end % trial
    
       if block*trial == numBlocks*numTrials
       endBlock = Screen(w, 'OpenOffScreenWindow', backColor, ScreenRect);
        Screen(endBlock, 'TextFont', 'Arial');
        Screen(endBlock, 'TextSize', 36);
        Screen(endBlock, 'DrawText', 'Great job!', (Center_X-150), (Center_Y-37), fixColor);
        Screen(endBlock, 'DrawText', 'You''ve finished with this part of the experiment.', (Center_X-400), (Center_Y), fixColor);
        Screen(endBlock, 'DrawText', 'Please call the experimenter.', (Center_X-350), (Center_Y+37), fixColor);
        Screen('CopyWindow', endBlock, w);
        Screen('Flip', w);
     	WaitSecs(1);
		kbWait;
       elseif (mod(trial,numTrials) == 0)   % mod is a remainder function
		endBlock = Screen(w, 'OpenOffScreenWindow', backColor, ScreenRect);
        Screen(endBlock, 'TextFont', 'Arial');
        Screen(endBlock, 'TextSize', 36);
        Screen(endBlock, 'DrawText', 'End of block. Press any key to continue.', (Center_X-350), (Center_Y-36), fixColor);
        Screen('CopyWindow', endBlock, w);
        Screen('Flip', w);
     	WaitSecs(1);
		kbWait;
       end
   
end % block 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENDING EXPERIMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if eeg == 'Y'
            FlushEvents('keyDown');
            putvalue(dio,253);
            WaitSecs(interSample);
            putvalue(dio,0);
else % eeg == 'N'
end
    
fclose('all');
Screen('CloseAll');
        
