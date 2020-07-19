#include <algorithm>
#include <iostream>
#include <type_traits>
#include <vector>
#include <optional>
using namespace std;

// lifts data into the monad
template<typename T>
auto pure(T&& data) -> std::optional<T> {
  return std::make_optional(std::move(data));
}

// bind aka >>=
template<typename T, typename F>
auto operator>>=(std::optional<T>&& opt, F&& f) -> typename std::result_of<F(T)>::type {
  return opt ? f(*opt) : std::nullopt;
}

template<typename T> auto id(T&& arg) -> T { return arg; }

template<typename F, typename... Args>
auto lift(F&& f, std::optional<Args>... args) -> typename std::result_of<F(Args...)>::type {
  const auto results = std::vector<bool>(static_cast<bool>(args)...);
  const auto ok = std::all_of(results.begin(), results.end(), id<bool>);
  return ok ? f(*args...) : std::nullopt;
}

int main() {
  const auto ex1 = lift([](auto n, auto str) { return pure(n+str.size()); },
                        pure(1u), pure(string("hello")));
  cout << "example1: " << *ex1 << '\n';

  const auto ex2 =
      pure(string("hello")) >>= [&](auto str) {
      return pure(str.length()) >>= [&](auto n) {
      return pure(n+1);};};
  cout << "example2: " << *ex2 << '\n';

  return 0;
}
