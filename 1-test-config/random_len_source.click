// random_len_source.click 

// Print TIMESTAMP
elementclass PTimestampQueue {
	SIZE $buffer_size |
	input
	-> Print("QI", TIMESTAMP true, MAXLENGTH 46)
	-> Queue($buffer_size)
	-> Print("QO", TIMESTAMP true, MAXLENGTH 46)
	-> output
}
i::RatedSource(RATE 100, LENGTH 10, LIMIT 10000)
  -> s::Script(TYPE PACKET, write i.length $(mod $(random) 100))
  -> Print("r", MAXLENGTH 60)
  -> c1::Counter(BYTE_COUNT_CALL)
	-> Discard;
 
s2:: Script(TYPE PASSIVE, print $(c1.byte_count));

