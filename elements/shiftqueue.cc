// -*- c-basic-offset: 4 -*-
/*
 * shiftqueue.{cc,hh} -- shift queue element safe for use on SMP
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
#include "shiftqueue.hh"
#include <click/handlercall.hh>
#include <click/error.hh>

CLICK_DECLS

//class RandomSimulator;

ShiftQueue::ShiftQueue()
{ 
}

ShiftQueue::~ShiftQueue()
{
}

void *
ShiftQueue::cast(const char *n)
{
    if (strcmp(n, "ShiftQueue") == 0)
	return (ShiftQueue *)this;
    else
	return SimpleQueue::cast(n);
}

int
ShiftQueue::configure(Vector<String> &conf, ErrorHandler *errh)
{
  _outrate = 0;
   int new_capacity = 1000;
   if (cp_va_kparse(conf, this, errh,
          "CAPACITY", cpkP, cpUnsigned, &new_capacity,
          "OUTRATE", 0, cpDouble, &_outrate,
          cpEnd) < 0)
      return -1;
  
  _capacity = new_capacity;
  if (_outrate < 0)
    _outrate = 0;
  return 0;
}

void
ShiftQueue::push(int, Packet *p)
{
  int h = _head, t = _tail;
  int nh = next_i(h), nt = next_i(t);
  Packet *hp = _q[h];
  Packet *tp = NULL;
  double check = 0;
  Timestamp now = Timestamp::now();

  if ((h == nt) && (hp)) {
    // If queue full, drop the first packet if it waits too long
    Timestamp waith = hp->timestamp_anno() - now;
    if (waith <= 0) {
      // drop head
      if (_drops == 0 && _capacity > 0)
        click_chatter("%{element}: overflow. Drop the first", this);
      _drops++;

      packet_memory_barrier(_q[nh], _head);
      _head = nh;
      checked_output_push(1, hp);
    }
    while (_outrate > 0 && (size() > 0)) {
      int s = size()-1;
      t = prev_i(t);
      tp = _q[t];
      Timestamp waitt = tp->timestamp_anno() - now;
      check = (waitt.doubleval() * _outrate) - s;

      if (check <= 0) {
        // drop tail since it will be expired in future
        if (_drops == 0 && _capacity > 0)
          click_chatter("%{element}: overflow. Drop tail", this);
        _drops++;
        packet_memory_barrier(_q[t], _tail);
        _tail = t;
        checked_output_push(1, tp);
      } else break;
    }
  }
  SimpleQueue::push(0, p);
}

enum { H_WRATE };
void
ShiftQueue::add_handlers()
{
  add_data_handlers("outrate", Handler::OP_READ | Handler::CALM, &_outrate);
  add_write_handler("outrate", sq_write_handler, (void*)H_WRATE);
  SimpleQueue::add_handlers();
}

int
ShiftQueue::sq_write_handler(const String &s, Element *e, void *vparam,
                   ErrorHandler *errh)
{
  ShiftQueue *sq = (ShiftQueue *)e;
  switch ((intptr_t)vparam) {
    case H_WRATE: {      // rate
      double r;
      if (!cp_double(s, &r) || (r < 0))
        return errh->error("rate parameter must be a positive real number");
      sq->_outrate = r;
      break;
    default:
      break;
    }
  }
  return 0;
}

CLICK_ENDDECLS
ELEMENT_REQUIRES(SimpleQueue)
EXPORT_ELEMENT(ShiftQueue)
