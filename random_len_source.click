// UDP_TCP_generator.click 
// iizke

// Print TIMESTAMP
elementclass PTimestampQueue {
	SIZE $buffer_size |
	input
	-> Print("QI", TIMESTAMP true, MAXLENGTH 46)
	-> Queue($buffer_size)
	-> Print("QO", TIMESTAMP true, MAXLENGTH 46)
	-> output
}
i::RatedSource(RATE 1000, LENGTH 10, LIMIT 10000000)
  //-> s::Script(TYPE PACKET, write i.length $(mod $(random) 100))
  //-> Strip(14)
	//-> Align(4, 0)    // in case we're not on x86
  //-> SetIPChecksum
  //-> CheckIPHeader(INTERFACES 192.168.1.154/24 02.00.00.255/24)
  //-> FixIPSrc(1.1.1.1)
  -> Print("r", MAXLENGTH 60)
  -> c1::Counter(BYTE_COUNT_CALL)
	-> Discard;
 
s2:: Script(TYPE PASSIVE, print $(c1.byte_count));

