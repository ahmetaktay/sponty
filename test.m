% Start by removing anything you had left over in the memory:
clear all; close all;
% Set DebugLevel to 3:
Screen('Preference', 'VisualDebuglevel', 3);

% Get the params of the experiment (this also opens the display):
params = getParams;

% Show question mark to indicate that a response is needed
Screen('FillRect', params.wPtr, params.white*params.bgContrast);
%%% Save old text size
Screen(params.wPtr, 'TextFont', 'Arial');
oldTextSize = Screen('TextSize', params.wPtr, params.fontSize);
%%% Draw text centered on screen
DrawFormattedText(params.wPtr, WrapString('?', params.wrap), 'center', 'center');
%%% Display text
startResponseTime = Screen('Flip', params.wPtr);
%%% Return textsize to normal
Screen('TextSize', params.wPtr, oldTextSize);

HideCursor;

WaitSecs(5);

% Get screen back to normal
Screen('CloseAll');
ShowCursor;
