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

  // This is controller to control the gate (ps pullswitch)
  sw::Switch(0)
  input 
    -> Script(TYPE PACKET, 
                set t $(tokenq.length), 
                write sw.switch $(if $(gt $t 0) 0 1), 
                write ps.switch $(if $(gt $t 0) 0 1)
                )
    -> sw;

  // Legal packets Go to output 0
  sw[0] -> output;
  // Illegal packets Die in output 1
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
                set r $(add $(mod $(random) $rate) 800),
                write s0.rate $r, 
                write s1.rate $r);
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


flow0::UncontrolledFlow(RATE 1000, BURST 10);
flow1::UncontrolledFlow(RATE 1000, BURST 10);

flow0 -> c1::Counter -> TokenBucketPolicer(RATE 1000, BURST 10) -> c2::Counter -> Discard;
flow1
  -> ToDump(dumpin, SNAPLEN 1)
  -> c3::Counter 
  -> TokenBucketShaper(RATE 1000, BURST 10, SIZE 5000) 
  -> ToDump(dumpout, SNAPLEN 1)
  -> c4::Counter 
  -> Discard;

