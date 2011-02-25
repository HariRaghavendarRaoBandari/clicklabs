// -*- c-basic-offset: 4 -*-
// iizke
// inherited from settimestamp.*
#ifndef CLICK_CHECKTIMESTAMP_HH
#define CLICK_CHECKTIMESTAMP_HH
#include <click/element.hh>
CLICK_DECLS

/*
=c

CheckTimestamp

=d
Check or compare the timestamp of packet with current time. Let packets go through 
if its timestamp does not get over the current time.

=back

=a StoreTimestamp, SetTimeStamp */

class CheckTimestamp : public Element { public:

    CheckTimestamp();
    ~CheckTimestamp();

    const char *class_name() const		{ return "CheckTimestamp"; }
    const char *port_count() const		{ return PORTS_1_1X2; }
    const char *processing() const		{ return AGNOSTIC; }
    int configure(Vector<String> &, ErrorHandler *);

    Packet *simple_action(Packet *);
    void add_handlers();

  private:

    bool _active;    
    
};

CLICK_ENDDECLS
#endif
