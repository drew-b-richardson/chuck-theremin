// Coursera-Chuck-Assignment02-Lodz-2013-11-07
<<<"Coursera-Chuck-Assignment02-Lodz-2013-11-07">>>;

// Notes durations
.25::second => dur quarter;
2::quarter => dur half;
4::quarter => dur whole;
.5::quarter => dur eight;
.25::quarter => dur sixteenth;

// notes values
[50, 52, 53, 55, 57, 59, 60, 62] @=> int noteNumbers[];
// octaves (-24 - two octaves lower, -12 - octave lower, 0 - no change, 12 - octave higher)
[-24,-12,0,12] @=> int octave[];

// Array of strings for wav samples
[me.dir() + "audio/kick_01.wav", 
me.dir() + "audio/snare_01.wav", 
me.dir() + "audio/hihat_01.wav", 
me.dir() + "audio/stereo_fx_02.wav"
] @=> string paths[];

// Sound chain
Gain master => dac;
SndBuf kick => master;
SndBuf snare => master;
SndBuf hihat => master;
SndBuf2 fx => master;
TriOsc bass => master;
SinOsc lead => dac.left;
SinOsc lead2 => dac.right;

// initial gain values
0 => bass.gain;
0 => lead.gain;
0 => lead2.gain;
0.2 => kick.gain;
0.5 => snare.gain;
0.2 => hihat.gain;
0.5 => fx.gain;

// read wav files
paths[0] => kick.read;
paths[1] => snare.read;
paths[2] => hihat.read;
paths[3] => fx.read;

// set positions
kick.samples() => kick.pos;
snare.samples() => snare.pos;
hihat.samples() => hihat.pos;
fx.samples() => fx.pos;

// Play reversed fx
fx.samples() /2 => fx.pos ;
-1 => fx.rate;
6000::ms => now;

// set gain
0.5 => bass.gain;
0.2 => lead.gain;
0.1 => lead2.gain;
0 => fx.gain;


// Play beat
0 => int counter;
while(counter < 4*24){
    
    if(counter%4 == 0){
        0 => kick.pos;
        0 => bass.gain;
        Std.mtof(noteNumbers[Math.random2(0,7)]+octave[3]) => lead2.freq;
    }
    
    if(counter%4 == 2){
        0 => snare.pos;
        0 => bass.gain;
    }
    
    if((counter%4 == 1) || (counter%4 == 3)){
        0.3 => bass.gain;
    }
    
    if(counter%4 == 3){
        0 => hihat.pos;
        1.2 => hihat.rate;
    } else {
        0 => hihat.pos;
        1.0 => hihat.rate;
    }
    
    Std.mtof(noteNumbers[counter%8]+octave[1]) => bass.freq;
    Std.mtof(noteNumbers[Math.random2(0,7)]+octave[3]) => lead.freq;
    
    quarter => now;
    counter++;
}

