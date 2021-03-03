#***************************************************************************
#* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
#***************************************************************************
#**@file FindGTest.cmake
#  @brief<b>Description: </b> find script that searches for gtest library
#                             set 'GTEST_LIBRARY_SEARCH_DIRS'
#                             to find gtest in a custom library search path
#
#  <br> Initially written by: 1000len-scm
#  <br> $Author:$
#  <br> $Date:$
#  <br> $HeadURL:$
#  <br> $Revision:$
#
#***************************************************************************

find_file(GTEST_CONFIG NAMES  "GTestConfig.cmake" PATHS 
  "${GTEST_LIBRARY_SEARCH_DIRS}" 
  NO_SYSTEM_ENVIRONMENT_PATH
)
include("${GTEST_CONFIG}")
include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(GTest DEFAULT_MSG GTEST_LIBRARIES GTEST_INCLUDE_DIR)

mark_as_advanced(GTEST_CONFIG)

# create info message block 
get_filename_component(THIS_CMAKE_PATH "${CMAKE_CURRENT_LIST_FILE}" PATH) 
include("${CMAKE_CURRENT_LIST_DIR}/TestoLibFunctions.cmake")
createFindInfo("GTest" "${GTEST_VERSION}" "${GTEST_INCLUDE_DIR}" "${GTEST_LIBRARY_DIR}" "${GTEST_BINARY_DIR}" "${GTEST_BOTH_LIBRARIES}")

# add link and include directories to test projects
link_directories("${GTEST_LIBRARY_DIR}")
include_directories("${GTEST_INCLUDE_DIR}")
