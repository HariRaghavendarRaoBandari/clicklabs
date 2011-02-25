// -*- c-basic-offset: 4 -*-
/*
 * eddqueue.{cc,hh} -- EDD queue element safe for use on SMP
 * iizke
 *
 * Eddie Kohler
 *
 * Copyright (c) 2008 Meraki, Inc.
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
#include <click/glue.hh>

//#include "../standard/threadsafequeue.hh"
//#include "../standard/counter.hh"
#include "eddqueue.hh"
#include <click/handlercall.hh>

CLICK_DECLS

//class RandomSimulator;

EDDQueue::EDDQueue()
{
}

EDDQueue::~EDDQueue()
{
}

int
EDDQueue::configure(Vector<String> &conf, ErrorHandler *errh)
{
  _fixedrate = 0;
  int new_capacity = 1000;
  if (cp_va_kparse(conf, this, errh,
        "CAPACITY", cpkP, cpUnsigned, &new_capacity,
        "RATE", 0, cpDouble, &_fixedrate,
        cpEnd) < 0)
    return -1;
  _capacity = new_capacity;
  _full_note.initialize(Notifier::FULL_NOTIFIER, router());
  _full_note.set_active(true, false);
  _empty_note.initialize(Notifier::EMPTY_NOTIFIER, router());          
  //ThreadSafeQueue::configure(conf, errh);
  return 0;
}


void
EDDQueue::reset()
{
}

void
EDDQueue::update_rate()
{
   _rate.update(1);
}

void *
EDDQueue::cast(const char *n)
{
    if (strcmp(n, "EDDQueue") == 0)
	return (EDDQueue *)this;
    else
	return ThreadSafeQueue::cast(n);
}

Packet *
EDDQueue::pull(int)
{
  /*
    // Code taken from SimpleQueue::deq.
    int h, t, nh;

    do {
	h = _head;
	t = _tail;
	nh = next_i(h);

	if (h == t)
	    return pull_failure();
    } while (!_xhead.compare_and_swap(h, nh));

    return pull_success(h, t, nh);
*/
  Packet * pk = ThreadSafeQueue::pull(0);
  if (pk)
    update_rate();

  return pk;
}

void
EDDQueue::push(int, Packet *p)
{
  // Decide ability of joining us
  if (!p)
    return;

  double now = Timestamp::now().doubleval();
  _rate.update(0);
  double rate = _fixedrate;
  if (rate < 1)
    rate = _rate.rate();
  double ts = p->timestamp_anno().doubleval();
  double check = (ts - now) * rate - size();
  //click_chatter("check = %f, rate = %f, now = %f, ts = %f , size = %d \n", check, rate, now, ts, size() );
  if (check < 0) {
    // Drop packet
    p->kill();
  } else {
    ThreadSafeQueue::push(0, p);
  }
}

enum { H_RATE };
void
EDDQueue::add_handlers()
{
  add_read_handler("rate", read_handler, (void *)H_RATE);
  ThreadSafeQueue::add_handlers();
}

String
EDDQueue::read_handler(Element *e, void *thunk)
{
  EDDQueue *c = (EDDQueue *)e;
  switch ((intptr_t)thunk) {
    case H_RATE:
      c->_rate.update(0); // drop rate after idle period
      return c->_rate.unparse_rate();
    default:
      return ThreadSafeQueue::read_handler(e, thunk);
  }
}

CLICK_ENDDECLS
ELEMENT_REQUIRES(ThreadSafeQueue)
EXPORT_ELEMENT(EDDQueue)
