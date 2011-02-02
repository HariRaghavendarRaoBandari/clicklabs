// Random_IP_generator.click 

// Print TIMESTAMP
elementclass PTimestampQueue {
	SIZE $buffer_size |
	input
	-> Print("QI", TIMESTAMP true, MAXLENGTH 46)
	-> Queue($buffer_size)
	-> Print("QO", TIMESTAMP true, MAXLENGTH 46)
	-> output
}

// StoreTimestamp
elementclass STimestampQueue {
	SIZE $buffer_size |
	input
	-> StoreTimestamp(TAIL true)
	-> Queue($buffer_size)
	-> StoreTimestamp(TAIL true)
	-> Print("SQ", MAXLENGTH 70, TIMESTAMP true)
	-> output
}

// LIFO Queue with StoreTimestamp
elementclass SLIFOQueue {
	SIZE $buffer_size |
	MQ :: MixedQueue($buffer_size);
	
	Idle 
	-> [0]MQ;
	
	input
	-> StoreTimestamp(TAIL true)
	 // Input 1 is used for LIFO, Input 0 is used for FIFO
	-> [1]MQ
	-> StoreTimestamp(TAIL true)
	-> Print("SLQ", MAXLENGTH 70)
	-> output
}

// LIFO Queue with Print
elementclass PLIFOQueue {
	SIZE $buffer_size |
	MQ :: MixedQueue($buffer_size);
	Idle 
	-> [0]MQ;
	
	input
	-> Print("LQI", TIMESTAMP true, MAXLENGTH 46)
	-> [1]MQ
	-> Print("LQO", TIMESTAMP true, MAXLENGTH 46)
	-> output
}

//PQ  :: PTimestampQueue(SIZE 1000);
//SQ  :: STimestampQueue(SIZE 1000);
//SLQ :: SLIFOQueue(SIZE 1000);
//PLQ :: PLIFOQueue(SIZE 1000);
RQ  :: RandomQueue(CAPACITY 10000);

//InfiniteSource(DATA \<
source::RandInfiniteSource(DATA \<
		00 00 c0 ae  67 ef  00 00 00 00 00 00  08 00 // Datalink header
		45 00 00 28  00 00 00 00  40 11 
		77 c3       // Checksum
		c0 a8 01 91 // Source IP Address
		02 00 00 02 // Destination IP Address
		13 69 13 69  00 14 d6 41  55 44 50 20
		70 61 63 6b  65 74 21 0a>,
		//LIMIT 1000, STOP true, BURST 5) 
		LIMIT -1, STOP true, BURST 5, RNDBYTEID 30)
  // Add one FIFO QUEUE, timestamp using PRINT
	//-> PQ
	// Unqueue to change from pull to push
	//-> Unqueue
	// Add one FIFO QUEUE, timestamp using StoreTimestamp in tail of packet
	//-> SQ
	//-> Unqueue
	//-> PLQ
  //-> Unqueue
	-> RQ
  -> Strip(14)
	-> Align(4, 0)    // in case we're not on x86
  -> SetCRC32
  -> c1::Counter(COUNT_CALL)
  // Above: error free link

  // Create some bit error here
  // Estimation number of lost packets (assume: all packets have the same size): 
  //    (p_packet_error = perror * packet_len(bit) >= 1 ? 0 : p_packet_error ) * number_of_packets
  -> e::RandomBitErrors(P 0.000001)
	//-> chkIP :: CheckIPHeader(CHECKSUM false, BADSRC 192.168.1.154)
	//-> SetIPChecksum
	//-> CheckIPHeader(INTERFACES 192.168.1.154/24 02.00.00.255/24)
	-> CheckCRC32
  -> c2::Counter(COUNT_CALL)
	-> Discard;

autoupdate_lostp_percent::Script(TYPE PASSIVE, return $(div $(sub $(c1.count) $(c2.count)) $(c1.count) ) ); 
autoupdate_lostp_estimation::Script(TYPE PASSIVE, return $(div $(mul $(e.p_bit_error) $(c1.byte_count) 8 ) $(c1.count)) );
// this estimation is correct if: P_BIT_ERROR * PACKET_SIZE < 1
autoupdate_real_bit_error::Script(TYPE PASSIVE, return $(div $(sub $(c1.count) $(c2.count)) $(c1.byte_count) 8) );


