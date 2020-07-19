#include <stdio.h>

int main(void) {
  int c, p;

  p = EOF;
  while ((c = getchar()) != EOF) {
    if ((c != ' ' && c != '\t' && c != '\n') ||
        ((c == ' ' || c == '\t' || c == '\n') &&
         (p != ' ' && p != '\t' && p != '\n'))) {
      putchar(c);
      p = c;
    }
  }

  return 0;
}
