// test-token.click

//#include "token-bucket.click"
//#include "uncontrol-flow.click"

//flow0::UncontrolledFlow1(RATE 20, BURST 10, STABLE 10);
//flow1::UncontrolledFlow(RATE 1000, BURST 10);
//flow2::ProbUncontrolledFlow(MAXRATE 200, PROB_CHANGE 0.4)

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

//flow2 -> ToDump(dumpin) -> c1::Counter
//  -> RatedTokenBucketPolicer2(RATE 50, BURST 4) -> ToDump(dumpout) -> c2::Counter
//  -> Discard;

FromDump(dumpin, TIMING true)
-> RatedTokenBucketShaper2(RATE 50, INTERVAL 0.02, BURSTS 2, BURSTP 4, SIZE 1000)
-> ToDump(dumpout_shaper) -> Discard;

