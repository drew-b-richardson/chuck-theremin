//echo parameters
Echo e1;
Echo e2;
Echo e3;
1000::ms => e1.max => e2.max => e3.max;
750::ms => e1.delay => e2.delay => e3.delay;
.50 => e1.mix => e2.mix => e3.mix;

//filter settings
BPF f;
1 => f.Q;
1000 => f.freq;

//main instrument
Wurley instr =>  Pan2 p =>  JCRev r => Gain g => dac;

SerialIO cereal;
cereal.open(2, SerialIO.B9600, SerialIO.ASCII);

[0,2,4,5,7,9,11,12] @=>  int IONIAN[];
[0,2,3,5,7,9,10,12,14,15,17,19,21,23,24] @=>  int DORIAN[];

0 =>  int C;
2 =>  int D;


0 => int value;
100 => float frequency;
0.0 => float percentage;
0.0 => float offset;
.4 => float volume;
1000 => float freq;

D =>   int key;
DORIAN   @=> int scale[];
5 => int octave;
octave * 12 + key => int transpose;
"" => string cmd;
scale[2] => instr.freq;

Machine.add( "week3-sample.ck");

while(true)
{


  cereal.onLine() => now;
  cereal.getLine() => string line;
  if(line$Object != null)
  {
    line.substring(0,1) => cmd;
    Std.atoi(line.substring(1)) => value;

    //volume - always get one of these before any note
    //NOTE - CREATES CLIPPING ON CHANGE OF VOLUME
    if (cmd == "y")
    {
      //if under sound threshold, turn off previous note for silence
      if(value < 20)
      {
        0 => instr.gain;
      }

      //otherwise change volume 
      else
      {
        (0.0 + value)/100 => volume;
        volume => instr.gain;
      }
    }


    //play pad in separate shred so will still sound when restarting main
    else if(cmd == "k")
    {
      /*if(shredId == 0)*/
      /*{*/
      /*numShreds++;*/
      /*Machine.add( "/docs/chuck/theremin/test.ck" ) => shredId;*/
      /*}*/
      /*else{*/
      /*Machine.replace(shredId, "/docs/chuck/theremin/test.ck");*/
      /*}*/
    }

    //play note
    else if(cmd == "z")
    {
      <<< value, scale[value], transpose >>>;
      Std.mtof(scale[value] + transpose) =>	frequency;
      0.3 => instr.noteOn;
    }

    //vibrato - amount is percentage of original freq
    else if(cmd == "s")
    {
      (0.0 + value)/10000*2 => percentage;
      frequency*percentage => offset;

      frequency+offset => frequency;
    }

    //filter
    else if(cmd == "v")
    {
      frequency*value/15 + 100  =>  freq;
      freq => f.freq;
    }

    frequency => instr.freq;

  }

}

