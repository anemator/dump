#include <algorithm>
#include <iomanip>
#include <iostream>
#include <map>
using namespace std;

void permute_aux(map<char, int>& chars, int& count, string acc) {
  if (all_of(chars.cbegin(), chars.cend(),
             [](const pair<char, int>& p) { return p.second == 0; })) {
    cout << setw(2) << count++ << ": " << acc << '\n';
    return;
  }
  for (auto ii = chars.begin(), end = chars.end(); ii != end; ++ii) {
    if (ii->second > 0) {
      --ii->second;
      permute_aux(chars, count, acc + ii->first);
      ++ii->second;
    }
  }
}
//
void permute(const string& str) {
  if (str.empty()) {
    return;
  }
  map<char, int> chars;
  for (auto ii = str.begin(), end = str.end(); ii != end; ++ii) {
    ++chars[*ii];
  }
  int count = 1;
  permute_aux(chars, count, "");
}

int main() {
  permute("aabc");

  return 0;
}
