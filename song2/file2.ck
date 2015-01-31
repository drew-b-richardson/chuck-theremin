Std.atoi(me.arg(0)) => int section;

TriOsc osc => ADSR env =>  dac;
env.set(0.01 :: second, 0.05 :: second, 0.3,  0.7 :: second);

.2 => osc.gain;
2 => int startOctave;

Constants c;
c.setKeyAndScale(c.g, c.aeolian);
c.populateScale();


["2|8","0","0","0","0","0","2|7","0","0","0","0","0","2|6","0","0","0","0","0","0","0","0","0","0","0"] @=> string melody1[];
["2|5","0","0","0","0","0","2|1","0","0","0","0","0","2|2","0","0","0","0","0","2|3","0","0","0","0","0"] @=> string melody2[];

0 => int counter; //this increments forever
0 => int beat; //this increments and repeats after numBeats
0 => int measure; //keep track of # of measures


while(true)
{
  updateBeat();
  if (section == 2)
  {
    if (melody2[beat] != "0")
    {
      c.setKeyAndScale(c.f, c.mixolydian);
      c.populateScale();
      playOsc(melody2[beat]);
    }
  }
  else
  {
    if (melody1[beat] != "0")
    {
      c.setKeyAndScale(c.g, c.aeolian);
      c.populateScale();
      playOsc(melody1[beat]);
    }
  }
  progress();
  1 => env.keyOff;
}

fun void playOsc(string note)
{
  if (note != "0"  )
  { 
    Std.atoi(note.substring(0,1))=> int startOctave;
    Std.atoi(note.substring(2)) => int stepNumber;
    c.getFreq(stepNumber, startOctave) => osc.freq;
    1 => env.keyOn;
  }
}


fun void updateBeat()
{
  counter % c.numBeats => beat;  
}

fun void progress()
{
  counter++;
  if(beat == c.numBeats -1)
    measure++;

  c.tempo::second => now; 
}

