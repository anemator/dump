#include <algorithm>
#include <iostream>
#include <memory>
#include <string>
#include <utility>
#include <vector>
// Sean Parent's Inheritance is the Base Class of all Evil and C++ Seasoning

class Object {
  struct Concept {
    virtual ~Concept() = default;
    virtual void draw_(std::ostream&, std::size_t) const = 0;
  };
  std::shared_ptr<const Concept> self_;

  template<typename T> struct Model : Concept {
    T data_;

    Model(T t) : data_(std::move(t)) {}
    void draw_(std::ostream& os, std::size_t position) const override {
      draw(data_, os, position);
    }
  };

public:
  template<typename T>
  /*! explicit */ Object(T t)
      : self_(std::make_shared<Model<T>>(std::move(t))) {}

  friend void draw(const Object& obj, std::ostream& os, std::size_t position) {
    obj.self_->draw_(os, position);
  }
};

using Document = std::vector<Object>;
void draw(const Document& doc, std::ostream& os, std::size_t position) {
  os << std::string(position, ' ') << "<document>\n";
  for (auto& elem : doc) {
    draw(elem, os, position + 2);
  }
  os << std::string(position, ' ') << "</document>\n";
}

class Button {
public:
  friend void draw(const Button&, std::ostream& os, std::size_t position) {
    os << std::string(position, ' ') << "<button></button>\n";
  }
};

class Label {
public:
  friend void draw(const Label&, std::ostream& os, std::size_t position) {
    os << std::string(position, ' ') << "<label></label>\n";
  }
};

class Animal {
  struct Concept {
    virtual ~Concept() = default;
    virtual std::string type_() const = 0;
    virtual std::string name_() const = 0;
  };
  std::shared_ptr<const Concept> self_;

  template<typename T> struct Model : Concept {
    T data_;
    Model(T t) : data_(std::move(t)) {}
    std::string type_() const { return type(data_); }
    std::string name_() const { return name(data_); }
  };

public:
  template<typename T>
  Animal(T t) : self_(std::make_shared<Model<T>>(std::move(t))) {}
  friend std::string type(const Animal& a) { return a.self_->type_(); }
  friend std::string name(const Animal& a) { return a.self_->name_(); }
};

#define MAKE_ANIMAL(TYPE)                                                      \
  class TYPE {                                                                 \
    std::string name_;                                                         \
                                                                               \
  public:                                                                      \
    TYPE(const std::string& name) : name_(name) {}                             \
    friend std::string type(const TYPE&) { return #TYPE; }                     \
    friend std::string name(const TYPE& t) { return t.name_; }                 \
  }

MAKE_ANIMAL(Lion);
MAKE_ANIMAL(Tiger);
MAKE_ANIMAL(Bear);

int main(int argc, char* argv[]) {
  std::vector<Object> objs;
  objs.emplace_back(Button());
  objs.emplace_back(Label());
  draw(objs, std::cout, 0);

  std::vector<Animal> animals{Lion("c"), Tiger("a"), Bear("d"), Lion("e"),
                              Bear("b")};
  auto print_animals = [&animals]() {
    std::cout << "----------\n";
    for (const auto& a : animals) {
      std::cout << type(a) << ": " << name(a) << '\n';
    }
  };

  print_animals();
  std::sort(
      animals.begin(), animals.end(),
      [](const Animal& a1, const Animal& a2) { return name(a1) < name(a2); });
  print_animals();
  std::stable_sort(
      animals.begin(), animals.end(),
      [](const Animal& a1, const Animal& a2) { return type(a1) < type(a2); });
  print_animals();

  return 0;
}
