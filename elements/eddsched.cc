// -*- mode: c++; c-basic-offset: 4 -*-
/*
 * eddsched.{cc,hh} -- element merges sorted packet streams by timestamp
 * iizke
 * Eddie Kohler
 *
 * Copyright (c) 2001-2003 International Computer Science Institute
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
#include "eddsched.hh"
#include <click/standard/scheduleinfo.hh>
#include <click/confparse.hh>
#include <click/router.hh>
CLICK_DECLS

EDDSched::EDDSched()
    : _vec(0), _signals(0), _notifier(Notifier::SEARCH_CONTINUE_WAKE)
{
}

EDDSched::~EDDSched()
{
}

void *
EDDSched::cast(const char *n)
{
    if (strcmp(n, Notifier::EMPTY_NOTIFIER) == 0)
	return &_notifier;
    else
	return Element::cast(n);
}

int
EDDSched::configure(Vector<String> &conf, ErrorHandler *errh)
{
    _notifier.initialize(Notifier::EMPTY_NOTIFIER, router());
    _stop = false;
    _tsanno = false;
    return cp_va_kparse(conf, this, errh,
			"STOP", 0, cpBool, &_stop,
      "TSANNO", 0, cpBool, &_tsanno,
		       cpEnd);
}

int
EDDSched::initialize(ErrorHandler *errh)
{
    _vec = new Packet*[ninputs()];
    _signals = new NotifierSignal[ninputs()];
    if (!_vec || !_signals)
	return errh->error("out of memory!");
    for (int i = 0; i < ninputs(); i++) {
	_vec[i] = 0;
	_signals[i] = Notifier::upstream_empty_signal(this, i, 0, &_notifier);
    }
    return 0;
}

void
EDDSched::cleanup(CleanupStage)
{
    if (_vec)
	for (int i = 0; i < ninputs(); i++)
	    if (_vec[i])
		_vec[i]->kill();
    delete[] _vec;
    delete[] _signals;
}

Packet*
EDDSched::pull(int)
{
    int which = -1;
    double tv = 0;
    double now = Timestamp::now().doubleval();
    double deadline = 0;
    bool signals_on = false;

    for (int i = 0; i < ninputs(); i++) {
    	do {
        if (_vec[i]) {
          // check deadline
          // We assume that the first 8 bytes is timestamp
          if (_tsanno == false)
            deadline = reinterpret_cast<const Timestamp*>(_vec[i]->data())->doubleval();
          else
            deadline = _vec[i]->timestamp_anno().doubleval();
          //click_chatter("EDDSched: Debug now = %f\n", deadline);
          if (now <= deadline) break;
          _vec[i]->kill();
        }
        // Find other packets from this port.
        _vec[i] = NULL;
	      _vec[i] = input(i).pull();
        if (_signals[i]) 
  	      signals_on = true;
      } while (_signals[i] && _vec[i]);

	    if (_vec[i]) {
	      //Timestamp* this_tv = &_vec[i]->timestamp_anno();
  	    if (!tv || deadline < tv) {
	  	    which = i;
		      tv = deadline;
	      }
  	  }
    }

    _notifier.set_active(which >= 0 || signals_on);
    if (which >= 0) {
	    Packet *p = _vec[which];
	    _vec[which] = input(which).pull();
	    return p;
    } else {
	  if (_stop && !signals_on)
	    router()->please_stop_driver();
	    return 0;
    }
}

CLICK_ENDDECLS
EXPORT_ELEMENT(EDDSched)
