// fecn.click
// simulation of FECN (Forward Congestion)

//Congestion Detectable Queue
elementclass CoDeQueue {
DROPRATE $rate, SIZE $s |

  FECNDetect::Script (TYPE PACKET,
    set l $(dq.length),
    goto CONT $(lt $l 3),
    write fecnPaint.color 1,
    end,
    label CONT,
    write fecnPaint.color 0,
    end, 
  );
  q::SimpleQueue($s);
  input -> q -> FECNDetect -> fecnPaint::Paint(0) -> output;
  q[1] -> dq::Queue(5) -> RatedUnqueue($rate) -> Discard;
}

elementclass LAPFEncap {
  SRC $src, DEST $dest | 
  // encap LAP-F header
  input -> output;

}

// Simulate a LAP-F flow
RatedSource(RATE 10, LENGTH 1)
-> LAPFEncap (SRC 0, DEST 1)
// Simulate simple switch with 1 input, 1 output
-> CoDeQueue (DROPRATE 1, SIZE 10)
-> RatedUnqueue(6)
//
-> CheckPaint(1)
-> Print("FECN")
-> Discard;
