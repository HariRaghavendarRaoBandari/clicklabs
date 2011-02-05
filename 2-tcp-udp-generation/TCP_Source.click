// TCP_Source.click
// Generate TCP packets

elementclass TCP_Generator {
  // Note: SRCPORT and DSTPORT: string number (4 characters) with hexa layout.
  SRC $src, DST $dst, 
  SRCPORT $sport, DSTPORT $dport, 
  RATE $rate |

  s::Script(TYPE ACTIVE, write t.interval $(div 1 $rate));

  t::TimedSource(DATA \<
    // TCP header
    $sport $dport  00 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00
    // TCP payload
    55 44 50 20    70 61 63 6b  65 74 21 0a  04 00 00 00  01 00 00 00  
    01 00 00 00    00 00 00 00  00 80 04 08  00 80 04 08  53 53 00 00
    53 53 00 00    05 00 00 00  00 10 00 00  01 00 00 00  54 53 00 00
    54 e3 04 08    54 e3 04 08  d8 01 00 00
    >, LIMIT -1)
  -> IPEncap(PROTO 6, SRC $src, DST $dst)
  -> SetTCPChecksum
  -> EtherEncap(0x0800, 1:1:1:1:1:1, 2:2:2:2:2:2)
//  -> Queue($buffer_size)
  -> output;
}

//TCP_Generator (SRC 204.204.204.204, DST 221.221.221.221, SRCPORT 0050, 
//               DSTPORT 0050, RATE 1000, SIZE 100)
//  -> Print("tcp", MAXLENGTH 52, ACTIVE false)
//  -> Discard;
