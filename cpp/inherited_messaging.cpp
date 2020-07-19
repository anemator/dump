#include <cassert>
#include <functional>
#include <iostream>
#include <sstream>
#include <vector>
// A poor attempt at a messaging system using templates and multiple inheritance

// ROUTING //
template<typename Msg> class Plugin {
  std::vector<Plugin<Msg>*> receivers_;

  virtual void On(Msg const& msg) = 0;

public:
  void Register(Plugin<Msg>* plugin) {
    assert(plugin != nullptr);
    receivers_.push_back(plugin);
  }

  void Send(Msg const& msg) {
    for (auto plugin : receivers_) {
      plugin->On(msg);
    }
  }
};

// MESSAGE TYPES //
struct Initialize {
  int n;
  double x;
};

struct SpecialInitialize : public Initialize {
  std::string str;
};

struct Terminate {};

// PLUGINS //
class SomePlugin : public Plugin<Initialize>, public Plugin<SpecialInitialize> {
  void On(Initialize const& msg) override {
    std::cout << "x: " << msg.x << "\nn: " << msg.n << '\n';
  }
  void On(SpecialInitialize const& msg) override {
    On(static_cast<Initialize>(msg));
    std::cout << msg.str << '\n';
  }
};

class Relay : public Plugin<Initialize>,
              public Plugin<Terminate>,
              public Plugin<SpecialInitialize> {
  template<typename T> void OnImpl(std::string const& type, T const& msg) {
    std::stringstream ss(std::ios::binary);
    char const* str = (type + ":" + (char*)&msg).data();
    ss.write(str, sizeof(str));
  }

  void On(Initialize const& msg) { OnImpl("Initialize", msg); }
  void On(SpecialInitialize const& msg) { OnImpl("SpecialInitialize", msg); }
  void On(Terminate const& msg) { OnImpl("Terminate", msg); }

  void Receive() {}
};

// MAIN //
int main(int argc, char* argv[]) {
  SomePlugin p1;
  SomePlugin p2;
  Relay relay;

  // XXX: Name lookup happens before overload resolution :(
  // http://stackoverflow.com/questions/1734893/overloading-a-method-in-a-subclass-in-c
  relay.Plugin<Initialize>::Register(&p1);
  relay.Plugin<Initialize>::Register(&p2);
  relay.Plugin<SpecialInitialize>::Register(&p1);
  relay.Plugin<SpecialInitialize>::Register(&p2);

  p1.Plugin<Initialize>::Register(&p2);
  p1.Plugin<Initialize>::Register(&relay);
  Initialize msg;
  msg.n = 1;
  msg.x = 2.0;
  p1.Plugin<Initialize>::Send(msg);

  p2.Plugin<SpecialInitialize>::Register(&p1);
  SpecialInitialize msg2;
  msg2.n = 2;
  msg2.x = 3.0;
  msg2.str = "abc";
  p2.Plugin<SpecialInitialize>::Send(msg2);

  return 0;
}
