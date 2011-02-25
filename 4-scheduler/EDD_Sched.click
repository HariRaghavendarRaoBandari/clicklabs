// EDD_Sched.click
// Simulate the Earliest Due Date algorithm.

elementclass SetDeadline {
  DEADLINE $d, STORETS $sb |

  StoreDeadline::Script (TYPE PACKET,
    goto END $sb,
    return 0,
    label END,
    return 1,
  );

  input 
  -> SetTimestamp2(FIRST true, ADD $d) 
  -> StoreDeadline[0] -> output;
  
  StoreDeadline[1] -> Unstrip(8) -> StoreTimestamp(OFFSET 0) 
  -> output;
}

// Assume that deadline is put in timestamp annotation of packets
elementclass _EDDSched0 {
  DEAD0 $d0, DEAD1 $d1, OUTRATE $or |
    
  Init::Script(TYPE ACTIVE,
      //write GlobalQueue.capacity $(mul 2 $or $(if $(lt $d0 $d1) $d1 $d0)),
      //set ir $(if (lt $ir $or) $or $ir),
      write DeadlineQueue0.capacity $(add 2000 $(mul 2 $or $d0)),
      write DeadlineQueue1.capacity $(add 2000 $(mul 2 $or $d1)),
     );
    
  sched::TimeSortedSched;
  DeadlineQueue0::Queue(1000);
  DeadlineQueue1::Queue(10);
//  DeadlineQueue2::Queue(100);
  
  input[0] 
  -> SetDeadline(DEADLINE $d0, STORETS false)
  -> DeadlineQueue0 
  -> ct0::CheckTimestamp[0] 
  -> [0]sched 
  -> CheckTimestamp
  -> RatedUnqueue($or)
  -> output;
  input[1] 
  -> SetDeadline(DEADLINE $d1, STORETS false)
  -> DeadlineQueue1 
  -> ct1::CheckTimestamp[0] 
  -> [1]sched;
//  input[2] -> DeadlineQueue2 -> [2]sched;
  //ct0[1] -> Discard;
  //ct1[1] -> Discard;
}

// Assume that deadline is put in first 8 byte of packets.
elementclass _EDDSched1 {
  DEAD0 $d0, DEAD1 $d1, OUTRATE $or |
  

  Init::Script(TYPE ACTIVE,
    write DeadlineQueue0.capacity $(add 800 $(mul 2 $or $d0)),
    write DeadlineQueue1.capacity $(add 800 $(mul 2 $or $d1)),
  );

  sched::EDDSched(TSANNO true);
  DeadlineQueue0::Queue(15);
  DeadlineQueue1::Queue(30);
//  DeadlineQueue2::Queue(100);

  input[0] 
  -> SetDeadline(DEADLINE $d0, STORETS false)
  -> DeadlineQueue0 
  -> [0]sched 
  -> RatedUnqueue($or)
  -> output;
  input[1] 
  -> SetDeadline(DEADLINE $d1, STORETS false)
  -> DeadlineQueue1 
  -> [1]sched;
//  input[2] -> DeadlineQueue2 -> [2]sched;
}


// Improving EDD Scheduler with known output rate (bandwidth)
// assume that DEAD0 < DEAD1
elementclass _EDDSched2 {
  MININRATE $ir, OUTRATE $or, DEAD0 $d0, DEAD1 $d1 |

  elementclass ShouldDrop {
    DELAY $d, QUEUE $i |

    input 
    -> Script(TYPE PACKET, 
        set l $(add $(GlobalQueue.length) $(DeadlineQueue$i.length)),
        //set l $(GlobalQueue.length),
        set t $(mul 1.7 $or $d),
        goto CONTINUE $(le $l $t),
        exit,
        label CONTINUE,
        end)
    -> output;
  }
  
  Init::Script(TYPE ACTIVE, 
    write GlobalQueue.capacity $(mul 2 $or $(if $(lt $d0 $d1) $d1 $d0)),
    write ru.rate $(if $(lt $ir $or) $or $ir),
    write DeadlineQueue0.capacity $(add 5 $(mul 2 $or $d0)),
    write DeadlineQueue1.capacity $(add 5 $(mul 2 $or $d1)),
  );

  sched0::EDDSched(TSANNO true);
  sched1::EDDSched(TSANNO true); //just used for checking deadline
  DeadlineQueue0::Queue(15);
  DeadlineQueue1::Queue(30);
  GlobalQueue::EDDQueue(CAPACITY 100, RATE $or);

  input[0] 
  -> SetDeadline(DEADLINE $d0, STORETS false)
  -> ShouldDrop(DELAY $d0, QUEUE 0)
  -> DeadlineQueue0
  -> [0]sched0
  -> ru::RatedUnqueue($ir)
  -> GlobalQueue 
  -> sched1
  -> RatedUnqueue($or) 
  -> output;
  input[1] 
  -> SetDeadline(DEADLINE $d1, STORETS false)
  -> ShouldDrop(DELAY $d1, QUEUE 1) 
  -> DeadlineQueue1
  -> [1]sched0;
}

elementclass _EDDSched3 {
  OUTRATE $or, DEAD0 $d0, DEAD1 $d1 |


  Init::Script(TYPE ACTIVE,
     write DeadlineQueue0.capacity $(add 5 $(mul 2 $or $d0)),
     write DeadlineQueue1.capacity $(add 5 $(mul 2 $or $d1)),
  );
  DeadlineQueue0::ShiftQueue(CAPACITY 30, OUTRATE $or);
  DeadlineQueue1::ShiftQueue(CAPACITY 30, OUTRATE $or);
  sched::EDDSched(TSANNO true);

  input[0]
  -> SetDeadline(DEADLINE $d0, STORETS false)
  -> DeadlineQueue0
  -> [0]sched
  -> RatedUnqueue($or)
  -> output;

  input[1]
  -> SetDeadline(DEADLINE $d1, STORETS false)
  -> DeadlineQueue1
  -> [1]sched;
}

//edds::_EDDSched2(MININRATE 100, OUTRATE 20, DEAD0 6, DEAD1 8);
edds::_EDDSched3(OUTRATE 20, DEAD0 6, DEAD1 8);

RatedSource(RATE 100, LENGTH 1, ACTIVE true)
-> Paint(0)
-> [0]edds
-> ps::PaintSwitch;

RatedSource(RATE 100, LENGTH 1, ACTIVE true)
-> Paint(1)
-> [1]edds;

ps[0] 
//-> ToDump(out03-deadline, SNAPLEN 1) 
//-> SetTimestamp
//-> ToDump(out03, SNAPLEN 1)
//-> Print("0", TIMESTAMP true)
-> Discard; 
ps[1] 
//-> ToDump(out13-deadline, SNAPLEN 1) 
//-> SetTimestamp
//-> ToDump(out13, SNAPLEN 1)
//-> Print("1", TIMESTAMP true)
-> Discard;
