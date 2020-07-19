#include <chrono>
#include <iostream>
// Benchmark of virtual function calls (probably inaccurate)

class Adder {
public:
  virtual void incr() = 0;
};

class AdderImpl : public Adder {
  long long data_;

public:
  AdderImpl() : data_(0) {}
  void incr() override { ++data_; }
};

int main() {
  using namespace std;
  using namespace std::chrono;
  const long long Size = 1000 * 1000 * 1000;

  Adder* a1 = new AdderImpl();
  AdderImpl a2;

  auto start1 = high_resolution_clock::now();
  for (long long ii = 0; ii < Size; ++ii) {
    a1->incr();
  }
  auto stop1 = high_resolution_clock::now();
  auto diff1 = duration_cast<milliseconds>(stop1 - start1).count();

  auto start2 = high_resolution_clock::now();
  for (long long ii = 0; ii < Size; ++ii) {
    a2.incr();
  }
  auto stop2 = high_resolution_clock::now();
  auto diff2 = duration_cast<milliseconds>(stop2 - start2).count();

  cout << "virtual: " << diff1 << '\n' << "direct : " << diff2 << '\n';

  return 0;
}
