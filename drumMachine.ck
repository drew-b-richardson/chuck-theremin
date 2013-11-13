Std.atoi(me.arg(0)) => int numBeats;
Std.atoi(me.arg(1)) => int tempo;
Std.atof(me.arg(2)) => float pan;

Gain g => Pan2 p => dac;
TriOsc o => g;
pan => p.pan;
1 => o.gain;
4 => int numSounds;
1.0/numSounds => g.gain;
0 => int playRandomMelody;
0 => int currentMelody;

Constants constants;
constants.d =>   int key;
constants.ionian @=> int scaleBase[];
5 => int startOctave;
4 => int octaveRange;
int scale[scaleBase.cap()*octaveRange];
startOctave * 12 + key => int transpose;
//increase scale size
for(0 => int i; i < scaleBase.cap(); i++)
{
  for(0 => int j; j < octaveRange - 1; j++)
  {
  scaleBase[i] + j*12 => scale[i + (scaleBase.cap()-1)*j];
  }
}


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


[0, 0, 0, 1, 2, 3, 4, 5, 6, 7,8, 9, 10, 11, 12, 13] @=> int melodyNotes[];
[1, 0, 0, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1, 1, 1 ] @=> int melody[];
[1, 0, 0, 0, 1, 0, 0, 0,1, 0, 1, 0, 1, 0, 1, 0 ] @=> int kicks[];
[0, 0, 1, 0, 0, 0, 1, 0,0, 0, 1, 0, 0, 0, 1, 0 ] @=> int snares[];
[0, 0, 0, 0, 0, 0, 0, 1,1, 0, 1, 0, 1, 0, 1, 0 ] @=> int fxs[];
[0, 0, 0, 0, 0, 0, 0, 0,0, 0, 0, 1, 0, 0, 0, 0 ] @=> int reverses[];

0 => int counter;
0 => int measure;
0 => float melodyFreq;
200 => int lag;
0 => int baseNote;

while(true)
{
  counter % numBeats => int beat;  
  /*<<< measure, beat >>>;*/

  //if first beat, mark new measure, play root in melody, play louder hihat
  //play random hihat sound every beat.  Louder if first beat
  Math.random2(0, hihatFiles.cap() - 1) => int whichHiHat ;
  hihatFiles[whichHiHat] => hihat.read; 
  0 => hihat.pos;

  //other instruments only play if they have a 1 in the array for the matching beat
  if (melody[beat])
  {
    if(playRandomMelody)
    {
      //start measures on root
      if(beat == 0 )
      {
        Std.mtof(scale[0] + transpose) => o.freq;
      }
      else
      {
        //if previous note was chord tone, chose any note in scale, otherwise, choose chord tone
        if(baseNote == 0 || baseNote == 2 || baseNote == 4)
          scale[Math.random2(0, scale.cap() -8)]  => baseNote ;
        else
          scale[Math.random2(0, 2)*2]=> baseNote;
        Std.mtof(baseNote + transpose) => o.freq;
      }
    }
    else
    {
      Std.mtof(scale[melodyNotes[beat]] + transpose) => o.freq;
    }
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
  if(beat == melody.cap() -1)
    measure++;

  tempo::ms => now; 

}

