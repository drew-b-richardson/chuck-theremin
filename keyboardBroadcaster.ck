

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
      // take ascii value of button, convert to freq

      //function keys for octave above notes
      if (msg.which >=59 && msg.which <= 68 )
      {
        
        "n" => constants.event.cmd;
        msg.which - 58 + 7 => constants.event.value;
      }

      //if between 1 and 9, send note numnber
      else if (msg.which >=2 && msg.which <= 10 )
      {
        "n" => constants.event.cmd;
        msg.which - 1 => constants.event.value;
        <<< "which", msg.which >>>;
      }

      //if 0, send note off.  good for stopping long playing instruments
      else if(msg.which == 11) 
      {
       "n" => constants.event.cmd;
       0 => constants.event.value;
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

     //d starts drum machine
      else if(msg.which == 32) 
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

      //number keypad 1 to call file
      else if(msg.which == 79) 
      {
       "f" => constants.event.cmd;
       1 => constants.event.value;
      }

      //number keypad 2 to call file
      else if(msg.which == 80) 
      {
       "f" => constants.event.cmd;
       2 => constants.event.value;
      }

      //'t' will start turntable
      else if(msg.which == 20) 
      {
       "t" => constants.event.cmd;
      }

    }
    constants.event.broadcast();
    1::samp => now;
  }
}

