// -*- c-basic-offset: 4 -*-
/*
 * delayedd.{cc,hh} -- element pulls packets from input, make decision to delay 
 * packet or not.
 * Inherit from source: delayshaper.*
 * iizke
 * Copyright (c) 1999-2001 Massachusetts Institute of Technology
 * Copyright (c) 2003 International Computer Science Institute
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, subject to the conditions
 * listed in the Click LICENSE file. These conditions include: you must
 * preserve this copyright notice, and you cannot mention the copyright
 * holders in advertising related to the Software without their permission.
 * The Software is provided WITHOUT ANY WARRANTY, EXPRESS OR IMPLIED. This
 * notice is a summary of the Click LICENSE file; the license in that file is
 * legally binding.
 */

#include <click/config.h>
#include <click/error.hh>
#include <click/confparse.hh>
#include <click/glue.hh>
#include "delayedd.hh"
#include <click/standard/scheduleinfo.hh>
CLICK_DECLS

DelayEDD::DelayEDD()
    : _p(0), _timer(this), rate(0), syncdead(0), _notifier(Notifier::SEARCH_CONTINUE_WAKE)
{
}

DelayEDD::~DelayEDD()
{
}

void *
DelayEDD::cast(const char *n)
{
    if (strcmp(n, "DelayEDD") == 0)
	return (DelayEDD *)this;
    else if (strcmp(n, Notifier::EMPTY_NOTIFIER) == 0)
	return &_notifier;
    else
	return Element::cast(n);
}

int
DelayEDD::configure(Vector<String> &conf, ErrorHandler *errh)
{
    syncdead = (Timestamp)0;
    _notifier.initialize(Notifier::EMPTY_NOTIFIER, router());
    int ret = cp_va_kparse(conf, this, errh,
      "RATE", cpkM, cpDouble, &rate,
			"SYNCDEAD", 0, cpTimestamp, &syncdead, 
      cpEnd);

    if (rate < 0) 
      return errh->error("RATE should be positive");

    return ret;
}

int
DelayEDD::initialize(ErrorHandler *)
{
    _timer.initialize(this);
    _upstream_signal = Notifier::upstream_empty_signal(this, 0, 0, &_notifier);
    return 0;
}

void
DelayEDD::cleanup(CleanupStage)
{
    if (_p)
	_p->kill();
}

Packet *
DelayEDD::pull(int)
{
  // Do not run if timer is scheduled.
  if (_timer.scheduled())
    return 0;

  // read a packet
  if (!_p)
    _p = input(0).pull();

  if (!_p){
    if (!_upstream_signal) {
      // no packet available, we go to sleep right away
      _notifier.sleep();
    }
    return 0;
  }

  // calculate delay time
  Timestamp now = Timestamp::now();
  Timestamp delay = _p->timestamp_anno() - now - syncdead;
  double mininterval = 1/rate;
  //click_chatter("interval %f, delay %f, now is %f, ts is %f, syncdead %f\n", mininterval, delay.doubleval(), now.doubleval(), _p->timestamp_anno().doubleval(), syncdead.doubleval());

  if (delay <= 0) {
    // packet ready for output
    Packet *p = _p;
    _p = 0;
    return p;
  } else {
    if (delay > mininterval)
      delay = (Timestamp)mininterval;

    // adjust time by a bit
	  Timestamp expiry = now + delay - Timer::adjustment();
    click_chatter("Sleep to %f, now is %f\n", expiry.doubleval(), now.doubleval());

	  if (expiry <= 0) {
      // small delta, don't go to sleep -- but mark our Signal as active,
	    // since we have something ready.
      _notifier.wake();
	  } else {
	    // large delta, go to sleep and schedule Timer
      //click_chatter("Sleep to %f, now is %f\n", expiry.doubleval(), now.doubleval());
	    _timer.schedule_at(expiry);
	    _notifier.sleep();
    }
  }
  return 0;
}

void
DelayEDD::run_timer(Timer *)
{
    _notifier.wake();
}

enum {LRATE, LSYNCDEAD};

int
DelayEDD::write_param(const String &s, Element *e, void *label, ErrorHandler *errh)
{
  DelayEDD *u = (DelayEDD *)e;
  if ((int)label == LRATE){
    if (!cp_double(s, &u->rate) || u->rate < 0){
	    return errh->error("rate must be a positive number.");
    }
  } else if (!cp_time(s, &u->syncdead)){
    return errh->error("syncdead must be a number");
  }
  return 0;
}

void
DelayEDD::add_handlers()
{
    add_data_handlers("rate", Handler::OP_READ | Handler::CALM, &rate);
    add_write_handler("rate", write_param, (void *)LRATE);
    add_data_handlers("syncdead", Handler::OP_READ | Handler::CALM, &syncdead);
    add_write_handler("syncdead", write_param, (void *)LSYNCDEAD);

}

CLICK_ENDDECLS
EXPORT_ELEMENT(DelayEDD)
ELEMENT_MT_SAFE(DelayEDD)
