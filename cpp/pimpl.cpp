#include <memory>
// aka Handle-Body

// sample.h
class PrintImpl;
class Print {
public:
  Print();
  void Call(const char*);
private:
  std::unique_ptr<PrintImpl> impl_;
};

// sample.cpp
#include <iostream>
class PrintImpl {
public:
  void Call(const char* str) {
    std::cout << str << '\n';
  }
};

Print::Print() 
  : impl_(std::make_unique<PrintImpl>()) {
}

void Print::Call(const char* str) {
  impl_->Call(str);
}

// main.cpp
int main() {
  Print().Call("hey");
}
