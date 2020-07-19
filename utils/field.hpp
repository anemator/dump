#ifndef FIELD_HPP_INCLUDED
#define FIELD_HPP_INCLUDED
#include <iostream>
#include <sstream>
#include <vector>
// A readable serializer in the style of boost serialization

template<typename T>
class Field final {
public:
  Field() = default;

  Field(const std::string& name) {
    if (!IsValid(name)) {
      throw "nooooooooooo";
    }
    name_ = name;
  }

  Field(const std::string& name, const T& data)
    : name_(name), data_(data) {}

  /**/  std::string& Name()       { return name_; }
  const std::string& Name() const { return name_; }

  // Getters & Setters
  /**/           T& Data()                      { return data_; }
  const          T& Data()       const          { return data_; }
  operator       T&()                           { return data_; }
  operator const T&()            const          { return data_; }
  /**/           T& operator*()                 { return data_; }
  const          T& operator*()  const          { return data_; }
  /**/           T* operator->()                { return &data_; }
  const          T* operator->() const          { return &data_; }

  // static Field<T> Deserialize(std::istream&);
  // std::ostream& Serialize(std::ostream&);

private:
  bool IsValid(char ch) {
    return ch == '_' || std::isalnum(ch);
  }

  bool IsValid(const std::string& name) {
    return name.size() > 0
        && std::isalpha(name[0])
        ;// && std::all_of(name.begin(), name.end(), &Field::IsValid);
  }

  T data_;
  std::string name_;
};

std::ostream& Serialize(std::ostream& os, double d) {
  return os << std::to_string(d);
}

// https://stackoverflow.com/questions/2417588/escaping-a-c-string#
std::ostream& Serialize(std::ostream& os, const std::string& s) {
  os << '"';
  for (char ch : s) {
    if (ch != '\\' && ch != '"' && std::isprint(ch)) {
      os << ch;
    }
    else {
      os << '\\';
      switch (ch) {
        case '"': os << ch; break;
        case '\\': os << '\\'; break;
        case '\r': os << 'r'; break;
        case '\n': os << 'n'; break;
        case '\t': os << 't'; break;
        default: throw "invalid char";
      }
    }
  }
  os << '"';
  return os;
}

std::istream& Deserialize(std::istream& is, std::string& s) {
  char ch;
  is >> std::noskipws;
  while (is >> ch) {
    if (ch == '\\') {
      is >> ch;
      switch (ch) {
        case '"': s += '"'; break;
        case 'r': s += '\r'; break;
        case 'n': s += '\n'; break;
        case 't': s += '\t'; break;
        case '\\': s += '\\'; break;
        default: throw "invalid char";
      }
    }
    else if (ch == '"') {
      break;
    }
    else {
      s += ch;
    }
  }
  is >> std::skipws;
  return is;
}

std::ostream& Serialize(std::ostream& os, const Field<double>& field) {
  return os << '(' << field.Name() << ' ' << std::to_string(field.Data()) << ')';
}

std::ostream& Serialize(std::ostream& os, const Field<std::string>& field) {
  os << '(' << field.Name() << ' ';
  Serialize(os, field.Data()) << ')';
  return os;
}

template<typename T>
std::ostream& Serialize(std::ostream& os, const Field<std::vector<T>>& field) {
  os << '(' << field.Name();
  for (const auto& item : field.Data()) {
    os << ' ';
    Serialize(os, item);
  }
  os << ')';
  return os;
}

// template<typename T>
// std::ostream& Field<T>::Serialize(std::ostream& os) {
//   return ::Serialize(os, *this);
// }

template<typename T>
std::istream& Deserialize(std::istream& is, Field<T>& field) {
  char ch;
  is >> ch;
  is >> field.Name();

  std::string str;
  while (is) {
    while (is.peek() == ' ') {
      is >> ch;
    }
    if (is.peek() == ')') {
      is >> ch;
      break;
    }
    str.clear();
    Deserialize(is, str);
    field->push_back(str);
  }
  return is;
}

// template<> Field<double> Field<double>::Deserialize(std::istream& is) {
template<>
std::istream& Deserialize(std::istream& is, Field<double>& field) {
  char ch;
  is >> ch;
  std::getline(is, field.Name(), ' '); 

  double d;
  return is >> field >> ch;
}

// template<> Field<std::string> Field<std::string>::Deserialize(std::istream& is) {
template<>
std::istream& Deserialize(std::istream& is, Field<std::string>& field) {
  char ch;
  is >> std::noskipws >> ch;
  std::getline(is, field.Name(), ' ');
  Deserialize(is, field.Data());
  return is;
}

#if 0
struct test {
  Field<double> x = {"x"};
  Field<std::vector<std::string>> strs = {"strs"};
};

std::ostream& Serialize(std::ostream& os, const test& t) {
  os << '(';
  Serialize(os, t.x);
  Serialize(os, t.strs);
  return os << ')';
}

std::istream& Deserialize(std::istream& is, test& t) {
  char ch;
  is >> ch;
  Deserialize(is, t.x);
  Deserialize(is, t.strs);
  return is >> ch;
}

using namespace std;
int main() {
  Field<std::vector<std::string>> field1("vec");
  field1->push_back("aa bb cc");
  field1->push_back("dd");
  field1->push_back("ee ff");

  stringstream ss;
  Serialize(ss, field1);
  cout << "field1: " << ss.str() << '\n';

  Field<std::vector<std::string>> field2("blah");
  Deserialize(ss, field2);
  cout << "field2: ";
  Serialize(cout, field2);
  cout << '\n';

  test t;
  *t.x = 1.233;
  *t.strs = { "a", "bb", "ccc", "1.2" };
  ss = stringstream();
  Serialize(ss, t);
  cout << "input: " << ss.str() << '\n';
  
  test t2;
  Deserialize(ss, t2);
  cout << "output: ";
  Serialize(cout, t2);
  cout << '\n';

  return 0;
}
#endif

#endif // FIELD_HPP_INCLUDED
