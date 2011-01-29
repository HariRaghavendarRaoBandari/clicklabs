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

flow0::UncontrolledFlow1 (RATE 100, BURST 2, STABLE 25);
ps::PaintSwitch;
flow0 
-> c1::Counter 
-> r::RatedNegotiablePolicer1(CBS 10, CBST 0.01, CEBS 12)
-> ps;
ps[0] -> Discard;
ps[1] -> Discard;
