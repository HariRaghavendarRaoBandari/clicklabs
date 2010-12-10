// UDP_TCP_generator.click 
// Support import click file

//#include "TCP_Source.click"
//#include "UDP_Source.click"

elementclass TimedSourceQueue {
	RATE $rate, SIZE $buffer_size |
  t::TimedSource();
  //t::TCPIPSend;
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
    //-> Print("Paint", PRINTANNO true, CONTENTS NONE)
    -> output
}

TCP_UDP_generator(TCP 1000, UDP 1)
  //-> scale::Script (TYPE PACKET, div $(tcp_counter.count) $(udp_counter.count) )
  -> cp::CheckPaint (16);

cp[0]
  -> tcp_counter::Counter
  -> TimedSink (0.001);

cp[1]
  -> udp_counter::Counter
  -> Discard;

autoupdate_scale::Script (TYPE PASSIVE, 
                return $(div $(tcp_counter.count) $(udp_counter.count)));

reset_button::Script (TYPE PASSIVE,
                write tcp_counter.reset, 
                write udp_counter.reset);

