// -*- c-basic-offset: 4 -*-
// iizke
// inherited from settimestamp.*
#ifndef CLICK_SETVIRTUALCLOCK_HH
#define CLICK_SETVIRTUALCLOCK_HH
#include <click/element.hh>
CLICK_DECLS

/*
=c

SetVirtualClock([<keyword> RATE])

=s timestamps

store the virutal time in the packet's timestamp annotation

=d

Store the specified TIMESTAMP in the packet's timestamp annotation which is set
to the virtual system time when the packet arrived at the SetVirtualClock element.

Keyword arguments are:

=over 8

=item RATE
Identify the rate or bandwidth for this flow (byte per second).

=back

=a StoreTimestamp, SetTimeStamp */

class SetVirtualClock : public Element { public:

    SetVirtualClock();
    ~SetVirtualClock();

    const char *class_name() const		{ return "SetVirtualClock"; }
    const char *port_count() const		{ return PORTS_1_1; }
    const char *processing() const		{ return AGNOSTIC; }
    int configure(Vector<String> &, ErrorHandler *);

    Packet *simple_action(Packet *);

  private:
    Timestamp _last_tv;
    uint32_t rate;

};

CLICK_ENDDECLS
#endif
