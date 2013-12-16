Std.atoi(me.arg(0)) => int section;
JCRev r;
0.1 => r.mix;
ModalBar instr1 => r => dac;
ModalBar instr2 =>r =>  dac.left;
ModalBar instr3 => r => dac.right;

.4 => float instrGain;
5 => int startOctave;
2 => int octaveRange;

Constants constants;
int scale[constants.scale.cap()*octaveRange];
startOctave * 12 + constants.key => int transpose;
populateScale(); 

/*[8,0,0,0,0,0,7,0,0,0,0,0,6,0,0,0,0,0,6,0,0,0,0,0] @=> int melody[];*/
[0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,0] @=> int melody1[];
[0,0,3,0,3,0,0,0,3,0,3,0,0,0,3,0,3,0,0,0,3,0,3,0] @=> int melody2[];
[0,0,5,0,5,0,0,0,5,0,5,0,0,0,5,0,5,0,0,0,5,0,5,0] @=> int melody3a[];

[0,0,7,0,7,0,0,0,7,0,7,0,0,0,7,0,7,0,0,0,7,0,7,0] @=> int melody3b[];


0 => int counter; //this increments forever
0 => int beat; //this increments and repeats after numBeats
0 => int measure; //keep track of # of measures


while(true)
{
  updateBeat();

  playStkNote(melody1[beat], instr1);
  playStkNote(melody2[beat], instr2);

  if(section == 2)
    playStkNote(melody3b[beat], instr3);
  else
    playStkNote(melody3a[beat], instr3);

  progress();
}

fun int playStkNote(int scaleNum, StkInstrument instr)
{
    if (scaleNum > 0)
    {
      Std.mtof(scaleNum - 1 + transpose) =>	instr.freq;
      instrGain => instr.noteOn;
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

