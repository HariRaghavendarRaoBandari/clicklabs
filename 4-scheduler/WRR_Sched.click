// WRR_Sched.click
// Simulate WRR scheduler with at most 10 inputs (flows)

elementclass WRRSched {
  //Static weight from 1 -> 10 (input 0 -> 9)
  //Simulate WRR using RR with number of input ports is: sum(1 -> 10) = 55

  rrs::RoundRobinSched;
  input[1] -> rs1::RandomSwitch;
  input[2] -> rs2::RandomSwitch;
  input[3] -> rs3::RandomSwitch;
  input[4] -> rs4::RandomSwitch;
  input[5] -> rs5::RandomSwitch;
  input[6] -> rs6::RandomSwitch;
  input[7] -> rs7::RandomSwitch;
  input[8] -> rs8::RandomSwitch;
  input[9] -> rs9::RandomSwitch;
  //weight 1
  input[0] -> Queue(1000) -> [29]rrs;
  //weight 2
  rs1[0] -> Queue(1000) -> [16]rrs;
  rs1[1] -> Queue(1000) -> [41]rrs;
  //weight 3
  rs2[0] -> Queue(1000) -> [10]rrs;
  rs2[1] -> Queue(1000) -> [28]rrs;
  rs2[2] -> Queue(1000) -> [53]rrs;
  //weight 4
  rs3[0] -> Queue(1000) -> [8]rrs;
  rs3[1] -> Queue(1000) -> [21]rrs;
  rs3[2] -> Queue(1000) -> [39]rrs;
  rs3[3] -> Queue(1000) -> [47]rrs;
  //weight 5
  rs4[0] -> Queue(1000) -> [5]rrs;
  rs4[1] -> Queue(1000) -> [15]rrs;
  rs4[2] -> Queue(1000) -> [26]rrs;
  rs4[3] -> Queue(1000) -> [34]rrs;
  rs4[4] -> Queue(1000) -> [46]rrs;
  //weight 6
  rs5[0] -> Queue(1000) -> [4]rrs;
  rs5[1] -> Queue(1000) -> [14]rrs;
  rs5[2] -> Queue(1000) -> [22]rrs;
  rs5[3] -> Queue(1000) -> [33]rrs;
  rs5[4] -> Queue(1000) -> [40]rrs;
  rs5[5] -> Queue(1000) -> [50]rrs;
  //weight 7
  rs6[0] -> Queue(1000) -> [3]rrs;
  rs6[1] -> Queue(1000) -> [11]rrs;
  rs6[2] -> Queue(1000) -> [20]rrs;
  rs6[3] -> Queue(1000) -> [27]rrs;
  rs6[4] -> Queue(1000) -> [35]rrs;
  rs6[5] -> Queue(1000) -> [44]rrs;
  rs6[6] -> Queue(1000) -> [51]rrs;
  //weight 8
  rs7[0] -> Queue(1000) -> [2]rrs;
  rs7[1] -> Queue(1000) -> [9]rrs;
  rs7[2] -> Queue(1000) -> [17]rrs;
  rs7[3] -> Queue(1000) -> [23]rrs;
  rs7[4] -> Queue(1000) -> [32]rrs;
  rs7[5] -> Queue(1000) -> [38]rrs;
  rs7[6] -> Queue(1000) -> [45]rrs;
  rs7[7] -> Queue(1000) -> [52]rrs;
  //weight 9
  rs8[0] -> Queue(1000) -> [1]rrs;
  rs8[1] -> Queue(1000) -> [7]rrs;
  rs8[2] -> Queue(1000) -> [13]rrs;
  rs8[3] -> Queue(1000) -> [19]rrs;
  rs8[4] -> Queue(1000) -> [25]rrs;
  rs8[5] -> Queue(1000) -> [31]rrs;
  rs8[6] -> Queue(1000) -> [37]rrs;
  rs8[7] -> Queue(1000) -> [43]rrs;
  rs8[8] -> Queue(1000) -> [49]rrs;
  //weight 10
  rs9[0] -> Queue(1000) -> [0]rrs;
  rs9[1] -> Queue(1000) -> [6]rrs;
  rs9[2] -> Queue(1000) -> [12]rrs;
  rs9[3] -> Queue(1000) -> [18]rrs;
  rs9[4] -> Queue(1000) -> [24]rrs;
  rs9[5] -> Queue(1000) -> [30]rrs;
  rs9[6] -> Queue(1000) -> [36]rrs;
  rs9[7] -> Queue(1000) -> [42]rrs;
  rs9[8] -> Queue(1000) -> [48]rrs;
  rs9[9] -> Queue(1000) -> [54]rrs;

  rrs -> output;
}

Sched::WRRSched();

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


