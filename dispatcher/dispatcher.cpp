#include "increment.pb.h"
#include "system.pb.h"
#include <array>
#include <iostream>
#include <sstream>
#include <unordered_set>

// XXX Lazy construction of dispatchers delays StreamDispatcher registration.
// XXX Deal with handler exceptions and singleton destruction order.
// XXX Add event loop, channels, parallel event dispatching, and thread-safe IO.

// Dispatchers and EventHandlers ///////////////////////////////////////////////

/// The template classes to be specialized. Disallow construction...
template<typename> class EventHandler final { EventHandler() = delete; };
template<typename> class Dispatcher final { Dispatcher() = delete; };

struct STREAM {};
class StreamDispatcher {
public:
  friend class Dispatcher<STREAM>;
protected:
  virtual ~StreamDispatcher() = default;
private:
  virtual bool Dispatch(std::istream&) = 0;
};

/// A Meta-Dispatcher for forwarding messages to the appropriate Dispatcher.
template<> class Dispatcher<STREAM> final : public StreamDispatcher {
public:
  template<typename> friend class Dispatcher;

  Dispatcher(Dispatcher&) = delete;
  Dispatcher(Dispatcher&&) = delete;
  void operator=(Dispatcher&) = delete;
  void operator=(Dispatcher&&) = delete;

private:
  Dispatcher() : delim_(':') {}

  static Dispatcher<STREAM>& Get() {
    static Dispatcher<STREAM> d;
    return d;
  }
  const std::string& TypeName() const {
    static std::string s("STREAM");
    return s;
  }

  /// Forwards the stream to the appropriate Dispatcher (sans meta-data)
  /// for deserialization and handling.
  bool Dispatch(std::istream& is) override {
    is.get(buffer_.data(), buffer_size_, delim_);
    const unsigned count = is.gcount();                 // order matters!
    if (is.good() && delim_ == is.get() && is.good()) { // yep check twice...
      std::string key(buffer_.data(), count);
      if (dispatchers_.count(key) > 0) {
        return dispatchers_.at(key)->Dispatch(is);
      }
    }
    return false;
  }

  /// Serializes the message with the appropriate dispatcher meta-data.
  template<typename Msg> bool Serialize(const Msg& msg, std::ostream& os) {
    const auto& type = Dispatcher<Msg>::Get().TypeName();
    os.write(type.data(), type.size()).put(delim_);
    return Dispatcher<Msg>::Get().Serialize(msg, os);
  }

  const char delim_;
  enum { buffer_size_ = 64 };
  std::array<char, buffer_size_> buffer_;
  std::map<const std::string, StreamDispatcher*> dispatchers_;
};

