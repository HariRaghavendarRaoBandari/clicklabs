// -*- c-basic-offset: 4 -*-
#ifndef CLICK_DELAYEDD_HH
#define CLICK_DELAYEDD_HH
#include <click/element.hh>
#include <click/timer.hh>
#include <click/notifier.hh>
CLICK_DECLS

/*
=c

DelayEDD(RATE, SYNCDEAD)

=s DelayEDD

Decide to delay high deadline packet 

=d

Pulls packets from the single input port. Delay packet if necessary.
Time to delay = min(1/RATE, max(0, Timestamp - SYNCDEAD - CurrentTimestamp))

=h rate read/write

Returns or sets the RATE parameter (this is output rate).

=h syncdead read/write
Returns or sets the SYNCDEAD parameter (This is the smallest deadline delta).

=a BandwidthShaper, DelayUnqueue, SetTimestamp */

class DelayEDD : public Element, public ActiveNotifier { public:

    DelayEDD();
    ~DelayEDD();

    const char *class_name() const	{ return "DelayEDD"; }
    const char *port_count() const	{ return PORTS_1_1; }
    const char *processing() const	{ return PULL; }
    void *cast(const char *);

    int configure(Vector<String> &, ErrorHandler *);
    int initialize(ErrorHandler *);
    void cleanup(CleanupStage);
    void add_handlers();

    Packet *pull(int);
    void run_timer(Timer *);

  private:

    Packet *_p;
    //Timestamp _delay;
    Timer _timer;
    double rate;
    Timestamp syncdead;
    NotifierSignal _upstream_signal;
    ActiveNotifier _notifier;

    //static String read_param(Element *, void *);
    static int write_param(const String &, Element *, void *, ErrorHandler *);

};

CLICK_ENDDECLS
#endif
