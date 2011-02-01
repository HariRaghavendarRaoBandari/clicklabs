// test-token.click

//#include "token-bucket.click"
//#include "uncontrol-flow.click"

flow0::UncontrolledFlow1(RATE 20, BURST 10, STABLE 10);
//flow1::UncontrolledFlow(RATE 1000, BURST 10);

flow0 
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

flow0
//  -> ToDump(dumpin, SNAPLEN 1)
  -> c1::Counter
  -> RatedTokenBucketPolicer2(RATE 1000, BURST 100, REPEATED true)
//  -> ToDump(dumpout, SNAPLEN 1)
  -> c2::Counter
  -> Discard;

