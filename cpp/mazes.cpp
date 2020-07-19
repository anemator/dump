#include <iostream>
#include <vector>
using namespace std;
// Uses recursive backtracking (not my implementation)
// http://www.geeksforgeeks.org/backttracking-set-2-rat-in-a-maze/

static const int N = 4;

void printMaze(int maze[N][N]) {
  for (int row = 0; row < N; ++row) {
    for (int col = 0; col < N; ++col) {
      cout << maze[row][col] << ' ';
    }
    cout << '\n';
  }
}

bool isSafe(int maze[N][N], int row, int col) {
  if (row >= 0 && row < N && col >= 0 && col < N && maze[row][col] == 1) {
    return true;
  }
  return false;
}

// Recursive with backtracking
bool solveMazeBt(int maze[N][N], int row, int col, int sol[N][N]) {
  printMaze(sol);
  cout << endl;
  if (row == N - 1 && col == N - 1) {
    sol[row][col] = 1;
    return true;
  }

  if (isSafe(maze, row, col)) {
    sol[row][col] = 1;
    if (solveMazeBt(maze, row, col + 1, sol)) {
      return true;
    }
    if (solveMazeBt(maze, row + 1, col, sol)) {
      return true;
    }
  }

  sol[row][col] = 0;
  return false;
}

int main(int argc, char* argv[]) {
  int maze[N][N] = {{1, 1, 1, 0}, {1, 1, 0, 1}, {0, 1, 0, 0}, {1, 1, 1, 1}};
  int sol[N][N] = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}};

  if (solveMazeBt(maze, 0, 0, sol)) {
    cout << "Solution: " << endl;
    printMaze(sol);
  } else {
    cout << "No Solution" << endl;
  }

  return 0;
}
