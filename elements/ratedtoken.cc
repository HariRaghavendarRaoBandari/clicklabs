// -*- c-basic-offset: 4 -*-
/*
 * ratedtoken.{cc,hh} -- Rated Token Bucket
 * iizke
 * 
 * Copyright (c) 1999-2000 Massachusetts Institute of Technology
 * Copyright (c) 2005 Regents of the University of California
 * Copyright (c) iizke @ Politecnico di Torino
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
#include "ratedtoken.hh"
#include <click/confparse.hh>
#include <click/packet_anno.hh>
#include <click/error.hh>
#include <math.h>

CLICK_DECLS

RatedToken::RatedToken()
{
}

RatedToken::~RatedToken()
{
}

int
RatedToken::configure(Vector<String> &conf, ErrorHandler *errh)
{
  _active = true;
  _rate = 1;
  _burst = 1;
  lock = 0;
  _fulltk_tv = Timestamp::now();
  if (cp_va_kparse(conf, this, errh,
     "ACTIVE", 0, cpBool, &_active,
     "RATE", 0, cpUnsigned, &_rate,
     "BURST", 0, cpUnsigned, &_burst,
     cpEnd) < 0)
    return -1;
  _cburst = _burst;
  return 0;
}

void RatedToken::require_lock() 
{
  while (!lock.compare_and_swap(0,1));
}

void RatedToken::release_lock()
{
  lock = 0;
}

Packet *
RatedToken::simple_action(Packet *p)
{
  if (!_active)
    return p;
  // Calculate token size
  // = max(cburst + (now - fulltk_tv)*rate, burst)
  Timestamp now = Timestamp::now();
  // Do busy waiting
  require_lock();
    int32_t steps = floor((now - _fulltk_tv).doubleval()*_rate);
    int32_t newcb = _cburst + steps;
    if ((newcb >= (int32_t)_burst) || (steps >= _rate)) {
      newcb = (newcb > _burst)?_burst:newcb;
      _cburst = newcb;
      _fulltk_tv += (Timestamp)((double)steps/(double)_rate);
    }
    //click_chatter("ratedtoken - debug cburst = %d, newcb = %d\n",_cburst, newcb);
    if (newcb > 0) {
      // accept packet
      //click_chatter("ratedtoken - debug cburst = %d, newcb = %d, full = %f, now = %f, step %d\n",_cburst, newcb, _fulltk_tv.doubleval(), now.doubleval(), steps);
          
      _cburst--;
      release_lock();
      return p;
    }
  release_lock();
  // deny packet
  checked_output_push(1, p); 
  return NULL;
}

enum { H_WRATE, H_WRESET, H_WBURST};
int
RatedToken::change_params(const String &s, Element *e, void *vparam,
                   ErrorHandler *errh)
{
  RatedToken *rt = (RatedToken *)e;
  switch ((intptr_t)vparam) {
    case H_WRATE: {      // rate
      uint32_t r;
      if (!cp_integer(s, &r))
        return errh->error("rate parameter must be integer");
      rt->_rate = r;
      break;
    }
    case H_WBURST: {      // burst
      uint32_t b;
      if (!cp_integer(s, &b))
        return errh->error("burst parameter must be integer");
      rt->_burst = b;
      break;
    }
    case H_WRESET: {
      rt->_fulltk_tv = Timestamp::now();
      rt->_cburst = rt->_burst;
      break;
    }
    default:
      break;
  }
  return 0;
}


void
RatedToken::add_handlers()
{
  add_data_handlers("active", Handler::OP_READ | Handler::OP_WRITE | Handler::CHECKBOX | Handler::CALM, &_active);
  add_data_handlers("rate", Handler::OP_READ | Handler::CALM, &_rate);
  add_write_handler("rate", change_params, (void*)H_WRATE);
  add_data_handlers("burst", Handler::OP_READ | Handler::CALM, &_burst);
  add_write_handler("burst", change_params, (void*)H_WBURST);
  add_write_handler("reset", change_params, (void *)H_WRESET, Handler::BUTTON);

}


CLICK_ENDDECLS
EXPORT_ELEMENT(RatedToken)
