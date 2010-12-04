// leaky-bucket.click
// Simulate traffic policer and shaper: leaky bucket

elementclass LeakyBucketPolicer {
  RATE $rate |

  rs::BandwidthRatedSplitter(RATE $rate);
  //With BandwidthMeter, stream (all packets) is dropped
  //rs::BandwidthMeter($rate);
  input -> rs;
  rs[0] -> output;
  rs[1] -> Discard;
}

elementclass LeakyBucketShaper {
  SIZE $size, RATE $rate |
  
  input
    -> red::RED(100, $size, 0.01)
    -> q::Queue($size)
    -> shaper::BandwidthRatedUnqueue(RATE $rate)
    -> rs::BandwidthRatedSplitter(RATE $rate);
    rs[0] -> output;
    rs[1] -> Discard;

  autoupdate_changerate::Script(TYPE PASSIVE, 
                                set r $(rs.rate),
                                write shaper.rate $r);
  autoupdate_changesize::Script(TYPE PASSIVE, 
                                write red.min_thresh $(mul $(q.capacity) 0.5),
                                write red.max_thresh $(mul $(q.capacity) 1.5));
}

elementclass UncontrolledFlow {
  s::InfiniteSource(LENGTH 100, LIMIT -1, ACTIVE true, STOP true, BURST 1)
    -> link::BandwidthRatedUnqueue(RATE 1000kbps)
    -> output;

  change_rate::Script(TYPE ACTIVE, 
              wait 4,
              set r $(add $(mod $(random) 5000) 900)kbps,
              write link.rate $r,
              loop );
  change_burst::Script(TYPE ACTIVE, 
              wait 1,
              set r $(add $(mod $(random) 100) 1),
              write s.burst $r,
              loop);
}

flow0::UncontrolledFlow;
flow1::UncontrolledFlow;

flow0 -> c1::Counter -> LeakyBucketPolicer(RATE 4000 kbps) -> c2::Counter -> Discard;
flow1 -> c3::Counter -> LeakyBucketShaper(RATE 4000 kbps, SIZE 10000) -> c4::Counter -> Discard;

