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
    : _next(0), _signals(0), _weights(0), _nweights(0), _porders(0), scale(1)
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
  scale = 1;
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

static int find_max(int * array, int len) {
  int max = 0;
  for (int i = 0; i < len; i++) {
    if (array[i] > max) 
      max = array[i];
  }
  return max;
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
  int posize = _sumwei * scale;
  _porders = new int[posize];
  if (_porders == 0) {
    return errh->error("Memory is out with %d integers \n", posize);
  }
  init_porders (_porders, posize);
  
  /* distribute ports
   * 1st solution:
   * scattering ports port-by-port (after finishing scattering port_i,
   * continue with port_i+1
   */
  for (int i=0; i < _nweights; i++) {
    double freq = double(_sumwei) / double(_weights[i]);
    int start = 0;
    int nextp = 0;
    //printf("freq = %f \n", freq);
    for (int k=0; k < (_weights[i] * scale); k++) {
      nextp = (start + int(freq * k));// % posize;
      if (_porders[nextp] >= 0) {
        // have to find another one
        for (int j=0; j < posize; j++) {
          int pos = (j + nextp - i/2) % posize;
          if (_porders[pos] == -1) {
            // use this postition and then stop seeking
            nextp = pos;
            break;
          }
        }
      }
      _porders[nextp] = i;
      if (k == 0) start = nextp;
      printf("port %d: k = %d, nextp = %d, porder_nextp = %d \n", i, k, nextp,
      _porders[nextp]);
    }
  }


  /* distribute ports
   * 2nd solution:
   * scattering ports by round-robin
   *
  int maxweight = find_max(_weights, _nweights);
  printf("maxweight = %d\n", maxweight);
  for (int i = 0; i < (maxweight * scale); i++) {
    for (int j = 0; j < _nweights; j++) {
      int numports = _weights[j] * scale;
      if (i < numports) {
        int nextp = int(_sumwei*i/_weights[j]);
        if (_porders[nextp] == -1) 
          // can use this position
          _porders[nextp] = j;
        else {
          // find another position
          for (int k = int(nextp-j); k < posize; k++) {
            if (_porders[k] == -1) {
              _porders[k] = j;
              break;
            }
          }
        }
      }
    }
  }
  */
  // debug
  for (int i=0; i < posize; i++) 
    printf("porders %d : port %d \n", i, _porders[i]);
  return 0;
}

Packet *
WRRSched::pull(int)
{
  int n = _sumwei * scale;
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
