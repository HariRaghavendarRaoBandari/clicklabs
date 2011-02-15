// wred.click
// Weighted RED buffer management
// Support 2 classes of packets

elementclass WRED2 {
  RATE1 $r1, MAX_P1 $p1, MIN1 $m1, MAX1 $mx1,
  RATE2 $r2, MAX_P2 $p2, MIN2 $m2, MAX2 $mx2, |

  //cal_drop1::Script(TYPE PACKET,
      //set scale $(div $(red1.drops) $(c0.count)),
      //print >>red1.txt $(red1.avg_queue_size) $scale,
  //);

  //cal_drop2::Script(TYPE PACKET,
      //set scale $(div $(red2.drops) $(add $(c0.count) $(c2.count))),
      //print >>red2.txt $(red2.avg_queue_size) $scale,
  //);

  bwmeter::BandwidthMeter($r1, $r2);
  input -> bwmeter;
  bwmeter[0] -> red0::RED($m1, $mx1, $p1, GENTLE false) -> output;
  bwmeter[1] -> c1::Counter -> red1::RED($m2, $mx2, $p2, STABILITY 10, GENTLE false) -> output;
  bwmeter[2] -> c2::Counter -> red2::RED($m1, $mx1, $p1, STABILITY 10, GENTLE false) -> output;

  red1[1] -> c1drop::Counter -> Discard;
  red2[1] -> c2drop::Counter -> Discard;
}

s::RatedSource(LENGTH 10, RATE 1000, STOP true) 
-> wred::WRED2( RATE1 200 Bps,  MAX_P1 0.4, MIN1 40, MAX1 80, 
                RATE2 12000 Bps, MAX_P2 0.3, MIN2 50, MAX2 80)
-> queue::ThreadSafeQueue(100) 
-> uq::RatedUnqueue(RATE 900) 
-> Discard;

Test::Script ( TYPE ACTIVE,
  set dr 50, // delta rate
  set sr 2000, // source rate
  set or $sr, // output rate
  set lr 400, // limit rate (stop when go to this rate)
  set mt 10, // measured time
  write s.rate $sr,
  write s.active false,
  label AGAIN,
  write uq.rate $or,
  write wred/c1.reset,
  write wred/c1drop.reset,
  write wred/c2.reset,
  write wred/c2drop.reset,
  wait 1,
  write s.active true,
  wait $mt,
  write s.active false,
  set prob $(div $(wred/c2drop.count) $(wred/c2.count)),
  print >>red2.txt $(wred/red2.avg_queue_size) $prob,
  set or $(sub $or $dr),
  goto AGAIN $(gt $or $lr),
  write s.limit 1,
  write s.active true,
  print "Finish",
);
