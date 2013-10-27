//echo parameters
Echo e1;
Echo e2;
Echo e3;
1000::ms => e1.max => e2.max => e3.max;
750::ms => e1.delay => e2.delay => e3.delay;
.50 => e1.mix => e2.mix => e3.mix;

//pad parameters
Flute pad1;
pad1 =>dac;
0.5 => pad1.gain;

//main instrument
TubeBell instr;
JCRev r;
BPF f;
Gain g;
instr =>r => e3 => f => g => dac;
0.5 => instr.gain;
0.7 => g.gain;

//sampling
LiSa lisa;
1::second => lisa.duration;
false => int isRecording;

//filter settings
1 => f.Q;
1000 => f.freq;

220.0 => instr.freq;
1 => instr.gain;
.8 => r.gain;
.2 => r.mix;

SerialIO cereal;
cereal.open(2, SerialIO.B9600, SerialIO.ASCII);

0 => int value;
500 => float frequency;
0.0 => float percentage;
0.0 => float offset;
.4 => float volume;
1000 => float freq;
[10, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100 ] @=> int notes[];

"" => string cmd;



fun void play(StkInstrument pad, float vol, int i )
{
  //0 => pad1.gain;
  notes[i] => pad1.freq;
  0.2 => pad1.noteOn;


}
 fun void test()
    {
      <<< "new shred" >>>;
      SinOsc pad => dac;
      .5 => pad1.gain;
      while(true)
      {
      500 => pad1.freq;
      1::second => now;
      }

      <<< "end shred" >>>;
    }


fun void play(LiSa playback)
{

  //1::second => playback.duration;
  while(true)
  {
    1 => playback.play;

    5::second => now;

    0 => playback.play;
  }
}


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


    //play drum
    else if(cmd == "k")
    {
      <<< "knock" >>>;
      notes[2]*2 =>	frequency;
      0.5 => instr.noteOn;
    }

    //play note
    else if(cmd == "z")
    {

      notes[value]*2 =>	frequency;
      0.8 => instr.noteOn;
    }

    //play pad
    else if(cmd == "c")
    {
      if(!isRecording)
      {
        <<< "start recording" >>>;
        true => isRecording;
        instr => r => lisa => g =>  dac;
        1 => lisa.record;

        //hang out 
        /*1::second => now;*/
        /*0 => lisa.record;*/
        /*spork ~ play(lisa);*/
        /*500::ms => now;*/
        /*600 => sin.freq;*/
        /*500::ms => now;*/
      }
      else
      {
        <<< "stop recording" >>>;
        false => isRecording;
        instr =>r  => f => g=> dac;
        0.5 => g.gain;

        //stop recording 
        0 => lisa.record;
        spork ~ play(lisa);
      }
//Machine.add( "/docs/chuck/pads.ck" ) => int id;

     // play(pad, volume, value);
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
      <<< freq >>>;
      freq => f.freq;
    }

    frequency => instr.freq;

  }
}
