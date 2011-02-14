// wred.click
// Weighted RED buffer management
// Support 2 classes of packets

elementclass WRED2 {
  RATE1 $r1, MAX_P1 $p1, MIN1 $m1, MAX1 $mx1,
  RATE2 $r2, MAX_P2 $p2, MIN2 $m2, MAX2 $mx2, |

  cal_drop1::Script(TYPE PACKET,
      set scale $(div $(red1.drops) $(c0.count)),
      print >>red1.txt $(red1.avg_queue_size) $scale,
  );

  cal_drop2::Script(TYPE PACKET,
      set scale $(div $(red2.drops) $(add $(c0.count) $(c2.count))),
      print >>red2.txt $(red2.avg_queue_size) $scale,
  );

  bwmeter::BandwidthMeter($r1, $r2);
  input -> bwmeter;
  bwmeter[0] -> c0::Counter -> red0::RED($m1, $mx1, $p1, GENTLE false) -> [0]output;
  bwmeter[1] -> cal_drop1 -> c1::Counter -> red1::RED($m2, $mx2, $p2, GENTLE false) -> [1]output;
  bwmeter[2] -> cal_drop2 -> c2::Counter -> red2::RED($m1, $mx1, $p1, GENTLE false) -> [2]output;
}

Test::Script(TYPE ACTIVE, 
  write s.rate 100,
  wait 2,
  write uq.rate 20,
  wait 2, 
  write uq.rate 40,
  wait 2,
  write uq.rate 60,
  wait 2,
  write uq.rate 80,
  wait 2,
  write uq.rate 100,
  wait 2,
  write s.rate 200,
  wait 2,
  write uq.rate 80,
  wait 2, 
  write uq.rate 60,
  wait 2,
  write uq.rate 120,
  wait 2,
  write uq.rate 140,
  wait 2,
  write uq.rate 160,
  wait 2,
  write uq.rate 180,
  wait 2,
  write uq.rate 200,
  wait 2,
  print "Finish",
);

s::RatedSource(LENGTH 10, RATE 100)
-> wred::WRED2( RATE1 200 Bps,  MAX_P1 0.4, MIN1 40, MAX1 80, 
                RATE2 1200 Bps, MAX_P2 0.3, MIN2 50, MAX2 80);

wred[0] -> queue::ThreadSafeQueue(100) -> uq::RatedUnqueue(RATE 10) -> Discard;
wred[1] -> queue;
wred[2] -> queue;


