#include <iostream>

class Base {
  struct Hidden {
    void Print() { std::cout << "hello\n"; }
  };

public:
  static Hidden Get() { return Hidden(); }
};

int main() {
  auto h = Base::Get();
  h.Print();

  // Hidden is private in Base
  //Base::Hidden fails = Base::Get();

  return 0;
}
