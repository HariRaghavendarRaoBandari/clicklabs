// -*- c-basic-offset: 4 -*-
/*
 * checktimestamp.{cc,hh} -- check timestamp of packets
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
#include "checktimestamp.hh"
#include <click/confparse.hh>
#include <click/packet_anno.hh>
#include <click/error.hh>
CLICK_DECLS

CheckTimestamp::CheckTimestamp()
{
}

CheckTimestamp::~CheckTimestamp()
{
}

int
CheckTimestamp::configure(Vector<String> &conf, ErrorHandler *errh)
{
  _active = true;
  if (cp_va_kparse(conf, this, errh,
     "ACTIVE", 0, cpBool, &_active,
     cpEnd) < 0)
    return -1;
  return 0;
}

Packet *
CheckTimestamp::simple_action(Packet *p)
{
  if (!_active)
    return p;

  Timestamp now = Timestamp::now();

  if (p->timestamp_anno() >= now)
    return p;
  checked_output_push(1, p);
  return NULL;
}

void
CheckTimestamp::add_handlers()
{
  add_data_handlers("active", Handler::OP_READ | Handler::OP_WRITE | Handler::CHECKBOX | Handler::CALM, &_active);
}


CLICK_ENDDECLS
EXPORT_ELEMENT(CheckTimestamp)
