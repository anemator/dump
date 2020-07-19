#include <iostream>
#include <string>

// https://en.wikipedia.org/wiki/X_Macro
#define VARS \
  X(Red) \
  X(Green) \
  X(Blue)

#define X(COLOR) COLOR,
enum class Color {
VARS
};
#undef X

#define X(COLOR) case (Color::COLOR): return #COLOR;
std::string string_of(Color c) {
  switch (c) {
    VARS
  }

  return "";
}
#undef X

#undef VARS

int main() {
  using namespace std;
  cout << string_of(Color::Red) << '\n';
  return 0;
}
