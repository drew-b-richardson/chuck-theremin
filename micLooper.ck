Constants c;
adc => LiSa lisa => Pan2 p => dac;
<<< "enter looper" >>>;

0.5 => lisa.gain;
Std.atoi(me.arg(0)) => int numBeats;
Std.atof(me.arg(1)) => float tempo;
Std.atof(me.arg(2)) => float lag;
Std.atof(me.arg(3)) => float pan;
pan => p.pan;
c.tempo::second * c.numBeats => dur measureTime;
measureTime => lisa.duration;
1 => lisa.loop;
1 =>  lisa.record;
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
  10::ms => now;
}



