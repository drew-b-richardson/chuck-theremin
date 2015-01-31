Std.atoi(me.arg(0)) => int section;

Gain g =>  dac;
0.3 => g.gain;

Constants c;

SndBuf kick;
me.dir() + "/docs/chuck/theremin/audio/kick_05.wav" =>  kick.read;
0.5 => kick.gain;

SndBuf hihat;
me.dir() + "/docs/chuck/theremin/audio/hihat_01.wav" =>  hihat.read;
0.1 => hihat.gain;

SndBuf bufs[2];
kick @=> bufs[0];
hihat @=> bufs[1];
for(0 => int i; i < bufs.cap(); i++)
{
  bufs[i] => g;
  bufs[i].samples() => bufs[i].pos; 
}

[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0] @=> int kicks1[];
[0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0] @=> int hihats1[];

[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0] @=> int kicks2[];

0 => int counter; //this increments forever
0 => int beat; //this increments and repeats after numBeats
0 => int measure; //keep track of # of measures

while(true)
{
  updateBeat();

  playBuffer(hihats1[beat], 1);

  if (section == 2)
  {
    playBuffer(kicks2[beat], 0);
  }
  else
  {
    playBuffer(kicks1[beat], 0);
  }

  progress();
}

fun void playBuffer(int doPlay, int bufNumber)
{
  if (doPlay)
  {
    0  => bufs[bufNumber].pos;
  }

}
fun void updateBeat()
{
  counter % c.numBeats => beat;  
}

fun void progress()
{
  counter++;
  if(beat == c.numBeats -1)
    measure++;

  c.tempo::second => now; 
}

