Constants c;
0 => int value;
"" => string cmd;
"" => string prevCmd;
adc => LiSa lisa =>  NRev rev => Chorus chorus => Gain g => Pan2 p =>    dac;
0.2 => chorus.modDepth;
0.5 => lisa.gain;
0.2 => rev.mix;
0.0 => chorus.mix;
0 => p.pan;

Delay delay;
rev => delay => delay => p;
0 => int isDelay;
0.0 => delay.gain;
c.tempo::second * c.numBeatsPerMeasure => delay.max => delay.delay;

<<< "enter looper" >>>;

Std.atoi(me.arg(0)) => int numBeats;
Std.atof(me.arg(1)) => float tempo;
Std.atof(me.arg(2)) => float lag;
Std.atof(me.arg(3)) => float pan;
pan => p.pan;
c.tempo::second * c.numBeats => dur measureTime;
measureTime => lisa.duration;
1 => lisa.loop;
1 =>  lisa.record;
string previousMsg;
/*<<< measureTime >>>;*/

//record for one measure - lag time
measureTime - lag::ms => now;
0 => lisa.record;

0::ms =>  lisa.playPos;
measureTime =>  lisa.loopEnd;
//wait for one full measure minus lag
/*measureTime - lag::ms => now;*/
1 =>  lisa.play;
while(true)
{
  c.event => now;
  c.event.cmd => cmd;
  c.event.value => value;

  //for all keys that require a following action:
  if(cmd == "m" || cmd == "i" || cmd == "r" || cmd == "d" || cmd == "c" || cmd == "-" || cmd == "=" || cmd == "_" || cmd == "rs")
  {
    cmd => previousMsg;
  }

  //top number keys and function keys
  else if (cmd == "n")
  {
    //change reverb
    if (previousMsg == "r")
    {
      (value - 1)/10.0 => rev.mix;
    }

    //change delay
    else if (previousMsg == "d")
    {
      (value - 1)/10.0 => delay.gain;
    }

    //change chorus
    else if (previousMsg == "c")
    {
      (value - 1)/10.0 => chorus.mix;
    }

    " " => previousMsg; //clear out previous message

  }
  10::ms => now;
}



