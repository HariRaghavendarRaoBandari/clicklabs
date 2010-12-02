// FIFO_Sched.click
// Simulate FIFO scheduler with at most 10 inputs (flows)

FFSched::TimeSortedSched();

// Initialize flows
s0::RatedSource(LENGTH 64, RATE 100);
s1::RatedSource(LENGTH 64, RATE 200);
s2::RatedSource(LENGTH 64, RATE 400);
s3::RatedSource(LENGTH 64, RATE 800);
s4::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
s5::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
s6::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
s7::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
s8::RatedSource(LENGTH 64, RATE 100, ACTIVE false);
s9::RatedSource(LENGTH 64, RATE 100, ACTIVE false);

s0 -> Paint(0) -> [0]FFSched;
s1 -> Paint(1) -> [1]FFSched;
s2 -> Paint(2) -> [2]FFSched;
s3 -> Paint(3) -> [3]FFSched;
s4 -> Paint(4) -> [4]FFSched;
s5 -> Paint(5) -> [5]FFSched;
s6 -> Paint(6) -> [6]FFSched;
s7 -> Paint(7) -> [7]FFSched;
s8 -> Paint(8) -> [8]FFSched;
s9 -> Paint(9) -> [9]FFSched;

FFSched
  //Pull-to-Push Converter
  -> BandwidthRatedUnqueue(100MBps)
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

