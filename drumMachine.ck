Gain g => dac;
SndBuf kick => g;
me.dir() + "audio/kick_05.wav" =>  kick.read;
kick.samples() => kick.pos; 

SndBuf snare => g;
me.dir() + "audio/snare_01.wav" =>  snare.read;
snare.samples() => snare.pos; 

SndBuf fx => g;
me.dir() + "audio/stereo_fx_03.wav" =>  fx.read;
fx.samples() => fx.pos; 
0.3 => fx.gain;


SndBuf reverse => g;
me.dir() + "audio/hihat_03.wav" =>  reverse.read;
0 => reverse.pos; 
-1 => reverse.rate;

SndBuf hihat => g;
[me.dir() + "audio/hihat_01.wav",me.dir() + "audio/hihat_02.wav",me.dir() + "audio/hihat_03.wav",me.dir() + "audio/hihat_04.wav"]   @=>  string hihatFiles[];

[50, 52, 53, 55, 57, 59, 60, 62] @=> int notes[];
SinOsc o => g;
1 => o.gain;

4 => int numSounds;

1.0/numSounds => g.gain;

/*me.dir() + "audio/hihat_01.wav" =>  hihat.read;*/
/*hihat.samples() => hihat.pos; */

[1, 0, 0, 0, 0, 0, 1, 0,1, 0, 1, 0, 1, 0, 1, 0 ] @=> int melody[];
[1, 0, 0, 0, 1, 0, 0, 0,1, 0, 1, 0, 1, 0, 1, 0 ] @=> int kicks[];
[0, 0, 1, 0, 0, 0, 1, 0,0, 0, 1, 0, 0, 0, 1, 0 ] @=> int snares[];
[0, 0, 0, 0, 0, 0, 0, 1,1, 0, 1, 0, 1, 0, 1, 0 ] @=> int fxs[];
[0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 1, 0, 0, 0, 0 ] @=> int reverses[];

0 => int counter;
0 => int measure;
0 => float melodyFreq;
200 => int lag;

.25 => float tempo;
while(true)
{

  counter % melody.cap() => int beat;  //8 beats per measure
  <<< measure, beat >>>;


  //if first beat, mark new measure, play root in melody, play louder hihat
  if(beat == 0)
  {
    Std.mtof(notes[0]) => melodyFreq;
    .6 => hihat.gain;
  }
  else
  {
    Std.mtof(notes[Math.random2(0, notes.cap() -1)]) => melodyFreq;
    .2 => hihat.gain;
  }

  if((measure == 1 || measure == 2 || measure == 3)&& beat==0)
  {
    Machine.add( "simpleMicLooper.ck:" + melody.cap() + ":" + tempo + ":" + lag );
  }


  //play random hihat sound every beat.  Louder if first beat
  Math.random2(0, hihatFiles.cap() - 1) => int whichHiHat ;
  hihatFiles[whichHiHat] => hihat.read; 
  0 => hihat.pos;

  //other instruments only play if they have a 1 in the array for the matching beat
  if (melody[beat])
  {
    melodyFreq => o.freq;
  }

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
  if(measure == 0 && beat==15)
  {
    <<< "here" >>>;
    lag::ms => now;
    Machine.add( "simpleMicLooper.ck:" + melody.cap() + ":" + tempo );
    tempo::second- lag::ms => now; 
  }
  else
  {
    tempo::second => now; 
  }
  if(beat == melody.cap() -1)
    measure++;

}

