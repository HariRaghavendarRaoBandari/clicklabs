// test-token.click

//#include "token-bucket.click"
//#include "uncontrol-flow.click"

flow0::UncontrolledFlow(RATE 1000, BURST 10);
flow1::UncontrolledFlow(RATE 1000, BURST 10);

flow0 -> c1::Counter -> TokenBucketPolicer(RATE 1000, BURST 10) -> c2::Counter
-> Discard;
flow1
  -> ToDump(dumpin, SNAPLEN 1)
  -> c3::Counter
  -> TokenBucketShaper(RATE 1000, BURST 10, SIZE 5000)
  -> ToDump(dumpout, SNAPLEN 1)
  -> c4::Counter
  -> Discard;

