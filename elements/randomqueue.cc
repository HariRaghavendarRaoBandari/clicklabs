// -*- c-basic-offset: 4 -*-
/*
 * randomqueue.{cc,hh} -- queue element safe for use on SMP
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

#include "randomqueue.hh"
//#include "randomsimulator.hh"
#include "randomsimulator.cc"

CLICK_DECLS

//class RandomSimulator;

RandomQueue::RandomQueue()
{
}

RandomQueue::~RandomQueue()
{
}

void *
RandomQueue::cast(const char *n)
{
    if (strcmp(n, "RandomQueue") == 0)
	return (RandomQueue *)this;
    else
	return FullNoteQueue::cast(n);
}

Packet *
RandomQueue::pull(int)
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
  int rand_id, h;
  RandomSimulator *rs = new RandomSimulator();
  rs->set_max_value(size()-1);
  rand_id = (int)rs->random_value();
  h = _head;
  swap_packets(h, rand_id + h); 
  return ThreadSafeQueue::pull(0);
}

void RandomQueue::swap_packets (int p1, int p2) {
  int h = _head, t = _tail;
  Packet * tmp;

    //h = _head;
    //t = _tail;
    // queue is empty
    if (h == t) return;
    // check p1 p2
    if (p1 < h || p1 > t) return;
    if (p2 < h || p2 > t) return;
    if (p1 == p2) return;
    // do swap
    tmp = _q[p1];
    _q[p1] = _q[p2];
    _q[p2] = tmp;
}

CLICK_ENDDECLS
ELEMENT_REQUIRES(ThreadSafeQueue)
EXPORT_ELEMENT(RandomQueue)
