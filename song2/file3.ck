Std.atoi(me.arg(0)) => int section;
NRev r;
0.1 => r.mix;
Rhodey instr => r => dac;
Rhodey instr1 => r => dac;
Rhodey instr2 =>r =>  dac.left;
Rhodey instr3 => r => dac.right;

.1 => float instrGain;
2 => int startOctave;
4 => int octaveRange;

Constants constants;
int scale[constants.scale.cap()*octaveRange];
startOctave * 12 + constants.key => int transpose;
populateScale(); 

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
    setKey(constants.f, constants.mixolydian);
    if (melodyb[beat]> 0)
    { 
      getFreq(melodyb[beat]) => instr.freq;
      instrGain => instr.noteOn;
    }
    if (melodyb1[beat]> 0)
    { 
      getFreq(melodyb1[beat]) => instr1.freq;
      instrGain => instr1.noteOn;
    }
    if (melodyb2[beat]> 0)
    { 
      getFreq(melodyb2[beat]) => instr2.freq;
      instrGain => instr2.noteOn;
    }
    if (melodyb3[beat]> 0)
    { 
      getFreq(melodyb3[beat]) => instr3.freq;
      instrGain => instr3.noteOn;
    }

  }
  else
  {
    setKey(constants.g, constants.aeolian);
    if (melody[beat]> 0)
    { 
      getFreq(melody[beat]) => instr.freq;
      instrGain => instr.noteOn;
    }
    if (melody1[beat]> 0)
    { 
      getFreq(melody1[beat]) => instr1.freq;
      instrGain => instr1.noteOn;
    }
    if (melody2[beat]> 0)
    { 
      getFreq(melody2[beat]) => instr2.freq;
      instrGain => instr2.noteOn;
    }
    if (melody3[beat]> 0)
    { 
      getFreq(melody3[beat]) => instr3.freq;
      instrGain => instr3.noteOn;
    }


  }
  progress();

  instrGain => instr1.noteOff;
  instrGain => instr2.noteOff;
  instrGain => instr3.noteOff;

}
fun float getFreq(int noteNumber)
{
  <<< "noteNum", noteNumber >>>;
  <<< "transpose", transpose >>>;
  Std.mtof(scale[noteNumber - 1] + transpose) => float freq;
  return freq;
}

fun int playStkNote(int scaleNum, StkInstrument instr)
{
  if (scaleNum > 0)
  {
    Std.mtof(scaleNum - 1 + transpose) =>	instr.freq;
    instrGain => instr.noteOn;
    10::ms => now;
    instrGain => instr.noteOff;

  }
}

//populate notes to be played based on # octabes and which scale is chosen in constants
fun void populateScale()
{
  for(0 => int i; i < constants.scale.cap(); i++)
  {
    for(0 => int j; j < octaveRange - 1; j++)
    {
      constants.scale[i] + j*12 => scale[i + (constants.scale.cap()-1)*j];
    }
  }
}

fun void updateBeat()
{
  counter % constants.numBeats => beat;  
}

fun void progress()
{
  counter++;
  if(beat == constants.numBeats -1)
    measure++;

  constants.tempo::second => now; 
}

fun void setKey(int key, int scale[])
{
    key =>   constants.key;
    scale @=> constants.scale; 
    startOctave * 12 + constants.key => transpose;
    populateScale(); 
}
