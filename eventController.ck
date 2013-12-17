StkInstrument inst[4];
// make each instrument a different type
Flute inst0 @=> inst[0];
Rhodey inst1 @=> inst[1];
Clarinet inst2 @=> inst[2];
BlowBotl inst3 @=> inst[3];

inst[0] @=> StkInstrument instr;

//main instrument
instr =>   JCRev r => Gain g =>Pan2 p =>   dac;
0.2 => float instrGain;
0.2 => r.mix;
0 => p.pan;

Constants c;

Delay delay;
instr => delay => delay => p;
0 => int isDelay;
0.0 => delay.gain;
c.tempo::second * c.numBeatsPerMeasure => delay.max => delay.delay;

5 => int startOctave;


//vars to make LiSa start at beginning of next measure
//NOTE:  ONCE THIS SHRED IS REMOVED, MEASURES ARE NO LONGER ACCURATE.  STARTTIME IS FROM START OF VM, NOT SHRED
1 => int playFromMeasure;
200 => int lag;
c.numBeats * c.tempo::second => dur durPerMeasure;
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
  c.event => now;
  c.event.cmd => cmd;
  c.event.value => value;

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
        c.setScale(c.ionian);
      }
      else if(value==2)
      {
        c.setScale(c.dorian);
      }
      else
      {
        c.setScale(c.gypsy);
      }
    }

    //if there were no previous messages, this is just a 1st octave note to be played
    else
    {
      if (value == 0)
      {
        instrGain => instr.noteOff;
      }
      else
      {
        //if we want to have other shreds update key, need to have this since arrays cant be static
        c.populateScale(); //if we don't mind setting it manually this can go away

        Std.mtof(c.fullScale[value-1] + startOctave*12) => frequency;
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
      /*Machine.add( "drumMachine.ck:" + c.numBeats + ":" + c.tempo + ":" +  pan) => drumMachineId;*/
      now => timeStartDrum;
    }
    else
    {
      waitTillNextMeasure();
      /*Machine.replace( drumMachineId, "drumMachine.ck:" + c.numBeats + ":" + c.tempo + ":" + pan ) => drumMachineId;*/
      now => timeStartDrum;
    }
  }

  //change octave
  else if(cmd == "o")
  {
    startOctave + value => startOctave;
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
    Machine.add( "/docs/chuck/theremin/micLooper.ck:" + c.numBeats * value + ":" + c.tempo + ":" + lag + ":" + pan );
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
      for(0 => int i; i < fileIds.cap(); i++)
      {
        if(fileIds[i] > -1)
        {
          spork ~ replaceFile(i+1, fileIds[i]);
          /*Machine.replace(fileIds[i], "file" + (i+1) + ".ck:" + currentSection);*/
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
    toggle(isDelay) => isDelay;
    if (isDelay)
      0.6 => delay.gain;
    else
      0.0 => delay.gain;
  }

  frequency => instr.freq;
  " " => cmd;
  1::samp => now;

}

fun void addNewFile(int value)
{
  //check to see if any other existing threads, if so, wait
  for(0 => int i; i < fileIds.cap(); i++)
  {
    if(fileIds[i] > -1)
    {
      waitTillNextMeasure();
      1::ms => now;
      break;
    }
  }
  Machine.add("file" + value + ".ck:" + currentSection) @=> fileIds[value - 1];
  now  => timeStartDrum;
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

fun void waitTillNextMeasure()
{
  now - timeStartDrum => dur durSinceDrums;
  durSinceDrums/durPerMeasure => curMeasure; //current measure after start of drums as float

  Math.ceil(curMeasure) - curMeasure => measureLeft;  //fraction of a measure until next measure starts
  measureLeft * durPerMeasure => tillNextMeasure;//time until next measure starts
  tillNextMeasure => now; //wait until start of next measure and start looper
}

fun int toggle(int bool)
{
  if (bool == 1)
  {
    <<< "is 0" >>>;
    0 => bool;
  }
  else if (bool == 0)
  {
    <<< "is 1" >>>;
   1 => bool;
  }
  return bool;
}


