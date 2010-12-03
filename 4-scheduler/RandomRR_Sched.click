// RandomPull_Sched.click
// Simulate Random FIFO scheduler with at most 10 inputs (flows)

elementclass RandomRRSched {
  input[0] -> rs0::RandomSwitch;
  input[1] -> rs1::RandomSwitch;
  input[2] -> rs2::RandomSwitch;
  input[3] -> rs3::RandomSwitch;
  input[4] -> rs4::RandomSwitch;
  input[5] -> rs5::RandomSwitch;
  input[6] -> rs6::RandomSwitch;
  input[7] -> rs7::RandomSwitch;
  input[8] -> rs8::RandomSwitch;
  input[9] -> rs9::RandomSwitch;

  rr::RoundRobinSched -> output;

  rr0::RoundRobinSched -> [0]rr;
  rr1::RoundRobinSched -> [1]rr;
  rr2::RoundRobinSched -> [2]rr;
  rr3::RoundRobinSched -> [3]rr;
  rr4::RoundRobinSched -> [4]rr;
  rr5::RoundRobinSched -> [5]rr;
  rr6::RoundRobinSched -> [6]rr;
  rr7::RoundRobinSched -> [7]rr;
  rr8::RoundRobinSched -> [8]rr;
  rr9::RoundRobinSched -> [9]rr;

  rs0[0] -> Queue(100) -> [0]rr0;
  rs0[1] -> Queue(100) -> [0]rr1;
  rs0[2] -> Queue(100) -> [0]rr2;
  rs0[3] -> Queue(100) -> [0]rr3;
  rs0[4] -> Queue(100) -> [0]rr4;
  rs0[5] -> Queue(100) -> [0]rr5;
  rs0[6] -> Queue(100) -> [0]rr6;
  rs0[7] -> Queue(100) -> [0]rr7;
  rs0[8] -> Queue(100) -> [0]rr8;
  rs0[9] -> Queue(100) -> [0]rr9;
  
  rs1[0] -> Queue(100) -> [1]rr0;
  rs1[1] -> Queue(100) -> [1]rr1;
  rs1[2] -> Queue(100) -> [1]rr2;
  rs1[3] -> Queue(100) -> [1]rr3;
  rs1[4] -> Queue(100) -> [1]rr4;
  rs1[5] -> Queue(100) -> [1]rr5;
  rs1[6] -> Queue(100) -> [1]rr6;
  rs1[7] -> Queue(100) -> [1]rr7;
  rs1[8] -> Queue(100) -> [1]rr8;
  rs1[9] -> Queue(100) -> [1]rr9;

  rs2[0] -> Queue(100) -> [2]rr0;
  rs2[1] -> Queue(100) -> [2]rr1;
  rs2[2] -> Queue(100) -> [2]rr2;
  rs2[3] -> Queue(100) -> [2]rr3;
  rs2[4] -> Queue(100) -> [2]rr4;
  rs2[5] -> Queue(100) -> [2]rr5;
  rs2[6] -> Queue(100) -> [2]rr6;
  rs2[7] -> Queue(100) -> [2]rr7;
  rs2[8] -> Queue(100) -> [2]rr8;
  rs2[9] -> Queue(100) -> [2]rr9;

  rs3[0] -> Queue(100) -> [3]rr0;
  rs3[1] -> Queue(100) -> [3]rr1;
  rs3[2] -> Queue(100) -> [3]rr2;
  rs3[3] -> Queue(100) -> [3]rr3;
  rs3[4] -> Queue(100) -> [3]rr4;
  rs3[5] -> Queue(100) -> [3]rr5;
  rs3[6] -> Queue(100) -> [3]rr6;
  rs3[7] -> Queue(100) -> [3]rr7;
  rs3[8] -> Queue(100) -> [3]rr8;
  rs3[9] -> Queue(100) -> [3]rr9;

  rs4[0] -> Queue(100) -> [4]rr0;
  rs4[1] -> Queue(100) -> [4]rr1;
  rs4[2] -> Queue(100) -> [4]rr2;
  rs4[3] -> Queue(100) -> [4]rr3;
  rs4[4] -> Queue(100) -> [4]rr4;
  rs4[5] -> Queue(100) -> [4]rr5;
  rs4[6] -> Queue(100) -> [4]rr6;
  rs4[7] -> Queue(100) -> [4]rr7;
  rs4[8] -> Queue(100) -> [4]rr8;
  rs4[9] -> Queue(100) -> [4]rr9;
  
  rs5[0] -> Queue(100) -> [5]rr0;
  rs5[1] -> Queue(100) -> [5]rr1;
  rs5[2] -> Queue(100) -> [5]rr2;
  rs5[3] -> Queue(100) -> [5]rr3;
  rs5[4] -> Queue(100) -> [5]rr4;
  rs5[5] -> Queue(100) -> [5]rr5;
  rs5[6] -> Queue(100) -> [5]rr6;
  rs5[7] -> Queue(100) -> [5]rr7;
  rs5[8] -> Queue(100) -> [5]rr8;
  rs5[9] -> Queue(100) -> [5]rr9;

  rs6[0] -> Queue(100) -> [6]rr0;
  rs6[1] -> Queue(100) -> [6]rr1;
  rs6[2] -> Queue(100) -> [6]rr2;
  rs6[3] -> Queue(100) -> [6]rr3;
  rs6[4] -> Queue(100) -> [6]rr4;
  rs6[5] -> Queue(100) -> [6]rr5;
  rs6[6] -> Queue(100) -> [6]rr6;
  rs6[7] -> Queue(100) -> [6]rr7;
  rs6[8] -> Queue(100) -> [6]rr8;
  rs6[9] -> Queue(100) -> [6]rr9;

  rs7[0] -> Queue(100) -> [7]rr0;
  rs7[1] -> Queue(100) -> [7]rr1;
  rs7[2] -> Queue(100) -> [7]rr2;
  rs7[3] -> Queue(100) -> [7]rr3;
  rs7[4] -> Queue(100) -> [7]rr4;
  rs7[5] -> Queue(100) -> [7]rr5;
  rs7[6] -> Queue(100) -> [7]rr6;
  rs7[7] -> Queue(100) -> [7]rr7;
  rs7[8] -> Queue(100) -> [7]rr8;
  rs7[9] -> Queue(100) -> [7]rr9;

  rs8[0] -> Queue(100) -> [8]rr0;
  rs8[1] -> Queue(100) -> [8]rr1;
  rs8[2] -> Queue(100) -> [8]rr2;
  rs8[3] -> Queue(100) -> [8]rr3;
  rs8[4] -> Queue(100) -> [8]rr4;
  rs8[5] -> Queue(100) -> [8]rr5;
  rs8[6] -> Queue(100) -> [8]rr6;
  rs8[7] -> Queue(100) -> [8]rr7;
  rs8[8] -> Queue(100) -> [8]rr8;
  rs8[9] -> Queue(100) -> [8]rr9;

  rs9[0] -> Queue(100) -> [9]rr0;
  rs9[1] -> Queue(100) -> [9]rr1;
  rs9[2] -> Queue(100) -> [9]rr2;
  rs9[3] -> Queue(100) -> [9]rr3;
  rs9[4] -> Queue(100) -> [9]rr4;
  rs9[5] -> Queue(100) -> [9]rr5;
  rs9[6] -> Queue(100) -> [9]rr6;
  rs9[7] -> Queue(100) -> [9]rr7;
  rs9[8] -> Queue(100) -> [9]rr8;
  rs9[9] -> Queue(100) -> [9]rr9;

}

Sched::RandomRRSched();

// Initialize flows
s0::RatedSource(LENGTH 1000, RATE 1000, ACTIVE true);
s1::RatedSource(LENGTH 1000, RATE 2000, ACTIVE true);
s2::RatedSource(LENGTH 1000, RATE 4000, ACTIVE true);
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

