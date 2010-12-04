// Counter_test.click 

Script(TYPE ACTIVE, wait 2);
// Compound element
elementclass PrintCounter {
	// Parameter declaration
	$label, PRINTACTIVE $boolp |
	// Procedure
	input
	-> c::Counter(COUNT_CALL)
	//-> Print($label, ACTIVE $boolp)
	-> output;
}

InfiniteSource(DATA \<
		00 00 c0 ae  67 ef  00 00 00 00 00 00  08 00 // Datalink header
		45 00 00 28  00 00 00 00  40 11 
		77 c3       // Checksum
		c0 a8 01 91 // Source IP Address
		02 00 00 02 // Destination IP Address
		13 69 13 69  00 14 d6 41  55 44 50 20
		70 61 63 6b  65 74 21 0a>, LIMIT 10000, STOP true)
	-> c1 :: Counter(COUNT_CALL) 
	-> Script(TYPE PACKET, print c1.count) 
	//-> Print("c")
	-> Strip(14)
	-> Align(4, 0)    // in case we're not on x86
	-> chkIP :: CheckIPHeader(CHECKSUM false, BADSRC 192.168.1.145);

chkIP[0]
	-> otherIP_counter :: Counter(COUNT_CALL)
	//-> Print(n) // not 192.168.1.145
	-> Discard;

chkIP[1] 
	//-> p :: PrintCounter("y", PRINTACTIVE false)
	-> Discard;

//Script(TYPE DRIVER, print '(all)'$(c1.count) '= (other)'$(otherIP_counter.count) '+ (proper)'$(p/c.count)) ; // Use this Script to print out the Counter when route stops

