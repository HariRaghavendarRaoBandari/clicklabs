// leaky-bucket.click
// Simulate traffic policy: leaky bucket

elementclass LeakyBucket {
  INTERVAL $i, RATE $rate, SIZE $size |

  // Using TimedUnqueue
  // 100%CPU
  //uq::TimedUnqueue(INTERVAL $i, BURST 1);

  // Using RatedUnqueue
  // also 100%CPU but rate can be changed
  uq::RatedUnqueue(RATE $rate);
  
  input -> Queue ($size) -> uq -> output;
}

elementclass UncontrolledFlow {
  s::InfiniteSource(LENGTH 100, LIMIT -1, ACTIVE true, STOP true, BURST 1)
    -> link::RatedUnqueue(RATE 1000)
    -> output;

  change_rate::Script(TYPE ACTIVE, 
              wait 4,
              set r $(add $(mod $(random) 5000) 900),
              write link.rate $r,
              loop );
  change_burst::Script(TYPE ACTIVE, 
              wait 1,
              set r $(add $(mod $(random) 10) 1),
              write s.burst $r,
              loop);
}

flow::UncontrolledFlow;

flow -> c1::Counter -> LeakyBucket(INTERVAL 1ms, RATE 1000, SIZE 1000) -> c2::Counter -> Discard;
