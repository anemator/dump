#ifndef IF_EXPR_INCLUDED
#define IF_EXPR_INCLUDED
#include <memory>
#include <vector>
// An 'if statement' as an expression for the << stream operator

class If {
  struct Concept {
    virtual ~Concept() = default;
    virtual std::ostream& Write(std::ostream& os) const = 0;
  };

  template<typename T>
  struct Model : Concept {
    T&& object_;

    Model(T&& object) : object_(std::forward<T>(object)) {}

    std::ostream& Write(std::ostream& os) const override {
      return os << object_;
    }
  };

  bool condition_;
  std::vector<std::unique_ptr<const Concept>> concepts_;

public:
  If(bool condition) : condition_(condition) {}

  template<typename T>
  If&& Get(T&& object) {
    concepts_.emplace_back(std::make_unique<Model<T>>(std::forward<T>(object)));
    return std::move(*this);
  }

  friend std::ostream& operator<<(std::ostream& os, const If& self) {
    if (self.condition_) {
      for (const auto& ptr : self.concepts_) {
        ptr->Write(os);
      }
    }
    return os;
  }

  friend std::ostream& operator<<(std::ostream& os, If&& self) {
    if (self.condition_) {
      for (const auto& ptr : self.concepts_) {
        ptr->Write(os);
      }
    }
    return os;
  }
};

#if 0
#include <iostream>
#include <string>
using namespace std;

class Obj {
public:
  explicit Obj(const std::string& s) : s_(s)  { cout << "ctor\n"; }
  Obj(const Obj& obj) : s_(obj.s_)            { cout << "copy ctor\n"; }
  void operator=(const Obj& obj)              { s_ = obj.s_; cout << "copy assign\n"; }
  Obj(Obj&& obj) : s_(std::move(obj.s_))      { cout << "move ctor\n"; }
  void operator=(Obj&& obj)                   { s_ = std::move(obj.s_); cout << "move assign\n"; }
  friend ostream& operator<<(ostream& os, const Obj& obj) { return os << obj.s_; }
private:
  std::string s_;
};

int main() {
  Obj x("x");
  cout << If(true).Get(x) << '\n'
       << "----------\n"
       << If(true).Get("y").Get('\n')
       << "----------\n"
       << If(false).Get(x).Get('\n')
       << "----------\n"
       << If(true).Get(Obj("z")) << '\n'
       << "----------\n";

  return 0;
}
#endif
#endif // IF_EXPR_INCLUDED
