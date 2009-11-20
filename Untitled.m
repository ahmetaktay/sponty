InitializePsychSound;
pahandle = PsychPortAudio('Open', [], [], 0, [], 1);
stimBeep = 0.5 * tukeywin(199,10) .* transpose(sin(1:0.5:100));
PsychPortAudio('FillBuffer', pahandle, stimBeep');
t1 = PsychPortAudio('Start', pahandle, 0, 0, 1);
PsychPortAudio('Stop', pahandle);
PsychPortAudio('Close', pahandle);
