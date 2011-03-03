// test-leaky.click
// iizke

//#include "leaky-bucket.click"
//#include "uncontrol-flow.click"

//flow0::BandwidthUncontrolledFlow (RATE 500000, BURST 10);
//flow1::BandwidthUncontrolledFlow (RATE 500000, BURST 10);
flow2::ProbUncontrolledFlow (MAXRATE 1000, PROB_CHANGE 0.2);
//flow3::RatedSource(RATE 10);

//flow0 -> c1::Counter -> LeakyBucketPolicer(RATE 4000 kbps) -> c2::Counter ->
//Discard;
//flow1 -> ToDump(dumpin, SNAPLEN 1)
//      -> c3::Counter -> LeakyBucketShaper(RATE 10000 kbps, SIZE 10000)
//      -> Queue (100) -> LinkUnqueue(LATENCY 1s, BANDWIDTH 12Mbps)
//      -> c4::Counter
//      -> ToDump(dumpout, SNAPLEN 1)
//      -> Discard;

flow2 
//-> ToDump(dumpin)
//-> tee::Tee (2);
//tee[0]
      //-> c3::Counter 
      //-> RatedLeakyBucketPolicer(RATE 400)
      //-> Queue (60) -> RatedUnqueue(10)
      //-> c4::Counter
      //-> SetTimestamp
      //-> ToDump(dumpout)
      //-> Discard;

//FromDump(./dumpin, TIMING true)
//tee[1]
-> RatedLeakyBucketShaper(SIZE 2000, RATE 400, INTERVAL 0.01)
//-> SetTimestamp
//-> ToDump(dumpout_shaper)
-> Discard;
