#include <stdio.h>

int main(void) {
  int fahr, celsius;
  int lower, upper, step;

  lower = 0;
  upper = 300;
  step = 20;

  printf("Fahrenheit\tCelsius\n");

  fahr = lower;
  while (fahr <= upper) {
    celsius = 5 * (fahr - 32) / 9;
    printf("%10d\t%d\n", fahr, celsius);
    fahr = fahr + step;
  }

  return 0;
}
