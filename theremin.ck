//echo parameters
Echo e1;
Echo e2;
Echo e3;
1000::ms => e1.max => e2.max => e3.max;
750::ms => e1.delay => e2.delay => e3.delay;
.50 => e1.mix => e2.mix => e3.mix;

//sampling
LiSa lisa;
5::second => lisa.duration;
false => int isRecording;
time startRecTime;
time endRecTime;
dur recDur;


//filter settings
BPF f;
1 => f.Q;
1000 => f.freq;

//have all sources input into single Gain to control volume
1 => int numShreds;
Gain g => dac;

//pad parameters
Flute pad1 => g;
0 => int padId;

//main instrument
Clarinet instr =>  g;
JCRev r;

SerialIO cereal;
cereal.open(2, SerialIO.B9600, SerialIO.ASCII);

0 => int value;
0 => float frequency;
0.0 => float percentage;
0.0 => float offset;
.4 => float volume;
1000 => float freq;
[10, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100 ] @=> int notes[];
"" => string cmd;
notes[2] => instr.freq;

fun void play(LiSa playback, dur recDur)
{
  0::ms => playback.playPos;
  1 => playback.loop;
  recDur => playback.loopEnd;
  1 => playback.play;
}

while(true)
{

  1.0/numShreds => g.gain; 
  <<< "numShreds = " + numShreds >>>;

  //use this to create an always on sound even during restarts.  must be before the cereal.online => now
  /*1 => instr.noteOn;*/

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
        <<< volume >>>;
        volume => instr.gain;
      }
    }


    //play pad in separate shred so will still sound when restarting main
    else if(cmd == "k")
    {
      if(padId == 0)
      {
        numShreds++;
        Machine.add( "/docs/chuck/theremin/pads.ck" ) => padId;
      }
      else{
        Machine.replace(padId, "/docs/chuck/theremin/pads.ck");
      }
    }

    //play note
    else if(cmd == "z")
    {
      notes[value] =>	frequency;
      1 => instr.noteOn;
    }

    //play pad
    else if(cmd == "c")
    {
      if(!isRecording)
      {
        <<< "start recording" >>>;
        true => isRecording;
        instr => lisa => g;
        now => startRecTime;
        1 => lisa.record;
      }
      else
      {
        <<< "stop recording" >>>;
        false => isRecording;
        0 => lisa.record;
        now => endRecTime;
        endRecTime - startRecTime => recDur;
        numShreds++;
        spork ~ play(lisa, recDur);
      }
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
