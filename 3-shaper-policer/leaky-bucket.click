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
  RATE $rate |

  rs::RatedSplitter(RATE $rate);
  //With BandwidthMeter, stream (all packets) is dropped
  //rs::BandwidthMeter($rate);
  input -> rs;
  rs[0] -> output;
  rs[1] -> Discard;
}

elementclass RatedLeakyBucketShaper {
  SIZE $size, RATE $rate |

  input
//  -> red::RED(100, $size, 0.01)
  -> q::Queue($size)
  -> shaper::BandwidthRatedUnqueue(RATE $rate)
  -> rs::BandwidthRatedSplitter(RATE $rate);
  rs[0] -> output;
  rs[1] -> Discard;

  autoupdate_changerate::Script(TYPE PASSIVE, 
                                set r $(rs.rate),
                                write shaper.rate $r);
  //autoupdate_changesize::Script(TYPE PASSIVE,
  //                              write red.min_thresh $(mul $(q.capacity) 0.5),
  //                              write red.max_thresh $(mul $(q.capacity) 1.5));
}

