---
date: 2022-06-18
authors:
  - mgao
tags:
  - C
  - Code
categories:
  - Programming
---

# Uninitialized Variable in C

Uninitialized variable in C can be anything (most of the time). I find, in some cases, we can know the value of an uninitialized variable and thus maybe exploit it.

<!-- more -->

The example code below compiled with `gcc`, without optimization, exits successfully. Very interesting!

```c
#include <assert.h>
#include <limits.h>
#include <stdlib.h>

void f(int n) {
  // Declare and init `a` with the value of n
  // This would push n on the stack memory
  int a = n;
  return;
  // f() returns,
  // but `a` leaves on the stack a garbage value n
}

void g(int n) {
  // Declare but do no initialize `x` so
  // `x` may be of anything...?
  int x;
  assert(x == n);  // Should fail here if `x` is not n
}

int main() {
  for (int i = INT_MIN; i < INT_MAX; i++) {
    f(i);  // However, if we call f() and g() sequentially...
    g(i);  // The local variable `x` in g() will always be i,
           // which is the garbage value left by f() on the stack.
  }
  // This program will end peacefully
  return 0;
}
```

We can also try to "contaminate" the stack by filling it with a value, e.g.,

```c
#include <assert.h>
#include <memory.h>
#include <stdint.h>
#include <stdio.h>

void f(uint8_t n) {
  // Try to "contaminate" the stack with value n
  uint8_t arr[BUFSIZ];
  memset(arr, n, BUFSIZ * sizeof(uint8_t));
}

void g(uint8_t n) {
  uint8_t x;
  assert(x == n);
  printf("uninitialized x is %d\n", x);
  uint8_t y;
  assert(y == n);  // uninitialized y is also n
}

int main() {
  for (uint8_t i = 0; i < UINT8_MAX; i++) {
    f(i);
    g(i);
  }
  // This program will end peacefully!
  return 0;
}
```

As a result, the uninitialized local variables `x` and `y` both have the same value of `n` because `f(n)` writes many `n` on the stack.

Studying C is real fun!
