#include <stdio.h>

#define IN 1
#define OUT 0

int main(void) {
  int c, i, j, length, maxLength, maxWords, state;
  int nWords[29];

  maxLength = 28;

  /* initialize array */
  for (i = 0; i <= maxLength; ++i) {
    nWords[i] = 0;
  }

  /* find number of words of length 1, 2, ..., 28, 29+ */
  length = 0;
  state = OUT;
  while ((c = getchar()) != EOF) {
    if (state == OUT && c != ' ' && c != '\t' && c != '\n') {
      state = IN;
      ++length;
    } else if (state == IN && (c == ' ' || c == '\t' || c == '\n')) {
      if (length <= maxLength) {
        ++nWords[length - 1];
      } else {
        ++nWords[maxLength];
      }

      state = OUT;
      length = 0;
    } else if (state == IN) {
      ++length;
    }
  }

  /* print horizontal histogram */
  printf("\n\nHorizontal Histogram\n\n");

  for (i = 0; i <= maxLength; ++i) {
    printf("| ");

    for (j = 0; j < nWords[i]; ++j) {
      putchar('*');
    }

    putchar('\n');
  }

  /* find most frequently occurring word length */
  maxWords = 0;
  for (i = 0; i <= maxLength; ++i) {
    if (nWords[i] > maxWords) {
      maxWords = nWords[i];
    }
  }

  /* print vertical histogram */
  printf("\n\nVertical Histogram\n\n");

  for (i = 0; i <= maxWords; ++i) {
    for (j = 0; j <= maxLength; ++j) {
      if (nWords[j] >= maxWords) {
        printf("* ");
      } else {
        printf("  ");
      }
    }

    putchar('\n');
    --maxWords;
  }

  for (i = 0; i <= maxLength; ++i) {
    printf("| ");
  }

  putchar('\n');

  return 0;
}
