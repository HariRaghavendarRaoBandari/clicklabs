// -*- c-basic-offset: 4 -*-
/*
 * setvirtualclock.{cc,hh} -- set virtual timestamp annotations
 * iizke
 * (Douglas S. J. De Couto, Eddie Kohler)
 * based on setperfcount.{cc,hh} and settimestamp.{cc,hh}
 *
 * Copyright (c) 1999-2000 Massachusetts Institute of Technology
 * Copyright (c) 2005 Regents of the University of California
 * Copyright (c) iizke
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
#include "setvirtualclock.hh"
#include <click/confparse.hh>
#include <click/packet_anno.hh>
#include <click/error.hh>
CLICK_DECLS

SetVirtualClock::SetVirtualClock()
{
  last_tag_tv = (Timestamp)0;
  last_virtual_tv = (Timestamp)0;
  last_real_tv = (Timestamp)0;
  rate = 1;
  maxbw = 1;
  currentbw = 1;
}

SetVirtualClock::~SetVirtualClock()
{
}

int
SetVirtualClock::configure(Vector<String> &conf, ErrorHandler *errh)
{
  _active = true;
  if (cp_va_kparse(conf, this, errh,
     "RATE", cpkM, cpUnsigned, &rate,
     "MAXBW", 0, cpUnsigned, &maxbw,
     "CURRENTBW", 0, cpUnsigned, &currentbw,
     "ACTIVE", 0, cpBool, &_active,
     cpEnd) < 0)
    return -1;

  if (maxbw == 0)
    maxbw = rate;
  if (currentbw == 0)
    currentbw = maxbw;
  return 0;
}

Packet *
SetVirtualClock::simple_action(Packet *p)
{
  if (!_active)
    return p;

  uint32_t len = p->length();
  Timestamp now_real_tv = Timestamp::now();
  Timestamp now_virtual_tv = last_virtual_tv + (now_real_tv - last_real_tv)*maxbw/currentbw;

  if (last_tag_tv > now_virtual_tv) 
    p->timestamp_anno() = last_tag_tv + (Timestamp)(len/rate);
  else
    p->timestamp_anno() = now_virtual_tv + (Timestamp)(len/rate);

  last_tag_tv = p->timestamp_anno();
  last_real_tv = now_real_tv;
  last_virtual_tv = now_virtual_tv;
  return p;
}

enum { H_WRATE, H_WRESET, H_WMAXBW, H_WCURRENTBW};
int
SetVirtualClock::change_param(const String &s, Element *e, void *vparam,
               ErrorHandler *errh)
{
  SetVirtualClock *svc = (SetVirtualClock *)e;
  switch ((intptr_t)vparam) {
    case H_WRATE: {      // rate
      uint32_t r;
      if (!cp_integer(s, &r))
        return errh->error("rate parameter must be integer");
      svc->rate = r;
      break;
    }

    case H_WMAXBW: {      // maxbw
      uint32_t mb;
      if (!cp_integer(s, &mb))
        return errh->error("maxbw parameter must be integer");
      svc->maxbw = mb;
      break;
    }
    case H_WCURRENTBW: {      // currentbw
      uint32_t cb;
      if (!cp_integer(s, &cb))
        return errh->error("currentbw parameter must be integer");
      svc->currentbw = cb;
      break;
    }

    case H_WRESET: {
      svc->last_tag_tv = (Timestamp)0;
      svc->last_virtual_tv = (Timestamp)0;
      svc->last_real_tv = (Timestamp)0;
      break;
    }
  }
  return 0;
}

void
SetVirtualClock::add_handlers()
{
  add_data_handlers("rate", Handler::OP_READ | Handler::CALM, &rate);
  add_write_handler("rate", change_param, (void*)H_WRATE);
  add_write_handler("reset", change_param, (void *)H_WRESET, Handler::BUTTON);
  add_data_handlers("maxbw", Handler::OP_READ | Handler::CALM, &maxbw);
  add_write_handler("maxbw", change_param, (void*)H_WMAXBW);
  add_data_handlers("currentbw", Handler::OP_READ | Handler::CALM, &currentbw);
  add_write_handler("currentbw", change_param, (void*)H_WCURRENTBW);  
  add_data_handlers("active", Handler::OP_READ | Handler::OP_WRITE | Handler::CHECKBOX | Handler::CALM, &_active);
}


CLICK_ENDDECLS
EXPORT_ELEMENT(SetVirtualClock)
