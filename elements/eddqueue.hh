// -*- c-basic-offset: 4 -*-
#ifndef CLICK_EDDQUEUE_HH
#define CLICK_EDDQUEUE_HH
//#include "../standard/fullnotequeue.hh"
#include "../standard/threadsafequeue.hh"
#include <click/ewma.hh>
#include <click/llrpc.h>

CLICK_DECLS

class HandlerCall;

/*
=c

EDDQueue
EDDQueue(CAPACITY)

=s storage

Implementation of EDD queue based on Thread Safe FIFO queue and Counter.

=d

Stores incoming packets in a first-in-first-out queue. Pull out packet in 
FIFO order. Drops incoming packets if 
     + the queue already holds CAPACITY packets or:
     + (Packet_timestamp - NOW)* Average_Rate < Queue_length.
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

class EDDQueue : public ThreadSafeQueue { public:

    EDDQueue();
    ~EDDQueue();

    const char *class_name() const		{ return "EDDQueue"; }
    void *cast(const char *);
    int configure(Vector<String> &, ErrorHandler *);

    void reset();
    void add_handlers();

    Packet *pull(int port);
    void push(int port, Packet *p);
private:
    void update_rate ();
    static String read_handler(Element *, void *);
    double _fixedrate;

    // copy from Counter.hh (Counter element)
#ifdef HAVE_INT64_TYPES
    //typedef uint64_t counter_t;
    // Reduce bits of fraction for byte rate to avoid overflow
    typedef RateEWMAX<RateEWMAXParameters<4, 10, uint64_t, int64_t> > rate_t;
    //typedef RateEWMAX<RateEWMAXParameters<4, 4, uint64_t, int64_t> > byte_rate_t;
#else
    //typedef uint32_t counter_t;
    typedef RateEWMAX<RateEWMAXParameters<4, 10> > rate_t;
    //typedef RateEWMAX<RateEWMAXParameters<4, 4> > byte_rate_t;
#endif
    //counter_t _count;
    //counter_t _byte_count;
    rate_t _rate;
    //byte_rate_t _byte_rate;
    //counter_t _count_trigger;
    //HandlerCall *_count_trigger_h;
    //counter_t _byte_trigger;
    //HandlerCall *_byte_trigger_h;
    //bool _count_triggered : 1;
    //bool _byte_triggered  : 1;
};

CLICK_ENDDECLS
#endif
