// randomqueue.click
// Implement RandomQueue compound element

elementclass BRandomQueue {
  $size |

  input
  -> rs::RandomSwitch;
  rs[0] 
  -> [0]mq::MixedQueue($size);
  
  rs[1] 
  -> DropLIFO::Script(TYPE PACKET, 
      return $(if $(lt $(mq.length) $(mq.capacity)) 0 1)
  )
  ->[1]mq;
  DropLIFO[1] -> Discard;
  
  mq[0] -> [0]output;
  mq[1] -> Discard; 
}


elementclass 2PRandomQueue {
  $size |

  Init::Script(TYPE ACTIVE, 
    set l2 $(idiv $size 2),
    set l1 $(sub $size $l2),
    write mq0.capacity $l1,
    write mq1.capacity $l2,
    write sched.tickets0 $l1,
    write sched.tickets1 $l2
  );
  input
  -> rs::RandomSwitch;
  rs[0] -> [0]mq0::MixedQueue($size)[0] -> [0]sched::StrideSched($size, $size) -> output;
  rs[1] -> [1]mq0; 
  rs[2] -> [0]mq1::MixedQueue($size)[0] -> [1]sched;
  rs[3] -> [1]mq1;
  mq0[1] -> [1]mq1;
}

RatedSource(LENGTH 8, RATE 5)
-> StoreTimestamp(OFFSET 0)
//-> 2PRandomQueue(5)
-> BRandomQueue(5)
//-> RandomQueue(5)
-> RatedUnqueue(4)
-> Print("a")
-> Discard;
