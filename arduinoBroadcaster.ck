//SERIAL INPUT FROM ARDUINO
SerialIO cereal;
cereal.open(2, SerialIO.B9600, SerialIO.ASCII);
Constants constants;
1 => int firstTime;

while(true)
{

  cereal.onLine() => now;
  cereal.getLine() => string line;
  if(line$Object != null)
  {
    line.substring(0,1) => constants.event.cmd;
    Std.atoi(line.substring(1)) => constants.event.value;
    constants.event.broadcast();
    1::samp => now;
  }
}