/// Nested EventHandlers are tricky in that if you dispatch a message from a
/// parent handler's destructor to a child handler that is overriding a handler
/// at the current destructor's inheritance level or higher, then the child may
/// still be registered as a handler for that message even though (some) memory
/// for it has been released and may have been reallocated elsewhere.
#define MAKE_DISPATCHER_AND_HANDLER(MESSAGE)                                   \
  template<> class Dispatcher<MESSAGE> final : public StreamDispatcher {       \
  public:                                                                      \
    template<typename> friend class EventHandler;                              \
    Dispatcher(Dispatcher&) = delete;                                          \
    Dispatcher(Dispatcher&&) = delete;                                         \
    void operator=(Dispatcher&) = delete;                                      \
    void operator=(Dispatcher&&) = delete;                                     \
                                                                               \
    static Dispatcher<MESSAGE>& Get() {                                        \
      static Dispatcher<MESSAGE> d;                                            \
      return d;                                                                \
    }                                                                          \
    const std::string& TypeName() const {                                      \
      static std::string s(#MESSAGE);                                          \
      return s;                                                                \
    }                                                                          \
                                                                               \
    void Dispatch(const MESSAGE& msg);                                         \
                                                                               \
    bool Dispatch(std::istream& is) override {                                 \
      MESSAGE msg;                                                             \
      if (msg.ParseFromIstream(&is)) {                                         \
        Dispatcher<MESSAGE>::Get().Dispatch(msg);                              \
        return true;                                                           \
      }                                                                        \
      return false;                                                            \
    }                                                                          \
                                                                               \
    bool Serialize(const MESSAGE& msg, std::ostream& os) {                     \
      return msg.SerializeToOstream(&os);                                      \
    }                                                                          \
                                                                               \
  private:                                                                     \
    Dispatcher() {                                                             \
      Dispatcher<STREAM>::Get().dispatchers_[TypeName()] = this;               \
    }                                                                          \
    ~Dispatcher() {                                                            \
      Dispatcher<STREAM>::Get().dispatchers_.erase(TypeName());                \
    }                                                                          \
                                                                               \
    std::unordered_set<EventHandler<MESSAGE>*> handlers_;                      \
  };                                                                           \
                                                                               \
  template<> class EventHandler<MESSAGE> {                                     \
  public:                                                                      \
    EventHandler() { Dispatcher<MESSAGE>::Get().handlers_.insert(this); }      \
    virtual ~EventHandler() {Dispatcher<MESSAGE>::Get().handlers_.erase(this);}\
    virtual void On##MESSAGE(const MESSAGE&) = 0;                              \
  };                                                                           \
                                                                               \
  void Dispatcher<MESSAGE>::Dispatch(const MESSAGE& msg) {                     \
    for (auto itr : handlers_) {                                               \
      itr->On##MESSAGE(msg);                                                   \
    }                                                                          \
  }                                                                            \

template<typename Msg> void Dispatch(const Msg& msg) {
  Dispatcher<Msg>::Get().Dispatch(msg);
}

// Samples /////////////////////////////////////////////////////////////////////
MAKE_DISPATCHER_AND_HANDLER(Increment);
MAKE_DISPATCHER_AND_HANDLER(System);

// Example 1) ImplementsHandlerInterfaces
class ImplementsHandlerInterfaces : protected EventHandler<Increment>
                                  , protected EventHandler<System> {
public:
  ImplementsHandlerInterfaces() : value_(0) {}

private:
  int value_;

  void OnIncrement(const Increment& msg) override {
    std::cout << __PRETTY_FUNCTION__ << '\n';
    value_ = (msg.value() + value_) % System::Phase_ARRAYSIZE;
  }

  void OnSystem(const System& msg) override {
    std::cout << __PRETTY_FUNCTION__ << '\n';
    value_ = msg.phase();
  }
};


// Example 2) EmbedsExternalHandlers 
template<typename T>
class IncrementEventHandler : public EventHandler<Increment> {
public:
  IncrementEventHandler(T& model) : model_(model) {}

private:
  T& model_;

  void OnIncrement(const Increment& msg) override {
    std::cout << __PRETTY_FUNCTION__ << '\n';
    model_.value_ = (msg.value() + model_.value_) % System::Phase_ARRAYSIZE;
  }
};
template<typename T>
class SystemEventHandler : public EventHandler<System> {
public:
  SystemEventHandler(T& model) : model_(model) {}

private:
  T& model_;

  void OnSystem(const System& msg) override {
    std::cout << __PRETTY_FUNCTION__ << '\n';
    model_.value_ = msg.phase();
  }
};
class EmbedsExternalHandlers {
public:
  EmbedsExternalHandlers()
    : incrementEventHandler_(model_)
    , systemEventHandler_(model_) {}

private:
  struct Model { int value_; };
  IncrementEventHandler<Model> incrementEventHandler_;
  SystemEventHandler<Model> systemEventHandler_;

  // Event Handler constructors cannot change the model data safely in this
  // configuration because if an event handler depends on the model in its
  // constructor then it must be constructed after the model, but if it depends
  // on the model in its destructor then it must be destroyed before the model.
  Model model_;
};


// Example 3) MixesHandlersIn
struct PhaseModel { ::System_Phase phase_; };

template<typename T>
class IncrementHandlerMixin : public EventHandler<Increment>, public T {
  void OnIncrement(const Increment& msg) override {
    std::cout << __PRETTY_FUNCTION__ << '\n';
    this->SetValue(msg.value() + this->Value());
  }
};

template<typename T>
class SystemHandlerMixin : public EventHandler<System>, public T {
  void OnSystem(const System& msg) override {
    std::cout << __PRETTY_FUNCTION__ << '\n';
    this->phase_ = msg.phase();
  }
};

template<typename T>
class ValueModelOf : public T {
protected:
  void SetValue(int64_t val) {
    std::cout << __PRETTY_FUNCTION__ << '\n';
    this->phase_ = (::System_Phase)(val % System::Phase_ARRAYSIZE);
  }
  ::System_Phase Value() { return this->phase_; }
};

class MixesHandlersIn
    : public IncrementHandlerMixin<ValueModelOf<PhaseModel>>
    , public SystemHandlerMixin<PhaseModel> {};

// MAIN //////////////////////////////////////////////////////////////////////
int main() {
  {
    ImplementsHandlerInterfaces _;
    Dispatch(Increment());
    Dispatch(System());
  }
  std::cout << '\n';
  {
    EmbedsExternalHandlers _;
    Dispatch(Increment());
    Dispatch(System());
  }
  std::cout << '\n';
  {
    MixesHandlersIn _;
    Dispatch(Increment());
    Dispatch(System());
  }
  return 0;
}
