// UDP_Source.click
// Generate UDP packets

elementclass UDP_Generator {
  // Note: SRCPORT and DSTPORT: string number (4 characters) with hexa layout.
  SRC $src, DST $dst, SRCPORT $sport, DSTPORT $dport|
  
  InfiniteSource(DATA \<
    // UDP header
    $sport $dport 00 14 d6 41
    // UDP payload
    55 44 50 20   70 61 63 6b  65 74 21 0a  04 00 00 00  01 00 00 00  
    01 00 00 00   00 00 00 00  00 80 04 08  00 80 04 08  53 53 00 00
    53 53 00 00   05 00 00 00  00 10 00 00  01 00 00 00  54 53 00 00
    54 e3 04 08   54 e3 04 08  d8 01 00 00
    >, STOP true) 
  -> IPEncap(PROTO 0x11, SRC $src, DST $dst)
  -> SetUDPChecksum
  -> EtherEncap(0x0800, 1:1:1:1:1:1, 2:2:2:2:2:2)
  -> output;
}

//InfiniteSource (LENGTH 10)
  // PROTO IP for UDP: 0x11 (decimal 17)
//  -> UDPIPEncap(204.204.204.204, 80, 221.221.221.221, 80)
//  -> EtherEncap(0x0800, 1:1:1:1:1:1, 2:2:2:2:2:2)
//  -> Print("udp1", MAXLENGTH 52)
//  -> Script(TYPE PACKET, wait 1s)
//  -> Discard;

UDP_Generator (SRC 204.204.204.204, DST 221.221.221.221, SRCPORT 0050, DSTPORT 0050)
  //-> Print("udp2", MAXLENGTH 52, ACTIVE true)
  -> Discard;
