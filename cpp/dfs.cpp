#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace std;

struct node {
  int id;
  vector<int> neighbors;
};

std::map<int, node> read() {
  std::string line;
  std::map<int, node> nodes;
  while (getline(cin, line)) {
    auto itr = nodes.find(line[0]);
    if (itr == nodes.end()) {
      node n;
      n.id = line[0];
      n.neighbors.push_back(line[2]);
      nodes[n.id] = n;
    } else {
      itr->second.neighbors.push_back(line[2]);
    }
  }
  
  return nodes;
}

std::set<int> visited;
void print(int node_id, std::map<int, node> const& nodes) {
  if (visited.count(node_id) > 0) { return; }
  cout << (char)node_id << '\n';
  visited.insert(node_id);

  auto itr = nodes.find(node_id);
  if (itr == nodes.end()) return;

  for (auto n : itr->second.neighbors) {
    print(n, nodes);
  }
}


int main() {
  auto nodes = read();
  print(nodes.begin()->first, nodes);
  
  return 0;
}


// Broken (original) below, shoddy working code above
#if 0
/*
Input: Directed Edges (innode, outnode)
0 1\n
0 2\n
1 2\n
2 3\n
3 3
*/

/* Output: Node IDs
0
1
2
3
*/ 

struct node {
  int id;
  vector<int> neighbors;
};

std::map<int, node> read() {
  std::string line;
  std::map<int, node> nodes;
  while (getline(cin, line)) {
    auto itr = nodes.find(line[0]);
    if (itr == nodes.end()) {
      node n;
      n.id = line[0];
      n.neighbors.push_back(line[2]);
      nodes[id] = n;
    } else {
      itr->neighbors.push_back(line[2])
    }
  }
  
  return nodes;
}

std::set<int> visited;
void print(int node_id, std::map<int, node> const& nodes) {
  if (visited.contains(node_id)) { return; }
  cout << node_id << '\n';
  visited.insert(node_id);
  for (auto kv : nodes) {
    print(kv.second.id, nodes);
  }
}


int main() {
  auto nodes = read();
  print(nodes.front.first(), nodes);
  
  return 0;
}
#endif
