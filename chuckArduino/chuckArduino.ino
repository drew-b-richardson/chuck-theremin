#include <Wire.h>
#include <WiiChuck.h>
#include <Ping.h>

//WII SETUP
#define MAXANGLE 90
#define MINANGLE -90
WiiChuck chuck = WiiChuck();
int angleStart, currentAngle;
int tillerStart = 0;
double angle;

//PING
const int PING_PIN = 7;
Ping ping = Ping(PING_PIN,0,0);
const int PING_START_DISTANCE = 71;
const int PING_END_DISTANCE = 5;
int lastPingReading = -1;
int pingValue = 0;
int lastPingValue = 0;
long lastPingDebounceTime = 0;  // the last time the output pin was toggled
long pingDebounceDelay = 20;    // the debounce time; increase if the output flickers

//VIBRATO
int vibratoOn = 0;
int lastVibratoOn = 0;
int currentOctave = 4;
boolean isOctaveCocked = true;
boolean isVibratoCocked = true;
int bend=0;
int mappedX = 0;
int x=0;
int lastX =0;
int mappedY = 0;
int y=0;
int lastY =0;
boolean isShakeOn = false;
int previousRoll = 0;

int stepNum=0;
int notes[] = {
  100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100};

const int VIBRATO_START = 200;


// the follow variables are long's because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long time = 0;         // the last time the output pin was toggled
long debounce = 200;   // the debounce time, increase if the output flickers

//pot
int potPin = 1;
int potValue = 0.0;
int prevPotValue = 0.0;

//pot 2
int potPin2 = 2;
int potValue2 = 0.0;
int prevPotValue2 = 0.0;

void setup()
{
  Serial.begin(9600);
  chuck.begin();
  chuck.update();
}

void loop()
{
  chuck.update();
  
  writeZ();
  writeC();
  writeVert();
  writeHoriz();
  writeShakeX();
  //writeRoll();

  delay(50); 
}

void writeRoll()
{
if(isShakeOn)
{
  int roll = (int)chuck.readRoll();
  if(roll < previousRoll - 2 || roll > previousRoll + 2)
  {
    Serial.print("r");
    Serial.println((int)chuck.readRoll());
    previousRoll = roll;
  }
}
}

void writePot()
{
  int val = analogRead(potPin); 
  potValue = constrain(map(val, 0, 1023, -10, 10),-10, 10);
  potValue = -potValue;
  if(potValue != prevPotValue)
  {
    Serial.print("p");
    Serial.println(potValue);
    prevPotValue = potValue;
  }
}
void writePot2()
{
  int val = analogRead(potPin2); 
  potValue2 = constrain(map(val, 0, 1023, -10, 10),-10, 10);
  potValue2 = -potValue2;
  if(potValue2 != prevPotValue2)
  {
    Serial.print("q");
    Serial.println(potValue2);
    prevPotValue2 = potValue2;
  }
}

void writeZ()
{
  if(chuck.zPressed())
  {
    writePitch();
    Serial.print("z");
    Serial.println(stepNum);
  }
}

//turn shake on or off
void writeC()
{
  if(chuck.cPressed())
  {
    isShakeOn = !isShakeOn;
    Serial.print("c");
        Serial.println(isShakeOn);
  }
}

void writeVert()
{
  //bends
  int rawBend = chuck.readJoyY();
  if(rawBend > 10 || rawBend < -10)
  {
    //bend = constrain(rawBend,-100, 100);
    bend = constrain(map(rawBend, -100, 100, 0, 100),0, 100);
    Serial.print("v");
    Serial.println(bend);    
  }
}


void writeHoriz()
{
  //bends
  int rawBend = chuck.readJoyX();
  if(rawBend > 10 || rawBend < -10)
  {
    bend = constrain(rawBend,-100, 100);

    Serial.print("h");
    Serial.println(rawBend);    
  }
}


void writeShakeX()
{
  if(isShakeOn)
  {
  x =(int)chuck.readAccelX();
  mappedX = constrain(map(x, -500, 500, -100, 100),-100, 100);

  if(mappedX > 20 || mappedX < -20)
  {
    Serial.print("s");
    Serial.println(mappedX);   
    lastX = x;
  }
  else
  {
    if(lastX != 0)
    {
      Serial.println("s0");
      lastX = 0;
    }
  }

  }
}

void writePitch()
{
  y =chuck.readPitch();

  mappedY = constrain(map(y, 0, 160, 0, 100),0, 100);

  if(mappedY > 5)
  {
    Serial.print("y");
    Serial.println(mappedY);   
    lastY = y;
  }
  else
  {
    if(lastY != 0)
    {
      Serial.println("y0");
      lastY = 0;
    }
  }


}

int getPingValue(int minimumValue, int maxValue)
{
  ping.fire();

  int pingReading = ping.centimeters();
  if(pingReading < PING_START_DISTANCE)
  {
    pingReading =  constrain(map(pingReading, PING_START_DISTANCE, PING_END_DISTANCE, minimumValue, maxValue),minimumValue, maxValue);

    if(pingReading != lastPingReading)
    {
      lastPingDebounceTime = millis();
      lastPingReading = pingReading;
    }

    //if we've lasted as long as the debounceDelay without a state change, we send the signa
    if ((millis() - lastPingDebounceTime) > pingDebounceDelay) 
    {
      //whatever the reading is at, it's been there for longer than the debounce delay, so take it as the actual current state:
      pingValue = pingReading;
    }
    if(pingValue != lastPingValue)
    {

      lastPingValue = pingValue;   
      return pingValue;
    }
    // lightNewLed(pingValue);
  }
  //Serial.println(pingReading);
  return pingValue;
} 




