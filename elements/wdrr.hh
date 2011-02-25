// -*- c-basic-offset: 4 -*-
// Inheritted from drrsched.{hh,cc} in the Click source files.
// iizke
#ifndef CLICK_WDRR_HH
#define CLICK_WDRR_HH
#include <click/element.hh>
#include <click/notifier.hh>
CLICK_DECLS

/*
 * =c
 * WDRRSched(weight0, weight1, ...)
 * =s scheduling
 * pulls from inputs with weighted deficit round robin scheduling
 * =io
 * one output, zero or more inputs
 * =d
 * Schedules packets with deficit round robin scheduling, from
 * Shreedhar and Varghese's SIGCOMM 1995 paper "Efficient Fair
 * Queuing using Deficit Round Robin."
 *
 * The inputs usually come from Queues or other pull schedulers.
 * WDRRSched uses notification to avoid pulling from empty inputs.
 *
 * =n
 *
 * DRRSched is a notifier signal, active iff any of the upstream notifiers
 * are active.
 *
 * =a PrioSched, StrideSched, RoundRobinSched, DRRSched
 */

class WDRRSched : public Element { public:

    WDRRSched();
    ~WDRRSched();

    const char *class_name() const		{ return "WDRRSched"; }
    const char *port_count() const		{ return "-/1"; }
    const char *processing() const		{ return PULL; }
    const char *flags() const			{ return "S0"; }
    void *cast(const char *);

    int configure(Vector<String> &, ErrorHandler *);
    int initialize(ErrorHandler *);
    void cleanup(CleanupStage);

    Packet *pull(int port);

  private:

    double _quantum;   // Number of bytes to send per round.

    Packet **_head; // First packet from each queue.
    double *_deficit;  // Each queue's deficit.
    double *_weights;  // Each queue's weight.
    int _nweights;
    NotifierSignal *_signals;	// upstream signals
    Notifier _notifier;
    int _next;      // Next input to consider.

};

CLICK_ENDDECLS
#endif
