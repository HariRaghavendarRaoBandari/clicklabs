// gcra.click
// implement Generic Cell Rate Algorithm
// iizke

elementclass GCRA {
  RATE $r, TOLERANCE $to, PLEN $len |
  
  CheckTime::Script(TYPE PACKET,
      set Ta $(now),
      set TAT $(vc.lasttag),
      set T $(div $len $r),
      print "TAT $TAT, Ta $Ta, T $T",
      return $(if $(lt $Ta $(sub $TAT $to)) 1 0)
  );

  input
  -> CheckTime [0]
  -> vc::SetVirtualClock(RATE $r, MAXBW 1, CURRENTBW 1)
  -> output;

  CheckTime [1]
  -> Discard;
}

//RatedSource(LENGTH 10, RATE 2, LIMIT -1)
//-> GCRA(RATE 10, PLEN 10, TOLERANCE 0)
//-> Discard;
