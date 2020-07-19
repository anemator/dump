#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include <map>
#include <set>
#include <variant>
#include <vector>
class Msg;
class Value;
// Example
// Msg1 {
//   Type: string
//   Int1: int
//   Vec1: vector<int>
//   Msg1: NestedMsg
//   Msg2: { // inline nested msg
//     F: (value: int | long) -> value % 2 == 0
//   }
// }
//
// NestedMsg {
//   X: int
//   Y: int
// }


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
class Schema {
public:
  Schema() = default;

  auto Valid(const Msg&) const -> std::pair<bool, std::vector<std::string>>;

private:
  using Result = std::pair<bool, std::string>;
  std::multimap<std::string, std::function<Result(const Value&)>> checks_;
  // dhall as a format??
};
//////////////////////////////////////////////////////////////////////////////
// TODO add support for diffing
class Msg final {
  // function combinators
  // template<class F, class G>
  // auto combine(F&& f, G&& g, int x) -> intersection(f(x), g(x))

public:
  template<class Schema, class... Args>
  explicit Msg(Args&&... args);

  template<class... Args>
  friend auto UnsafeMsg(Args&&... args) -> Msg;

  template<class... Args>
  auto With(Args&&... args) const -> Msg;

  auto operator[](const std::string& key) const
  -> std::shared_ptr<const Value>;

  auto Get(const std::string& key) const -> std::shared_ptr<const Value>;

  template<class T>
  auto GetOr(const std::string& key, T&& backup) const
  -> std::shared_ptr<const Value>;

  auto Schema() const -> std::shared_ptr<const Schema>;

  using const_iterator =
    std::map<std::string, std::shared_ptr<const Value>>::const_iterator;
  auto begin() const -> const_iterator;
  auto end() const -> const_iterator;

  ~Msg() = default;
  Msg(const Msg&) = default;
  Msg(Msg&&) = default;
  Msg& operator=(const Msg& rhs) = default;
  Msg& operator=(Msg&& rhs) = default;

private:
  Msg() = default;

  auto WithAux(Msg&) const -> void;

  template<class Key, class Val, class... Args>
  auto WithAux(Msg& msg, Key&& key, Val&& val, Args&&... args) const -> void;

  std::map<std::string, std::shared_ptr<const Value>> data_;
  std::shared_ptr<const class Schema> schema_;
};
//////////////////////////////////////////////////////////////////////////////
// TODO add support for thread-safe caching, see AA's policy based design??
// CachePolicy can be None, Speed, ThreadSafe
// template<class CachePolicy>
class Value final {
public:
  enum class T { Int, Float, Double, Str, Vec, Msg };

  // TODO support unboxed vectors, e.g. vector<int>
  // vectors double as tuples
  explicit Value(int data);
  explicit Value(float data);
  explicit Value(double data);
  explicit Value(const std::string& data);
  explicit Value(std::string&& data);
  explicit Value(const std::vector<Value>& data);
  explicit Value(std::vector<Value>&& data);
  explicit Value(const Msg& data);
  explicit Value(Msg&& data);

  auto Type() const -> T;

  auto AsInt() const -> std::optional<int>;
  auto AsFloat() const -> std::optional<float>;
  auto AsDouble() const -> std::optional<double>;
  auto AsStr() const -> std::optional<std::string>;
  auto AsVec() const -> std::optional<std::vector<Value>>;
  auto AsMsg() const -> std::optional<Msg>;

private:
  std::variant<int, float, double, std::string, std::vector<Value>, Msg> data_;
  T type_;
};
//////////////////////////////////////////////////////////////////////////////
template<class Schema, class... Args>
inline Msg::Msg(Args&&... args)
  : schema_(std::make_shared<Schema>(std::forward(args...))) {
}

template<class... Args>
inline auto Msg::With(Args&&... args) const -> Msg {
  auto msg = *this;
  msg.schema_ = schema_;
  WithAux(msg, args...);
  return msg;
}

template<class... Args>
inline auto UnsafeMsg(Args&&... args) -> Msg {
  auto msg = Msg();
  msg.WithAux(msg, args...);
  return msg;
}

inline auto Msg::WithAux(Msg&) const -> void {}

