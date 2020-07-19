#ifndef SCOPE_HPP_INCLUDED
#define SCOPE_HPP_INCLUDED
#include <functional>
#include <iostream>
#include <memory>
#include <vector>
// Exit/Success/Failure scope guards similar to D(lang)
// https://stackoverflow.com/questions/130117/throwing-exceptions-out-of-a-destructor
// https://tour.dlang.org/tour/en/gems/scope-guards

class Scope final {
public:
  Scope()                   = default;
  Scope(Scope&&)            = default;
  Scope& operator=(Scope&&) = default;

  template<typename F>
  Scope&& Exit(F&& f) {
    vec_.emplace_back(f);
    return std::move(*this);
  }

  template<typename F>
  Scope&& Failure(F&& f) {
    vec_.emplace_back([f]() { if (std::uncaught_exception()) { f(); } });
    return std::move(*this);
  }

  template<typename F>
  Scope&& Success(F&& f) {
    vec_.emplace_back([f]() { if (!std::uncaught_exception()) { f(); } });
    return std::move(*this);
  }

  ~Scope() noexcept(false) {
    std::exception_ptr ptr;
    for (; !vec_.empty(); ) {
      try {
        vec_.back()();
      }
      catch (...) {
        // only capture the last exception thrown
        ptr = std::current_exception();
      }
      vec_.pop_back();
    }

    if (ptr != nullptr) {
      std::rethrow_exception(ptr);
    }
  }

private:
  std::vector<std::function<void(void)>> vec_;

  Scope(Scope&)          = delete;
  void operator=(Scope&) = delete;
};

#endif // SCOPE_HPP_INCLUDED
