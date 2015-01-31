Std.atoi(me.arg(0)) => int numBeats;
Std.atof(me.arg(1)) => float tempo;
Std.atof(me.arg(2)) => float pan;
<<< "tempo", tempo >>>;
Gain g => Pan2 p => dac;
pan => p.pan;
4 => int numSounds;
1.0/numSounds => g.gain;


SndBuf kick => g;
me.dir() + "/docs/chuck/theremin/audio/kick_05.wav" =>  kick.read;
kick.samples() => kick.pos; 

SndBuf snare => g;
me.dir() + "/docs/chuck/theremin/audio/snare_01.wav" =>  snare.read;
snare.samples() => snare.pos; 

SndBuf fx => g;
me.dir() + "/docs/chuck/theremin/audio/stereo_fx_03.wav" =>  fx.read;
fx.samples() => fx.pos; 
0.3 => fx.gain;

SndBuf reverse => g;
me.dir() + "/docs/chuck/theremin/audio/hihat_03.wav" =>  reverse.read;
0 => reverse.pos; 
-1 => reverse.rate;

SndBuf hihat => g;
[me.dir(-1) + "/docs/chuck/theremin/audio/hihat_01.wav",me.dir(-1) + "/docs/chuck/theremin/audio/hihat_02.wav",me.dir() + "/docs/chuck/theremin/audio/hihat_03.wav",me.dir() + "/docs/chuck/theremin/audio/hihat_04.wav"]   @=>  string hihatFiles[];


[1, 0, 0, 0, 1, 0, 0, 0,1, 0, 1, 0, 1, 0, 1, 0 ] @=> int kicks[];
[0, 0, 1, 0, 0, 0, 1, 0,0, 0, 1, 0, 0, 0, 1, 0 ] @=> int snares[];
[0, 0, 0, 0, 0, 0, 0, 1,1, 0, 1, 0, 1, 0, 1, 0 ] @=> int fxs[];
[0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 1, 0, 0, 0, 0 ] @=> int reverses[];

0 => int counter;
0 => int measure;
0 => float melodyFreq;
200 => int lag;
0 => int baseNote;

1 => int play;

while(play)
{
  counter % numBeats => int beat;  
  /*<<< measure, beat >>>;*/

  //if first beat, mark new measure, play root in melody, play louder hihat
  //play random hihat sound every beat.  Louder if first beat
  Math.random2(0, hihatFiles.cap() - 1) => int whichHiHat ;
  hihatFiles[whichHiHat] => hihat.read; 
  0 => hihat.pos;


  if (kicks[beat])
  {
    0  =>kick.pos ;
  }
  if (snares[beat])
  {
    0  =>snare.pos ;
  }
  if (measure%2 == 0 && beat < 5)
  {
    0  =>fx.pos ;
  }

  if (reverses[beat])
  {
    reverse.samples() => reverse.pos ;
  }

  counter++;
  if(beat == kicks.cap() -1)
    measure++;

  tempo::second => now; 

}

