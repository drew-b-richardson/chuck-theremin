Std.atoi(me.arg(0)) => int section;
NRev r;
0.1 => r.mix;
Rhodey instr => r => dac;
Rhodey instr1 => r => dac;
Rhodey instr2 =>r =>  dac.left;
Rhodey instr3 => r => dac.right;

.1 => float instrGain;
2 => int startOctave;

Constants c;

[8,0,0,0,0,0,7,0,0,0,0,0,6,0,0,0,0,0,4,0,0,0,0,0] @=> int melody[];
[0,15,0,15,0,15,0,15,0,15,0,15,0,12,0,12,0,12,0,11,0,11,0,0] @=> int melody1[];
[0,0,17,0,17,0,0,0,17,0,17,0,0,0,15,0,15,0,0,0,13,0,13,0] @=> int melody2[];
[0,0,19,0,19,0,0,0,19,0,19,0,0,0,17,0,17,0,0,0,15,0,15,0] @=> int melody3[];

[5,6,7,8,9,10,8,0,0,0,0,0,8,0,0,0,0,0,8,0,0,0,0,0] @=> int melodyb[];
[0,0,0,0,0,0,0,0,15,0,15,0,0,0,15,0,15,0,0,0,15,0,15,0] @=> int melodyb1[];
[0,0,0,0,0,0,0,0,17,0,17,0,0,0,17,0,17,0,0,0,17,0,17,0] @=> int melodyb2[];
[0,0,0,0,0,0,0,0,19,0,19,0,0,0,19,0,19,0,0,0,19,0,19,0] @=> int melodyb3[];


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
    if (melodyb[beat]> 0)
    { 
      c.getFreq(melodyb[beat], startOctave) => instr.freq;
      instrGain => instr.noteOn;
    }
    if (melodyb1[beat]> 0)
    { 
      c.getFreq(melodyb1[beat], startOctave) => instr1.freq;
      instrGain => instr1.noteOn;
    }
    if (melodyb2[beat]> 0)
    { 
      c.getFreq(melodyb2[beat], startOctave) => instr2.freq;
      instrGain => instr2.noteOn;
    }
    if (melodyb3[beat]> 0)
    { 
      c.getFreq(melodyb3[beat], startOctave) => instr3.freq;
      instrGain => instr3.noteOn;
    }

  }
  else
  {
    c.setKeyAndScale(c.g, c.aeolian);
    c.populateScale();
    if (melody[beat]> 0)
    { 
      c.getFreq(melody[beat], startOctave) => instr.freq;
      instrGain => instr.noteOn;
    }
    if (melody1[beat]> 0)
    { 
      c.getFreq(melody1[beat], startOctave) => instr1.freq;
      instrGain => instr1.noteOn;
    }
    if (melody2[beat]> 0)
    { 
      c.getFreq(melody2[beat], startOctave) => instr2.freq;
      instrGain => instr2.noteOn;
    }
    if (melody3[beat]> 0)
    { 
      c.getFreq(melody3[beat], startOctave) => instr3.freq;
      instrGain => instr3.noteOn;
    }


  }
  progress();

  instrGain => instr1.noteOff;
  instrGain => instr2.noteOff;
  instrGain => instr3.noteOff;

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

