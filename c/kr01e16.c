#include <stdio.h>

/* maximum input line size */
#define MAXLINE 1000

int mygetline(char line[], int maxline);
void copy(char to[], char from[]);

/* print longest input line */
int main(void) {
  int len, max, state, total;
  char line[MAXLINE], longest[MAXLINE], tmp[MAXLINE];

  /* state == 1 is in-line; state == 0 is out-of-line */
  state = 0;

  max = total = 0;
  while ((len = mygetline(line, MAXLINE)) > 0) {
    /* store the first MAXLINE chars of the current line */
    if (state == 0) {
      copy(tmp, line);
    }

    if (line[len - 1] == '\n') {
      state = 0;
    } else {
      state = 1;
    }

    total = total + len;

    if (state == 0) {
      if (total > max) {
        max = total;
        copy(longest, tmp);
      }

      total = 0;
    }
  }

  if (max > 0) {
    printf("\nlength = %d\n", max);
    printf("%s", longest);
  }

  return 0;
}

/* read a line into s, return length */
int mygetline(char s[], int lim) {
  int c, i;

  for (i = 0; i < lim - 1 && (c = getchar()) != EOF && c != '\n'; ++i) {
    s[i] = c;
  }

  if (c == '\n') {
    s[i] = c;
    ++i;
  }

  s[i] = '\0';

  return i;
}

/* copy from into to; assume to is big enough */
void copy(char to[], char from[]) {
  int i;

  i = 0;
  while ((to[i] = from[i]) != '\0') {
    ++i;
  }
}
