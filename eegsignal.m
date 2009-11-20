function eegsignal(dio, interSample, code)
    putvalue(dio, code);
    WaitSecs(interSample);
    putvalue(dio, 0)
