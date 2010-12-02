// RWRR_Sched.click
// Simulate Reconfigurable WRR scheduler with at most 10 inputs (flows)

elementclass WRRSched {
  RECONFIGTIME $reconfig_time |

  rrs::RoundRobinSched;
  input[0] -> q0::Queue(1000) -> bs0::BandwidthShaper (10KBps) -> [0]rrs;
  input[1] -> q1::Queue(1000) -> bs1::BandwidthShaper (20KBps) -> [1]rrs;
  input[2] -> q2::Queue(1000) -> bs2::BandwidthShaper (30KBps) -> [2]rrs;
  input[3] -> q3::Queue(1000) -> bs3::BandwidthShaper (40KBps) -> [3]rrs;
  input[4] -> q4::Queue(1000) -> bs4::BandwidthShaper (50KBps) -> [4]rrs;
  input[5] -> q5::Queue(1000) -> bs5::BandwidthShaper (60KBps) -> [5]rrs;
  input[6] -> q6::Queue(1000) -> bs6::BandwidthShaper (70KBps) -> [6]rrs;
  input[7] -> q7::Queue(1000) -> bs7::BandwidthShaper (80KBps) -> [7]rrs;
  input[8] -> q8::Queue(1000) -> bs8::BandwidthShaper (90KBps) -> [8]rrs;
  input[9] -> q9::Queue(1000) -> bs9::BandwidthShaper (10KBps) -> [9]rrs;
  rrs -> output;
  
  ReconfigBWScript::Script(TYPE ACTIVE, 
          // Notion: 'sw' means static weight
          //         'r' means ratio
          set sw0 10,
          set sw1 20,
          set sw2 30,
          set sw3 40,
          set sw4 50,
          set sw5 60,
          set sw6 70,
          set sw7 80,
          set sw8 90,
          set sw9 100,
          // Golden ratio 
          set r 1.618,
          label begin,
          wait $reconfig_time,
          set w0 $(if $(eq $(q0.length) 0) $(div $w0 $r) $sw0),
          set w1 $(if $(eq $(q1.length) 0) $(div $w1 $r) $sw1),
          set w2 $(if $(eq $(q2.length) 0) $(div $w2 $r) $sw2),
          set w3 $(if $(eq $(q3.length) 0) $(div $w3 $r) $sw3),
          set w4 $(if $(eq $(q4.length) 0) $(div $w4 $r) $sw4),
          set w5 $(if $(eq $(q5.length) 0) $(div $w5 $r) $sw5),
          set w6 $(if $(eq $(q6.length) 0) $(div $w6 $r) $sw6),
          set w7 $(if $(eq $(q7.length) 0) $(div $w7 $r) $sw7),
          set w8 $(if $(eq $(q8.length) 0) $(div $w8 $r) $sw8),
          set w9 $(if $(eq $(q9.length) 0) $(div $w9 $r) $sw9),

          set w $(add $w0 $w1 $w2 $w3 $w4 $w5 $w6 $w7 $w8 $w9),
          goto begin $(eq $w 0),
          write bs0.rate $(div $(mul $(link.bandwidth) $w0) $w),
          write bs1.rate $(div $(mul $(link.bandwidth) $w1) $w),
          write bs2.rate $(div $(mul $(link.bandwidth) $w2) $w),
          write bs3.rate $(div $(mul $(link.bandwidth) $w3) $w),
          write bs4.rate $(div $(mul $(link.bandwidth) $w4) $w),
          write bs5.rate $(div $(mul $(link.bandwidth) $w5) $w),
          write bs6.rate $(div $(mul $(link.bandwidth) $w6) $w),
          write bs7.rate $(div $(mul $(link.bandwidth) $w7) $w),
          write bs8.rate $(div $(mul $(link.bandwidth) $w8) $w),
          write bs9.rate $(div $(mul $(link.bandwidth) $w9) $w),

          goto begin
    );

//  Script(TYPE ACTIVE, 
//    write bs0.rate $(div $(link.bandwidth) 10) ,
//    write bs1.rate $(div $(link.bandwidth) 5) ,
//    write bs2.rate $(div $(mul $(link.bandwidth) 3) 10),
//    write bs3.rate $(div $(mul $(link.bandwidth) 4) 10) );
}
Sched::WRRSched(RECONFIGTIME 0.161803);

// Initialize flows
s0::RatedSource(LENGTH 1000, RATE 125, ACTIVE true);
s1::RatedSource(LENGTH 1000, RATE 250, ACTIVE true);
s2::RatedSource(LENGTH 1000, RATE 375, ACTIVE true);
s3::RatedSource(LENGTH 1000, RATE 500, ACTIVE true);
s4::RatedSource(LENGTH 1000, RATE 625, ACTIVE true);
s5::RatedSource(LENGTH 1000, RATE 750, ACTIVE true);
s6::RatedSource(LENGTH 1000, RATE 875, ACTIVE true);
s7::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s8::RatedSource(LENGTH 1000, RATE 1125, ACTIVE true);
s9::RatedSource(LENGTH 1000, RATE 1250, ACTIVE true);

s0 -> Paint(0) -> [0]Sched;
s1 -> Paint(1) -> [1]Sched;
s2 -> Paint(2) -> [2]Sched;
s3 -> Paint(3) -> [3]Sched;
s4 -> Paint(4) -> [4]Sched;
s5 -> Paint(5) -> [5]Sched;
s6 -> Paint(6) -> [6]Sched;
s7 -> Paint(7) -> [7]Sched;
s8 -> Paint(8) -> [8]Sched;
s9 -> Paint(9) -> [9]Sched;

Sched
  //Pull-to-Push Converter
  -> link::LinkUnqueue(10000us, 55Mbps)
  -> ps::PaintSwitch;

ps[0] -> c0::Counter -> Discard;
ps[1] -> c1::Counter -> Discard;
ps[2] -> c2::Counter -> Discard;
ps[3] -> c3::Counter -> Discard;
ps[4] -> c4::Counter -> Discard;
ps[5] -> c5::Counter -> Discard;
ps[6] -> c6::Counter -> Discard;
ps[7] -> c7::Counter -> Discard;
ps[8] -> c8::Counter -> Discard;
ps[9] -> c9::Counter -> Discard;
