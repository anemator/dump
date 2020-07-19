#include <stdio.h>
#include <stdint.h>
#include <string.h>
// Proper way to copy struct into an array
// https://wiki.sei.cmu.edu/confluence/display/c/EXP36-C.+Do+not+cast+pointers+into+more+strictly+aligned+pointer+types

typedef struct {
  int n;
} t;

int main() {
  uint8_t arr[4];
  /*
  t* pt = (t*)(void*)arr;
  pt->n = INT32_MAX;
  */
  t _t;
  _t.n = INT32_MAX;
  memcpy(arr, &_t, 4);
  printf("%d, %d, %d, %d\n", arr[0], arr[1], arr[2], arr[3]);

  return 0;
}
