public class Loop
{
  Constants c;
  0 => int value;
  "" => string cmd;
  "" => string prevCmd;
  adc => LiSa lisa =>  NRev rev => Chorus chorus => Gain g => Pan2 p =>    dac;
  0.2 => chorus.modDepth;
  0.5 => lisa.gain;
  0.0 => rev.mix;
  0.0 => chorus.mix;
  0 => p.pan;

  Delay delay;
  rev => delay => delay => p;
  0 => int isDelay;
  0.0 => delay.gain;
  c.tempo::second * c.numBeatsPerMeasure => delay.max => delay.delay;


  Std.atoi(me.arg(0)) => int numBeats;
  Std.atof(me.arg(1)) => float tempo;
  /*Std.atof(me.arg(2)) => float lag;*/
  Std.atof(me.arg(3)) => float pan;
  pan => p.pan;
  c.tempo::second * c.numBeats => dur measureTime;
  measureTime => lisa.duration;
  1 => lisa.loop;
  1 =>  lisa.record;
  string previousMsg;
  /*<<< measureTime >>>;*/

  fun void setDelay(float value)
  {
    value => delay.gain;
  }
  fun void setReverb(float reverb)
  {
    reverb => rev.mix;
  }
  fun void setGain(float value)
  {
    value => lisa.gain;
  }
  fun void setPan(float value)
  {
    value => p.pan;
    <<< "pan", p.pan() >>>;
  }

  fun void record(int lag)
  {
    c.tempo::second * c.numBeats => dur measureTime;
    measureTime => lisa.duration;
    1 =>  lisa.record;

    //record for one measure - lag time
    measureTime - lag::ms => now;
    <<< "looper recording" >>>;
    0 => lisa.record;
    play();
  }

  fun void stopPlaying()
  {
    0 =>  lisa.play;
  }
  fun void play()
  {
    1 => lisa.loop;
    0::ms =>  lisa.playPos;
    measureTime =>  lisa.loopEnd;
    1 =>  lisa.play;
    while(true)
    {
      10::ms => now;
    }
  }
}
