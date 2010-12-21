// -*- c-basic-offset: 4 -*-
/*
 * wrrsched.{cc,hh} -- weighted round robin scheduler element
 * iizke
 * Robert Morris, Eddie Kohler
 *
 * Copyright (c) 1999-2000 Massachusetts Institute of Technology
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
#include "wrrsched.hh"

CLICK_DECLS

WRRSched::WRRSched()
    : _next(0), _signals(0), _weights(0), _nweights(0), _porders(0)
{
}

WRRSched::~WRRSched()
{
  delete[] _weights;
  delete[] _porders;
}

int
WRRSched::initialize(ErrorHandler *errh)
{
    if (!(_signals = new NotifierSignal[ninputs()]))
	return errh->error("out of memory!");
    for (int i = 0; i < ninputs(); i++)
	_signals[i] = Notifier::upstream_empty_signal(this, i, 0);
    return 0;
}

void
WRRSched::cleanup(CleanupStage)
{
    delete[] _signals;
}

static inline void init_porders (int * porders, int n) {
    for (int i = 0 ; i < n; i++) 
          porders[i] = -1; 
}

int
WRRSched::configure(Vector<String> &conf, ErrorHandler *errh)
{

  delete[] _weights;
  _weights = 0;
  _nweights = 0;

  if (conf.size() == 0)
	  return errh->error("too few arguments to WRRSched(weight, ...)");

  Vector<int> vals(conf.size(), 0);
  for (int i = 0; i < conf.size(); i++)
	   if (!cp_integer(conf[i], &vals[i]))
	    return errh->error("argument %d should be positive real number", i+1);
	
	_weights = new int[vals.size()];
	memcpy(_weights, &vals[0], vals.size() * sizeof(int));
	_nweights = vals.size();
  
  if (_nweights != ninputs())
	  return errh->error("need at least %d arguments, more than or equal the number of input ports", ninputs());

  // Calculate sum of weights
  _sumwei = 0;
  for (int i=0; i < _nweights; i++)
	  _sumwei += _weights[i];
  
  // Create port order list
  _porders = new int[_sumwei];
  init_porders (_porders, _sumwei);
  
  // distribute ports
  for (int i=0; i < _nweights; i++) {
    double freq = _sumwei / _weights[i];
    for (int k=0; k < _weights[i]; k++) {
      int nextp = int(freq * k);
      if (_porders[nextp] == -1) 
        // can use this position
        _porders[nextp] = i;
      else {
        // have to find another one
        for (int j=nextp+1; j < _sumwei; j++) 
          if (_porders[j] == -1) {
            // use this postition and then stop seeking
            _porders[j] = i;
            break;
          }
      }
    }
  }
  return 0;
}

Packet *
WRRSched::pull(int)
{
  int n = _sumwei;
  int i = _next;
  for (int j = 0; j < n; j++) {
    int port = _porders[i];
  	Packet *p = (_signals[port] ? input(port).pull() : 0);
	  i++;
	  if (i >= n)
	    i = 0;
	  if (p) {
	    _next = i;
	    return p;
	  }
  }
  return 0;
}

CLICK_ENDDECLS
EXPORT_ELEMENT(WRRSched)
