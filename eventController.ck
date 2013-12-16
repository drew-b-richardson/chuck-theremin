StkInstrument inst[4];
// make each instrument a different type
Flute inst0 @=> inst[0];
Rhodey inst1 @=> inst[1];
Clarinet inst2 @=> inst[2];
BlowBotl inst3 @=> inst[3];

inst[0] @=> StkInstrument instr;

//main instrument
instr =>  JCRev r => Gain g =>Pan2 p =>   dac;
0.3 => float instrGain;
0.2 => r.mix;
0 => p.pan;

//SONG SETTINGS PASSED TO DRUM MACHINE AND LOOPER
Constants constants;
/*constants.e =>   int key;*/
/*constants.phrygian @=> int scaleBase[];*/
5 => int startOctave;
4 => int octaveRange;
int scale[constants.scale.cap()*octaveRange];
startOctave * 12 + constants.key => int transpose;
populateScale(); 

//vars to make LiSa start at beginning of next measure
//NOTE:  ONCE THIS SHRED IS REMOVED, MEASURES ARE NO LONGER ACCURATE.  STARTTIME IS FROM START OF VM, NOT SHRED
1 => int playFromMeasure;
200 => int lag;
constants.numBeats * constants.tempo::second => dur durPerMeasure;
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

string previousMsg;

//do we need this?!?
now => timeStartDrum;

-1 => int f1Id;
[-1,-1,-1,-1,-1] @=> int fileIds[]; //position in array corresponds to file #
1 => int currentSection;

float curMeasure; //current measure after start of drums as float
  float measureLeft;  //fraction of a measure until next measure starts
  dur tillNextMeasure;//time until next measure starts


//receive values
while (true)
{
  constants.event => now;
  constants.event.cmd => cmd;
  constants.event.value => value;

  //play note
  if (cmd == "n")
  {
    //change instrument
    if (previousMsg == "i")
    {
      0.6 => instr.noteOff;
      instr =< r;
      inst[value] @=> instr;
      instr =>  r => Gain g =>Pan2 p =>   dac;
    }

    //change scale
    if (previousMsg == "m")
    {
      <<< "value", value >>>;
      if(value==1)
      {
        constants.ionian @=> constants.scale;
      }
      else if(value==2)
      {
        constants.dorian @=> constants.scale;
      }

      else
      {
        constants.gypsy @=> constants.scale;
      }
      populateScale();
    }

    //if there were no previous messages, this is just a 1st octave note to be played
    else
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
      " " => previousMsg;
    
  }

  //start drum machine
  else if(cmd == "b")
  {
    <<< drumMachineId, "id" >>>;

    if(drumMachineId == -1)
    {
      /*Machine.add( "drumMachine.ck:" + constants.numBeats + ":" + constants.tempo + ":" +  pan) => drumMachineId;*/
      now => timeStartDrum;
    }
    else
    {
      waitTillNextMeasure();
      /*Machine.replace( drumMachineId, "drumMachine.ck:" + constants.numBeats + ":" + constants.tempo + ":" + pan ) => drumMachineId;*/
      now => timeStartDrum;
    }
  }

  //change octave
  else if(cmd == "o")
  {
    value + startOctave => startOctave;
    startOctave * 12 + constants.key =>  transpose;
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
    Machine.add( "/docs/chuck/theremin/micLooper.ck:" + constants.numBeats * value + ":" + constants.tempo + ":" + lag + ":" + pan );
  }

  //check if switching song section
  if (cmd == "-")
  {
    "-" => previousMsg;

  }

  //play the local version of the file number in question
  if(cmd == "f")
  { 
    //if switching song section
    if (previousMsg == "-")
    {
      value => currentSection;
      //check to see if any other existing threads, if so, wait
      waitTillNextMeasure();
      for(0 => int i; i < fileIds.cap(); i++)
      {
        if(fileIds[i] > -1)
        {
          Machine.replace(fileIds[i], "file" + (i+1) + ".ck:" + currentSection);
        }
      }
      " " => previousMsg;
    }

    //otherwise, just starting or stopping shred
    else
    {
      //find current shred ID of file in quesiton.  if -1, create a new 
      fileIds[value - 1] => int fileId;
      <<< "fileId", fileId >>>;
      if(fileId == -1)
      {
        <<< "adding ", value >>>;
        spork ~ addNewFile(value);
      }
      else
      {
        <<< "removing ", value >>>;
        spork ~ removeFile(value, fileId);
      }
    }
  }

  //change mode(scale) -- depends on next msg
  if(cmd == "m")
  {
    "m" => previousMsg;
  }

  //change instrument
  if(cmd == "i")
  {
    "i" => previousMsg;
  }

  if (cmd == "d")
  {
    Delay delay;
    0.6 => delay.gain;
    constants.tempo::second * constants.numBeatsPerMeasure => delay.max => delay.delay;

    instr => delay => delay => p;
  }

  frequency => instr.freq;
  " " => cmd;
  20::ms => now;

}

fun void addNewFile(int value)
{
  //check to see if any other existing threads, if so, wait
  for(0 => int i; i < fileIds.cap(); i++)
  {
    if(fileIds[i] > -1)
    {
      waitTillNextMeasure();
      break;
    }
  }
  Machine.add("file" + value + ".ck:" + currentSection) @=> fileIds[value - 1];
  now => timeStartDrum;
}

fun void replaceFile(int value, int fileId)
{
  waitTillNextMeasure();  
  Machine.replace(fileId, "file" + value + ".ck:" + currentSection);
}

fun void removeFile(int value, int fileId)
{
  //this sometimes breaks things... don't know why
  waitTillNextMeasure();  
  Machine.remove(fileId);
  -1 @=> fileIds[value - 1];
}



//populate notes to be played based on # octabes and which scale is chosen in constants
fun void populateScale()
{
  for(0 => int i; i < constants.scale.cap(); i++)
  {
    for(0 => int j; j < octaveRange - 1; j++)
    {
      constants.scale[i] + j*12 => scale[i + (constants.scale.cap()-1)*j];
    }
  }

}

fun void waitTillNextMeasure()
{
  now - timeStartDrum => dur durSinceDrums;
  durSinceDrums/durPerMeasure => curMeasure; //current measure after start of drums as float

  Math.ceil(curMeasure) - curMeasure => measureLeft;  //fraction of a measure until next measure starts
  measureLeft * durPerMeasure => tillNextMeasure;//time until next measure starts
  tillNextMeasure => now; //wait until start of next measure and start looper
}



