// WRR_Sched.click
// Simulate WRR scheduler with at most 10 inputs (flows)

elementclass 2WRRSched {
  //Static weight from 1 -> 10 (input 0 -> 9)
  //Simulate WRR using RR with number of input ports is: sum(1 -> 10) = 55

  rrs::RoundRobinSched;
  input[1] -> rs1::RoundRobinSwitch;
  //weight 1
  input[0] -> Queue(1000) -> [1]rrs;
  //weight 2
  rs1[0] -> Queue(1000) -> [0]rrs;
  rs1[1] -> Queue(1000) -> [2]rrs;

  rrs -> output;
}

Sched::2WRRSched();

// Initialize flows
s0::RatedSource(LENGTH 1000, RATE 125, ACTIVE true)
-> [0]Sched;
s1::RatedSource(LENGTH 1000, RATE 250, ACTIVE false)
-> [1]Sched;


Sched
  //Pull-to-Push Converter
  //-> link::LinkUnqueue(10000us, 55Mbps) 
  -> Discard;