template<class Key, class Val, class... Args>
inline auto Msg::WithAux(Msg& msg, Key&& key, Val&& val, Args&&... args) const
-> void {
  using namespace std;
  msg.data_[move(key)] =
    make_shared<const typename remove_reference<Val>::type>(move(val));
  WithAux(msg, args...);
}

template<class T>
inline auto Msg::GetOr(const std::string& key, T&& backup) const
-> std::shared_ptr<const Value> {
  using namespace std;
  const auto ptr = Get(key);
  return ptr ? ptr : make_shared<const Value>(move(backup));
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
using namespace std;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
auto Schema::Valid(const Msg& msg) const -> pair<bool, vector<string>> {
  vector<string> errors;
  // for (const auto& pair : msg) {
  //   const auto& range = checks_.equal_range(pair.first);
  //   if (range.first == range.second) {
  //     errors.push_back();
  //   }
  //   else {
  //     for (auto i = range.first; i != range.second; ++i) {
  //     }
  //   }
  // }
  return make_pair(true, errors);
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
Value::Value(int data) : data_(data), type_(T::Int) {}
Value::Value(float data) : data_(data), type_(T::Float) {}
Value::Value(double data) : data_(data), type_(T::Double) {}
Value::Value(const string& data) : data_(data), type_(T::Str) {}
Value::Value(string&& data) : data_(move(data)), type_(T::Str) {}
Value::Value(const vector<Value>& data) : data_(data), type_(T::Vec) {}
Value::Value(vector<Value>&& data) : data_(move(data)), type_(T::Vec) {}
Value::Value(const Msg& data) : data_(data), type_(T::Msg) {}
Value::Value(Msg&& data) : data_(move(data)), type_(T::Msg) {}

auto Value::Type() const -> Value::T { return type_; }

auto Value::AsInt() const -> optional<int> {
  switch (type_) {
    case T::Int:
      return make_optional(get<int>(data_));
    case T::Str:
      try {
        return make_optional(stoi(get<string>(data_)));
      }
      catch (...) {
        return nullopt;
      }
    case T::Vec: {
      string tmp;
      const auto vec = *AsVec();
      for (const auto e : vec) {
        if (const auto n = e.AsInt(); n) {
          tmp += to_string(*n);
        }
        else {
          return nullopt;
        }
      }

      try {
        return make_optional(stoi(tmp));
      }
      catch (...) {
        return nullopt;
      }
    }
    case T::Float: {
      const auto n = get<float>(data_);
      return n == static_cast<int>(n) ? make_optional(n) : nullopt;
    }
    case T::Double: {
      const auto n = get<double>(data_);
      return n == static_cast<int>(n) ? make_optional(n) : nullopt;
    }
    case T::Msg:
      return nullopt;
  }
}

auto Value::AsFloat() const -> optional<float> {
  switch (type_) {
    case T::Int:
      return make_optional(get<int>(data_));
    case T::Float:
      return make_optional(get<float>(data_));
    case T::Double: {
      const int n = get<double>(data_);
      return n == static_cast<float>(n) ? make_optional(n) : nullopt;
    }
    case T::Str:
      try {
        return make_optional(stof(get<string>(data_)));
      }
      catch (...) {
        return nullopt;
      }
    case T::Vec:
    case T::Msg:
      return nullopt;
  }
}

auto Value::AsDouble() const -> optional<double> {
  switch (type_) {
    case T::Int:
      return make_optional(get<int>(data_));
    case T::Float:
      return make_optional(get<float>(data_));
    case T::Double:
      return make_optional(get<double>(data_));
    case T::Str:
      try {
        return make_optional(stod(get<string>(data_)));
      }
      catch (...) {
        return nullopt;
      }
    case T::Vec:
    case T::Msg:
      return nullopt;
  }
}

auto Value::AsStr() const -> optional<string> {
  using namespace std;
  switch (type_) {
    case T::Str:
      return make_optional(get<string>(data_));
    case T::Int:
      return make_optional(to_string(get<int>(data_)));
    case T::Float:
      return make_optional(to_string(get<float>(data_)));
    case T::Double:
      return make_optional(to_string(get<double>(data_)));
    case T::Vec:
    case T::Msg:
      return nullopt;
  }
}

auto Value::AsVec() const -> optional<vector<Value>> {
  using namespace std;
  switch (type_) {
    case T::Str:
    case T::Int:
    case T::Float:
    case T::Double:
    case T::Msg: // TODO Value of vector of Value of vectors
      return nullopt;
    case T::Vec:
      return make_optional(get<vector<Value>>(data_));
  }
}

auto Value::AsMsg() const -> optional<Msg> {
  using namespace std;
  switch (type_) {
    case T::Str:
    case T::Int:
    case T::Float:
    case T::Double:
    case T::Vec:
      return nullopt;
    case T::Msg:
      return make_optional(get<Msg>(data_));
  }
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
auto Msg::Schema() const -> std::shared_ptr<const class Schema> {
  return schema_;
}

auto Msg::Get(const string& key) const -> shared_ptr<const Value> {
  auto const itr = data_.find(key);
  return itr != data_.end() ? itr->second : nullptr;
}

auto Msg::operator[](const string& key) const -> shared_ptr<const Value> {
  return Get(key);
}

auto Msg::begin() const -> Msg::const_iterator {
  return data_.begin();
}

auto Msg::end() const -> Msg::const_iterator {
  return data_.end();
}

auto Safe(const Msg& msg) -> bool {
  return static_cast<bool>(msg.Schema());
}

auto Valid(const Msg& msg) -> bool {
  return Safe(msg) ;//&& msg.Schema()->Valid(msg);
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
auto AsStr(const Value::T& type) -> string {
  switch (type) {
    case Value::T::Int: return "int";
    case Value::T::Float: return "float";
    case Value::T::Double: return "double";
    case Value::T::Str: return "string";
    case Value::T::Vec: return "vector<Value>";
    case Value::T::Msg: return "msg";
  }
}

auto operator<<(ostream& out, const Msg& msg) -> ostream&;
auto operator<<(ostream& out, const Value& val) -> ostream& {
  switch (val.Type()) {
    case Value::T::Int:
      out << *val.AsInt();
      break;
    case Value::T::Float:
      out << *val.AsFloat();
      break;
    case Value::T::Double:
      out << *val.AsDouble();
      break;
    case Value::T::Str:
      out << *val.AsStr();
      break;
    case Value::T::Vec: {
      out << '[';
      bool first = true;
      const auto vec = *val.AsVec();
      for (const auto& value : vec) {
        if (!first) {
          out << ",";
        }
        out << value;
        first = false;
      }
      out << ']';
      break;
    }
    case Value::T::Msg:
      out << *val.AsMsg();
  }
  return out;
}

auto operator<<(ostream& out, const Msg& msg) -> ostream& {
  out << '{';
  bool first = true;
  for (const auto& kv : msg) {
    if (!first) {
      out << ",";
    }
    out << kv.first << ':' << *kv.second;
    first = false;
  }
  out << '}';
  return out;
}
//////////////////////////////////////////////////////////////////////////////
int main() {
  // vector<Value> vec;
  // vec.emplace_back(1);
  // vec.emplace_back("hello");
  // vec.emplace_back(2.1);
  // cout << Value(vec) << '\n';
  // cout << Value(vec).AsVec().value()[0] << '\n';

  // shared_ptr<const Value> opt = nullptr;
  // // {
  //   auto m = UnsafeMsg("vec", Value(vec));
  //   opt = m["vec"];
  // // }
  // cout << "count: " << opt.use_count() << endl;
  // if (auto v = opt->AsVec(); v) {
  //   cout << Value(*v) << '\n';
  // }

  // for (auto kv : m) {
  //   cout << kv.first << ": " << *kv.second << '\n';
  // }

  const auto m1 = UnsafeMsg("nested", Value(2.1), "vec",
                            Value(vector<Value>{Value(1),Value(2),Value(3)}));
  const auto m2 = UnsafeMsg("outer", Value(m1));
  cout << m2 << endl;
  cout << *m1.GetOr("nested", 133) << endl;
  cout << *Value(vector<Value>{Value(1), Value(2), Value(3)}).AsInt() << endl;

  return 0;
}

// need non-null shared_ptrs
