#***************************************************************************
#* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
#***************************************************************************
#**@file FindTiLib.cmake
#  @brief<b>Description: </b> find script that searches for TiLib library
#                             set 'TILIB_LIBRARY_SEARCH_DIRS'
#                             to find TiLib in a custom library search path
#
#  <br> Initially written by: 1000len-dim
#  <br> $Author:$
#  <br> $Date:$
#  <br> $HeadURL:$
#  <br> $Revision:$
#
#***************************************************************************

find_file(TILIB_CONFIG NAMES  "TiLibConfig.cmake" PATHS 
  "${TILIB_LIBRARY_SEARCH_DIRS}" 
  NO_SYSTEM_ENVIRONMENT_PATH
)

include("${TILIB_CONFIG}")
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(TiLib DEFAULT_MSG TILIB_LIBRARIES TILIB_INCLUDE_DIR)

mark_as_advanced(TILIB_CONFIG)

# create info message block 
get_filename_component(THIS_CMAKE_PATH "${CMAKE_CURRENT_LIST_FILE}" PATH) 
include("${CMAKE_CURRENT_LIST_DIR}/TestoLibFunctions.cmake")
createFindInfo("TiLib" "${TILIB_VERSION}" "${TILIB_INCLUDE_DIR}" "${TILIB_LIBRARY_DIR}" "${TILIB_BINARY_DIR}" "${TILIB_LIBRARIES}")

# add link and include directories to test projects
link_directories("${TILIB_LIBRARY_DIR}")
include_directories("${TILIB_INCLUDE_DIR}")
