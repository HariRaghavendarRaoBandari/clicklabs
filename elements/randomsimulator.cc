/*
 * randomsimulator.{cc,hh} 
 * iizke 
 */
#include <stdio.h>
#include <stdlib.h>
//#include <time.h>
#include <sys/time.h>
#include <math.h>
#include "randomsimulator.hh"

double RandomSimulator::factorial(uint32_t n) {
  double value = 1;
  for (uint32_t i = 1; i <=n ; i++)
    value = value * i;
  return value;
}

double RandomSimulator::density(DISTRIB_T type, double value) {
  uint32_t int_value = 0;
  uint32_t i = 1;
  double p = 0;
  double den = 1;

  if ((value < 0) || (value > max_value)) return 0;

  switch (type) {
    case D_POISSON:
      int_value = (uint32_t)value;
      for (i = 1; i <= int_value; i++)
        den = den * lambda / i;
      den = den * exp(-lambda);
      break;
    case D_BINOMIAL:
      p = lambda / max_value;
      den = pow(p, value) * pow(1-p, max_value - value) *
            factorial(max_value) /
            (factorial((uint32_t)value)*factorial((uint32_t)(max_value - value)));
      break;
    case D_EXPONENTIAL:
      den = lambda * exp(-lambda*value);
      break;
    case D_UNIFORM:
      den = 1 / max_value;
      break;
    case D_NORMAL:
      den = exp(-pow(value - mean, 2)/(2*var)) / sqrt(2*M_PI*var);
      break;
    default:
      break;
  }
  return den;
}

double RandomSimulator::distribution_func(DISTRIB_T type, double value) {
  double ret = 0;
  
  if (value < 0) return 0;
  if (value >= max_value) return 1;

  switch (type) {
    case D_POISSON:
    case D_BINOMIAL:
    case D_NORMAL:
      for (int i = 0; i <= value; i++)
        ret += density(type, i);
      break;
    case D_EXPONENTIAL:
      ret = 1 - exp(-lambda*value);
      break;
    case D_UNIFORM:
      ret = value/max_value;
      break;
    default:
      break;
  }
  return ret;
}

double RandomSimulator::density(double value) {
  return density(type, value);
}

double RandomSimulator::distribution_func(double value) {
  return distribution_func(type, value);
}

double RandomSimulator::random_value() {

  uint32_t val = 0;
  double lower_bound = 0;
  double u = generate_uniform_rv();
  //printf("u = %f \n", u);
  for (val = 0; val < max_value; val++) {
    lower_bound += density(val);
    if (lower_bound > u)
      break;
  }
  return val;
}

double RandomSimulator::generate_uniform_rv() {
  struct timeval tv;
  struct timezone tz;
  
  gettimeofday(&tv, &tz);
  srand(tv.tv_usec);
  int rv = random() % MAX_RANGE;
  double ret = (double)rv/(double)MAX_RANGE;
  return ret;
}
