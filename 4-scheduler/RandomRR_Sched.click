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

  rs0[0] -> q00::Queue(100) -> [0]rr0;
  rs0[1] -> q01::Queue(100) -> [0]rr1;
  rs0[2] -> q02::Queue(100) -> [0]rr2;
  rs0[3] -> q03::Queue(100) -> [0]rr3;
  rs0[4] -> q04::Queue(100) -> [0]rr4;
  rs0[5] -> q05::Queue(100) -> [0]rr5;
  rs0[6] -> q06::Queue(100) -> [0]rr6;
  rs0[7] -> q07::Queue(100) -> [0]rr7;
  rs0[8] -> q08::Queue(100) -> [0]rr8;
  rs0[9] -> q09::Queue(100) -> [0]rr9;
  
  rs1[0] -> q10::Queue(100) -> [1]rr0;
  rs1[1] -> q11::Queue(100) -> [1]rr1;
  rs1[2] -> q12::Queue(100) -> [1]rr2;
  rs1[3] -> q13::Queue(100) -> [1]rr3;
  rs1[4] -> q14::Queue(100) -> [1]rr4;
  rs1[5] -> q15::Queue(100) -> [1]rr5;
  rs1[6] -> q16::Queue(100) -> [1]rr6;
  rs1[7] -> q17::Queue(100) -> [1]rr7;
  rs1[8] -> q18::Queue(100) -> [1]rr8;
  rs1[9] -> q19::Queue(100) -> [1]rr9;

  rs2[0] -> q20::Queue(100) -> [2]rr0;
  rs2[1] -> q21::Queue(100) -> [2]rr1;
  rs2[2] -> q22::Queue(100) -> [2]rr2;
  rs2[3] -> q23::Queue(100) -> [2]rr3;
  rs2[4] -> q24::Queue(100) -> [2]rr4;
  rs2[5] -> q25::Queue(100) -> [2]rr5;
  rs2[6] -> q26::Queue(100) -> [2]rr6;
  rs2[7] -> q27::Queue(100) -> [2]rr7;
  rs2[8] -> q28::Queue(100) -> [2]rr8;
  rs2[9] -> q29::Queue(100) -> [2]rr9;

  rs3[0] -> q30::Queue(100) -> [3]rr0;
  rs3[1] -> q31::Queue(100) -> [3]rr1;
  rs3[2] -> q32::Queue(100) -> [3]rr2;
  rs3[3] -> q33::Queue(100) -> [3]rr3;
  rs3[4] -> q34::Queue(100) -> [3]rr4;
  rs3[5] -> q35::Queue(100) -> [3]rr5;
  rs3[6] -> q36::Queue(100) -> [3]rr6;
  rs3[7] -> q37::Queue(100) -> [3]rr7;
  rs3[8] -> q38::Queue(100) -> [3]rr8;
  rs3[9] -> q39::Queue(100) -> [3]rr9;

  rs4[0] -> q40::Queue(100) -> [4]rr0;
  rs4[1] -> q41::Queue(100) -> [4]rr1;
  rs4[2] -> q42::Queue(100) -> [4]rr2;
  rs4[3] -> q43::Queue(100) -> [4]rr3;
  rs4[4] -> q44::Queue(100) -> [4]rr4;
  rs4[5] -> q45::Queue(100) -> [4]rr5;
  rs4[6] -> q46::Queue(100) -> [4]rr6;
  rs4[7] -> q47::Queue(100) -> [4]rr7;
  rs4[8] -> q48::Queue(100) -> [4]rr8;
  rs4[9] -> q49::Queue(100) -> [4]rr9;
  
  rs5[0] -> q50::Queue(100) -> [5]rr0;
  rs5[1] -> q51::Queue(100) -> [5]rr1;
  rs5[2] -> q52::Queue(100) -> [5]rr2;
  rs5[3] -> q53::Queue(100) -> [5]rr3;
  rs5[4] -> q54::Queue(100) -> [5]rr4;
  rs5[5] -> q55::Queue(100) -> [5]rr5;
  rs5[6] -> q56::Queue(100) -> [5]rr6;
  rs5[7] -> q57::Queue(100) -> [5]rr7;
  rs5[8] -> q58::Queue(100) -> [5]rr8;
  rs5[9] -> q59::Queue(100) -> [5]rr9;

  rs6[0] -> q60::Queue(100) -> [6]rr0;
  rs6[1] -> q61::Queue(100) -> [6]rr1;
  rs6[2] -> q62::Queue(100) -> [6]rr2;
  rs6[3] -> q63::Queue(100) -> [6]rr3;
  rs6[4] -> q64::Queue(100) -> [6]rr4;
  rs6[5] -> q65::Queue(100) -> [6]rr5;
  rs6[6] -> q66::Queue(100) -> [6]rr6;
  rs6[7] -> q67::Queue(100) -> [6]rr7;
  rs6[8] -> q68::Queue(100) -> [6]rr8;
  rs6[9] -> q69::Queue(100) -> [6]rr9;

  rs7[0] -> q70::Queue(100) -> [7]rr0;
  rs7[1] -> q71::Queue(100) -> [7]rr1;
  rs7[2] -> q72::Queue(100) -> [7]rr2;
  rs7[3] -> q73::Queue(100) -> [7]rr3;
  rs7[4] -> q74::Queue(100) -> [7]rr4;
  rs7[5] -> q75::Queue(100) -> [7]rr5;
  rs7[6] -> q76::Queue(100) -> [7]rr6;
  rs7[7] -> q77::Queue(100) -> [7]rr7;
  rs7[8] -> q78::Queue(100) -> [7]rr8;
  rs7[9] -> q79::Queue(100) -> [7]rr9;

  rs8[0] -> q80::Queue(100) -> [8]rr0;
  rs8[1] -> q81::Queue(100) -> [8]rr1;
  rs8[2] -> q82::Queue(100) -> [8]rr2;
  rs8[3] -> q83::Queue(100) -> [8]rr3;
  rs8[4] -> q84::Queue(100) -> [8]rr4;
  rs8[5] -> q85::Queue(100) -> [8]rr5;
  rs8[6] -> q86::Queue(100) -> [8]rr6;
  rs8[7] -> q87::Queue(100) -> [8]rr7;
  rs8[8] -> q88::Queue(100) -> [8]rr8;
  rs8[9] -> q89::Queue(100) -> [8]rr9;

  rs9[0] -> q90::Queue(100) -> [9]rr0;
  rs9[1] -> q91::Queue(100) -> [9]rr1;
  rs9[2] -> q92::Queue(100) -> [9]rr2;
  rs9[3] -> q93::Queue(100) -> [9]rr3;
  rs9[4] -> q94::Queue(100) -> [9]rr4;
  rs9[5] -> q95::Queue(100) -> [9]rr5;
  rs9[6] -> q96::Queue(100) -> [9]rr6;
  rs9[7] -> q97::Queue(100) -> [9]rr7;
  rs9[8] -> q98::Queue(100) -> [9]rr8;
  rs9[9] -> q99::Queue(100) -> [9]rr9;

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
  -> link::LinkUnqueue(10000us, 8000000 bps) 
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

