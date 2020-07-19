#include <stdio.h>

int filter_line(void) {
  int c = getchar();
  while (EOF != c && '\n' != c)
    c = getchar(); // do nothing
  return c;
}

int filter_block(void) {
  int c = getchar();
  if (EOF == c)
    return EOF;

  do {
    int tmp = getchar();
    if (EOF == tmp)
      return EOF;

    if ('*' == c && '/' == tmp)
      return getchar();

    c = getchar();
    if ('*' == tmp && '/' == c)
      return getchar();
  } while (EOF != c);

  return EOF;
}

int filter_quote(void) {
  int c = getchar();
  if (EOF == c) {
    return EOF;
  } else if ('"' == c) {
    putchar('"');
    return getchar();
  }

  do {
    int tmp = getchar();
    if (EOF == tmp)
      return EOF;

    if ('\\' != c && '"' == tmp) {
      putchar(c);
      putchar(tmp);
      return getchar();
    }

    putchar(c);
    c = getchar();
    if ('\\' != tmp && '"' == c) {
      putchar(tmp);
      putchar(c);
      return getchar();
    }
    putchar(tmp);
  } while (EOF != c);

  return EOF;
}

int main(void) {
  int c = getchar();
  if (EOF == c)
    return 0;

  do {
    int tmp = getchar();
    if (EOF == tmp) {
      putchar(c);
      break;
    }

    if ('/' == c && '/' == tmp) {
      c = filter_line();
      continue;
    } else if ('/' == c && '*' == tmp) {
      c = filter_block();
      continue;
    } else if ('\\' != c && '"' == tmp) {
      putchar(c);
      putchar(tmp);
      c = filter_quote();
      continue;
    }

    putchar(c);
    c = getchar();
    if (EOF == c) {
      putchar(tmp);
      break;
    }

    if ('/' == tmp && '/' == c) {
      c = filter_line();
      continue;
    } else if ('/' == tmp && '*' == c) {
      c = filter_block();
      continue;
    } else if ('\\' != tmp && '"' == c) {
      putchar(tmp);
      putchar(c);
      c = filter_quote();
      continue;
    }
    putchar(tmp);
  } while (EOF != c);

  return 0;
}
