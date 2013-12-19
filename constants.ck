public  class Constants
{
  [0,2,4,5,7,9,11,12] @=> int ionian[];
  [0,2,3,5,7,9,10,12] @=>  int dorian[];
  [0,1,3,5,7,8,10,12] @=>  int phrygian[];
  [0,2,4,6,7,9,11,12] @=>  int lydian[];
  [0,2,4,5,7,9,10,12] @=>  int mixolydian[];
  [0,2,3,5,7,8,10,12] @=>  int aeolian[];
  [0,1,3,5,6,8,10,12] @=>  int locrian[];
  
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
  8 => int octaveRange;
  1 => int startOctave;
  int fullScale[ionian.cap() * (octaveRange)];

  0 => static int currentMeasure;

  fun int[] getScale(int number)
  {
    if(number == 1)
      return ionian;
    else if(number == 2)
      return dorian;
    else if(number == 3)
      return phrygian ;
    else if(number == 4)
      return lydian;
    else if(number == 5)
      return mixolydian;
    else if(number == 6)
      return aeolian;
    else if(number == 7)
      return locrian;
    else if(number == 8)
      return minpent;
    else if(number == 9)
      return majpent;
    else if(number == 10)
      return hungarian;
    else if(number == 11)
      return persian;
    else if(number == 12)
      return gypsy;

  }

  fun void setTempo()
  {
    numBeatsPerMeasure * numMeasures => numBeats;
    60.0 * numBeatsPerMeasure  / (bpm * baseBeat   ) => tempo;
  }

  fun void setKey(int newKey)
  {
    newKey => key;
    populateScale();
  }

  fun void setScale(int newScale[])
  {
    newScale @=> scale;
    populateScale();
  }

  fun void setKeyAndScale(int newKey, int newScale[])
  {
    newScale @=> scale;
    newKey => key;
    populateScale();
  }

  fun void populateScale()
  {
    for(0 => int i; i < scale.cap(); i++)
    {
      for(0 => int j; j < octaveRange; j++)
      {
        /*i + j => fullScale[i + (scale.cap()-1)*j];*/
        scale[i] + j*12 + key @=> fullScale[i + (scale.cap()-1)*j];
      }
    }
  }

  fun float getFreq(int midiNum, int startOctave)
  {
     return Std.mtof(fullScale[midiNum -1] + startOctave*12);
  }
    


}

new CustomEvent @=> Constants.event;

