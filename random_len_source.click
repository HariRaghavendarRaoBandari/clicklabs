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
// InfiniteSource(DATA \<
//       00 00 c0 ae  67 ef  00 00 00 00 00 00  08 00 // Datalink header
//       45 00 00 28  00 00 00 00  40 11
//       77 c3       // Checksum
//       c0 a8 01 91 // Source IP Address
//       02 00 00 02 // Destination IP Address
//       13 69 13 69  00 14 d6 41  55 44 50 20
//       70 61 63 6b  65 74 21 0a>, LIMIT 10, STOP true)
i::InfiniteSource(LENGTH 10, LIMIT 10, STOP true)
  -> s::Script(TYPE PACKET, write i.length $(mod $(random) 100))
  //-> Strip(14)
	-> Align(4, 0)    // in case we're not on x86
  //-> SetIPChecksum
  //-> CheckIPHeader(INTERFACES 192.168.1.154/24 02.00.00.255/24)
  //-> FixIPSrc(1.1.1.1)
  -> Print("r", MAXLENGTH 60)
  -> c1::Counter(COUNT_CALL)
//  -> s::Script(TYPE PACKET, write i.length $(mod $(random) 100))
	-> Discard;
