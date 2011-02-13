// WDRR_Sched_element.click
// Simulate WDRR scheduler (element)

Sched::WDRRSched(0.2,0.4,0.8);

// Initialize flows
s0::RatedSource(LENGTH 100, RATE 1025, ACTIVE true);
s1::RatedSource(LENGTH 200, RATE 2250, ACTIVE true);
s2::RatedSource(LENGTH 400, RATE 3175, ACTIVE true);

s0 -> Paint(0) -> Queue(300) -> [0]Sched;
s1 -> Paint(1) -> Queue(300) -> [1]Sched;
s2 -> Paint(2) -> Queue(300) -> [2]Sched;

Sched
  //Pull-to-Push Converter
  //-> link::LinkUnqueue(10000us, 55Mbps) 
  -> TimedUnqueue(0.1,1)
  -> SetTimestamp
  -> ps::PaintSwitch;

ps[0] -> ToDump(out-w0.2-l100, SNAPLEN 1) -> Discard;
ps[1] -> ToDump(out-w0.4-l200, SNAPLEN 1) -> Discard;
ps[2] -> ToDump(out-w0.8-l400, SNAPLEN 1) -> Discard;


