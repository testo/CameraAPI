# DIRECTORIES
set(GTEST_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/include" CACHE PATH "Path where gtest includes are located")
set(GTEST_LIBRARY_DIR "${CMAKE_CURRENT_LIST_DIR}/lib"     CACHE PATH "Path where gtest libraries are located")

if(WIN32)
  set(GTEST_BINARY_DIR  "${CMAKE_CURRENT_LIST_DIR}/bin"     CACHE PATH "Path where gtest binaries are located")
else()
  set(GTEST_BINARY_DIR  "${CMAKE_CURRENT_LIST_DIR}/lib"     CACHE PATH "Path where gtest binaries are located")
endif()

# LIBRARIES
set(GTEST_LIBRARIES_DEBUG   debug     gtestd.lib)
set(GTEST_LIBRARIES_RELEASE optimized gtest.lib)
set(GTEST_LIBRARIES ${GTEST_LIBRARIES_DEBUG} ${GTEST_LIBRARIES_RELEASE})

#if(OFF)
#set(GTEST_MAIN_LIBRARIES)
#else()
set(GTEST_MAIN_LIBRARIES_DEBUG   debug     gtest_maind.lib   )
set(GTEST_MAIN_LIBRARIES_RELEASE optimized gtest_main.lib )
set(GTEST_MAIN_LIBRARIES ${GTEST_MAIN_LIBRARIES_DEBUG} ${GTEST_MAIN_LIBRARIES_RELEASE} )
#endif()

set(GTEST_BINARIES_DEBUG)
set(GTEST_BINARIES_RELEASE)
set(GTEST_BINARIES ${GTEST_BINARIES_DEBUG} ${GTEST_BINARIES_RELEASE})

set(GTEST_BOTH_LIBRARIES ${GTEST_LIBRARIES} ${GTEST_MAIN_LIBRARIES})
set(GTEST_LIBRARIES ${GTEST_BOTH_LIBRARIES})

if()
  add_definitions(-D__native_client__)
endif()

if(TRUE)
  add_definitions(-DGTEST_HAS_POSIX_RE=0)
else()
  add_definitions(-DGTEST_HAS_POSIX_RE=1)
endif()

if(TRUE) #gtest_disable_pthreads
  add_definitions(-DGTEST_HAS_PTHREAD=0)
else()
  add_definitions(-DGTEST_HAS_PTHREAD=1)
endif()

if(MSVC11)
  add_definitions(-D_VARIADIC_MAX=10)
endif()

if(ON)
  add_definitions(-DGTEST_LINKED_AS_SHARED_LIBRARY=1)
endif()

include_directories(${GTEST_INCLUDE_DIR})
link_directories(${GTEST_LIBRARY_DIR})

mark_as_advanced(GTEST_INCLUDE_DIR)
mark_as_advanced(GTEST_LIBRARY_DIR)
mark_as_advanced(GTEST_BINARY_DIR)
