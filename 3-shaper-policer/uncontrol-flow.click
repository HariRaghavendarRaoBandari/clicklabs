// uncontrol-flow.click
// Simulate rate and burst flow

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

elementclass UncontrolledFlow1 {
  RATE $rate, BURST $burst, STABLE $st |
  s0::InfiniteSource(LENGTH 1, BURST $burst, LIMIT $burst)
    -> output;

  change_rate::Script (TYPE ACTIVE,
                set stable 1,
                set t1 $(div 1 $rate),
                label START,
                set stable $(sub $stable 1),
                goto RESET $(ne $stable 0),
                set stable $st,
                //label SET_RATE,
                set r $(add $(mod $(random) $rate) $(mod $(random) $rate) 1),
                //set r $rate,
                set t1 $(div 1 $r),
                label RESET,
                write s0.reset,
                //print $t1,
                wait $t1,
                goto START);
  autoupdate_change_burst::Script (TYPE PASSIVE,
                set b $(add $(mod $(random) $burst) 1),
                write s0.burst $b,
                write s0.limit $b);
}

//flow0::UncontrolledFlow1(RATE 10, BURST 1, STABLE 5);
//flow0 
//  -> ToDump(dump/dumpucout)
//  -> c1::Counter -> Discard;
