// http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html
//
// cc -c a*.c; ar -cvq libmath.a *.o; cc -o static main.c libmath.a
//
// cc -fPIC -c a*.c; cc -shared -o libmath.so *.o
//   cc -L. -lmath -o dlink main.c
// OR
//   cc -rdynamic -o dload main.c
#include <assert.h>
//#include <dlfcn.h>

extern int add1(int);

int main(int argc, char** argv) {
  /*
  void* lib = dlopen("libmath.so", RTLD_LAZY);
  if (!lib) {
    assert(0 && "Failed to open library");
  }

  int (*add1)(int) = dlsym(lib, "add1");
  if (dlerror()) {
    assert(0 && "Failed to load function");
  }
  */

  assert(2 == add1(1));

  // dlclose(lib);
  return 0;
}
