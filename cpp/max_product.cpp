#include <iostream>
#include <vector>
using namespace std;
// Calculates the largest product in an array of ints

long long max_prod(const vector<int>& vec) {
  int neg1 = 0, neg2 = 0;
  int pos1 = 0, pos2 = 0, pos3 = 0;

  for (auto ii = vec.cbegin(); ii != vec.cend(); ++ii) {
    if (*ii > pos1) {
      pos3 = pos2;
      pos2 = pos1;
      pos1 = *ii;
    } else if (*ii > pos2) {
      pos3 = pos2;
      pos2 = *ii;
    } else if (*ii > pos3) {
      pos3 = *ii;
    } else if (*ii < neg1) {
      neg2 = neg1;
      neg1 = *ii;
    } else if (*ii < neg2) {
      neg2 = *ii;
    }
  }

  return max(pos1 * pos2 * pos3, neg1 * neg2 * pos1);
}

double max_prod(const vector<double>& vec) {
  double neg1 = 0, neg2 = 0;
  double pos1 = 0, pos2 = 0;

  for (auto ii = vec.cbegin(); ii != vec.cend(); ++ii) {
    if (*ii > pos1) {
      pos2 = pos1;
      pos1 = *ii;
    } else if (*ii > pos2) {
      pos2 = *ii;
    } else if (*ii < neg1) {
      neg2 = neg1;
      neg1 = *ii;
    } else if (*ii < neg2) {
      neg2 = *ii;
    }
  }

  return max(pos1 * pos2, neg1 * neg2);
}

int main(int argc, char** argv) {
  vector<int> vec;

  for (int ii = 1; ii < argc; ++ii) {
    vec.push_back(stoi(argv[ii]));
    // vec.push_back(stod(argv[ii]));
  }

  cout << max_prod(vec) << endl;

  return 0;
}
