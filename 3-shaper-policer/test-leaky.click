// test-leaky.click
// iizke

//#include "leaky-bucket.click"
//#include "uncontrol-flow.click"

//flow0::BandwidthUncontrolledFlow (RATE 500000, BURST 10);
flow1::BandwidthUncontrolledFlow (RATE 500000, BURST 10);

//flow0 -> c1::Counter -> LeakyBucketPolicer(RATE 4000 kbps) -> c2::Counter ->
//Discard;
flow1 -> ToDump(./dumpin, SNAPLEN 1)
      -> c3::Counter -> LeakyBucketShaper(RATE 10000 kbps, SIZE 10000)
      -> Queue (100) -> LinkUnqueue(LATENCY 1s, BANDWIDTH 12Mbps)
      -> c4::Counter
      -> ToDump(./dumpout, SNAPLEN 1)
      -> Discard;

utoupdate_Backlog0Calc::Script (TYPE PASSIVE,
                      set count1 $(c1.count),
                      set count2 $(c2.count),
                      return $(sub $count1 $count2));

autoupdate_Backlog1Calc::Script (TYPE PASSIVE,
                      set count3 $(c3.count),
                      set count4 $(c4.count),
                      return $(sub $count3 $count4));

reset_button::Script (TYPE PASSIVE,
                      write c1.reset,
                      write c2.reset,
                      write c3.reset,
                      write c4.reset);

utoupdate_Delay1Calc::Script (TYPE ACTIVE,
                      set tin $(now),
                      set count3 $(c3.count),
                      print $tin,
                      label DELAY,
                      wait 0.1ms,
                      set tout $(now),
                      print $tout,
                      set count4 $(c4.count),
                      goto DELAY $(lt $count4 $count3),
                      return $(sub $count4 $count3));


