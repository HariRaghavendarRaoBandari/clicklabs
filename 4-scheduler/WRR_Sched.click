// WRR_Sched.click
// Simulate WRR scheduler with at most 10 inputs (flows)

elementclass WRRSched {
  rrs::RoundRobinSched;
  Script(TYPE ACTIVE, 
    write bs0.rate $(div $(link.bandwidth) 10),
    write bs1.rate $(div $(link.bandwidth) 5),
    write bs2.rate $(div $(mul $(link.bandwidth) 3) 10),
    write bs3.rate $(div $(mul $(link.bandwidth) 4) 10) );
  input[0] -> Queue(1000) -> bs0::BandwidthShaper (10KBps) -> [0]rrs;
  input[1] -> Queue(1000) -> bs1::BandwidthShaper (20KBps) -> [1]rrs;
  input[2] -> Queue(1000) -> bs2::BandwidthShaper (30KBps) -> [2]rrs;
  input[3] -> Queue(1000) -> bs3::BandwidthShaper (40KBps) -> [3]rrs;
  rrs -> output;
}
Sched::WRRSched();

// Initialize flows
s0::RatedSource(LENGTH 1000, RATE 125);
s1::RatedSource(LENGTH 1000, RATE 250);
s2::RatedSource(LENGTH 1000, RATE 375);
s3::RatedSource(LENGTH 1000, RATE 500);
//s4::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
//s5::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
//s6::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
//s7::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
//s8::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
//s9::RatedSource(LENGTH 64, RATE 100, ACTIVE false);

s0 -> Paint(0) -> [0]Sched;
s1 -> Paint(1) -> [1]Sched;
s2 -> Paint(2) -> [2]Sched;
s3 -> Paint(3) -> [3]Sched;
//s4 -> Paint(4) -> [4]Sched;
//s5 -> Paint(5) -> [5]Sched;
//s6 -> Paint(6) -> [6]Sched;
//s7 -> Paint(7) -> [7]Sched;
//s8 -> Paint(8) -> [8]Sched;
//s9 -> Paint(9) -> [9]Sched;

Sched
  //Pull-to-Push Converter
  -> link::LinkUnqueue(10000us, 10Mbps)
  //-> Script(TYPE PACKET, write bs0.rate $(div $(link.bandwidth) 10))
  -> ps::PaintSwitch;

ps[0] -> c0::Counter -> Discard;
ps[1] -> c1::Counter -> Discard;
ps[2] -> c2::Counter -> Discard;
ps[3] -> c3::Counter -> Discard;
//ps[4] -> c4::Counter -> Discard;
//ps[5] -> c5::Counter -> Discard;
//ps[6] -> c6::Counter -> Discard;
//ps[7] -> c7::Counter -> Discard;
//ps[8] -> c8::Counter -> Discard;
//ps[9] -> c9::Counter -> Discard;

