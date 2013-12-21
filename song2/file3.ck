Std.atoi(me.arg(0)) => int section;
StkInstrument instruments[4];
Rhodey inst0 @=> instruments[0];
Rhodey inst1 @=> instruments[1];
Rhodey inst2 @=> instruments[2];
Rhodey inst3 @=> instruments[3];

for(0 => int i; i < instruments.cap(); i++)
{
  instruments[i] => dac;
}

.1 => float instrGain;
2 => int startOctave;

Constants c;

["2|8","0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"2|7","0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"2|6","0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"2|4","0"  ,"0"  ,"0"  ,"0"  ,"0"  ] @=> string melody1a[];
["0"  ,"4|1","0"  ,"4|1","0"  ,"4|1","0"  ,"4|1","0"  ,"4|1","0"  ,"4|1","0"  ,"4|5","0"  ,"4|5","0"  ,"4|5","0"  ,"4|4","0"  ,"4|4","0"  ,"0"  ] @=> string melody1b[];
["0"  ,"0"  ,"4|3","0"  ,"4|3","0"  ,"0"  ,"0"  ,"4|3","0"  ,"4|3","0"  ,"0"  ,"0"  ,"4|1","0"  ,"4|1","0"  ,"0"  ,"0"  ,"4|6","0"  ,"4|6","0"  ] @=> string melody1c[];
["0"  ,"0"  ,"4|5","0"  ,"4|5","0"  ,"0"  ,"0"  ,"4|5","0"  ,"4|5","0"  ,"0"  ,"0"  ,"4|3","0"  ,"4|3","0"  ,"0"  ,"0"  ,"4|1","0"  ,"4|1","0"  ] @=> string melody1d[];

["2|5","2|6","2|7","3|1","3|2","3|3","2|8","0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"2|8","0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"2|8","0"  ,"0"  ,"0"  ,"0"  ,"0"  ] @=> string melody2a[];
["0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"4|1","0"  ,"4|1","0"  ,"0"  ,"0"  ,"4|1","0"  ,"4|1","0"  ,"0"  ,"0"  ,"4|1","0"  ,"4|1","0"  ] @=> string melody2b[];
["0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"4|3","0"  ,"4|3","0"  ,"0"  ,"0"  ,"4|3","0"  ,"4|3","0"  ,"0"  ,"0"  ,"4|3","0"  ,"4|3","0"  ] @=> string melody2c[];
["0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"0"  ,"4|5","0"  ,"4|5","0"  ,"0"  ,"0"  ,"4|5","0"  ,"4|5","0"  ,"0"  ,"0"  ,"4|5","0"  ,"4|5","0"  ] @=> string melody2d[];


0 => int counter; //this increments forever
0 => int beat; //this increments and repeats after numBeats
0 => int measure; //keep track of # of measures

while(true)
{
  updateBeat();
  if (section == 2)
  {
    c.setKeyAndScale(c.f, c.mixolydian);
    c.populateScale();
    playInstr(melody2a[beat],0);
    playInstr(melody2b[beat],1);
    playInstr(melody2c[beat],2);
    playInstr(melody2d[beat],3);
  }
  else
  {
    c.setKeyAndScale(c.g, c.aeolian);
    c.populateScale();
    playInstr(melody1a[beat],0);
    playInstr(melody1b[beat],1);
    playInstr(melody1c[beat],2);
    playInstr(melody1d[beat],3);
  }
  progress();

}

fun void playInstr(string note, int instr)
{
  if (note != "0"  )
  { 
    Std.atoi(note.substring(0,1))=> int startOctave;
    Std.atoi(note.substring(2)) => int stepNumber;
    c.getFreq(stepNumber, startOctave) => instruments[instr].freq;
    instrGain => instruments[instr].noteOn;
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

