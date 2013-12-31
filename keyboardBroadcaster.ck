

Constants constants;
int asciiwhich;

// Hid object
Hid hi;
// message to convey data from Hid device
HidMsg msg;

// device number: which keyboard to open
0 => int device;

// open keyboard; or exit if fail to open
if( !hi.openKeyboard( device ) ) me.exit();
// print a message!
<<< "keyboard '" + hi.name() + "' ready", "" >>>;

// infinite event loop
while( true )
{
  // wait for event
  hi => now;

  // get message
  while( hi.recv( msg ) )
  {
    // filter out button down events
    if( msg.isButtonDown() )
    {

   <<< "down:", msg.which, "(which)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;

      //function keys for octave above notes
      if (msg.which >=59 && msg.which <= 68 || (msg.which == 87 || msg.which == 88 ))
      {
        msg.which - 59 => int funNumber; 
        if (msg.which == 87 || msg.which == 88)
        {
         msg.which - 85 + constants.scale.cap() => funNumber; 
        }
        "n" => constants.event.cmd;
        funNumber + constants.scale.cap() => constants.event.value;
      }

      //if top number keys between 1 and 9, send note numnber
      else if (msg.which >=2 && msg.which <= 11 )
      {
        "n" => constants.event.cmd;
        msg.which - 1 => constants.event.value;
      }

      //turn on/off polyphony
      else if(msg.which == 25) 
      {
       "p" => constants.event.cmd;
      }

      //up arrow increases octave
      else if(msg.which == 200) 
      {
       "o" => constants.event.cmd;
       1 => constants.event.value;
      }

      //up arrow increases octave
      else if(msg.which == 208) 
      {
       "o" => constants.event.cmd;
       -1 => constants.event.value;
      }

     //b starts drum machine
      else if(msg.which == 48) 
      {
       "b" => constants.event.cmd;
       0 => constants.event.value;
      }

     //b starts beat
      else if(msg.which == 48) 
      {
       "d" => constants.event.cmd;
       0 => constants.event.value;
      }

      //l starts looper
      else if(msg.which == 38) 
      {
       "l" => constants.event.cmd;
       2 => constants.event.value;
      }

      //number keypad 1-3 to call file
      else if(msg.which == 79 || msg.which == 80 || msg.which == 81) 
      {
       "f" => constants.event.cmd;
       msg.which - 78 => constants.event.value;
      }

      //number keypad 1-3 to call file
      else if(msg.which == 75 || msg.which == 76 || msg.which == 77) 
      {
       "f" => constants.event.cmd;
       msg.which - 71 => constants.event.value;
      }

      //number keypad 1-3 to call file
      else if(msg.which == 71 || msg.which == 72 || msg.which == 73) 
      {
       "f" => constants.event.cmd;
       msg.which - 64 => constants.event.value;
      }

      //'m' 
      else if(msg.which == 50) 
      {
        "m" => constants.event.cmd;
      }

      else if(msg.which == 31) 
      {
        "s" => constants.event.cmd;
      }

      //'i' will set scale/mode
      else if(msg.which == 23) 
      {
        "i" => constants.event.cmd;
      }

      //'d' will set delay 
      else if(msg.which == 32) 
      {
        "d" => constants.event.cmd;
      }

      //'g' will set chorus
      else if(msg.which == 34) 
      {
        "g" => constants.event.cmd;
      }
      //'c' will set chorus
      else if(msg.which == 46) 
      {
        "c" => constants.event.cmd;
      }

      //'r' will set reverb
      else if(msg.which == 19) 
      {
        "r" => constants.event.cmd;
      }

      //'-' will replace all shreds with 2nd verse
      else if(msg.which == 74) 
      {
        "-" => constants.event.cmd;
      }
      
      //backspace 
      else if(msg.which == 14) 
      {
        "bs" => constants.event.cmd;
      }
      //_ 
      else if(msg.which == 12) 
      {
        "_" => constants.event.cmd;
      }
      else if(msg.which == 13) 
      {
        "=" => constants.event.cmd;
      }
      //right shift 
      else if(msg.which == 54) 
      {
        "rs" => constants.event.cmd;
      }
      //right arrow 
      else if(msg.which == 205) 
      {
        "ra" => constants.event.cmd;
      }
      //left arrow 
      else if(msg.which == 203) 
      {
        "la" => constants.event.cmd;
      }
      constants.event.broadcast();
      1::samp => now;
    }
  }
}

