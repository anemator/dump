#include <iostream>
#include "base.h"

// This 'overrides' the actual def of Base::f, comment it out and the
// code will still compile but the result will be different
int Base::f() const {
  return 2;
}

int main() {
  Base b;
  std::cout << b.f() << std::endl;

  return 0;
}
