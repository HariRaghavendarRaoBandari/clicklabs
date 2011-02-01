// VC_Sched.click
// Simulate Virtual Clock Scheduling

// This code is to test new Click element: SetVirtualClock
//InfiniteSource(LENGTH 10, BURST 2, LIMIT 2, STOP true)
//-> Print("f", 1, TIMESTAMP true)
//-> SetVirtualClock(RATE 1)
//-> Print("a", 1, TIMESTAMP true)
//-> Discard;

// This code implement VC Sched based on TimeSortedSched
tss::TimeSortedSched;
RatedSource(LENGTH 10, LIMIT 5, STOP true, RATE 1)
-> Paint(0)
-> SetVirtualClock(RATE 1)
-> Queue(10)
-> [0] tss;

RatedSource(LENGTH 10, LIMIT 5, STOP true, RATE 2)
-> Paint(1)
-> SetVirtualClock(RATE 2)
-> Queue(10)
-> [1] tss;

tss
-> Unqueue
-> ps::PaintSwitch;

ps[0]
-> Print("flow 0", 1, TIMESTAMP true)
-> Discard;

ps[1]
-> Print("flow 1", 1, TIMESTAMP true)
-> Discard;

