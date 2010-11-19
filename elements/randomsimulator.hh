#ifndef CLICK_RANDOMSIMUL_HH 
#define CLICK_RANDOMSIMUL_HH 

/* RandomSimulator: 
 * Discrete Random Variable Simulation 
 */
#include <stdint.h>
#define MAX_RANGE	(1<<20)

enum DISTRIB_T	{D_NORMAL, D_POISSON, D_BINOMIAL, D_EXPONENTIAL, D_UNIFORM};

class RandomSimulator { public:

  RandomSimulator ()     { type = D_UNIFORM; max_value = 1; mean = 0; var = 1;};
  ~RandomSimulator ()    {}; 
  double density (double value); 
  double density (DISTRIB_T type, double value);
  double random_value ();
  DISTRIB_T test;

  inline DISTRIB_T get_type () { return type; }
  void set_type(DISTRIB_T t);
  inline double get_lambda () { return lambda; }
  inline void set_lambda (double l) { lambda = l; }
  inline double get_max_value () { return max_value; }
  inline void set_max_value (double max) { max_value = max; }
  inline double get_mean () { return mean; }
  inline void set_mean (double m) { mean = m; }
  inline double get_var () { return var; }
  inline void set_var (double v) { var = v; }
  private:
    DISTRIB_T type;
    // lambda is used for: POISSON, BINOMIAL, EXPONENTIAL
    double lambda;
    // max_value is used for: POISSON, BINOMIAL, UNIFORM
    double max_value;
    // mean & stdvar are used for: NORMAL
    double mean;
    double var;

    double factorial (uint32_t n) ;
  protected:
    double generate_uniform_rv ();
};

#endif
