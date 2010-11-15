// Random_IP_generator.click 
// iizke

RandomInfiniteSource(DATA \<
		00 00 c0 ae  67 ef  00 00 00 00 00 00  08 00 // Datalink header
		45 00 00 28  00 00 00 00  40 11 
		77 c3       // Checksum
		c0 a8 01 91 // Source IP Address
		02 00 00 02 // Destination IP Address
		13 69 13 69  00 14 d6 41  55 44 50 20
		70 61 63 6b  65 74 21 0a>, LIMIT 1000, STOP true, RNDBYTEID 30)
	-> Strip(14)
	-> Align(4, 0)    // in case we're not on x86
	-> chkIP :: CheckIPHeader(CHECKSUM false, BADSRC 192.168.1.154)
	-> SetIPChecksum
	-> CheckIPHeader(INTERFACES 192.168.1.154/24 02.00.00.255/24)
	-> c::Counter(COUNT_CALL)
	-> Print ("check", MAXLENGTH 32)
	-> Discard;

//Script(TYPE DRIVER, print $(c.count)); //With this script, cannot count 1000, normally, not exceed 130
