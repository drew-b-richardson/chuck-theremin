Rhodey instr => JCRev r => Echo e =>  dac;
0.3 => instr.gain;
90 => int bpm;
4.0/bpm => float minutesPerWholeNote;
5 => int octave;
Constants constants;
constants.D =>   int key;
constants.DORIAN   @=> int scale[];
octave * 12 + key => int transpose;

0 => int fadeIn;
0.6 => float noteGain;

[[5, 4],[2, 2],[6, 8],[7, 8],[1, 2],[1, 16],[3, 16],[5, 4]] @=> int notes1[][];
[[1, 1]] @=> int root[][];

fun void playSequence(int sequence[][])
{
  for(0  => int i; i < sequence.cap(); i++)
  {
    
    Math.mtof(scale[sequence[i][0] - 1 ] + transpose) => instr.freq;
    <<<scale[sequence[i][0] - 1 ] + transpose>>>; 
    instr.noteOn(noteGain);
    minutesPerWholeNote::minute/sequence[i][1] => now;
  }
}

fun void playRandom(int curScale[])
{
  /*Std.mtof(Std.rand2(4,6)*12+curScale[Std.rand2(0,curScale.cap()-1)]) => instr.freq;*/
<<<  Std.rand2(1,2)*transpose+curScale[Std.rand2(0,curScale.cap()-1)]>>>;
  Std.mtof(curScale[Std.rand2(0,curScale.cap()-1)] + transpose)*Std.rand2(1,3)  => instr.freq;
  <<< Std.ftom(instr.freq())>>>;
  instr.noteOn(noteGain);
  1::second => now;
}
while(true)
{
  /*playRandom(scale);*/
 playSequence(notes1);
}
