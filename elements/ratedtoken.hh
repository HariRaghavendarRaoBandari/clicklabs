// -*- c-basic-offset: 4 -*-
// iizke
#ifndef CLICK_RATEDTOKEN_HH
#define CLICK_RATEDTOKEN_HH
#include <click/element.hh>
CLICK_DECLS

/*
=c

RatedToken([keyword]BURST b, RATE r)

=d
Rated Token bucket with burst duration B (packets) and rate R (pps).
pps: packets per second.

=h burst read/write
Read or set up parameter Burst-duration. Default value is 1 (packet).

=h rate read/write
Read or set up parameter Rate. Default value is 1 (pps).

=h active read/write
Boolean. If false, packet is just gone through this element.

=back

=a RatedSplitter, RatedUnqueue, Meter */

class RatedToken : public Element { public:

    RatedToken();
    ~RatedToken();

    const char *class_name() const		{ return "RatedToken"; }
    const char *port_count() const		{ return PORTS_1_1X2; }
    const char *processing() const		{ return AGNOSTIC; }
    int configure(Vector<String> &, ErrorHandler *);

    Packet *simple_action(Packet *);
    void add_handlers();

  private:
    static int change_params(const String&, Element*, void*, ErrorHandler*);
    bool _active;
    uint32_t _rate;
    int32_t _burst;
    int32_t _cburst; // count number of accepted packets from fulltk_tv
    Timestamp _fulltk_tv; // last full token timestamp
    atomic_uint32_t lock; // protect cburst and fulltk_tv
    void require_lock();
    void release_lock();
};

CLICK_ENDDECLS
#endif
