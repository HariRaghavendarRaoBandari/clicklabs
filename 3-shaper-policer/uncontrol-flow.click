// uncontrol-flow.click
// Simulate rate and burst flow

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
                set r $(add $(mod $(random) $rate) $(mod $(random) $rate) 100),
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

flow0::UncontrolledFlow1(RATE 1000, BURST 20, STABLE 100);
flow0 
  -> ToDump(dump/dumpucout)
  -> c1::Counter -> Discard;
