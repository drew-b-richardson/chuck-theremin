Std.atoi(me.arg(0)) => int section;

Gain g =>  dac;
0.3 => g.gain;

Constants constants;

SndBuf kick => g;
me.dir() + "/docs/chuck/theremin/audio/kick_05.wav" =>  kick.read;
kick.samples() => kick.pos; 

SndBuf hihat => g;
me.dir() + "/docs/chuck/theremin/audio/hihat_01.wav" =>  hihat.read;
hihat.samples() => hihat.pos; 
0.3 => hihat.gain;

[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0] @=> int kicks[];
[0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0,0,0,1,0,1,0] @=> int hihats[];

[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0] @=> int kicks2[];

0 => int counter; //this increments forever
0 => int beat; //this increments and repeats after numBeats
0 => int measure; //keep track of # of measures

while(true)
{
  updateBeat();

  playSndBuf(hihats[beat], hihat);

  if (section == 2)
    playSndBuf(kicks2[beat], kick);
  else
    playSndBuf(kicks[beat], kick);

  progress();
}

fun int playSndBuf(int doPlay, SndBuf buffer)
{
    if (doPlay)
    {
      0  => buffer.pos;
    }
}

fun void updateBeat()
{
  counter % constants.numBeats => beat;  
}

fun void progress()
{
  counter++;
  if(beat == constants.numBeats -1)
    measure++;

  constants.tempo::second => now; 
}

