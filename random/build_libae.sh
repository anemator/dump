#!/bin/sh
set -x

if [ -z "$CC" ]; then
  CC=cc
fi

if [ -z "$REDIS" ]; then
  REDIS="$(pwd)/redis"
fi

if [ ! -d "$REDIS" ]; then
  git clone https://github.com/antirez/redis.git "$REDIS"
fi

INCDIR=$PWD/include
LIBDIR=$PWD/lib
OS=$(uname -s)

if [ "$OS" = Darwin ]; then
  LDARGS="-dynamiclib -o $LIBDIR/libae.dylib"
elif [ "$OS" = Linux ]; then
  LDARGS="-shared -o $LIBDIR/libae.so"
else
  echo "ERROR: unsupported operating system <<$OS>>"
  exit 1
fi

mkdir -p "$INCDIR" "$LIBDIR"
(cd "$REDIS/src" && $CC -fPIC $LDARGS ae.c zmalloc.c)
cp "$REDIS/src/ae.h" "$REDIS/src/zmalloc.h" "$INCDIR"

echo '#ifndef __AE_HPP__
#define __AE_HPP__
extern "C" {
#include <ae.h>
}
#endif // __AE_HPP__' > "$INCDIR/ae.hpp"

echo '#ifndef __ZMALLOC_HPP__
#define __ZMALLOC_HPP__
extern "C" {
#include <zmalloc.h>
}
#endif // __ZMALLOC_HPP__' > "$INCDIR/zmalloc.hpp"
