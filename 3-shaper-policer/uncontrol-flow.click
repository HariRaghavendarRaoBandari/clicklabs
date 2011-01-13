// uncontrol-flow.click
// Simulate rate and burst flow

elementclass UncontrolledFlow1 {
  RATE $rate, BURST $burst, TIME $t |
  s0::InfiniteSource(LENGTH 1, BURST $burst, LIMIT $burst)
    -> output;

  change_rate::Script (TYPE ACTIVE,
                set r $(add $(mod $(random) $rate) 1),
                set t1 $(div 1 $r),
                write s0.reset,
                //print $t1,
                wait $t1,
                loop);
  autoupdate_change_burst::Script (TYPE PASSIVE,
                set b $(add $(mod $(random) $burst) 1),
                write s0.burst $b,
                write s0.limit $b);
}
flow0::UncontrolledFlow1(RATE 10000, BURST 3, TIME 0.001);
flow0 
  -> ToDump(dumpucout)
  -> c1::Counter -> Discard;
