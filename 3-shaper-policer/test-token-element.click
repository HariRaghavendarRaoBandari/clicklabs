// test-token.click

//#include "token-bucket.click"
//#include "uncontrol-flow.click"
//#include "leaky-bucket.click"


//flow::UncontrolledFlow1(RATE 20, BURST 10, STABLE 10);
//flow::UncontrolledFlow(RATE 1000, BURST 10);
//flow::ProbUncontrolledFlow(MAXRATE 60, PROB_CHANGE 0.7);
flow::BurstUncontrolledFlow(RATE 2);


flow 
//-> SetTimestamp -> ToDump(dumpin) 
-> RatedToken(BURST 5, RATE 2)
-> Print("out", TIMESTAMP true)
//-> ToDump(dumpout_tk_element, SNAPLEN 1)
-> Discard;
