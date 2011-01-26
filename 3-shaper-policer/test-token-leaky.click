// token-leaky.click
// Simulate traffic policer and shaper: combining of token and leaky bucket

//#include "token-bucket.click"
//#include "leaky-bucket.click"
//#include "uncontrol-flow.click"

elementclass RatedTokenLeakyPolicer {
  PRATE $peak, ARATE $average, BURST $burst |
  
  leaky::RatedLeakyBucketPolicer (RATE $peak);
  token::RatedTokenBucketPolicer (RATE $average, BURST $burst);

  input -> token -> leaky -> output;

}

flow0::UncontrolledFlow (RATE 1000, BURST 10);
//flow1::UncontrolledFlow (RATE 1000, BURST 10);

flow0 -> c1::Counter -> RatedTokenLeakyPolicer(BURST 5, PRATE 10000, ARATE 1000) -> c2::Counter -> Discard;
//flow1 -> c3::Counter -> LeakyBucketShaper(RATE 4000 kbps, SIZE 10000) -> c4::Counter -> Discard;

