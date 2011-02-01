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
}

SetVirtualClock::~SetVirtualClock()
{
}

int
SetVirtualClock::configure(Vector<String> &conf, ErrorHandler *errh)
{
    if (cp_va_kparse(conf, this, errh,
		     "RATE", 0, cpUnsigned, &rate,
		     cpEnd) < 0)
      return -1;
    return 0;
}

Packet *
SetVirtualClock::simple_action(Packet *p)
{
  uint32_t len = p->length();
  p->timestamp_anno().assign_now();
  if (_last_tv > p->timestamp_anno()) 
    p->timestamp_anno() = _last_tv + (Timestamp)(len/rate);
  else
    p->timestamp_anno() += (Timestamp)(len/rate);
  _last_tv = p->timestamp_anno();
  return p;
}

CLICK_ENDDECLS
EXPORT_ELEMENT(SetVirtualClock)
