"/git/chuck-theremin/" => string PATH;
"song1/" => string SONG;

Machine.add(PATH + "event.ck");
Machine.add(PATH + "constants.ck");
Machine.add(PATH + SONG + "setup.ck");
// Machine.add("/git/chuck-theremin/arduinoBroadcaster.ck");
Machine.add(PATH + "keyboardBroadcaster.ck");
Machine.add(PATH + "micLooper.ck");
Machine.add(PATH + SONG + "samples.ck");
Machine.add(PATH + "eventController.ck");
