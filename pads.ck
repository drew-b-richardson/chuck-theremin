Flute instr => JCRev r => dac;
[10, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100 ] @=> int notes[];
      .5 => instr.gain;
      while(true)
{
      notes[4] => instr.freq;

     0.2 => instr.noteOn;
     1::second => now;
}

