// -*- c-basic-offset: 4 -*-
/*
 * drr.{cc,hh} -- deficit round-robin scheduler
 * Robert Morris, Eddie Kohler
 *
 * Copyright (c) 1999-2000 Massachusetts Institute of Technology
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
#include "wdrr.hh"
CLICK_DECLS

WDRRSched::WDRRSched()
    : _quantum(500), _head(0), _deficit(0), _weights(0), _signals(0),
      _notifier(Notifier::SEARCH_CONTINUE_WAKE), _next(0)
{
}

WDRRSched::~WDRRSched()
{
}

void *
WDRRSched::cast(const char *n)
{
    if (strcmp(n, Notifier::EMPTY_NOTIFIER) == 0)
	return &_notifier;
    else
	return Element::cast(n);
}

int
WDRRSched::configure(Vector<String> &conf, ErrorHandler *errh)
{
    //_notifier.initialize(Notifier::EMPTY_NOTIFIER, router());
    //return Element::configure(conf, errh);
  delete[] _weights;
  _weights = 0;
  _nweights = 0;

  if (conf.size() == 0)
    return errh->error("too few arguments to WRRSched(weight, ...)");

  Vector<double> vals(conf.size(), 0);
  for (int i = 0; i < conf.size(); i++)
    if (!cp_double(conf[i], &vals[i]))
      return errh->error("argument %d should be positive real number", i+1);

   _weights = new double[vals.size()];
   memcpy(_weights, &vals[0], vals.size() * sizeof(double));
   _nweights = vals.size();

   if (_nweights != ninputs())
     return errh->error("need at least %d arguments, more than or equal the number of input ports", ninputs());
   return 0;
}

int
WDRRSched::initialize(ErrorHandler *errh)
{
    _head = new Packet *[ninputs()];
    _deficit = new double[ninputs()];
    _signals = new NotifierSignal[ninputs()];
    if (!_head || !_deficit || !_signals)
	return errh->error("out of memory!");

    for (int i = 0; i < ninputs(); i++) {
	_head[i] = 0;
	_deficit[i] = 0;
	_signals[i] = Notifier::upstream_empty_signal(this, i, 0, &_notifier);
    }
    _next = 0;
    return 0;
}

void
WDRRSched::cleanup(CleanupStage)
{
    if (_head)
	for (int j = 0; j < ninputs(); j++)
	    if (_head[j])
		_head[j]->kill();
    delete[] _head;
    delete[] _deficit;
    delete[] _signals;
    delete[] _weights;
}

Packet *
WDRRSched::pull(int)
{
    int n = ninputs();
    bool signals_on = false;

    // Look at each input once, starting at the *same*
    // one we left off on last time.
    for (int j = 0; j < n; j++) {
	Packet *p;
	if (_head[_next]) {
	    p = _head[_next];
	    _head[_next] = 0;
	    signals_on = true;
	} else if (_signals[_next]) {
	    p = input(_next).pull();
	    signals_on = true;
	} else
	    p = 0;

	if (p == 0)
	    _deficit[_next] = 0;
	else if ((double)p->length() <= _deficit[_next]) {
	    _deficit[_next] -= p->length();
	    _notifier.set_active(true);
	    return p;
	} else
	    _head[_next] = p;

	_next++;
	if (_next >= n)
	    _next = 0;
	_deficit[_next] += (_quantum * _weights[_next]);
    }

    _notifier.set_active(signals_on);
    return 0;
}

CLICK_ENDDECLS
EXPORT_ELEMENT(WDRRSched)
