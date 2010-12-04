// token-leaky.click
// Simulate traffic policer and shaper: combining of token and leaky bucket

elementclass RatedTokenBucketPolicer {
  RATE $rate, BURST $size |

  // Token bucket
  ps::PullSwitch(1);
  Idle -> [1]ps;
  s::RatedSource(LENGTH 1, LIMIT -1, ACTIVE true, STOP true, RATE $rate)
    -> tokenq::Queue($size)
    -> [0]ps
    -> Script(TYPE PACKET, write ps.switch 1)
    -> Discard;

  sw::Switch(0)
  input 
    -> Script(TYPE PACKET, 
                set t $(tokenq.length), 
                write sw.switch $(if $(gt $t 0) 0 1), 
                write ps.switch $(if $(gt $t 0) 0 1)
                )   
    -> sw;
    
  // Go on output 0
  sw[0] -> output;
  // Die in output 1
  sw[1] -> Discard;
}

elementclass RatedTokenBucketShaper {
  SIZE $size, RATE $rate, BURST $burst |
  
  policer::RatedTokenBucketPolicer(RATE $rate, BURST $burst);
  input
    -> red::RED(100, $size, 0.01)
    -> q::Queue($size)
    -> shaper::RatedUnqueue(RATE $rate)
    -> policer 
    -> output;

  cal_peak_rate::Script(TYPE ACTIVE, write shaper.rate $(mul $rate $burst));
  autoupdate_changesize::Script(TYPE PASSIVE, 
                                write red.min_thresh $(mul $(q.capacity) 0.5),
                                write red.max_thresh $(mul $(q.capacity) 1.5));
}

elementclass UncontrolledFlow {
  RATE $rate, BURST $burst |
  s0::RatedSource(LENGTH 2, RATE $rate);
  s1::RatedSource(LENGTH 2, RATE $rate);
  p::PullSwitch;
  s1 -> q::Queue($burst) -> [1]p;
  s0 -> [0]p;

  p 
    -> Script(TYPE PACKET, write p.switch $(if $(lt $(mod $(random) 10) 4) 1 0))
    -> Unqueue
    -> output;

  autoupdate_change_rate::Script (TYPE PASSIVE, 
                set r $(add $(mod $(random) $rate) 800),
                write s0.rate $r,
                write s1.rate $r);
  autoupdate_change_burst::Script (TYPE PASSIVE,
                set b $(add $(mod $(random) $burst) 1),
                write q.capacity $b);
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

