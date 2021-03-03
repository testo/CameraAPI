#ifndef __TILIBCONFIG_H__
#define __TILIBCONFIG_H__

/* #undef HAVE_GNU_C0X */
#define HAVE_GNU_C11

#define TILIB_BUILD_SHARED_LIBS
#define TILIB_BUILD_CAMCOM_GEN1
#define TILIB_BUILD_CAMCOM_GEN2
#define TILIB_BUILD_CAMCOM_GEN3
/* #undef TILIB_BUILD_CAMCOM_ETHERNET_GEN1 */
#define TILIB_BUILD_ENHANCEMENT
/* #undef TILIB_HAVE_MIL */
/* #undef TILIB_HAVE_NATIONALINSTRUMENTS */
/* #undef TILIB_USE_PTHREADS */
/* #undef TILIB_HAVE_QT */
/* #undef TILIB_HAVE_BOOST */
/* #undef TILIB_ENABLE_FW_COMPATIBILITY */
/* #undef TILIB_ENABLE_EXT_MEMORY_ALLOCATOR */

#define TILIB_UNITTESTDATA_DIR "C:/svn/pl/tilib_labview/../TIPITestData"

#define TILIB_BUILD_DIR "C:/svn/pl/tilib_labview_build"
#define TILIB_SOURCE_DIR "C:/svn/pl/tilib_labview"

#define TILIB_VERSION "1.5.5"

#define TLIB_CAMCOM_SEARCH_DIR "C:/svn/pl/tilib_labview_build"

#ifndef RC_INVOKED 
// RC_INVOKED resolves warning that is induced by the rc compiler that has problems with yVals.h
// that is included by cstdint
# ifdef WIN32
  #include <cstdint>
# else
  #include <stdint.h>
# endif
#endif 

// disable dll-linkage warnings that have no effect at all
#if defined WIN64 || defined WIN32
# pragma warning(disable:4251)
# pragma warning(disable:4996)
#endif


// includes and defines needed to show memory leak information at the end of the programm
#if defined(WIN32) && defined(_DEBUG)
# define _CRTDBG_MAP_ALLOC
# include <stdlib.h>
# include <crtdbg.h>
# if defined CONF_DI_PREDEFINED_MACRO_USAGE && (CONF_DI_PREDEFINED_MACRO_USAGE == 1)
#  define DEBUG_NEW_LEAKAGE new( _NORMAL_BLOCK, "", 0 )
# else
#  define DEBUG_NEW_LEAKAGE new( _NORMAL_BLOCK, __FILE__, __LINE__ )
# endif
#else
# define DEBUG_NEW_LEAKAGE new
#endif

// deprecated warning macro definition
#if defined WIN64 || defined WIN32
# define __deprecated__(a)   __declspec(deprecated(a))        // msvc marco
#else
# define __deprecated__(a)   __attribute__ ((deprecated(a)))  // gnu macro
#endif 


#ifdef _DEBUG
#  define DEBUG
#endif


#endif
