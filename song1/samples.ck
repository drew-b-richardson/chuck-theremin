public class Samples
{
  "/git/chuck-theremin/" => string PATH;

  Gain g => Pan2 p => dac;

  SndBuf one;
  PATH + "audio/AbdicationAddress.wav" =>  one.read;
  0.5 => one.gain;

  SndBuf two;
  PATH + "audio/DemConvention.wav" =>  two.read;
  0.1 => two.gain;

  SndBuf bufs[2];
  one @=> bufs[0];
  two @=> bufs[1];
  for(0 => int i; i < bufs.cap(); i++)
  {
    bufs[i] => g;
    bufs[i].samples() => bufs[i].pos;
  }

  fun void playSample(int sample)
  {
    0 => bufs[sample].pos;
  }
}
