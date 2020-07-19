#include <cassert>
#include <limits>

// A simple positive int hash map. Open addressing for collision resolution
class NatMap {
public:
  NatMap() {
    for (int itr = 0; itr < Size_; ++itr) {
      array_[itr] = Invalid_Value_;
    }
  }
  int insert(int value) {
    if (!valueValid(value)) {
      return Invalid_Key_;
    }
    int key = hash_(value);
    if (keyValid(key)) {
      array_[key] = value;
    }
    return key;
  }
  bool keyValid(int key) const { return key > Invalid_Key_ && key <= Size_; }
  bool remove(int key) {
    if (!keyValid(key)) {
      return false;
    }
    array_[key] = Invalid_Value_;
    return true;
  }
  int search(int key) const {
    return keyValid(key) ? array_[key] : Invalid_Value_;
  }
  bool valueValid(int value) const {
    return value >= 0 && value <= std::numeric_limits<int>::max();
  }

private:
  /** Returns the next available key or an invalid key. */
  int hash_(int value) const {
    // TODO: caching
    int key = value * value % 100;
    int itr = key;
    do {
      if (keyAvailable_(itr)) {
        return itr;
      } else if (itr == Size_) {
        itr = 0;
      } else {
        ++itr;
      }
    } while (itr != key);
    return Invalid_Key_;
  }
  bool keyAvailable_(int key) const {
    return keyValid(key) && array_[key] == Invalid_Value_;
  }

  static const int Invalid_Key_ = -1;
  static const int Invalid_Value_ = -1;
  static const int Size_ = 100;
  static const int Squares_[];
  int array_[Size_]; // TODO: dynamic resizing
};

int main() {
  NatMap map;
  assert(!map.valueValid(map.search(25)));
  assert(!map.valueValid(map.search(26)));
  assert(map.insert(5) == 25);
  assert(map.insert(25) == 26);
  assert(map.search(25) == 5);
  assert(map.search(26) == 25);
  assert(map.remove(25));
  assert(map.remove(26));
  assert(!map.valueValid(map.search(25)));
  assert(!map.valueValid(map.search(26)));

  return 0;
}
