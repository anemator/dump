#include "increment.pb.h"
#include "system.pb.h"
#include <array>
#include <cassert>
#include <iostream>
#include <map>
#include <set>
#include <sstream>

// XXX: Deal with handler exceptions and singleton destruction order
// XXX: Consider implementing channels
// XXX: Add a DispatchLater function (and maybe an event loop) for threading

// Dispatcher Framework //////////////////////////////////////////////////////
//@brief A uniform method for creating type dispatchers.
//
// MESSAGE must provide the following interface:
// - MESSAGE()
// - bool ParseFromIstream(istream&)
// - bool SerializeToOstream(ostream&)
#define MAKE_DISPATCHER(MESSAGE)                                               \
  template<> class Dispatcher<MESSAGE> final : public IDispatcher {            \
  public:                                                                      \
    static Dispatcher<MESSAGE>& Get() {                                        \
      static Dispatcher<MESSAGE> d;                                            \
      return d;                                                                \
    }                                                                          \
                                                                               \
    ~Dispatcher() { Dispatcher<Stream>::Get().Unregister(this); }              \
                                                                               \
    const std::string& TypeName() const override {                             \
      static std::string s(#MESSAGE);                                          \
      return s;                                                                \
    }                                                                          \
                                                                               \
    bool Dispatch(const MESSAGE& msg) {                                        \
      for (auto itr : handlers_) {                                             \
        itr.second(msg);                                                       \
      }                                                                        \
      return true;                                                             \
    }                                                                          \
                                                                               \
    bool Dispatch(std::istream& is) override {                                 \
      MESSAGE msg;                                                             \
      return msg.ParseFromIstream(&is) && Dispatch(msg);                       \
    }                                                                          \
                                                                               \
    bool Serialize(const MESSAGE& msg, std::ostream& os) {                     \
      return msg.SerializeToOstream(&os);                                      \
    }                                                                          \
                                                                               \
  private:                                                                     \
    friend HandlerDelegate;                                                    \
                                                                               \
    Dispatcher() { Dispatcher<Stream>::Get().Register(this); }                 \
                                                                               \
    template<typename Handler>                                                 \
    bool Register(const HandlerDelegate* d, Handler&& h) {                     \
      assert(d);                                                               \
      auto p = std::make_pair(d, std::forward<Handler>(h));                    \
      return handlers_.emplace(p).second;                                      \
    }                                                                          \
                                                                               \
    bool Unregister(const HandlerDelegate* d) override {                       \
      assert(d);                                                               \
      return handlers_.erase(d) > 0;                                           \
    }                                                                          \
                                                                               \
    Dispatcher(Dispatcher&) = delete;                                          \
                                                                               \
    Dispatcher(Dispatcher&&) = delete;                                         \
                                                                               \
    void operator=(Dispatcher&) = delete;                                      \
                                                                               \
    void operator=(Dispatcher&&) = delete;                                     \
                                                                               \
    /* XXX: Might be worthwhile to get return values from handlers  */         \
    using Handler = std::function<void(const MESSAGE&)>;                       \
    std::map<const HandlerDelegate*, Handler> handlers_;                       \
  }

/// The template class to be specialized. Disallow construction...
template<typename> class Dispatcher final { Dispatcher() = delete; };

class HandlerDelegate;
class IDispatcher {
public:
  virtual bool Dispatch(std::istream&) = 0;
  virtual bool Unregister(const HandlerDelegate*) = 0;
  virtual const std::string& TypeName() const = 0;
};

/// The one and only class which can register handlers for automating
/// lifetime management of member function pointers with Dispatchers
/// to prevent the possibility of dereferencing an invalid pointer.
/// Inheritance is disabled because the dtor of this class would
/// necessarily run after the dtor of its child allowing invalid
/// pointers in each of its Dispatchers for a brief period of time.
class HandlerDelegate final {
public:
  template<typename Msg, typename Handler> bool Register(Handler&& h) {
    // XXX: Registration and insertion should be atomic
    return Dispatcher<Msg>::Get().Register(this, std::forward<Handler>(h)) &&
           dispatchers_.insert(&Dispatcher<Msg>::Get()).second;
  }

  ~HandlerDelegate() {
    for (auto& d : dispatchers_) {
      d->Unregister(this);
    }
  }

private:
  std::set<IDispatcher*> dispatchers_;
};

// Dispatchers ///////////////////////////////////////////////////////////////
/// A Meta-Dispatcher for forwarding messages to the appropriate Dispatcher.
struct Stream {};
template<> class Dispatcher<Stream> final {
public:
  static Dispatcher<Stream>& Get() {
    static Dispatcher<Stream> d;
    return d;
  }

  /// Forwards the stream to the appropriate Dispatcher (sans meta-data)
  /// for deserialization and handling.
  bool Dispatch(std::istream& is) {
    is.get(buffer_.data(), buffer_size_, delim_);
    const unsigned count = is.gcount();                 // order matters!
    if (is.good() && delim_ == is.get() && is.good()) { // yep check twice...
      std::string key(buffer_.data(), count);
      return dispatchers_.count(key) > 0 && dispatchers_.at(key)->Dispatch(is);
    }
    return false;
  }

  bool Register(IDispatcher* d) {
    assert(d);
    dispatchers_[d->TypeName()] = d;
    return true;
  }

  bool Unregister(IDispatcher* d) {
    assert(d);
    return dispatchers_.erase(d->TypeName()) > 0;
  }

  /// Serializes the message with the appropriate dispatcher meta-data.
  template<typename Msg> bool Serialize(const Msg& msg, std::ostream& os) {
    const auto& type = Dispatcher<Msg>::Get().TypeName();
    os.write(type.data(), type.size()).put(delim_);
    return Dispatcher<Msg>::Get().Serialize(msg, os);
  }

  const std::string& TypeName() const {
    static std::string s("Stream");
    return s;
  }

private:
  Dispatcher() : delim_(':') {}

  enum { buffer_size_ = 64 };
  std::array<char, buffer_size_> buffer_;
  const char delim_;
  std::map<std::string, IDispatcher*> dispatchers_;
};

MAKE_DISPATCHER(Increment);
MAKE_DISPATCHER(System);

///@brief Dispatches to all registered listeners (of that message type).
template<typename Msg> bool Dispatch(const Msg& msg) {
  return Dispatcher<Msg>::Get().Dispatch(msg);
}

// Sample ////////////////////////////////////////////////////////////////////
class Sample {
public:
  Sample() : value_(0) {
    hd_.Register<System>([this](const System& msg) { this->OnSystem(msg); });
    hd_.Register<Increment>(
        [this](const Increment& msg) { this->OnIncrement(msg); });
  }

  long long value_;
  void OnIncrement(const Increment& msg) { value_ = msg.value(); }

private:
  void OnSystem(const System& msg) {
    std::cout << "Received " << msg.Phase_Name(msg.phase()) << " via "
              << msg.method() << '\n';
  }
  HandlerDelegate hd_;
};

void demo() {
  // Create plugin and Notify message
  System msg;
  Sample sample;

  // Direct Dispatch (unserialized, effectively zero-cost)
  {
    msg.set_phase(System_Phase_Initialize);
    msg.set_method("direct dispatch");
    Dispatcher<System>::Get().Dispatch(msg);

    msg.set_phase(System_Phase_Ready);
    msg.set_method("direct dispatch helper");
    Dispatch(msg);
  }

  // Direct Dispatch (serialized)
  {
    std::stringstream ss;
    msg.set_phase(System_Phase_Start);
    msg.set_method("direct dispatch serialized");
    Dispatcher<System>::Get().Serialize(msg, ss);
    Dispatcher<System>::Get().Dispatch(ss);
  }

  // Indirect Dispatch (serialized)
  {
    std::stringstream ss;
    msg.set_phase(System_Phase_Terminate);
    msg.set_method("indirect dispatch serialized");
    Dispatcher<Stream>::Get().Serialize(msg, ss);
    Dispatcher<Stream>::Get().Dispatch(ss);
  }
}

void benchmark() {
  using namespace std::chrono;
  Sample sample;
  Increment msg;
  std::stringstream ss;
  const long long size = 1000 * 1000 * 10;

  // Direct Call
  auto start1 = high_resolution_clock::now();
  for (long long ii = 0; ii < size; ++ii) {
    msg.set_value(ii);
    sample.OnIncrement(msg);
  }
  auto stop1 = high_resolution_clock::now();
  auto diff1 = duration_cast<milliseconds>(stop1 - start1).count();
  sample.value_ = 0;

  // Direct Dispatch
  auto start2 = high_resolution_clock::now();
  for (long long ii = 0; ii < size; ++ii) {
    msg.set_value(ii);
    Dispatcher<Increment>::Get().Dispatch(msg);
  }
  auto stop2 = high_resolution_clock::now();
  auto diff2 = duration_cast<milliseconds>(stop2 - start2).count();
  sample.value_ = 0;

  // Direct Dispatch serialized
  auto start3 = high_resolution_clock::now();
  for (long long ii = 0; ii < size; ++ii) {
    ss.clear();
    msg.set_value(ii);
    Dispatcher<Increment>::Get().Serialize(msg, ss);
    Dispatcher<Increment>::Get().Dispatch(ss);
  }
  auto stop3 = high_resolution_clock::now();
  auto diff3 = duration_cast<milliseconds>(stop3 - start3).count();
  sample.value_ = 0;

  // Indirect Dispatch serialized
  auto start4 = high_resolution_clock::now();
  for (long long ii = 0; ii < size; ++ii) {
    ss.clear();
    msg.set_value(ii);
    Dispatcher<Stream>::Get().Serialize(msg, ss);
    Dispatcher<Stream>::Get().Dispatch(ss);
  }
  auto stop4 = high_resolution_clock::now();
  auto diff4 = duration_cast<milliseconds>(stop4 - start4).count();
  sample.value_ = 0;

  std::cout << "call: " << diff1 << '\n'
            << "dispatch: " << diff2 << '\n'
            << "dispatch-serial: " << diff3 << '\n'
            << "dynamic-serial: " << diff4 << '\n';
}

// MAIN //////////////////////////////////////////////////////////////////////
int main() {
  demo();
  benchmark();
  return 0;
}
