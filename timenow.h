#ifndef _TIMENOW_H
#define _TIMENOW_H
#include <time.h>
#include <sys/time.h>

#include <stdint.h>

#if defined(__APPLE__)
static inline uint64_t time_now() {
  struct timeval tv;
  uint64_t ret;

  gettimeofday(&tv, NULL);
  ret = tv.tv_sec;
  ret *= 1000000;
  ret += tv.tv_usec;
  return ret;
}
#else
static inline uint64_t time_now() {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);

  uint64_t ret = ts.tv_sec;
  ret *= 1000000;
  ret += ts.tv_nsec / 1000;
  return ret;
}
#endif

#endif  // _TIMENOW_H
