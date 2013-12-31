public class Samples
{

  SndBuf one;
  me.dir() + "/docs/chuck/theremin/audio/AbdicationAddress.wav" =>  one.read;
  0.5 => one.gain;

  SndBuf two;
  me.dir() + "/docs/chuck/theremin/audio/DemConvention.wav" =>  two.read;
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
