// token-bucket.click
// Simulate traffic policer and shaper: token bucket

elementclass TokenBucketPolicer {
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

elementclass TokenBucketShaper {
  SIZE $size, RATE $rate, BURST $burst |
  
  policer::TokenBucketPolicer(RATE $rate, BURST $burst);
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
                set r $(add $(mod $(random) 2000) 800),
                write s0.rate $r,
                write s1.rate $r);
  autoupdate_change_burst::Script (TYPE PASSIVE,
                set b $(add $(mod $(random) 10) 1),
                write q.capacity $b);
}

flow0::UncontrolledFlow(RATE 1000, BURST 10);
flow1::UncontrolledFlow(RATE 1000, BURST 10);

flow0 -> c1::Counter -> TokenBucketPolicer(RATE 1000, BURST 10) -> c2::Counter -> Discard;
flow1 -> c3::Counter -> TokenBucketShaper(RATE 1000, BURST 10, SIZE 5000) -> c4::Counter -> Discard;

