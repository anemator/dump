#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

class Int;
class Double;
class NumVisitor {
public:
  virtual void visit(Int*) const = 0;
  virtual void visit(Double*) const = 0;
};

class Num {
public:
  virtual void accept(NumVisitor const&) = 0;
};

class Int : public Num {
  int data_;

public:
  std::string operator()() { return std::to_string(data_); }

  Int(int n) : data_(n) {}

  void accept(NumVisitor const& v) { v.visit(this); }
};

class Double : public Num {
  double data_;

public:
  std::string operator()() { return std::to_string(data_); }

  Double(double n) : data_(n) {}

  void accept(NumVisitor const& v) { v.visit(this); }
};

class PrintNumVisitor : public NumVisitor {
public:
  virtual void visit(Int* n) const { std::cout << (*n)() << std::endl; }
  virtual void visit(Double* x) const { std::cout << (*x)() << std::endl; }
};

int main(int argc, char* argv[]) {
  Int n(1);
  Double x(2.3);
  std::vector<Num*> vec{&n, &x};
  std::for_each(vec.begin(), vec.end(),
                [](Num* num) { num->accept(PrintNumVisitor()); });

  return 0;
}
