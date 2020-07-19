#include <stdio.h>

int main(void) {
  int c;

  /* <ctrl>-D/Z is EOF, <return> is not */
  while ((c = getchar()) != EOF) {
    printf("=> %d\n", c != EOF);
  }

  printf("=> %d\n", c != EOF);

  return 0;
}
