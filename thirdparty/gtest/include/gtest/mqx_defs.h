#ifndef __MQX_DEFS_H__
#define __MQX_DEFS_H__

#ifdef __cplusplus
#include <cstdio>
extern "C" {
	
#else
#include <stdio.h>
#endif

#if defined (__GNUC__) && defined (__STRICT_ANSI__)
/* GCC in C++11 mode uses strict mode where it tries not to define any functions that are not defined by the language.
 * This functions are defined by POSIX, which is a standard that includes, but is separate from the C language standard. */

//  typedef struct stat StatStruct;

  int fileno(FILE* stream);

//  int isatty(int fd);

//  int stat(const char *path, struct stat *buf);

  char *strdup (const char *s);

//  int rmdir(const char* dir);

//  int S_ISDIR(const StatStruct& st);

  FILE* fdopen(int, const char *);

#endif

#ifdef __cplusplus
}
#endif

#endif
