
# set library version
set(TILIB_VERSION_MAJOR        "1")
set(TILIB_VERSION_MINOR        "5")
set(TILIB_VERSION_PATCH        "100")
set(TILIB_VERSION              "${TILIB_VERSION_MAJOR}.${TILIB_VERSION_MINOR}.${TILIB_VERSION_PATCH}")

# DIRECTORIES
set(TILIB_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/include" CACHE PATH "Path where TiLib includes are located")
set(TILIB_LIBRARY_DIR "${CMAKE_CURRENT_LIST_DIR}/lib"     CACHE PATH "Path where TiLib libraries are located")
set(TILIB_BINARY_DIR  "${CMAKE_CURRENT_LIST_DIR}/bin"     CACHE PATH "Path where TiLib binaries are located")


#  SET LIBRARIES
set(TILIB_LIBRARIES_DEBUG   debug     TiLibExternInterfaceD.lib)
set(TILIB_LIBRARIES_RELEASE optimized TiLibExternInterface.lib)
set(TILIB_LIBRARIES ${TILIB_LIBRARIES_DEBUG} ${TILIB_LIBRARIES_RELEASE})


#set(TILIB_BINARIES_DEBUG)
#set(TILIB_BINARIES_RELEASE)
#set(TILIB_BINARIES ${TILIB_BINARIES_DEBUG} ${TILIB_BINARIES_RELEASE})

#set(TILIB_BOTH_LIBRARIES ${TILIB_LIBRARIES} ${TILIB_MAIN_LIBRARIES})
#set(TILIB_LIBRARIES ${TILIB_BOTH_LIBRARIES})

include_directories(${TILIB_INCLUDE_DIR})
link_directories(${TILIB_LIBRARY_DIR})
