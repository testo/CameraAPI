#ifndef __TILIB_EXTERN_INTERFACE_H__
#define __TILIB_EXTERN_INTERFACE_H__
/***************************************************************************
* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
***************************************************************************/
/**@file
   @brief<b>Description: </b> declspec of module extern interface

   <br> Initially written by: kuj
   <br> $Author: 1000len-kuj	 $
   <br> $Date: 2012-04-02 16:50:55 +0200 (Mo, 02 Apr 2012) $
   <br> $HeadURL: http://testosvn01/repos/pl/tilib/branches/stable-1.5/modules/radiometry/TiLibRadiometry.h $
   <br> $Revision: 44336 $

 *******************************	********************************************/

/***************************************************************************
* INCLUDES
***************************************************************************/
#include <TiLibConfig.h>

/***************************************************************************
* DEFINES FOR DECLSPEC
***************************************************************************/
#if defined (WIN32) && defined(TILIB_BUILD_SHARED_LIBS) 

# if defined TiLibExternInterface_EXPORTS 
#  define TILIB_EXTERN_INTERFACE_DECL __declspec(dllexport)
# else  
#  define TILIB_EXTERN_INTERFACE_DECL __declspec(dllimport)
# endif 

#else // (WIN32) && defined(TILIB_BUILD_SHARED_LIBS) 
# define TILIB_EXTERN_INTERFACE_DECL
#endif // (WIN32) && defined(TILIB_BUILD_SHARED_LIBS) 

#endif
