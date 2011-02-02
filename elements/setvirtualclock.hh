// -*- c-basic-offset: 4 -*-
// iizke
// inherited from settimestamp.*
#ifndef CLICK_SETVIRTUALCLOCK_HH
#define CLICK_SETVIRTUALCLOCK_HH
#include <click/element.hh>
CLICK_DECLS

/*
=c

SetVirtualClock([<keyword> RATE | MAXBW | CURRENTBW])

=s timestamps

store the virutal time in the packet's timestamp annotation

=d

Store the specified TIMESTAMP in the packet's timestamp annotation which is set
to the virtual system time when the packet arrived at the SetVirtualClock element.
This element is used to support Virtual Clock scheduling and Weighted Fair Queueing 
Scheduling

Keyword arguments are:

=over 8

=item RATE
Identify the rate or bandwidth for this flow (byte per second).

=item MAXBW
Determine the value of maximum bandwidth or link speed (byte per second).

=item CURRENTBW
Determine the maximum current load over all ACTIVE flows (byte per second).

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
    void add_handlers();

  private:
    Timestamp last_tag_tv;
    Timestamp last_real_tv;
    Timestamp last_virtual_tv;
    uint32_t rate;
    uint32_t maxbw;
    uint32_t currentbw;

    bool _active;    
    
    static int change_param(const String &, Element *, void *, ErrorHandler *);
};

CLICK_ENDDECLS
#endif
