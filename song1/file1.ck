"/git/chuck-theremin/" => string PATH;
SndBuf fx => dac;
PATH + "audio/stereo_fx_02.wav" =>  fx.read;
// Play reversed fx
fx.samples() /2 => fx.pos ;
-1 => fx.rate;
6::second => now;
