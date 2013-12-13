Std.atoi(me.arg(0)) => int numBeats;
Std.atoi(me.arg(1)) => int tempo;
Std.atof(me.arg(2)) => float pan;

Gain g => Pan2 p => dac;
SqrOsc o => g;
pan => p.pan;
0.2 => o.gain;
4 => int numSounds;
1.0/numSounds => g.gain;
0 => int playRandomMelody;
0 => int currentMelody;

Constants constants;
constants.d =>   int key;
constants.dorian @=> int scaleBase[];
2 => int startOctave;
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

[0, 0, 0, 1, 2, 3, 4, 5, 6, 7,8, 9, 10, 11, 12, 13] @=> int melodyNotes[];
[1, 0, 0, 1, 1, 1, 1, 1,1, 1, 1, 1, 1, 1, 1, 1 ] @=> int melody[];
0 => int counter;
0 => int measure;
0 => float melodyFreq;
200 => int lag;
0 => int baseNote;

1 => int play;

while(play)
{
  counter % numBeats => int beat;  
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
  counter++;
  if(beat == melody.cap() -1)
    measure++;

  tempo::ms => now; 
}
