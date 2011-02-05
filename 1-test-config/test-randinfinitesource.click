// test-randinfinitesource.click
// Check function of new element: RandInfiniteSource

RandInfiniteSource(LENGTH 8, RNDBYTEID 1, LIMIT 5, STOP true)
-> Print("rand at byte 1")
-> Script(TYPE PACKET, wait 1, end)
-> Discard;
