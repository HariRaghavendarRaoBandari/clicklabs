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
    set LowPrioRate $(idiv $(mul $ebs $cir) $cbs),
    write LowUnqueue.rate $LowPrioRate
  );

  ClassifyPacket::Script (TYPE PACKET,
    set c $(add $(HighCount.count) $(LowCount.count)),
    goto DROP $(eq $c $(add $cbs $ebs)),
    set prio $(if $(lt $(HighCount.count) $cbs) 0 1),
    return $prio,
    label DROP,
    exit
  );

  TimingControl::Script (TYPE PACKET,
    goto CONTINUE $(ne $(HighCount.count) $cbs),
    goto CONTINUE $(ne $(HighQueue.length) 0),
    write HighCount.reset_counts,
    write LowCount.reset_counts,
    label CONTINUE,
    return 0
  );

  input
  -> SetTimestamp // This action is done for holding sequence of packets
  -> ClassifyPacket;
  
  ClassifyPacket[0]
  -> HighCount::Counter(COUNT_CALL)
  -> HighQueue::Queue($cbs)
  -> TimingControl
  -> HighUnqueue::RatedUnqueue($cir)
  -> [0]output;

  ClassifyPacket[1]
  -> LowCount::Counter(COUNT_CALL)
  -> Queue($ebs)
  -> LowUnqueue::RatedUnqueue($cir)
  -> [1]output;
}

elementclass RatedNegotiablePolicer2 {
  CEBS $cebs, INTERVAL $interval, BURST $burst | 
  // interval = 1/rate

  sp::RatedTokenBucketShaper1(SIZE $cebs, INTERVAL $interval, BURST $burst, REPEATED true);
  input -> sp -> output;
}


