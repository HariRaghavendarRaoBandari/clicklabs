// WFQ_Sched.click
// Simulate Weighted Fair Queueing Scheduling

elementclass WFQSched {
  $rate0, $rate1, $rate2 |
  tss::TimeSortedSched;
  Init::Script (TYPE ACTIVE,
    set maxbw $(add $rate0 $rate1 $rate2),
    write vc0.maxbw $maxbw,
    write vc1.maxbw $maxbw,
    write vc2.maxbw $maxbw,
    write vc0.currentbw $maxbw,
    write vc1.currentbw $maxbw,
    write vc2.currentbw $maxbw,
  );
  UpdateCurrentBW::Script (TYPE ACTIVE,
    wait 1.1,
    set currentbw 0,

    set check $(if $(eq $(c0.count) 0) 0 1),
    write c0.reset,
    set currentbw $(add $currentbw $(mul $rate0 $check)),

    set check $(if $(eq $(c1.count) 0) 0 1),
    write c1.reset,
    set currentbw $(add $currentbw $(mul $rate1 $check)),

    set check $(if $(eq $(c2.count) 0) 0 1),
    write c2.reset,
    set currentbw $(add $currentbw $(mul $rate2 $check)),
    
    write vc0.currentbw $currentbw,
    write vc1.currentbw $currentbw,
    write vc2.currentbw $currentbw,
    
//    print $(vc0.lasttag) $(vc1.lasttag) $(vc2.lasttag),
    loop,
  );

  input[0]
  -> Paint(0)
  -> c0::Counter
  -> vc0::SetVirtualClock(RATE $rate0, MAXBW 3, CURRENTBW 3)
  -> Queue
  -> [0] tss;

  input[1]
  -> Paint(1)
  -> c1::Counter
  -> vc1::SetVirtualClock(RATE $rate1, MAXBW 3, CURRENTBW 3)
  -> Queue
  -> [1] tss;

  input[2]
  -> Paint(2)
  -> c2::Counter
  -> vc2::SetVirtualClock(RATE $rate2, MAXBW 3, CURRENTBW 3)
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
sched::WFQSched(1,1,1);

RatedSource(RATE 1, LENGTH 3, STOP false, LIMIT 50)
-> [0]sched; 

RatedSource(RATE 1, LENGTH 3, STOP false, LIMIT 50)
-> [1]sched;

Delay3::Script(TYPE ACTIVE, wait 15, write s3.active true);
s3::RatedSource(RATE 1, LENGTH 3, STOP false, LIMIT 50, ACTIVE false)
-> [2]sched;

sched
-> TimedUnqueue(1,1)
//-> SetTimestamp
-> ps::PaintSwitch;

ps[0]
//-> ToDump(out0, SNAPLEN 1)
//-> Print("flow 0", 1, TIMESTAMP true)
-> Discard;

ps[1]
//-> ToDump(out1, SNAPLEN 1)
//-> Print("flow 1", 1, TIMESTAMP true)
-> Discard;

ps[2]
//-> ToDump(out2, SNAPLEN 1)
//-> Print("flow 2", 1, TIMESTAMP true)
-> Discard;

