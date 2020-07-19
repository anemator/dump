#include <stdio.h>

#define MINLEN 80

/* echo lines greater than 80 characters */
int main(void) {
  int c, len;
  char buffer[MINLEN];

  len = 0;
  while ((c = getchar()) != EOF) {
    if (len < MINLEN) {
      buffer[len] = c;
    } else if (len == MINLEN) {
      printf("=> %s%c", buffer, c);
    } else {
      putchar(c);
    }

    if (c != '\n') {
      ++len;
    } else {
      len = 0;
    }
  }

  return 0;
}
