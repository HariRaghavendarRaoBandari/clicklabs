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

//flow1::UncontrolledFlow1 (RATE 100, BURST 2, STABLE 25);
//flow1
//-> RatedNegotiablePolicer2(CEBS 12, INTERVAL 0.1, BURST 2)
//-> Discard;

flow2::UncontrolledFlow1 (RATE 200, BURST 2, STABLE 25);
flow2
-> rnp3::RatedNegotiablePolicer3(CBS 0, EBS 3, CIR 100);
rnp3[0] -> Discard;
rnp3[1] -> Discard;

