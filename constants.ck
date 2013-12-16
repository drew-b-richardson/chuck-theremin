public  class Constants
{
  [0,2,4,5,7,9,11,12] @=> int ionian[];
  [0,2,3,5,7,9,10,12] @=>  int dorian[];
  [0,1,3,5,7,8,10,12] @=>  int phrygian[];
  [0,2,4,6,7,9,11,12] @=>  int lydian[];
  [0,2,4,5,7,9,10,12] @=>  int mixolydian[];
  [0,2,3,5,7,8,10,12] @=>  int aeolian[];
  [0,1,3,5,6,8,10,12] @=>  int locrain[];
  
  [0,3,5,6,7,10,12] @=> int minpent[];
  [0,2,4,7,9,12] @=>  int majpent[];

  [0,2,3,5,7,8,11,12] @=>   int harmminor[];
  [0,2,3,5,7,9,11,12] @=>   int melodminor[];
  
  [0,2,3,6,7,8,11,12] @=>   int hungarian[];
  [0,1,4,5,6,8,11,12] @=>   int persian[];
  [0,1,4,5,7,8,11,12] @=>   int byzantine[];
  [0,1,4,5,6,9,10,12] @=>  int oriental[];
  [0,1,3,5,7,8,10,12] @=>   int indian[];
  [0,2,3,6,7,8,11,12] @=>   int gypsy[];
  [0,1,4,5,7,8,10,12] @=>   int ahava[];
  

  0 => int c;
  1 =>  int cs;
  2 =>  int d;
  3 =>  int ds;
  4 =>  int e;
  5 =>  int f;
  6 =>  int fs;
  7 => int g;
  8 =>  int gs;
  9 =>  int a;
  10 =>  int as;
  11 =>  int b;

 static  int numBeatsPerMeasure;
 static int numMeasures;
 static int numBeats;
  static float bpm;
  static int baseBeat;
  static float tempo;

  static CustomEvent @ event;
  static int key;
  static int scale[];

  0 => static int currentMeasure;

  fun void setTempo()
  {
    numBeatsPerMeasure * numMeasures => numBeats;
    60.0 * numBeatsPerMeasure  / (bpm * baseBeat   ) => tempo;
  }
}

new CustomEvent @=> Constants.event;

