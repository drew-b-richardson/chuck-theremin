Std.atoi(me.arg(0)) => int section;

TriOsc osc => ADSR env =>  dac;
env.set(0.01 :: second, 0.05 :: second, 0.8, .7 :: second);

.2 => osc.gain;
2 => int startOctave;
2 => int octaveRange;

Constants constants;
int scale[constants.scale.cap()*octaveRange];
startOctave * 12 + constants.key => int transpose;
populateScale(); 

[8,0,0,0,0,0,7,0,0,0,0,0,6,0,0,0,0,0,0,0,0,0,0,0] @=> int melody[];
[1,0,0,0,0,0,2,0,0,0,0,0,3,0,0,0,0,5,0,0,0,0,0,0] @=> int melody2[];

0 => int counter; //this increments forever
0 => int beat; //this increments and repeats after numBeats
0 => int measure; //keep track of # of measures


while(true)
{
  updateBeat();

  if (melody[beat] > 0)
  {
    getFreq(melody[beat]) => osc.freq;
    1 => env.keyOn;
  }

  progress();
  1 => env.keyOff;
}

fun float getFreq(int noteNumber)
{
  Std.mtof(scale[noteNumber - 1] + transpose) => float freq;
  return freq;
}

fun int playOscNote(int scaleNum)
{
  if (scaleNum == 0)
  {
    1 => env.keyOff;
  }
  else
  {
    Std.mtof(scale[scaleNum-1] + transpose) =>	osc.freq;
    1 => env.keyOn;
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

