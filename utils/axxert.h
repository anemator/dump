#ifndef _AXXERT_H_
#define _AXXERT_H_
#include <cassert>
#include <cstdio>
// An attempt at an assert expression

#ifdef NDEBUG
#define axxert(x) x
#else
#define axxert(x) (assert(x), x)
#endif

// USAGE:
//
//class Base {
//  Base* base_;
//public:
//  Base() = default;
//  explicit Base(Base* base) : base_(axxert(base)) {}
//};
//
//int main() {
//  Base b;
//  Base good(&b);
//  Base bad(NULL);
//  return 0;
//}

#endif // _AXXERT_H_
