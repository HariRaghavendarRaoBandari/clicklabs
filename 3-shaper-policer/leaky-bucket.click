// leaky-bucket.click
// Simulate traffic policy: leaky bucket

elementclass LeakyBucket {
  MAXBW $maxbw, SIZE $size |

  input -> Queue ($size) -> BandwidthShaper($maxbw) -> output;
}

elementclass UncontrolledFlow {
  s::InfiniteSource(LENGTH 100, LIMIT -1, ACTIVE true, STOP true)
    // Random length
    -> sl::Script(TYPE PACKET, write s.length $(add 500 $(mod $(random) 1000)))
    // Random rate
    -> link::BandwidthRatedUnqueue(10Mbps)
    -> output;

  sb::Script(TYPE ACTIVE, 
             wait 2,
             set bw $(add $(mod $(random) 10000) 10000),
             write link.rate $(bw)bps,
             loop );
}

flow::UncontrolledFlow;

flow -> LeakyBucket(MAXBW 15Mbps, SIZE 1000) -> Discard;
