Flute t => NRev r =>Pan2 p1=>   dac;

TriOsc bass => ADSR env =>  dac;
env.set(0.01 :: second, 0.05 :: second, 0.8, .7 :: second);

.2 => t.gain;
.2 => bass.gain;
-.9 => p1.pan;
0.7 => float instrGain;

t => Delay delay =>  NRev r2 =>Pan2 p2 =>dac;
(.75 * 2)::second => delay.max => delay.delay;
.9 => p2.pan;
0.6 => delay.gain;

0.08 => r.mix;
0.08 => r2.mix;

//step patterns for the 3 modes to be used
[0,1,3,5,7,8,10,12] @=>  int phrygian[];
[0,2,4,6,7,9,11,12] @=>  int lydian[];
[0,2,4,5,7,9,10,12] @=>  int mixolydian[];

//keys to be used with each mode to ensure only eb phrygian notes are used throughout, but with different root
3 =>  int eb;
4 =>  int e;
6 =>  int gb;

6 => int octave;
eb => int key;
phrygian @=> int scale[];


[8, 7, 6, 5, 3, 4, 5,0, 0, 0, 0, 0] @=> int melody1[];
[1, 0, 0, 3, 0, 0, 5,0, 0, 8, 0, 0] @=> int harmony1[];

[6, 5, 4, 2, 0, 0, 6,5, 6, 7, 0, 0] @=> int melody2[];
[2, 0, 0, 6, 0, 0, 1,0, 0, 5, 0, 0] @=> int harmony2[];

[1] @=> int melodyEnd[];
[1] @=> int harmonyEnd[];


//this forces loops to stop after 30 seconds exactly
now + 30::second => time finishTime;


eb => key;
phrygian @=> scale;
playSection(melody1, harmony1);
playSection(melody1, harmony1);
playSection(melody2, harmony2);
playSection(melody2, harmony2);

e => key;
lydian @=> scale;
playSection(melody1, harmony1);
playSection(melody1, harmony1);
playSection(melody2, harmony2);
playSection(melody2, harmony2);

gb => key;
mixolydian @=> scale;
playSection(melody1, harmony1);

Std.mtof( scale[0] + octave*12 + key ) => float frequency;
frequency => t.freq;
Std.mtof( scale[0] +2*12 + key ) => frequency;
frequency => bass.freq;
finishTime - now => dur timeLeft;
timeLeft => now;

fun void playSection(int melodyNotes[], int harmonyNotes[])
{
  for(0 => int i; i < melodyNotes.cap() ; i++)
  {
    //since this is in 3/4, every 3rd beat should be louder
    if (i%3 == 0)
    {
      0.8 => instrGain;
    }
    else
    {
      0.5 => instrGain;
    }

    playNote(melodyNotes[i], "melody"); 
    playNote(harmonyNotes[i], "harmony"); 

    Math.random2f(-0.05, 0.05) => float humanization;
    ((.75 + humanization )/3.0)::second => now;
    1 => env.keyOff;
  }
}


fun void playNote(int note, string part)
{
  
  //if anything passed in other than 0, set to new frequency
  if(note > 0)
  {
    if ("melody" == part)
    {
      Std.mtof( scale[note - 1] + octave*12 + key ) => float frequency;
      Math.random2f(0.1, 1) => t.noteOn;
      frequency => t.freq;
    }
    else if("harmony" == part)
    {
      Std.mtof( scale[note - 1] +2*12 + key ) => float frequency;
      frequency => bass.freq;
      1 => env.keyOn;
    }
  }

}




