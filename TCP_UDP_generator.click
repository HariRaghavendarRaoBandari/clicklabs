// UDP_TCP_generator.click 
// iizke

elementclass TimedSourceQueue {
	RATE $rate, SIZE $buffer_size |
  t::TimedSource();
  s::Script(TYPE ACTIVE, write t.interval $(div 1 $rate));
  t
  -> Queue($buffer_size)
	-> output
}

// This using Round Robin Scheduler
elementclass TCP_UDP_generator {
  TCP $tcp, UDP $udp |
  tcpq::TimedSourceQueue(RATE $tcp, SIZE 200);
  udpq::TimedSourceQueue(RATE $udp, SIZE 200);
  rrsched::RoundRobinSched;
  tcpq[0]
    -> Paint(16)
    -> [0]rrsched;
  udpq[0]
    -> Paint (0)
    -> [1]rrsched;

  rrsched[0]
    -> Print("Paint", PRINTANNO true, CONTENTS NONE)
    -> output
}

TCP_UDP_generator(TCP 100, UDP 10)
  -> cp::CheckPaint (16);

cp[0]
  -> Counter
  -> TimedSink (0.001);

cp[1]
  -> Counter
  -> Discard;
