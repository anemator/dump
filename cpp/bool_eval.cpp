#include <cassert>
#include <functional>
#include <iostream>
#include <memory>
using std::make_shared;
using std::shared_ptr;
// https://en.wikipedia.org/wiki/Boolean_algebra#Basic_operations

namespace Template
{

struct True {};
struct False {};
template<typename Expr> struct Not {};
template<typename Lhs, typename Rhs> struct And {};
template<typename Lhs, typename Rhs> struct Or {};

template<typename> struct Eval;

template<> struct Eval<True> {
  enum { value = true };
};
template<> struct Eval<False> {
  enum { value = false };
};

template<typename T> struct Eval<Not<T>> {
  enum { value = !Eval<T>::value };
};

template<typename Lhs, typename Rhs> struct Eval<And<Lhs, Rhs>> {
  enum { value = Eval<Lhs>::value && Eval<Rhs>::value };
};

template<typename Lhs, typename Rhs> struct Eval<Or<Lhs, Rhs>> {
  enum { value = Eval<Lhs>::value || Eval<Rhs>::value };
};

template<typename Lhs, typename Rhs> struct Implies {
  typedef Or<Not<Lhs>, Rhs> value;
};

template<typename Lhs, typename Rhs> struct Xor {
  typedef And<Or<Lhs, Rhs>, Not<And<Lhs, Rhs>>> value;
};

template<typename Lhs, typename Rhs> struct Equiv {
  typedef Not<typename Xor<Lhs, Rhs>::value> value;
};

}

namespace ObjectOriented
{

class Expr {
public:
  virtual bool Eval() const = 0;
  virtual ~Expr() = default;
};

class True : public Expr {
public:
  bool Eval() const override { return true; }
};

class False : public Expr {
public:
  bool Eval() const override { return false; }
};

class Not : public Expr {
  shared_ptr<const Expr> expr_;

public:
  Not(shared_ptr<const Expr> expr) : expr_(expr) {}
  bool Eval() const override { return !expr_->Eval(); }
};

class And : public Expr {
  shared_ptr<const Expr> lhs_, rhs_;

public:
  And(shared_ptr<const Expr> lhs, shared_ptr<const Expr> rhs)
    : lhs_(lhs), rhs_(rhs) {}
  bool Eval() const override { return lhs_->Eval() && rhs_->Eval(); }
};

class Or : public Expr {
  shared_ptr<const Expr> lhs_, rhs_;

public:
  Or(shared_ptr<const Expr> lhs, shared_ptr<const Expr> rhs)
    : lhs_(lhs), rhs_(rhs) {}
  bool Eval() const override { return lhs_->Eval() || rhs_->Eval(); }
};

shared_ptr<const Expr>
Implies(shared_ptr<const Expr> x, shared_ptr<const Expr> y) {
  return make_shared<Or>(make_shared<Not>(x), y);
}

shared_ptr<const Expr>
Xor(shared_ptr<const Expr> x, shared_ptr<const Expr> y) {
  return make_shared<And>(make_shared<Or>(x, y),
                          make_shared<Not>(make_shared<And>(x, y)));
}

shared_ptr<const Expr>
Equiv(shared_ptr<const Expr> x, shared_ptr<const Expr> y) {
  return make_shared<Not>(Xor(x, y));
}

}

int main() {
  {
    using namespace Template;
    typedef True t;
    typedef False f;

    // And
    static_assert(Eval<And<t, t>>::value == true, "");
    static_assert(Eval<And<t, f>>::value == false, "");
    static_assert(Eval<And<f, t>>::value == false, "");
    static_assert(Eval<And<f, f>>::value == false, "");

    // Or
    static_assert(Eval<Or<t, t>>::value == true, "");
    static_assert(Eval<Or<t, f>>::value == true, "");
    static_assert(Eval<Or<f, t>>::value == true, "");
    static_assert(Eval<Or<f, f>>::value == false, "");

    // Or
    static_assert(Eval<Not<t>>::value == false, "");
    static_assert(Eval<Not<f>>::value == true, "");

    // Implies
    static_assert(Eval<Implies<t, t>::value>::value == true, "");
    static_assert(Eval<Implies<t, f>::value>::value == false, "");
    static_assert(Eval<Implies<f, t>::value>::value == true, "");
    static_assert(Eval<Implies<f, f>::value>::value == true, "");

    // Xor
    static_assert(Eval<Xor<t, t>::value>::value == false, "");
    static_assert(Eval<Xor<t, f>::value>::value == true, "");
    static_assert(Eval<Xor<f, t>::value>::value == true, "");
    static_assert(Eval<Xor<f, f>::value>::value == false, "");

    // Equiv
    static_assert(Eval<Equiv<t, t>::value>::value == true, "");
    static_assert(Eval<Equiv<t, f>::value>::value == false, "");
    static_assert(Eval<Equiv<f, t>::value>::value == false, "");
    static_assert(Eval<Equiv<f, f>::value>::value == true, "");

    // Miscellaneous
    static_assert(Eval<And<Or<True, False>, Not<False>>>::value == true, "");
  }
  {
    using namespace ObjectOriented;
    auto t = make_shared<True>();
    auto f = make_shared<False>();

    // And
    assert(And(t, t).Eval() == true);
    assert(And(t, f).Eval() == false);
    assert(And(f, t).Eval() == false);
    assert(And(f, f).Eval() == false);

    // Or
    assert(Or(t, t).Eval() == true);
    assert(Or(t, f).Eval() == true);
    assert(Or(f, t).Eval() == true);
    assert(Or(f, f).Eval() == false);

    // Not
    assert(Not(t).Eval() == false);
    assert(Not(f).Eval() == true);

    // Implies
    assert(Implies(t, t)->Eval() == true);
    assert(Implies(t, f)->Eval() == false);
    assert(Implies(f, t)->Eval() == true);
    assert(Implies(f, f)->Eval() == true);

    // Xor
    assert(Xor(t, t)->Eval() == false);
    assert(Xor(t, f)->Eval() == true);
    assert(Xor(f, t)->Eval() == true);
    assert(Xor(f, f)->Eval() == false);

    // Equiv
    assert(Equiv(t, t)->Eval() == true);
    assert(Equiv(t, f)->Eval() == false);
    assert(Equiv(f, t)->Eval() == false);
    assert(Equiv(f, f)->Eval() == true);

    // Miscellaneous
    assert(And(make_shared<Or>(t, f), make_shared<Not>(f)).Eval() == true);
  }
}
