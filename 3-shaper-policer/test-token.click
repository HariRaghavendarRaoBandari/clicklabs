// test-token.click

//#include "token-bucket.click"
//#include "uncontrol-flow.click"
//#include "leaky-bucket.click"


//flow0::UncontrolledFlow1(RATE 20, BURST 10, STABLE 10);
//flow1::UncontrolledFlow(RATE 1000, BURST 10);
//flow2::ProbUncontrolledFlow(MAXRATE 60, PROB_CHANGE 0.7);
//flow3::BurstUncontrolledFlow(RATE 1);


//flow2 -> ToDump(dumpin2) -> tee::Tee(2);
FromDump(dumpin2, TIMING true) -> SetTimestamp -> ToDump(dumpin) 
-> tee::Tee(6);

tee[0] 
  -> RatedTokenBucketPolicer3(RATE 10, BURST 10, INTERVAL 0.1)
  -> SetTimestamp
  -> ToDump(dumpout_tk3, SNAPLEN 1) 
  -> Discard;

tee[1]
-> RatedTokenBucketShaper3(RATE 10, INTERVAL 0.1, BURST 10, SIZE 500)
-> SetTimestamp
-> ToDump(dumpout_tk_shaper3, SNAPLEN 1) 
-> Discard;

tee[2]
-> RatedLeakyBucketPolicer(RATE 10,  INTERVAL 0.1)
-> SetTimestamp
-> ToDump(dumpout_lk, SNAPLEN 1)
-> Discard;

tee[3]
-> RatedLeakyBucketShaper(SIZE 500, RATE 10, INTERVAL 0.1)
-> SetTimestamp
-> ToDump(dumpout_lk_shaper, SNAPLEN 1)
-> Discard;

tee[4]
-> RatedTokenBucketPolicer2(RATE 10, BURST 10)
-> SetTimestamp
-> ToDump(dumpout_tk2, SNAPLEN 1)
-> Discard;

tee[5]
-> RatedTokenBucketShaper2(RATE 10, INTERVAL 0.1, BURST 10, SIZE 500)
-> SetTimestamp
-> ToDump(dumpout_tk_shaper2, SNAPLEN 1)
-> Discard;

