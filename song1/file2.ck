SndBuf fx => dac;
"/docs/chuck/theremin/audio/stereo_fx_01.wav" =>  fx.read;
0 => fx.pos;
5::second => now;

