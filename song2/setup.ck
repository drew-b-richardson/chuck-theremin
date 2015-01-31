
//set initial key and scale values
Constants c;
/*c.setKeyAndScale(c.g, c.aeolian);*/
c.setKeyAndScale(c.a, c.minpent);

// basic pattern is 4 measures of 6/8 
240.0 => c.bpm;
4 => c.numMeasures;
6 => c.numBeatsPerMeasure;
8 => c.baseBeat;
c.setTempo();
<<< "tempo", c.tempo >>>;

0 => int counter; //this increments forever
0 => int beat; //this increments and repeats after numBeats
0 => int measure; //keep track of # of measures
fun void updateBeat()
{
  counter % c.numBeats => beat;  
  <<< beat >>>;
}

fun void progress()
{
  counter++;
  if(beat == c.numBeats -1)
  {
    measure++;
    <<< "----------measure---------" >>>;
  }

  c.tempo::second => now; 
}

while(false)
{
  updateBeat();
  progress();
  
}
