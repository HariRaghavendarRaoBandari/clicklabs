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

elementclass BandwidthUncontrolledFlow {
  RATE $rate, BURST $burst |

  p::PullSwitch;
  s1::InfiniteSource(LENGTH 1000, LIMIT -1, ACTIVE true, STOP true, BURST 1)
    -> bs1::BandwidthRatedUnqueue(RATE $rate)
    -> q::Queue($burst)
    -> [1]p;
  s0::InfiniteSource(LENGTH 1000, LIMIT -1, ACTIVE true, STOP true, BURST 1)
    -> bs0::BandwidthShaper(RATE $rate)
    -> [0]p;

  p
    -> Script(TYPE PACKET,
              goto END1 $(eq $(s0.active) false),
              goto END0 $(eq $(s1.active) false),
              goto END1 $(lt $(mod $(random) 10) 4),
              label END0,
              write p.switch 0,
              goto END,
              label END1,
              write p.switch 1,
              label END)
    -> Unqueue(BURST $burst)
    -> output;

  autoupdate_change_rate::Script (TYPE PASSIVE,
                set r $(add $(mod $(random) $rate) $rate),
                write bs0.rate $r, 
                write bs1.rate $r
                );
  autoupdate_change_burst::Script (TYPE PASSIVE,
                set b $(add $(mod $(random) $burst) 2), 
                write q.capacity $b);
  autoupdate_switch::Script (TYPE PASSIVE, 
              goto END1 $(eq $(s0.active) false),
              goto END0 $(eq $(s1.active) false),
              goto END,
              label END0,
              write p.switch 0,
              goto END,
              label END1,
              write p.switch 1,
              label END);

}

flow0::BandwidthUncontrolledFlow (RATE 500000, BURST 10);
flow1::BandwidthUncontrolledFlow (RATE 500000, BURST 10);

flow0 -> c1::Counter -> LeakyBucketPolicer(RATE 4000 kbps) -> c2::Counter -> Discard;
flow1 -> c3::Counter -> LeakyBucketShaper(RATE 4000 kbps, SIZE 10000) -> c4::Counter -> Discard;

