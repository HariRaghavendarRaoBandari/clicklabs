// DRR_Sched.click
// Simulate DRR scheduler with at most 10 inputs (flows)

elementclass DRRSched {
  SIZE $s |
  drrs::DRRSched;
  input[0] -> q0::Queue($s) -> [0]drrs;
  input[1] -> q1::Queue($s) -> [1]drrs;
  input[2] -> q2::Queue($s) -> [2]drrs;
  input[3] -> q3::Queue($s) -> [3]drrs;
  input[4] -> q4::Queue($s) -> [4]drrs;
  input[5] -> q5::Queue($s) -> [5]drrs;
  input[6] -> q6::Queue($s) -> [6]drrs;
  input[7] -> q7::Queue($s) -> [7]drrs;
  input[8] -> q8::Queue($s) -> [8]drrs;
  input[9] -> q9::Queue($s) -> [9]drrs;
  drrs -> output;
}

Sched::DRRSched(SIZE 10);

// Initialize flows
s0::RatedSource(LENGTH 500, RATE 30, ACTIVE true);
s1::RatedSource(LENGTH 1000, RATE 60, ACTIVE true);
s2::RatedSource(LENGTH 1500, RATE 90, ACTIVE true);
s3::RatedSource(LENGTH 1000, RATE 800, ACTIVE false);
s4::RatedSource(LENGTH 1000, RATE 100, ACTIVE false);
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
  //-> LinkUnqueue(10000us, 10Mbps)
  -> RatedUnqueue(20)
  -> SetTimestamp
  -> ps::PaintSwitch;

ps[0] -> ToDump(out0-50, SNAPLEN 1) -> c0::Counter -> Discard;
ps[1] -> ToDump(out1-100, SNAPLEN 1) -> c1::Counter -> Discard;
ps[2] -> ToDump(out2-150, SNAPLEN 1) -> c2::Counter -> Discard;
ps[3] -> c3::Counter -> Discard;
ps[4] -> c4::Counter -> Discard;
ps[5] -> c5::Counter -> Discard;
ps[6] -> c6::Counter -> Discard;
ps[7] -> c7::Counter -> Discard;
ps[8] -> c8::Counter -> Discard;
ps[9] -> c9::Counter -> Discard;

