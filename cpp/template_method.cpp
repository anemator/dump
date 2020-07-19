#include <iostream>
#include <string>

// Template Method Pattern using templates and perfect forwarding
// Two versions: templates and non-virtual interface
// http://www.gotw.ca/publications/mill18.htm
namespace tmp {
template<typename T, typename... Args> class Printer {
  T t_;

public:
  Printer(Args&&... args) : t_(std::forward<Args>(args)...) {}

  void print(const std::string& str) { t_.printImpl(str); }
};
class StdOut {
public:
  void printImpl(const std::string& str) { std::cout << str << std::endl; }
};
class StdErr {
public:
  void printImpl(const std::string& str) { std::cerr << str << std::endl; }
};
class File {
public:
  explicit File(int fd) {}

  void printImpl(const std::string& str) {
    // print to file
  }
};
} // end namespace tmp

// Template Method Pattern using Non-Virtual Interface
namespace nvi {
class Printer {
public:
  void print(const std::string& str) { printImpl(str); }

private:
  virtual void printImpl(const std::string& str) = 0;
};
class StdOut : public Printer {
public:
  void printImpl(const std::string& str) override {
    std::cout << str << std::endl;
  }
};
class StdErr : public Printer {
public:
  void printImpl(const std::string& str) override {
    std::cerr << str << std::endl;
  }
};
class File : public Printer {
public:
  explicit File(int fd) {}

  void printImpl(const std::string& str) override {
    // print to file
  }
};
} // end namespace nvi

int main() {
  tmp::Printer<tmp::StdOut> tmpout;
  tmpout.print("tmpout");

  tmp::Printer<tmp::StdErr> tmperr;
  tmperr.print("tmperr");

  tmp::Printer<tmp::File, int> tmpfd(1);
  tmpfd.print("tmpfd");

  nvi::Printer* nviout = new nvi::StdOut();
  nviout->print("nviout");

  nvi::Printer* nvierr = new nvi::StdErr();
  nvierr->print("nvierr");

  nvi::Printer* nvifd = new nvi::File(1);
  nvifd->print("nvifd");

  return 0;
}
