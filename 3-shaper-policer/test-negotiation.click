// test-negotiation.click
// Negotiate with: CIR, CBS, EBS

//#include "negotiation.click"
//#include "token-bucket.click"

//flow0::UncontrolledFlow1 (RATE 100, BURST 2, STABLE 25);
//ps::PaintSwitch;
//flow0 
//-> c1::Counter 
//-> r::RatedNegotiablePolicer1(CBS 10, CBST 0.01, CEBS 12)
//-> ps
//-> Discard;

//flow2::UncontrolledFlow1 (RATE 100, BURST 2, STABLE 25);
flow3::ProbUncontrolledFlow (MAXRATE 500, PROB_CHANGE 0.6);
flow3
-> SetTimestamp
-> ToDump(dumpin2)
//-> rnp3::RatedNegotiablePolicer4(CBS 50, EBS 10, CIR 100);
-> RatedNegotiablePolicer2(LEAKYRATE 120, INTERVAL 0.00834, EBS 10, CIR 100)
-> SetTimestamp
-> ToDump(dumpout2)
-> Discard;

//tss::TimeSortedSched;
//rnp3[0] 
//-> Queue(100) 
//-> [0]tss 
//-> ToDump(dumpout) 
//-> Unqueue 
//-> Discard;
//rnp3[1] 
//-> Queue(100) 
//-> [1]tss;
//-> Discard;
