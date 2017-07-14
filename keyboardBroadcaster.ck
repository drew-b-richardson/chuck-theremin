

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
/*<<< "keyboard '" + hi.name() + "' ready", "" >>>;*/

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
      if (msg.key >=58 && msg.key <= 69)
      {
        msg.key - 58 => int funNumber;
        "n" => constants.event.cmd;
        funNumber + constants.scale.cap() => constants.event.value;
      }

      //if top number keys between 1 and 9, send note numnber
      else if (msg.key >=30 && msg.key <= 39 )
      {
        "n" => constants.event.cmd;
        msg.key - 29 => constants.event.value;
      }

      //set pan level
      else if(msg.key == 19)
      {
       "p" => constants.event.cmd;
      }

      //up arrow increases octave
      else if(msg.key == 82)
      {
       "o" => constants.event.cmd;
       1 => constants.event.value;
      }

      //down arrow decreases octave
      else if(msg.key == 81)
      {
       "o" => constants.event.cmd;
       -1 => constants.event.value;
      }

     //b starts drum machine
      // else if(msg.key == 5)
      // {
      //  "b" => constants.event.cmd;
      //  0 => constants.event.value;
      // }

     //b starts beat
      // else if(msg.which == 48)
      // {
      //  "d" => constants.event.cmd;
      //  0 => constants.event.value;
      // }

      //l starts looper
      else if(msg.key == 15)
      {
       "l" => constants.event.cmd;
       2 => constants.event.value;
      }

      else if(msg.key >= 89 && msg.key <= 97)
      {
       "f" => constants.event.cmd;
       msg.key - 88 => constants.event.value;
      }

      // m to turn on/off multinote poylphony
      else if(msg.key == 16)
      {
        "m" => constants.event.cmd;
      }

      //s to change scale/mode
      else if(msg.key == 22)
      {
        "s" => constants.event.cmd;
      }

      //'i' to change instrument
      else if(msg.key == 12)
      {
        "i" => constants.event.cmd;
      }

      //'d' will set delay
      else if(msg.key == 7)
      {
        "d" => constants.event.cmd;
      }

      //'g' set loop gain
      else if(msg.key == 10)
      {
        "g" => constants.event.cmd;
      }

      //'c' will set chorus
      else if(msg.key == 6)
      {
        "c" => constants.event.cmd;
      }

      //'r' will set reverb
      else if(msg.key == 21)
      {
        "r" => constants.event.cmd;
      }

      //'-' will replace all shreds with 2nd verse
      else if(msg.key == 86)
      {
        "-" => constants.event.cmd;
      }

      //backspace to stop sound
      else if(msg.key == 42)
      {
        "bs" => constants.event.cmd;
      }
      //- on top row
      else if(msg.key == 45)
      {
        "_" => constants.event.cmd;
      }
      else if(msg.key == 46)
      {
        "=" => constants.event.cmd;
      }
      //right shift
      else if(msg.key == 229)
      {
        "rs" => constants.event.cmd;
      }
      //right arrow
      else if(msg.which == 205)
      {
        "ra" => constants.event.cmd;
      }
      //left arrow
      else if(msg.key == 80)
      {
        "la" => constants.event.cmd;
      }
      //right control
      else if(msg.which == 157)
      {
        "rc" => constants.event.cmd;
      }
      constants.event.broadcast();
      1::samp => now;
    }
  }
}
