// VC_Sched.click
// Simulate Virtual Clock Scheduling

elementclass 3flows_VCSched {
  $rate1, $rate2, $rate3 |
  tss::TimeSortedSched;
  
  input[0]
  -> Paint(0)
  -> SetVirtualClock(RATE $rate1, MAXBW 3, CURRENTBW 3)
  -> Queue
  -> [0] tss;

  input[1]
  -> Paint(1)
  -> SetVirtualClock(RATE $rate2, MAXBW 3, CURRENTBW 3)
  -> Queue
  -> [1] tss;

  input[2]
  -> Paint(2)
  -> SetVirtualClock(RATE $rate3, MAXBW 3, CURRENTBW 3)
  -> Queue
  -> [2] tss;

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
vcsched::3flows_VCSched(1,1,1);

RatedSource(RATE 1, LENGTH 1, STOP false, LIMIT 10)
-> [0]vcsched; 

RatedSource(RATE 1, LENGTH 1, STOP false, LIMIT 10)
-> [1]vcsched;

Delay3::Script(TYPE ACTIVE, wait 5, write s3.active true);
s3::RatedSource(RATE 3, LENGTH 1, STOP false, LIMIT 10, ACTIVE false)
-> [2]vcsched;

vcsched
-> TimedUnqueue(1,1)

-> SetTimestamp
-> ps::PaintSwitch;

ps[0]
//-> ToDump(out01, SNAPLEN 1)
//-> Print("flow 0", 1, TIMESTAMP true)
-> Discard;

ps[1]
//-> ToDump(out11, SNAPLEN 1)
//-> Print("flow 1", 1, TIMESTAMP true)
-> Discard;

ps[2]
//-> ToDump(out21, SNAPLEN 1)
//-> Print("flow 2", 1, TIMESTAMP true)
-> Discard;

