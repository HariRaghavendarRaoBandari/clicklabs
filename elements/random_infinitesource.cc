/*
 * infinitesource.{cc,hh} -- element generates configurable random infinite stream
 * of packets at an position of byte
 * iizke (inherited from Eddie Kohler)
 *
 * Copyright (c) 1999-2000 Massachusetts Institute of Technology
 * Copyright (c) 2006 Regents of the University of California
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
#include "random_infinitesource.hh"
#include <click/confparse.hh>
#include <click/error.hh>
#include <click/router.hh>
#include <click/standard/scheduleinfo.hh>
#include <click/glue.hh>
#include <click/straccum.hh>
//#include <iostream>
CLICK_DECLS

RandomInfiniteSource::RandomInfiniteSource()
  : _task(this)
{
    _packet = new RandomBytePacket;
}

RandomInfiniteSource::~RandomInfiniteSource()
{
}

void *
RandomInfiniteSource::cast(const char *n)
{
  if (strcmp(n, "RandomInfiniteSource") == 0)
    return (RandomInfiniteSource *)this;
  else if (strcmp(n, Notifier::EMPTY_NOTIFIER) == 0)
    return static_cast<Notifier *>(this);
  else
    return 0;
}

int
RandomInfiniteSource::configure(Vector<String> &conf, ErrorHandler *errh)
{
    ActiveNotifier::initialize(Notifier::EMPTY_NOTIFIER, router());
  String data = "Random in a packet, at least 64 bytes long. Well, now it is.";
  int limit = -1;
  int burstsize = 1;
  int datasize = -1;
  uint32_t rndbyteid = 0;
  bool active = true, stop = false;

  if (cp_va_kparse(conf, this, errh,
		   "DATA", cpkP, cpString, &data,
		   "LIMIT", cpkP, cpInteger, &limit,
		   "BURST", cpkP, cpInteger, &burstsize,
		   "ACTIVE", cpkP, cpBool, &active,
		   "LENGTH", 0, cpInteger, &datasize,
		   "DATASIZE", 0, cpInteger, &datasize, // deprecated
		   "STOP", 0, cpBool, &stop,
		   "RNDBYTEID", 0, cpInteger, &rndbyteid,
		   cpEnd) < 0)
    return -1;
  if (burstsize < 1)
    return errh->error("burst size must be >= 1");

  _data = data;
  _datasize = datasize;
  _limit = limit;
  _burstsize = burstsize;
  _count = 0;
  _active = active;
  _stop = stop;
  _rndbyteid = rndbyteid;

  setup_packet();

  return 0;
}

int
RandomInfiniteSource::initialize(ErrorHandler *errh)
{
  if (output_is_push(0)) {
    ScheduleInfo::initialize_task(this, &_task, errh);
    _nonfull_signal = Notifier::downstream_full_signal(this, 0, &_task);
  }
  return 0;
}

void
RandomInfiniteSource::cleanup(CleanupStage)
{
  if (_packet)
    _packet->kill();
}

bool
RandomInfiniteSource::run_task(Task *)
{
    if (!_active || !_nonfull_signal)
	return false;
    int n = _burstsize;
    if (_limit >= 0 && _count + n >= _limit)
	n = (_count > _limit ? 0 : _limit - _count);
    for (int i = 0; i < n; i++) {
	//Packet *p = _packet->clone();
	Packet *p = _packet->clone(_rndbyteid);
	if (!p) {
	    continue;
	}
        p->timestamp_anno().assign_now();
	output(0).push(p);
    }
    _count += n;
    if (n > 0)
	_task.fast_reschedule();
    else if (_stop && _limit >= 0 && _count >= _limit)
	router()->please_stop_driver();
    return n > 0;
}

Packet *
RandomInfiniteSource::pull(int)
{
    if (!_active) {
    done:
	if (Notifier::active())
	    sleep();
	return 0;
    }
    if (_limit >= 0 && _count >= _limit) {
	if (_stop)
	    router()->please_stop_driver();
	goto done;
    }
    _count++;
    //Packet *p = _packet->clone();
    Packet *p = _packet->clone(_rndbyteid);
    if (!p) return NULL;
    p->timestamp_anno().assign_now();
    return p;
}

void
RandomInfiniteSource::setup_packet()
{
    if (_packet)
	_packet->kill();

    if (_datasize < 0)
	_packet->make(_data.data(), _data.length());
    else if (_datasize <= _data.length())
	_packet->make(_data.data(), _datasize);
    else {
	// make up some data to fill extra space
	StringAccum sa;
	while (sa.length() < _datasize)
	    sa << _data;
	_packet->make(sa.data(), _datasize);
    }
}

String
RandomInfiniteSource::read_param(Element *e, void *vparam)
{
  RandomInfiniteSource *is = (RandomInfiniteSource *)e;
  switch ((intptr_t)vparam) {
   case 0:			// data
    return is->_data;
    //case 7:
    //  return is->_nonfull_signal.unparse(is->router());
   default:
    return "";
  }
}

int
RandomInfiniteSource::change_param(const String &s, Element *e, void *vparam,
			     ErrorHandler *errh)
{
  RandomInfiniteSource *is = (RandomInfiniteSource *)e;
  switch ((intptr_t)vparam) {

   case 0:			// data
     is->_data = s;
     is->setup_packet();
     break;

   case 1: {			// limit
     int limit;
     if (!cp_integer(s, &limit))
       return errh->error("limit parameter must be integer");
     is->_limit = limit;
     break;
   }

   case 2: {			// burstsize
     int burstsize;
     if (!cp_integer(s, &burstsize) || burstsize < 1)
       return errh->error("burstsize parameter must be integer >= 1");
     is->_burstsize = burstsize;
     break;
   }

   case 3: {			// active
     bool active;
     if (!cp_bool(s, &active))
       return errh->error("active parameter must be boolean");
     is->_active = active;
     break;
   }

   case 5: {			// reset
     is->_count = 0;
     break;
   }

   case 6: {			// datasize
     int datasize;
     if (!cp_integer(s, &datasize))
       return errh->error("length must be integer");
     is->_datasize = datasize;
     is->setup_packet();
     break;
   }
  }

  if (is->_active && (is->_limit < 0 || is->_count < is->_limit)) {
    if (is->output_is_push(0) && !is->_task.scheduled())
      is->_task.reschedule();

    if (is->output_is_pull(0) && !is->Notifier::active())
      is->wake();
  }
  return 0;
}

void
RandomInfiniteSource::add_handlers()
{
  add_read_handler("data", read_param, (void *)0, Handler::CALM);
  add_write_handler("data", change_param, (void *)0, Handler::RAW);
  add_data_handlers("limit", Handler::OP_READ | Handler::CALM, &_limit);
  add_write_handler("limit", change_param, (void *)1);
  add_data_handlers("burst", Handler::OP_READ | Handler::CALM, &_burstsize);
  add_write_handler("burst", change_param, (void *)2);
  add_data_handlers("active", Handler::OP_READ | Handler::CHECKBOX, &_active);
  add_write_handler("active", change_param, (void *)3);
  add_data_handlers("count", Handler::OP_READ, &_count);
  add_write_handler("reset", change_param, (void *)5, Handler::BUTTON);
  add_data_handlers("length", Handler::OP_READ | Handler::CALM, &_datasize);
  add_write_handler("length", change_param, (void *)6);
  // deprecated
  add_data_handlers("burstsize", Handler::OP_READ | Handler::CALM | Handler::DEPRECATED, &_burstsize);
  add_write_handler("burstsize", change_param, (void *)2);
  add_data_handlers("datasize", Handler::OP_READ | Handler::CALM | Handler::DEPRECATED, &_datasize);
  add_write_handler("datasize", change_param, (void *)6);
  //add_read_handler("notifier", read_param, (void *)7);

  add_task_handlers(&_task);
}

unsigned char
random_byte() {
    //srand ( time(NULL) );
    return (unsigned char)(rand() % 255 + 1);
}

// iizke: This will randomize the byte in packet
Packet *
RandomBytePacket::clone(uint32_t byteid) {
#if CLICK_USERLEVEL
    WritablePacket *p = (this->_packet)->uniqueify();
    unsigned char * data;
    unsigned char rbyte = 0;

    if (!p) {
        printf("Cannot uniqueify packet\n");
        return p;
    }
    data = p->data();
    if ( byteid == 0 )
        return p->clone();
    if ( byteid <= p->length() ) {
        rbyte = random_byte();
        data[byteid - 1] = rbyte;
    }
    return p->clone();
#else // NO SUPPORT FOR KERNEL-LEVEL
    return clone();
#endif
}

void RandomBytePacket::kill() {
    if (_packet)
      _packet->kill();
    return;
}

void RandomBytePacket::make (const void *data, uint32_t length) {
    _packet = Packet::make(data, length);
    return;
}

RandomBytePacket::RandomBytePacket ()
    :_packet(0)
{
}

RandomBytePacket::~RandomBytePacket () {
    if (_packet)
        _packet->kill();
}

CLICK_ENDDECLS
EXPORT_ELEMENT(RandomInfiniteSource)
