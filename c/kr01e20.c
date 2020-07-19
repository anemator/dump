#include <stdio.h>

#define TABSTOP 8

#define TAB 1  /* a sequence of tabs */
#define COMP 0 /* a sequence of non-tabs */

/* Replaces tabs with the correct number of spaces. Works on lines of arbitrary
 * length (or at least those with less than INT_MAX/TABSTOP consecutive tabs).
 */
int main(void) {
  int c, pos, state, tabs;

  state = COMP;
  pos = tabs = 0;
  while ((c = getchar()) != EOF) {
    if (c == '\n') {
      putchar(c);
      state = COMP;
      pos = tabs = 0;
    } else if (c == '\t') {
      if (state == COMP) {
        state = TAB;
        tabs = 0;
      }

      ++tabs;
    } else {
      if (state == TAB) {
        int spaces = tabs * TABSTOP - pos % TABSTOP;
        while (spaces > 0) {
          putchar(' ');
          --spaces;
        }

        pos = 0;
        state = COMP;
      }

      putchar(c);
      ++pos;
    }
  }

  return 0;
}
