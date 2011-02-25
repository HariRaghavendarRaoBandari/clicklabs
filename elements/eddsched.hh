// -*- mode: c++; c-basic-offset: 4 -*-
#ifndef CLICK_EDDSCHED_HH
#define CLICK_EDDSCHED_HH
#include <click/element.hh>
#include <click/notifier.hh>
CLICK_DECLS

/*
=c

EDDSched(I<KEYWORDS>)

=s timestamps

merge sorted packet streams by timestamp

=io

one output, zero or more inputs

=d

EDDSched responds to pull requests by returning the chronologically
next packet pulled from its inputs, determined by packet timestamps.

EDDdSched listens for notification from its inputs to avoid useless
pulls, and provides notification for its output.

Keyword arguments are:

=over 8

=item STOP

Boolean. If true, stop the driver when there are no packets available (and the
upstream notifiers indicate that no packets will become available soon).
Default is false.

=back

=n

EDDSched is a notifier signal, active iff any of the upstream notifiers
are active.

=e

This example merges multiple tcpdump(1) files into a single, time-sorted
stream, and stops the driver when all the files are exhausted.

  tss :: EDDSched(STOP true);
  FromDump(FILE1) -> [0] tss;
  FromDump(FILE2) -> [1] tss;
  FromDump(FILE3) -> [2] tss;
  // ...
  tss -> ...;

=a

FromDump
*/

class EDDSched : public Element { public:

    EDDSched();
    ~EDDSched();

    const char *class_name() const	{ return "EDDSched"; }
    const char *port_count() const	{ return "-/1"; }
    const char *processing() const	{ return PULL; }
    const char *flags() const		{ return "S0"; }
    void *cast(const char *);

    int configure(Vector<String> &, ErrorHandler *);
    int initialize(ErrorHandler *);
    void cleanup(CleanupStage);

    Packet *pull(int);

  private:

    Packet **_vec;
    NotifierSignal *_signals;
    Notifier _notifier;
    bool _stop;
    bool _tsanno; // True if use Timestamp in Timestamp annotation
};

CLICK_ENDDECLS
#endif
