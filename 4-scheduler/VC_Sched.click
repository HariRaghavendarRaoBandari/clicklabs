// VC_Sched.click
// Simulate Virtual Clock Scheduling

elementclass 2flows_VCSched {
  RATE1 $rate1, RATE2 $rate2 |
  tss::TimeSortedSched;
  
  input[0]
  -> Paint(0)
  -> SetVirtualClock(RATE $rate1)
  -> Queue
  -> [0] tss;

  input[1]
  -> Paint(1)
  -> SetVirtualClock(RATE $rate2)
  -> Queue
  -> [1] tss;
  tss
  -> output;
}

// This code is to test new Click element: SetVirtualClock
//InfiniteSource(LENGTH 10, BURST 2, LIMIT 2, STOP true)
//-> Print("f", 1, TIMESTAMP true)
//-> SetVirtualClock(RATE 1)
//-> Print("a", 1, TIMESTAMP true)
//-> Discard;

// This code implement VC Sched based on TimeSortedSched
vcsched::2flows_VCSched(RATE1 1, RATE2 2);

RatedSource(RATE 1, LENGTH 10, STOP false, LIMIT 5)
-> [0]vcsched; 

RatedSource(RATE 2, LENGTH 10, STOP false, LIMIT 5)
-> [1]vcsched;

vcsched
-> Unqueue
-> ps::PaintSwitch;

ps[0]
-> Print("flow 0", 1, TIMESTAMP true)
-> Discard;

ps[1]
-> Print("flow 1", 1, TIMESTAMP true)
-> Discard;

