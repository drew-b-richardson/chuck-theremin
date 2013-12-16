
//set initial key and scale values
Constants c;
c.d =>   c.key;
c.minpent @=> c.scale;

80.0 => c.bpm;
16 => c.numBeats;
4 => c.baseBeat;
c.setTempo();
/*60.0 / (bpm * baseBeat )=> c.tempo;*/
<<< "tempo", c.tempo >>>;


