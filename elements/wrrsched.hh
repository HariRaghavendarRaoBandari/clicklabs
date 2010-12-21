// -*- c-basic-offset: 4 -*-
#ifndef CLICK_WRRSCHED_HH
#define CLICK_WRRSCHED_HH
#include <click/element.hh>
#include <click/notifier.hh>
CLICK_DECLS

/*
 * =c
 *
 * WRRched
 *
 * =s scheduling
 * pulls from weighted-round-robin inputs
 * =io
 * one output, zero or more inputs
 * =d
 * Each time a pull comes in the output, pulls from its inputs
 * in turn until one produces a packet. When the next pull
 * comes in, it starts from the input after the one that
 * last produced a packet. This amounts to a weighted round robin
 * scheduler.
 *
 * The inputs usually come from Queues or other pull schedulers.
 * WRRSched uses notification to avoid pulling from empty inputs.
 *
 * =a RoundRobinSched, PrioSched, StrideSched, DRRSched, RoundRobinSwitch
 */

class WRRSched : public Element { public:

    WRRSched();
    ~WRRSched();

    const char *class_name() const	{ return "WRRSched"; }
    const char *port_count() const	{ return "-/1"; }
    const char *processing() const	{ return PULL; }
    const char *flags() const		{ return "S0"; }

    int configure(Vector<String> &, ErrorHandler *);
    int initialize(ErrorHandler *);
    void cleanup(CleanupStage);

    Packet *pull(int port);

  private:
    int * _weights;
    int _nweights;
    int _sumwei;
    int * _porders;
    int _next;
    NotifierSignal *_signals;

};

CLICK_ENDDECLS
#endif
