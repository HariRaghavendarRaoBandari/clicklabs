// -*- c-basic-offset: 4 -*-
#ifndef CLICK_SETTIMESTAMP2_HH
#define CLICK_SETTIMESTAMP2_HH
#include <click/element.hh>
CLICK_DECLS

/*
=c

SetTimestamp2([TIMESTAMP, I<keyword> FIRST, DELTA, ADD])

=s timestamps

store the time in the packet's timestamp annotation

=d

Store the specified TIMESTAMP in the packet's timestamp annotation. If
TIMESTAMP is not specified, then sets the annotation to the system time when
the packet arrived at the SetTimestamp element.

Keyword arguments are:

=over 8

=item FIRST

Boolean.  If true, then set the packet's "first timestamp" annotation, not its
timestamp annotation.  Default is true.

=item DELTA

Boolean.  If true, then set the packet's timestamp annotation to the
difference between its current timestamp annotation and its "first timestamp"
annotation.  Default is false.

=item ADD
Double. Additional time is added to current timestamp annotation of packet.
Current timestamp is calculated after setting with new Timestamp and first, delta.

=h add read/write
View or change Additional Time.

=back

=a StoreTimestamp, PrintOld, SetVirtualClock, SetTimestamp */

class SetTimestamp2 : public Element { public:

    SetTimestamp2();
    ~SetTimestamp2();

    const char *class_name() const		{ return "SetTimestamp2"; }
    const char *port_count() const		{ return PORTS_1_1; }
    const char *processing() const		{ return AGNOSTIC; }
    int configure(Vector<String> &, ErrorHandler *);

    Packet *simple_action(Packet *);
    void add_handlers();

  private:

    enum { ACT_NOW, ACT_TIME, ACT_FIRST_NOW, ACT_FIRST_TIME, ACT_DELTA };
    int _action;
    double addtime;
    Timestamp _tv;

    bool _active;
    static int change_param(const String &, Element *, void *, ErrorHandler *);

};

CLICK_ENDDECLS
#endif
