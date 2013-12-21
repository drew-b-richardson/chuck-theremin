// Dave's Level Meter (free to a good home)
class LevelMeter extends Chugen {
    0 => float max_level; 

    fun void resetMax()
    {
      0 => max_level;
    }
    
    fun float tick(float in) {
       Math.max(max_level, in) => max_level;
       return in;
    }
    
    fun float max() {
        return max_level;
    }
}


Pan2 master;


StkInstrument inst[12];
// make each instrument a different type
Flute inst0 @=> inst[0];
Rhodey inst1 @=> inst[1];
Clarinet inst2 @=> inst[2];
BlowBotl inst3 @=> inst[3];
BandedWG inst4 @=> inst[4];
BlowHole inst5 @=> inst[5];
Bowed inst6 @=> inst[6];
Brass inst7 @=> inst[7];
Mandolin inst8 @=> inst[8];
ModalBar inst9 @=> inst[9];
Moog inst10 @=> inst[10];
Saxofony inst11 @=> inst[11];

StkInstrument polyInst[4];
0 => int currentInst;
0 => int currentInstNum;


inst[0] @=> StkInstrument instr;

//main instrument
instr =>  NRev rev => Chorus chorus => Gain g => LevelMeter meter => Pan2 p =>    dac;
0.2 => chorus.modDepth;
0.2 => float instrGain;
0.2 => rev.mix;
0.0 => chorus.mix;
0 => p.pan;



Constants c;

Delay delay;
rev => delay => delay => p;
0 => int isDelay;
0.0 => delay.gain;
c.tempo::second * c.numBeatsPerMeasure => delay.max => delay.delay;

5 => int startOctave;

0 => int isPolyphonic;

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
[-1,-1,-1,-1,-1,-1,-1,-1,-1] @=> int fileIds[]; //position in array corresponds to file #
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

  //if starts distorting, cut back on reverb
  if(meter.max() > 0.9)
  {
    <<< "danger" >>>;
    rev.mix() - 0.2 => rev.mix;
    meter.resetMax();
  }

  //for all keys that require a following action:
  if(cmd == "m" || cmd == "i" || cmd == "r" || cmd == "d" || cmd == "c" || cmd == "-" || cmd == "=" || cmd == "_" || cmd == "rs")
  {
    cmd => previousMsg;
  }

  //top number keys and function keys
  if (cmd == "n")
  {
    //change preset
    if (previousMsg == "rs")
    {
      getPreset(value);
    }
    //change instrument
    else if (previousMsg == "i")
    {
      changeInstrument(value -1);
    }

    //change reverb
    else if (previousMsg == "r")
    {
      (value - 1)/10.0 => rev.mix;
    }

    //change delay
    else if (previousMsg == "d")
    {
      (value - 1)/10.0 => delay.gain;
    }

    //up half step
    else if (previousMsg == "=")
    {
      <<< "here1" >>>;
        Std.mtof(c.fullScale[value-1] + startOctave*12 + 1) => frequency;
    }

    //down half step
    else if (previousMsg == "_")
    {
      <<< "here2" >>>;
        Std.mtof(c.fullScale[value-1] + startOctave*12 - 1) => frequency;
    }

    //change chorus
    else if (previousMsg == "c")
    {
      (value - 1)/10.0 => chorus.mix;
    }

    //change scale
    else if (previousMsg == "m")
    {
      c.setScale(c.getScale(value));
      c.populateScale();  
    }

    //if there were no previous messages, just play note
    else
    {
      c.populateScale(); //if we don't mind setting it manually this can go away
      Std.mtof(c.fullScale[value-1] + startOctave*12) => frequency;
      if (isPolyphonic)
      {
        spork ~ playNote();  
      }
      else
      {
        instrGain => instr.noteOn;
      }
    }

    " " => previousMsg; //clear out previous message

  }

  //backspace turns off note
  else if(cmd == "bs")
  {
    if (isPolyphonic)
    {
      for(0 => int i; i < polyInst.cap(); i++)
      {
        instrGain => polyInst[i].noteOff;
      }
    }
    else
    {
    instrGain => instr.noteOff;
    }
  }

  //numpad numbers 1-9
  else if(cmd == "f")
  { 
    <<< "num", value >>>;
    //if switching song section
    if (previousMsg == "-")
    {
      value => currentSection;
      for(0 => int i; i < fileIds.cap(); i++)
      {
        spork ~ replaceFile(i+1, fileIds[i]);
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
        spork ~ addNewFile(value);
      }
      else
      {
        spork ~ removeFile(value, fileId);
      }
    }
  }


  //toggle polyphony on/off
  else if(cmd == "p")
  {
    <<< "toggling" >>>;
    /*if (isPolyphonic)*/
    /*{*/

      /*for(0 => int i; i < polyInst.cap(); i++)*/
      /*{*/
        /*inst[currentInst] @=> polyInst[i];  */
      /*}*/
    /*}*/
    toggle(isPolyphonic) => isPolyphonic;
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
    <<< "pan", p.pan() >>>;
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
  }

  //play looper in separate shred so will still sound when restarting main
  else if(cmd == "l")
  {
    <<< "looper ready" >>>;
    waitTillNextMeasure();
    Machine.add( "/docs/chuck/theremin/micLooper.ck:" + c.numBeats * value + ":" + c.tempo + ":" + lag + ":" + pan );
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
    0 => bool;
  }
  else if (bool == 0)
  {
    1 => bool;
  }
  return bool;
}

fun void playNote()
{
  StkInstrument inst[4];
  // make each instrument a different type
  Flute inst0 @=> inst[0];
  Rhodey inst1 @=> inst[1];
  Clarinet inst2 @=> inst[2];
  BlowBotl inst3 @=> inst[3];

  currentInstNum % polyInst.cap() => int spot;
  <<< "spot", spot >>>;
  polyInst[spot] =< rev;
  inst[currentInst] @=> polyInst[spot];
  /*polyInst[0] @=> i;*/
  polyInst[spot] => rev;
  frequency => polyInst[spot].freq;
  0.1 => polyInst[spot].noteOn; 
  currentInstNum++;
  while(isPolyphonic)
  {
    1::second => now;
  }
}

fun void changeInstrument(int num)
{
      instrGain => instr.noteOff;
      instr =< rev;
      inst[num] @=> instr;  
      instr =>  rev ;
      num => currentInst;
}
fun void getPreset(int num)
{
  if (num == 1)
  {
    changeInstrument(0);
    0.3 => rev.mix;
    0 => chorus.mix;
    0.3 => delay.gain;
  }
  else if (num == 2)
  {
    changeInstrument(1);
    0.5 => rev.mix;
    0.7 => chorus.mix;
    0.3 => delay.gain;
  }
}
