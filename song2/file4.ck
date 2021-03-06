SawOsc saw =>  Gen17 gen => LPF lpf => HPF hpf => Pan2 mix =>  Pan2 master => dac; 
mix => NRev revL => PitShift shiftL => master.left; revL.mix(1); revL.gain(.2); shiftL.shift(4);
mix => NRev revR => PitShift shiftR => master.right; revR.mix(1); revR.gain(.2); shiftR.shift(4.01);
hpf => Pan2 dry => mix; dry.gain(0); lpf.Q(2); hpf.Q(3);
Step s => ADSR filtEnv => blackhole;
filtEnv.set(2000::ms, 2000::ms, 0, 1::ms);
gen.coefs( [ 2.2, .3, 0, 0.2, 1.2, .34, .2] );

-1.0 => master.pan;
master.gain(.05);
saw.freq(60);

Constants c;
c.populateScale();

fun void filtMod()
{
    while( true )
    {
        filtEnv.last() * 700 + 20 => lpf.freq;
        filtEnv.last() * 400  => hpf.freq;
        1::samp => now;
        
    }
}

spork~ filtMod();
while( true )
{
 Math.random2(1,c.scale.cap()) => int stepNum;
    filtEnv.keyOn(1);
   c.getFreq(stepNum, 5) => saw.freq;
      /*<<< "now", stepNum, "freq", saw.freq() >>>;*/
    2::second => now;
}

