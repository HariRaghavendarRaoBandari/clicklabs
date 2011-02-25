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
    -> shaper::Shaper(RATE $rate)
    -> Unqueue(BURST $burst)
    -> policer
    -> output;

  cal_peak_rate::Script(TYPE ACTIVE, write shaper.rate $(mul $rate $burst));
  autoupdate_changesize::Script(TYPE PASSIVE, 
                                write red.min_thresh $(mul $(q.capacity) 0.5),
                                write red.max_thresh $(mul $(q.capacity) 1.5));
}

elementclass RatedTokenBucketPolicer {
  RATE $rate, BURST $size |

  // Token bucket
  // similar a sample source
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
    -> shaper::Shaper(RATE $rate)
    -> Unqueue(BURST $burst)
    -> policer
    -> output;

  cal_peak_rate::Script(TYPE ACTIVE, write shaper.rate $(mul $rate $burst));
  autoupdate_changesize::Script(TYPE PASSIVE,
                                write red.min_thresh $(mul $(q.capacity) 0.5),
                                write red.max_thresh $(mul $(q.capacity) 1.5));
}

elementclass RatedTokenBucketPolicer1 {
  INTERVAL $interval, BURST $burst, REPEATED $repeated | 
  q::Queue($burst);
  // This TokenGen script increases Queue q size to maximum $burst periodically
  // T = 1/rate
  TokenGen::Script(TYPE ACTIVE, 
                  label GEN,
                  set newcap $(if $repeated $burst $(add $(q.capacity) 1)),
                  goto WAIT $(gt $newcap $burst), 
                  write q.capacity $newcap,
                  label WAIT,
                  wait $interval,
                  goto GEN);
  input
  -> q
  -> TokenReduced::Script(TYPE PACKET, write q.capacity $(sub $(q.capacity) 1))
  //-> RatedUnqueue(RATE $rate)
  -> TimedUnqueue($interval, $burst)
  -> output;
}

elementclass RatedTokenBucketShaper1 {
  SIZE $size, RATE $rate, INTERVAL $interval, BURST $burst, REPEATED $repeated |

  policer::RatedTokenBucketPolicer1(INTERVAL $interval, 
                                    BURST $burst, 
                                    REPEATED $repeated);
  input
    -> q::Queue($size)
    //-> shaper::RatedUnqueue(RATE $rate)
    -> shaper::Shaper(RATE $rate)
    -> TimedUnqueue(INTERVAL $interval, BURST $burst)
    -> policer
    -> output;
}

elementclass RatedTokenBucketPolicer2 {
  RATE $rate, BURST $burst |

  TokenProducer::Script(TYPE PACKET, 
    goto CONTINUE $(lt $(sub $(GenCount.count) $(UseCount.count)) $burst),
    exit,
    label CONTINUE,
    end
  );
  
  TokenConsumer::Script(TYPE PACKET,
    goto CONTINUE $(lt $(UseCount.count) $(GenCount.count)),
    exit,
    label CONTINUE,
    end
  );

  RatedSource(RATE $rate, LENGTH 1)
  -> TokenProducer
  -> GenCount::Counter(COUNT_CALL)
  -> Discard;

  input
  -> TokenConsumer
  -> UseCount::Counter(COUNT_CALL)
  -> output;
}

elementclass RatedTokenBucketShaper2 {
  SIZE $size, RATE $rate, INTERVAL $t,  BURST $burst|

  
  policer::RatedTokenBucketPolicer2(RATE $rate, BURST $burst);
  input
    -> q::Queue($size)
    -> shaper::Shaper(RATE $rate)
    -> tu::TimedUnqueue($t, $burst)
    -> policer
    -> output;
}

elementclass RatedTokenBucketPolicer3 {
  RATE $rate, INTERVAL $t, BURST $burst |

  Init::Script(TYPE ACTIVE, write s.switch $(if $(lt $rate 1000) 1 0));
  //rs::RatedSplitter(RATE $rate);

  //With BandwidthMeter, stream (all packets) is dropped
  //rs::BandwidthMeter($rate);

  input -> s::Switch(1) -> Queue($burst) -> RatedUnqueue($rate) -> output;
  s[1] -> Queue($burst) -> TimedUnqueue($t, 1) -> output;
  //rs[1] -> Discard;
}

elementclass RatedTokenBucketShaper3 {
  SIZE $size, RATE $rate, INTERVAL $t, BURST $burst|

  policer::RatedTokenBucketPolicer3(RATE $rate, INTERVAL $t, BURST $burst);
  input
    -> q::Queue($size)
    -> shaper::Shaper(RATE $rate)
    -> tu::TimedUnqueue($t, $burst)
    -> policer
    -> output;
}

