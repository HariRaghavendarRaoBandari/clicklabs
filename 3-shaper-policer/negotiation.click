// test-negotiation.click
// Negotiate with: CIR, CBS, EBS

//#include "token-bucket.click"
//#include "leaky-bucket.click"
//#include "uncontrol-flow.click"

elementclass RatedNegotiablePolicer1 {
  CBST $cbst, CEBS $cebs, CBS $cbs |
  // cir: Committed Information Rate (packets per second)
  // cbs: Committed Burst Size (packets)
  // ebs: Excess Burst Size (packets)
  // acr: Access Rate (packets per second)
  // cebs = cbs + ebs
  // limitation: cbst = cbs/cir >= 0.01

  tuq::TimedUnqueue ($cbst, $cebs);
  q::Queue($cebs);
  p::Paint(0);

  input
  -> MarkingPolicy::Script (TYPE PACKET, 
                      goto LO_PRIO $(gt $(q.length) $cbs),
                      label HI_PRIO,
                      write p.color 0,
                      end,
                      label LO_PRIO,
                      write p.color 1)
  -> p
  -> q
  -> tuq
  -> output;
}

elementclass RatedNegotiablePolicer3 {
  CIR $cir, CBS $cbs, EBS $ebs |

  InitParameters::Script(TYPE ACTIVE,
    goto BEST_EFFORT $(eq 0 $cbs),
    write LowUnqueue.rate $(idiv $(mul $ebs $cir) $cbs),
    end,
    label BEST_EFFORT,
    write LowUnqueue.rate $cir
  );

  ClassifyPacket::Script (TYPE PACKET,
    goto BEST_EFFORT $(eq 0 $cbs),
    set c $(add $(HighCount.count) $(LowCount.count)),
    goto DROP $(eq $c $(add $cbs $ebs)),
    set prio $(if $(lt $(HighCount.count) $cbs) 0 1),
    return $prio,
    label DROP,
    exit, 
    label BEST_EFFORT,
    return 1
  );

  TimingControl::Script (TYPE PACKET,
    goto CONTINUE $(ne $(SampleCount.count) $cbs),
    write HighCount.reset_counts,
    write LowCount.reset_counts,
    write SampleCount.reset_counts,
    label CONTINUE,
    end
  );

  // Holding T
  SampleSource::RatedSource(LENGTH 1, RATE $cir)
  -> TimingControl
  -> SampleCount::Counter(COUNT_CALL)
  -> Discard;

  input
  -> SetTimestamp // This action is done for holding sequence of packets
  -> ClassifyPacket;
  
  ClassifyPacket[0]
  -> HighCount::Counter(COUNT_CALL)
  -> HighQueue::Queue($cbs)
  -> HighUnqueue::RatedUnqueue($cir)
  -> [0]output;

  ClassifyPacket[1]
  -> LowCount::Counter(COUNT_CALL)
  -> Queue($ebs)
  -> LowUnqueue::RatedUnqueue($cir)
  -> [1]output;
}

elementclass RatedNegotiablePolicer4 {
  CIR $cir, CBS $cbs, EBS $ebs |

  InitParameters::Script(TYPE ACTIVE,
    goto BEST_EFFORT $(eq 0 $cbs),
    write LowUnqueue.rate $(idiv $(mul $ebs $cir) $cbs),
    end,
    label BEST_EFFORT,
    write LowUnqueue.rate $cir
  );

  ClassifyPacket::Script (TYPE PACKET,
    goto BEST_EFFORT $(eq 0 $cbs),
    set c $(add $(HighCount.count) $(LowCount.count)),
    goto DROP $(ge $c $(add $cbs $ebs)),
    set prio $(if $(lt $(HighCount.count) $cbs) 0 1),
    return $prio,
    label DROP,
    exit,
    label BEST_EFFORT,
    return 1
  );

  TimingControl::Script (TYPE PACKET,
    goto CONTINUE $(lt $(TimeCount.count) $cbs),
    write HighCount.reset_counts,
    write LowCount.reset_counts,
    write TimeCount.reset_counts,
    label CONTINUE,
    end
  );

  PrioScheduler::PrioSched;

  input
  -> SetTimestamp // This action is done for holding sequence of packets
  -> ClassifyPacket;

  ClassifyPacket[0]
  -> HighCount::Counter(COUNT_CALL)
  -> HighQueue::Queue($cbs)
  -> Paint(0)
  -> [0]PrioScheduler
  -> TimingControl
  -> TimeCount::Counter(COUNT_CALL)
  -> HighUnqueue::RatedUnqueue($cir)
  -> ps::PaintSwitch[0]
  -> [0]output;

  // Holding T
  SampleSource::RatedSource(LENGTH 1, RATE $cir)
  -> Paint(1)
  -> [1]PrioScheduler;

  ps[1] -> Discard;

  ClassifyPacket[1]
  -> LowCount::Counter(COUNT_CALL)
  -> Queue($ebs)
  -> LowUnqueue::RatedUnqueue($cir)
  -> [1]output;
}

elementclass RatedNegotiablePolicer2 {
  LEAKYRATE $lr, INTERVAL $interval, CIR $cir, EBS $ebs, CEBS $cebs | 
  // interval = 1/rate

  input 
  -> leaky::RatedLeakyBucketShaper(SIZE $cebs, RATE $lr, INTERVAL $interval)
  -> token::RatedTokenBucketShaper2(SIZE 1000, RATE $cir, BURST $ebs)
  -> output
}


