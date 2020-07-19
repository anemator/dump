#include <iostream>
using namespace std;

// https://stackoverflow.com/questions/274626/what-is-object-slicing
// https://stackoverflow.com/questions/7516545/why-is-object-slice-needed-in-c-why-it-is-allowed-for-more-bugs
class Data {
  string s_;
public:
  Data(const string& s) : s_(s) { cout << "ctor: " << s_ << ' ' << this << '\n'; }

  ~Data() { cout << "dtor: " << s_ << ' ' << this << '\n'; }
};

class A {
  Data da;
public:
  A() : da("A") {}
};

struct B : public A {
  Data db;
public:
  B() : db("B") {}
};

int main() {
  A a = B();
  return 0;
}
