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

//Rated prefix: packets per sec.
//Bandwidth prefix: bits per sec.
elementclass RatedLeakyBucketPolicer {
  RATE $rate, INTERVAL $i |

  Init::Script(TYPE ACTIVE, write s.switch $(if $(lt $rate 1000) 1 0));
  //rs::RatedSplitter(RATE $rate);

  //With BandwidthMeter, stream (all packets) is dropped
  //rs::BandwidthMeter($rate);
  
  input -> s::Switch(1) -> qr::SimpleQueue(1) -> RatedUnqueue($rate) -> output;
  s[1] -> qt::SimpleQueue(1) -> TimedUnqueue($i, 1) -> output;
  //rs[1] -> Discard;
  qr[1] -> Discard;
  qt[1] -> Discard;
}

elementclass RatedLeakyBucketShaper {
  SIZE $size, RATE $rate, INTERVAL $i |

  input
//  -> red::RED(100, $size, 0.01)
  -> q::Queue($size)
  -> RatedUnqueue($rate)
  -> RatedLeakyBucketPolicer(RATE $rate, INTERVAL $i)
  -> output;
}

