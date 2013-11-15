SndBuf buf  => Pan2 p => dac ;
/*me.dir() + "audio/DemConvention.wav" =>  buf.read;*/
/*me.dir() + "audio/AbdicationAddress.wav" =>  buf.read;*/
me.dir() + "audio/AddressonVietnamWarProtests.wav" =>  buf.read;
0.7 => float g;
g => buf.gain;
1 => buf.loop;
1.0 => buf.rate;
"" => string cmd;
0 => int value;
0 => int startPos;
200000 => int scratchAmount;

buf.samples() => int endPos;

//SERIAL INPUT FROM ARDUINO
SerialIO cereal;
cereal.open(2, SerialIO.B9600, SerialIO.ASCII);

while(true)
{
if (buf.pos() >= endPos)
{
  startPos => buf.pos;
}

  cereal.onLine() => now;
  cereal.getLine() => string line;
  if(line$Object != null)
  {
    line.substring(0,1) => cmd;
    Std.atoi(line.substring(1)) => value;

    //play looper in separate shred so will still sound when restarting main
    if(cmd == "b")
    {
      <<< "here" >>>;
      
      if(buf.gain() == 0)
      {
        g => buf.gain;
        startPos => buf.pos;
      }
      else
        0 => buf.gain;
    }

    //play looper in separate shred so will still sound when restarting main
    else if(cmd == "p")
    {
      <<< "pan",  value >>>;
      value/10.0 => p.pan;
    }

    //play note
    else if(cmd == "z")
    {
      buf.rate() * -1 => buf.rate;
    }

    //start drum machine
    else if(cmd == "c")
    {
      if(startPos == 0)
      {
        <<< "set startPos" >>>;
        buf.pos() => startPos;
      }
      else
      {
        if (endPos == buf.samples())
        {
          <<< "set endPos" >>>;
          buf.pos() => endPos;
        }
        else
        {
          <<< "reset Pos" >>>;
          0 => startPos;
          buf.samples() => endPos;
        }
      }
    }

    //vibrato - amount is percentage of original freq
    else if(cmd == "s")
    {
      <<< "value", value >>>;
      if(Math.abs(value) > 50)
      {
        <<< "currentPos", buf.pos() >>>;
        if (value < 0)
        {
          buf.pos() - scratchAmount => buf.pos;
        }
        else
        {
          buf.pos() + scratchAmount => buf.pos;
        }
        <<< "afterPos", buf.pos() >>>;
      } 
      (0.0 + value)/100 => float rate;
      if (buf.rate() < 0)
      {
        rate -1 => buf.rate;
      }
      else
        rate+1 => buf.rate;
    }

  }
}


