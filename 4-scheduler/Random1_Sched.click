// RandomPull_Sched.click
// Simulate Random scheduler with at most 10 inputs (flows)

elementclass RandomSched {
  rrsi::RoundRobinSched;
  input[0] -> q0::Queue(1000) -> [0]rrsi;
  input[1] -> q1::Queue(1000) -> [1]rrsi;
  input[2] -> q2::Queue(1000) -> [2]rrsi;
  input[3] -> q3::Queue(1000) -> [3]rrsi;
  input[4] -> q4::Queue(1000) -> [4]rrsi;
  input[5] -> q5::Queue(1000) -> [5]rrsi;
  input[6] -> q6::Queue(1000) -> [6]rrsi;
  input[7] -> q7::Queue(1000) -> [7]rrsi;
  input[8] -> q8::Queue(1000) -> [8]rrsi;
  input[9] -> q9::Queue(1000) -> [9]rrsi;
  rrsi -> Unqueue -> rs::RandomSwitch;
  rs[0] -> qo0::Queue(1000)-> [0]rrso::RoundRobinSched; 
  rs[1] -> qo1::Queue(1000)-> [1]rrso;
  rs[2] -> qo2::Queue(1000)-> [2]rrso;
  rs[3] -> qo3::Queue(1000)-> [3]rrso;
  rs[4] -> qo4::Queue(1000)-> [4]rrso;
  rs[5] -> qo5::Queue(1000)-> [5]rrso;
  rs[6] -> qo6::Queue(1000)-> [6]rrso;
  rs[7] -> qo7::Queue(1000)-> [7]rrso;
  rs[8] -> qo8::Queue(1000)-> [8]rrso;
  rs[9] -> qo9::Queue(1000)-> [9]rrso;

  rrso -> output;
}

Sched::RandomSched();

// Initialize flows
s0::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s1::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s2::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s3::RatedSource(LENGTH 1000, RATE 8000, ACTIVE true);
s4::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s5::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s6::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s7::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s8::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s9::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);

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
  -> link::LinkUnqueue(10000us, 10Mbps) 
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

