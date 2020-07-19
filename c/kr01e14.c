#include <stdio.h>

int main(void) {
  int c, i, j, maxChars;
  int freq[28];

  maxChars = 28;

  /* initialize array */
  for (i = 0; i < maxChars; ++i) {
    freq[i] = 0;
  }

  /* count chars */
  while ((c = getchar()) != EOF) {
    if (c >= 'A' && c <= 'Z') {
      ++freq[c - 'A'];
    } else if (c >= 'a' && c <= 'z') {
      ++freq[c - 'a'];
    } else if (c == ' ' || c == '\t' || c == '\n') {
      ++freq[26];
    } else {
      ++freq[27];
    }
  }

  /* print histogram */
  for (i = 0; i < maxChars; ++i) {
    if (i < maxChars - 2) {
      printf("  '%c' => ", i + 'a');
    } else if (i == maxChars - 2) {
      printf("white => ");
    } else {
      printf("other => ");
    }

    for (j = 0; j < freq[i]; ++j) {
      putchar('*');
    }
    putchar('\n');
  }

  return 0;
}
