InitializePsychSound;
pahandle = PsychPortAudio('Open', [], [], 0, [], 1);
tmp = transpose(sin(1:0.5:100));
stimBeep = 0.5 * tukeywin(length(tmp),10) .* tmp;
PsychPortAudio('FillBuffer', pahandle, stimBeep');
t1 = PsychPortAudio('Start', pahandle, 5, 0, 0);
PsychPortAudio('Stop', pahandle, 1);
PsychPortAudio('Close', pahandle);