#include <iostream>
#include <utility>

// Compile with -ftemplate-depth=256
static constexpr size_t DEPTH = 256;

template<ssize_t N> struct Peano {
  static constexpr ssize_t value = N;
  typedef Peano < N<DEPTH ? N + 1 : -1> succ;
};

template<typename LHS, typename RHS> struct Equals {
  static constexpr bool value = LHS::value == RHS::value;
};

template<typename LHS, typename RHS> struct LessThan {
  static constexpr bool value = LHS::value < RHS::value;
};

template<ssize_t N, ssize_t M>
constexpr bool operator==(Peano<N> const&, Peano<M> const&) {
  return N == M;
}

template<ssize_t N, ssize_t M>
constexpr bool operator<(Peano<N> const&, Peano<M> const&) {
  return N < M;
}

int main() {
  typedef Peano<0> Zero;
  std::cout << "zero:              " << Zero::value << '\n';

  typedef Zero::succ::succ Two;
  std::cout << "two:               " << Two::value << '\n';
  std::cout << "S(two):            " << Two::succ::value << '\n';

  std::cout << "Peano<0> == Zero:  " << std::boolalpha
            << Equals<Peano<0>, Zero>::value << ", " << (Peano<0>() == Zero())
            << '\n';
  std::cout << "Peano<0> == Two:   " << std::boolalpha
            << Equals<Peano<0>, Two>::value << ", " << (Peano<0>() == Two())
            << '\n';

  std::cout << "Peano<0> < Zero:   " << std::boolalpha
            << LessThan<Peano<0>, Zero>::value << ", " << (Peano<0>() < Zero())
            << '\n';
  std::cout << "Peano<0> < Two:    " << std::boolalpha
            << LessThan<Peano<0>, Two>::value << ", " << (Peano<0>() < Two())
            << '\n';

  return 0;
}
