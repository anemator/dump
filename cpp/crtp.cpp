#include <iostream>

// Derived is allowed as a template parameter (even though it not's declared
// until further down) because this class isn't instantiated by the compiler
// until its called which happens in main (after Derived is implemented).
template<class T> struct Base {
  // Static Polymorphism
  void f() {
    std::cout << "In Base::func\n\n";

    std::cout << "Calling this::f from Base::f\n";
    static_cast<T*>(this)->f();
    std::cout << "Called this::f from Base::f\n\n";

    std::cout << "Calling Derived::sf from Base::f\n";
    T::sf();
    std::cout << "Called Derived::sf from Base::f\n\n";
  }
};

struct Derived : public Base<Derived> {
  void f() { std::cout << "In Derived::f\n"; }

  static void sf() { std::cout << "In Derived::sf\n"; }
};

// Keeps track of T's created and alive count
template<class T> struct Counter {
  static int objects_created;
  static int objects_alive;

  Counter() {
    ++objects_created;
    ++objects_alive;
  }

  Counter(const Counter&) {
    ++objects_created;
    ++objects_alive;
  }

protected:
  ~Counter() { --objects_alive; }
};

// Initialize created and alive values for each class CLS
template<class T> int Counter<T>::objects_created(0);
template<class T> int Counter<T>::objects_alive(0);

// Create countable classes
class X : Counter<X> {};
class Y : Counter<Y> {};

template<typename This_>
class DoublePrinter {
public:
  void ShowDouble() {
    std::cout << "double: " << This()->Double() << '\n';
  }

private:
  This_* This() { return static_cast<This_*>(this); }
};

template<typename This_>
class StringPrinter {
public:
  void ShowString() {
    std::cout << "string: " << This()->String() << '\n';
  }

private:
  This_* This() { return static_cast<This_*>(this); }
};

class Output : public DoublePrinter<Output>, public StringPrinter<Output> {
public:
  double Double() const { return 1.0; }
  std::string String() const { return "1"; }
};

int main() {
  // Example 1
  Base<Derived> b;

  std::cout << "Calling Base::f\n";
  b.f();
  std::cout << "Called Base::f\n";

  // Example 2
  X x1;
  X x2;
  { X x3; }

  std::cout << "X => Created: " << Counter<X>::objects_created
            << "; Alive: " << Counter<X>::objects_alive << '\n';

  Y* y1 = new Y();
  Y y2;
  Y* y3 = new Y();
  delete y3;
  Y y4;
  delete y1;
  Y y5;

  std::cout << "Y => Created: " << Counter<Y>::objects_created
            << "; Alive: " << Counter<Y>::objects_alive << '\n';

  // Example 3
  Output o;
  o.ShowDouble();

  return 0;
}
