#include <stdio.h>

#define MAXWS 1000

#define IN 1
#define OUT 0

/* NOTE:
 * - Deletes blank lines.
 * - Removes leading white space.
 * - Prints non-whitespace characters immediately.
 * - Buffers up to MAXWS (non-leading) whitespace characters; prints them if
 *   they are followed by a non-whitespace character before the buffer is full,
 *   truncates otherwise.
 * - Depends upon consecutive input (consecutive whitespace), independent of
 *   line length.
 */
int main(void) {
  int c, len, state;
  char buffer[MAXWS];

  len = 0;
  state = OUT;
  while ((c = getchar()) != EOF) {
    if (c == '\n') {
      if (state == IN) {
        putchar(c);
      }

      len = 0;
      state = OUT;
    } else if (c == ' ' || c == '\t') {
      if (len < MAXWS) {
        buffer[len++] = c;
      }
    } else if (len < MAXWS) {
      if (len > 0 && state == IN) {
        buffer[len] = '\0';
        printf("%s", buffer);
      }

      len = 0;
      state = IN;
      putchar(c);
    }
  }

  return 0;
}
