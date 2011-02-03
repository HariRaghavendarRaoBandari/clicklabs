// wred.click
// Weighted RED buffer management
// Support 2 classes of packets

elementclass WRED2 {
  RATE1 $r1, MAX_P1 $p1, 
  RATE2 $r2, MAX_P2 $p2, TARGET $qlen |

  bwmeter::BandwidthMeter($r1, $r2);
  input -> bwmeter;
  bwmeter[0] -> red0::AdaptiveRED($qlen, MAX_P $p1) -> [0]output;
  bwmeter[1] -> red1::AdaptiveRED($qlen, $p2) -> [1]output;
  bwmeter[2] -> red2::AdaptiveRED($qlen, $p1) -> [2]output;
}

RatedSource(LENGTH 10, RATE 100)
-> wred::WRED2(RATE1 200 Bps, MAX_P1 0.8, RATE2 1200 Bps, MAX_P2 0.6, TARGET 60);

wred[0] -> queue::ThreadSafeQueue(100) -> RatedUnqueue(RATE 99) -> Discard;
wred[1] -> queue;
wred[2] -> queue;

