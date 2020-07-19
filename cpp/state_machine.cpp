#include <iostream>
#include <map>
#include <string.h>
#include <utility>

class StateMachine {
  enum class State { Locked, Unlocked };
  State mState = State::Locked;
  friend std::string AsString(State const&);

public:
  enum class Input { Coin, Push };

private:
  std::map<std::pair<State, Input>, State> mTransitions{
      std::make_pair(std::make_pair(State::Locked, Input::Coin),
                     State::Unlocked),
      std::make_pair(std::make_pair(State::Locked, Input::Push), State::Locked),
      std::make_pair(std::make_pair(State::Unlocked, Input::Coin),
                     State::Unlocked),
      std::make_pair(std::make_pair(State::Unlocked, Input::Push),
                     State::Locked),
  };

public:
  void Next(Input const& input) { mState = Peek(input); }
  State Peek(Input const& input) const {
    return mTransitions.at(std::make_pair(mState, input));
  }
  State Now() const { return mState; }
};

std::string AsString(StateMachine::State const& state) {
  switch (state) {
  case StateMachine::State::Locked:
    return "Locked";
  case StateMachine::State::Unlocked:
    return "Unlocked";
  }
  return "";
}

class RevStrSM {
public:
  enum class Event { Shift, Swap };

  struct State {
    bool done;
    size_t front, back;
  };

  RevStrSM(char str[]) : str_(str) {
    state_.done = false;
    state_.front = 0;
    state_.back = strlen(str) - 1;
  }

  Event Next(Event evt) {
    if (state_.done) return Event::Shift;

    if (state_.front >= state_.back - 1) {
      state_.done = true;
      return Event::Shift;
    }

    switch (evt) {
      case Event::Shift:
        ++state_.front;
        --state_.back;
        return Event::Swap;
      case Event::Swap:
        char tmp = str_[state_.front];
        str_[state_.front] = str_[state_.back];
        str_[state_.back] = tmp;
        return Event::Shift;
    }

    throw;
  }

  void Run() {
    auto evt = Event::Swap;
    while (!state_.done) {
      evt = Next(evt);
    }
  }

private:
  char* str_;
  State state_;
};

int main() {
  using std::cout;
  typedef StateMachine::Input Input;
  StateMachine sm;

  std::cout << AsString(sm.Now()) << '\n';
  sm.Next(Input::Push);
  std::cout << AsString(sm.Now()) << '\n';
  sm.Next(Input::Coin);
  std::cout << AsString(sm.Now()) << '\n';
  sm.Next(Input::Push);
  std::cout << AsString(sm.Now()) << '\n';

  char str[] = "hello";
  RevStrSM(str).Run();
  std::cout << str << '\n';

  return 0;
}
