#include <stdio.h>

int main(void) {
  int c, p;

  p = EOF;
  while ((c = getchar()) != EOF) {
    if (c == ' ') {
      if (p != ' ') {
        putchar(c);
        p = c;
      }
    }
    if (c != ' ') {
      putchar(c);
      p = c;
    }
  }

  return 0;
}
