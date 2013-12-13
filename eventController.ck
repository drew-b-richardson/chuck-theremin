
//main instrument
BeeThree instr =>  JCRev r => Gain g =>Pan2 p =>   dac;
0.3 => float instrGain;
0.2 => r.mix;
0 => p.pan;

//synth knob
SawOsc o =>BPF filter =>  JCRev r2=> Pan2 p2 =>  dac;
0 => o.freq;
1 => filter.Q;
1000 => filter.freq;
1 => int isStartUp;


//filter settings
BPF f;
1 => f.Q;
1000 => f.freq;

//SONG SETTINGS PASSED TO DRUM MACHINE AND LOOPER
250 => int tempo; 
16 => int numBeats;
Constants constants;
constants.e =>   int key;
constants.phrygian @=> int scaleBase[];
5 => int startOctave;
4 => int octaveRange;
int scale[scaleBase.cap()*octaveRange];
startOctave * 12 + key => int transpose;
//increase scale size
for(0 => int i; i < scaleBase.cap(); i++)
{
  for(0 => int j; j < octaveRange - 1; j++)
  {
    scaleBase[i] + j*12 => scale[i + (scaleBase.cap()-1)*j];
  }
}

//vars to make LiSa start at beginning of next measure
//NOTE:  ONCE THIS SHRED IS REMOVED, MEASURES ARE NO LONGER ACCURATE.  STARTTIME IS FROM START OF VM, NOT SHRED
1 => int playFromMeasure;
200 => int lag;
numBeats * tempo::ms => dur durPerMeasure;
time timeStartDrum;

//GLOBAL VARIABLES
0 => int value;
100 => float frequency;
0.0 => float percentage;
0.0 => float offset;
.4 => float volume;
1=> int noteNumber;
0.0 => float pan;
-1 => int drumMachineId;
-1 => int bassId;
"" => string cmd;
int noteOn;
"" => string prevCmd;
1 => int isBend;
0 => int isVolume;

//receive values
while (true)
{
  constants.event => now;
  constants.event.cmd => cmd;
  constants.event.value => value;

  //play note
  if (cmd == "n")
  {
    if (value == 0)
    {
      0 => instr.noteOn;
    }
    else
    {
      Std.mtof(scale[value -1] + transpose) =>	frequency;
      instrGain => instr.noteOn;
    }
  }

  //start drum machine
  else if(cmd == "d")
  {
    <<< drumMachineId, "id" >>>;

    if(drumMachineId == -1)
    {
      Machine.add( "drumMachine.ck:" + numBeats + ":" + tempo + ":" +  pan) => drumMachineId;
      now => timeStartDrum;
    }
    else
    {
      waitTillNextMeasure();
      Machine.replace( drumMachineId, "drumMachine.ck:" + numBeats + ":" + tempo + ":" + pan ) => drumMachineId;
      now => timeStartDrum;
    }
  }

  //start bass 
  else if(cmd == "b")
  {
    <<< bassId, "id" >>>;

    if(bassId == -1)
    {
      Machine.add( "bass.ck:" + numBeats + ":" + tempo + ":" +  pan) => bassId;
      now => timeStartDrum;
    }
    else
    {
      waitTillNextMeasure();
      Machine.replace( bassId, "bass.ck:" + numBeats + ":" + tempo + ":" + pan ) => bassId;
      now => timeStartDrum;
    }
  }

  //change octave
  else if(cmd == "o")
  {
    value + startOctave => startOctave;
    startOctave * 12 + key =>  transpose;
  }

  //instr pan
  else if(cmd == "h")
  {
    value/100.0 => p.pan;
  }

  //instr gain
  else if(cmd == "v")
  {
      value/100.0 => instr.gain;
  }

  //vibrato - amount is percentage of original freq
  else if(cmd == "s")
  {
    (0.0 + value)/10000*2 => percentage;
    frequency*percentage => offset;
    frequency+offset => frequency;
    /*o.freq() + offset => o.freq;*/
  }

  //play looper in separate shred so will still sound when restarting main
  else if(cmd == "l")
  {
  <<< "looper ready" >>>;
  waitTillNextMeasure();
  Machine.add( "/docs/chuck/theremin/simpleMicLooper.ck:" + numBeats * value + ":" + tempo + ":" + lag + ":" + pan );
  }

  //play the local version of the file number in question
  if(cmd == "f")
  {
      Machine.add("file" + value + ".ck");
  }
  
  //play turntable
  if(cmd == "t")
  {
      Machine.add("/docs/chuck/theremin/turnTable.ck");
  }

  frequency => instr.freq;
  " " => cmd;
  1::samp => now;

}

fun void waitTillNextMeasure()
{
  now - timeStartDrum => dur durSinceDrums;
  durSinceDrums/durPerMeasure => float curMeasure; //current measure after start of drums as float
  <<< "current", curMeasure >>>;

  Math.ceil(curMeasure) - curMeasure => float measureLeft;  //fraction of a measure until next measure starts
  measureLeft * durPerMeasure => dur tillNextMeasure;//time until next measure starts
  tillNextMeasure => now; //wait until start of next measure and start looper
}



