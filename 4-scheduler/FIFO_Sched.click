// FIFO_Sched.click
// Simulate FIFO scheduler with at most 10 inputs (flows)

elementclass FFSched {
  tss::TimeSortedSched;
  input[0] -> q0::Queue(1000) -> [0]tss;
  input[1] -> q1::Queue(1000) -> [1]tss;
  input[2] -> q2::Queue(1000) -> [2]tss;
  input[3] -> q3::Queue(1000) -> [3]tss;
  input[4] -> q4::Queue(1000) -> [4]tss;
  input[5] -> q5::Queue(1000) -> [5]tss;
  input[6] -> q6::Queue(1000) -> [6]tss;
  input[7] -> q7::Queue(1000) -> [7]tss;
  input[8] -> q8::Queue(1000) -> [8]tss;
  input[9] -> q9::Queue(1000) -> [9]tss;
  tss -> output;
}

Sched::FFSched();

// Initialize flows
s0::RatedSource(LENGTH 1000, RATE 100, ACTIVE true);
s1::RatedSource(LENGTH 1000, RATE 200, ACTIVE true);
s2::RatedSource(LENGTH 1000, RATE 400, ACTIVE true);
s3::RatedSource(LENGTH 1000, RATE 800, ACTIVE true);
s4::RatedSource(LENGTH 1000, RATE 100, ACTIVE true);
s5::RatedSource(LENGTH 1000, RATE 100, ACTIVE false);
s6::RatedSource(LENGTH 1000, RATE 100, ACTIVE false);
s7::RatedSource(LENGTH 1000, RATE 100, ACTIVE false);
s8::RatedSource(LENGTH 1000, RATE 100, ACTIVE false);
s9::RatedSource(LENGTH 1000, RATE 100, ACTIVE false);

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

