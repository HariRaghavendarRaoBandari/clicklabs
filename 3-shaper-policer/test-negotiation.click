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
flow3::ProbUncontrolledFlow (MAXRATE 300, PROB_CHANGE 0.6)
-> SetTimestamp
-> ToDump(dumpin)
-> tee::Tee(3);

tee[0]
//-> RatedNegotiablePolicer2(LEAKYRATE 120, INTERVAL 0.00833, EBS 10, CIR 100, CEBS 60)
//-> SetTimestamp
//-> ToDump(dumpout2)
-> Discard;

tee[1]
-> rnp4::RatedNegotiablePolicer4(CBS 50, EBS 10, CIR 100);
tss::TimeSortedSched;
rnp4[0] 
-> Queue(100) 
-> [0]tss 
-> Unqueue
-> SetTimestamp
-> ToDump(dumpout4) 
-> Discard;
rnp4[1] 
-> Queue(100) 
-> [1]tss
-> Discard;

tee[2]
-> srTCM_blind(CIR 100, CBS 50, EBS 10)
-> cp::CheckPaint(0)
-> Discard;
cp[1]
-> SetTimestamp
-> ToDump(out_gy, SNAPLEN 1)
-> Discard;
