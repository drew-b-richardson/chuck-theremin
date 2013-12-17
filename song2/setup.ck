
//set initial key and scale values
Constants c;
c.setKeyAndScale(c.g, c.aeolian);

// basic pattern is 4 measures of 6/8 
240.0 => c.bpm;
4 => c.numMeasures;
6 => c.numBeatsPerMeasure;
8 => c.baseBeat;
c.setTempo();
<<< "tempo", c.tempo >>>;

