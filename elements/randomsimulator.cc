/*
 * randomsimulator.{cc,hh} 
 * iizke 
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "randomsimulator.hh"

double RandomSimulator::factorial(uint32_t n) {
  double value = 1;
  for (int i = 1; i <=n ; i++)
    value = value * i;
  return value;
}

double RandomSimulator::density(DISTRIB_T type, double value) {
  uint32_t int_value = 0;
  int i = 1;
  double p = 0;
  double den = 1;

  switch (type) {
    case D_POISSON:
      int_value = (uint32_t)value;
      for (i = 1; i <= int_value; i++)
        den = den * lambda / i;
      den = den * exp(int_value);
      break;
    case D_BINOMIAL:
      p = lambda / max_value;
      den = pow(p, value) * pow(1-p, max_value - value) *
            factorial(max_value) /
            (factorial((uint32_t)value)*factorial((uint32_t)(max_value - value)));
      break;
    case D_EXPONENTIAL:
      if (value < 0) 
        den = 0;
      else 
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

double RandomSimulator::density(double value) {
  return density(type);
}

double RandomSimulator::random_value() {
  uint32_t val = 0;
  double lower_bound = 0;
  double u = generate_uniform_rv();

  for (val = 0; val < max_value; val++) {
    lower_bound += density(val);
    if (lower_bound > u)
      break;    
  }

  return val;
}

double RandomSimulator::generate_uniform_rv() {
  int rv = random() % MAX_RANGE;
  return (double)(rv)/MAX_RANGE;
}
