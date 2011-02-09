// gcra.click
// implement Generic Cell Rate Algorithm
// iizke

//#include "uncontrol-flow.click"
elementclass GCRA {
  RATE $r, // byte per second
  TOLERANCE $to, 
  PLEN $len | // byte 
  
  CheckTime::Script(TYPE PACKET,
      set Ta $(now),
      set TAT $(vc.lasttag),
      set T $(div $len $r),
      //print "TAT $TAT, Ta $Ta, T $T",
      goto DROP $(lt $Ta $(sub $TAT $to)),
      return 0,
      label DROP,
      //print "Drop $Ta" ,
      exit
  );

  input
  -> CheckTime[0]
  -> vc::SetVirtualClock(RATE $r, MAXBW 1, CURRENTBW 1)
  -> output;
}

//RatedSource(LENGTH 10, RATE 4, LIMIT -1)
ProbUncontrolledFlow(PROB_CHANGE 0.4, MAXRATE 10)
//-> ToDump(dumpin-2, SNAPLEN 1)
//-> SetTimestamp
-> GCRA(RATE 5, PLEN 1, TOLERANCE 0) // Note: RATE byte/second
//-> ToDump(dumpout-2, SNAPLEN 1)
-> Discard;
