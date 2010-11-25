// -*- c-basic-offset: 4 -*-
#ifndef CLICK_RANDOMQUEUE_HH
#define CLICK_RANDOMQUEUE_HH
//#include "../standard/fullnotequeue.hh"
#include "../standard/threadsafequeue.hh"
CLICK_DECLS

/*
=c

RandomQueue
RandomQueue(CAPACITY)

=s storage

Implementation of RANDOM queue based on Thread Safe FIFO queue.

=d

Stores incoming packets in a first-in-first-out queue.
Pull out packet with a random order.
Drops incoming packets if the queue already holds CAPACITY packets.
The default for CAPACITY is 1000.

This variant of the default Queue is (should be) completely thread safe, in
that it supports multiple concurrent pushers and pullers.  In all respects
other than thread safety it behaves just like Queue, and like Queue it has
non-full and non-empty notifiers.

=h length read-only

Returns the current number of packets in the queue.

=h highwater_length read-only

Returns the maximum number of packets that have ever been in the queue at once.

=h capacity read/write

Returns or sets the queue's capacity.

=h drops read-only

Returns the number of packets dropped by the queue so far.

=h reset_counts write-only

When written, resets the C<drops> and C<highwater_length> counters.

=h reset write-only

When written, drops all packets in the queue.

=a Queue, SimpleQueue, NotifierQueue, MixedQueue, FrontDropQueue */

class RandomQueue : public ThreadSafeQueue { public:

    RandomQueue();
    ~RandomQueue();

    const char *class_name() const		{ return "RandomQueue"; }
    void *cast(const char *);

    Packet *pull(int port);

  private:
    void swap_packets(int p1, int p2);

};

CLICK_ENDDECLS
#endif
