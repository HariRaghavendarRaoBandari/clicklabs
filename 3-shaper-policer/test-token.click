// test-token.click

//#include "token-bucket.click"
//#include "uncontrol-flow.click"
//#include "leaky-bucket.click"


//flow0::UncontrolledFlow1(RATE 20, BURST 10, STABLE 10);
//flow1::UncontrolledFlow(RATE 1000, BURST 10);
//flow2::ProbUncontrolledFlow(MAXRATE 3000, PROB_CHANGE 0.3)
//flow3::BurstUncontrolledFlow(RATE 1);

//flow0 
//  -> ToDump(dumpin, SNAPLEN 1)
//  -> c1::Counter
//  -> RatedTokenBucketPolicer1(INTERVAL 1, BURST 10, REPEATED true) 
//  -> ToDump(dumpout, SNAPLEN 1)
//  -> c2::Counter
//  -> Discard;

//flow1
//  -> ToDump(dumpin, SNAPLEN 1)
//  -> c3::Counter
//  -> TokenBucketShaper(RATE 1000, BURST 10, SIZE 5000)
//  -> ToDump(dumpout, SNAPLEN 1)
//  -> c4::Counter
//  -> Discard;

//flow3 -> ToDump(dumpin) -> Discard; //-> tee::Tee(4);

//tee[0] 
FromDump(dumpin, TIMING true)
//Idle
  -> RatedTokenBucketPolicer3(RATE 10, BURST 10, INTERVAL 0.1)
  -> SetTimestamp
  -> ToDump(dumpout_tk, SNAPLEN 1) 
  -> Discard;

//FromDump(dumpin, TIMING true)
//tee[1]
//Idle
//-> RatedTokenBucketShaper3(RATE 10, INTERVAL 0.1, BURST 10, SIZE 10)
//-> SetTimestamp
//-> ToDump(dumpout_tk_shaper, SNAPLEN 1) 
//-> Discard;

//tee[2]
//Idle
FromDump(dumpin, TIMING true)
-> RatedLeakyBucketPolicer(RATE 10,  INTERVAL 0.1)
-> SetTimestamp
-> ToDump(dumpout_lk, SNAPLEN 1)
-> Discard;

//tee[3]
//Idle
//FromDump(dumpin, TIMING true)
//-> RatedLeakyBucketShaper(SIZE 10, RATE 10, INTERVAL 0.1)
//-> SetTimestamp
//-> ToDump(dumpout_lk_shaper, SNAPLEN 1)
//-> Discard;

