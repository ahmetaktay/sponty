dio = digitalio('nidaq','Dev1');
addline(dio,0:7,'out');
putvalue(dio,0);
