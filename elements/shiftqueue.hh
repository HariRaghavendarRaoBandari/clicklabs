// -*- c-basic-offset: 4 -*-
#ifndef CLICK_SHIFTQUEUE_HH
#define CLICK_SHIFTQUEUE_HH
//#include "../standard/fullnotequeue.hh"
#include "../standard/simplequeue.hh"
#include <click/ewma.hh>
#include <click/llrpc.h>

CLICK_DECLS

class HandlerCall;

/*
=c

ShiftQueue
ShiftQueue(CAPACITY)

=s storage

Implementation of shift queue based on Simple FIFO queue.

=d

Stores incoming packets in a first-in-first-out queue. Pull out packet in 
FIFO order. When queue is full, drop the first packet to have space for 
new packet. The default for CAPACITY is 1000.

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

class ShiftQueue : public SimpleQueue { public:

    ShiftQueue();
    ~ShiftQueue();

    const char *class_name() const		{ return "ShiftQueue"; }
    void *cast(const char *);
    int configure(Vector<String> &, ErrorHandler *);
    void add_handlers();

    //Packet *pull(int port);
    void push(int port, Packet *p);
private:
    //static String read_handler(Element *, void *);
    static int sq_write_handler(const String&, Element*, void*, ErrorHandler*);

    //double _delay;
    double _outrate;
};

CLICK_ENDDECLS
#endif
