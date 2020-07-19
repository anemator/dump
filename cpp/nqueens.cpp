#include <algorithm>
#include <functional>
#include <iostream>
#include <string>
#include <vector>
using namespace std;
using namespace std::placeholders;

struct Position {
  int row, col;
  Position(int r, int c) : row(r), col(c) {}
  friend ostream& operator<<(ostream& os, const Position& p) {
    os << "row: " << p.row << ", col: " << p.col;
    return os;
  }
};

static int SIZE = 4;

bool sameRowColDiag(const Position& p, int row, int col) {
  return p.row == row || p.col == col || p.row - p.col == row - col ||
         p.row + p.col == row + col;
}

bool solve(const int row, vector<Position>& result) {
  if (row == SIZE) {
    return true;
  }
  for (int col = 0; col < SIZE; ++col) {
    auto safe = none_of(result.cbegin(), result.cend(),
                        bind(&sameRowColDiag, _1, row, col));
    if (safe) {
      result.push_back(Position(row, col));
      if (solve(row + 1, result)) {
        return true;
      }
      result.pop_back();
    }
  }
  return false;
}

void solveAll() {
  // TODO
}

int main(int argc, char* argv[]) {
  if (argc > 1) {
    SIZE = stoi(argv[1]);
  }

  vector<Position> result;
  solve(0, result);
  for (auto ii = result.cbegin(); ii != result.cend(); ++ii) {
    cout << *ii << '\n';
  }

  return 0;
}
