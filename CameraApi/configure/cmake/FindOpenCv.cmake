#***************************************************************************
#* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
#***************************************************************************
#**@file FindOpenCV.cmake
#  @brief<b>Description: </b> find script that searches for the OPENCV library
#                             set 'OPENCV_LIBRARY_SEARCH_DIRS'
#                             to find gtest in a custom library search path
#
#  <br> Initially written by: 1000len-scm
#  <br> $Author:$
#  <br> $Date:$
#  <br> $HeadURL:$
#  <br> $Revision:$
#
#***************************************************************************
  
find_file(OpenCV_Config NAMES  "OpenCVConfig.cmake" PATHS 
  "${OPENCV_LIBRARY_SEARCH_DIRS}"
  "${OPENCV_LIBRARY_SEARCH_DIRS}/share/OpenCV"
  "${TESTOLIB_THIRD_PARTY_LIBS_DIR}/opencv/"
  "${TESTOLIB_THIRD_PARTY_LIBS_DIR}/opencv/share/OpenCV"
  NO_SYSTEM_ENVIRONMENT_PATH
)

find_file(OpenCV_Config_Version NAMES  "OpenCVConfig-version.cmake" PATHS 
  "${OPENCV_LIBRARY_SEARCH_DIRS}"
  "${OPENCV_LIBRARY_SEARCH_DIRS}/share/OpenCV"
  "${TESTOLIB_THIRD_PARTY_LIBS_DIR}/opencv/"
  "${TESTOLIB_THIRD_PARTY_LIBS_DIR}/opencv/share/OpenCV"
  NO_SYSTEM_ENVIRONMENT_PATH
)

include("${OpenCV_Config}")
include("${OpenCV_Config_Version}")

set(OPENCV_INCLUDE_DIRS  ${OpenCV_INCLUDE_DIRS})
set(OPENCV_LIB_DIR       ${OpenCV_LIB_DIR})
set(OPENCV_LIBRARIES     ${OpenCV_LIBS})

if(UNIX)
  set(OPENCV_LIB_DIR    "${OpenCV_INSTALL_PATH}/lib")
  set(OPENCV_BIN_DIR    "${OpenCV_INSTALL_PATH}/lib")
  set(OPENCV_BINARY_DIR "${OpenCV_INSTALL_PATH}/lib")
else(WIN32)
  if(_OpenCV_LIB_PATH)
    string(REPLACE "\\" "/" OPENCV_BIN_DIR    ${_OpenCV_LIB_PATH})
    string(REPLACE "\\" "/" OPENCV_BINARY_DIR ${_OpenCV_LIB_PATH})
  else()
    set( OPENCV_BIN_DIR    "${OpenCV_LIB_DIR}/../bin" )
    set( OPENCV_BINARY_DIR "${OpenCV_LIB_DIR}/../bin" )
  endif() 
endif()


include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(OpenCV OpenCV_VERSION OpenCV_INCLUDE_DIRS OpenCV_LIB_DIR OpenCV_LIBRARIES)

link_directories("${OPENCV_INCLUDE_DIRS}")
include_directories("${OPENCV_INCLUDE_DIRS}")

set(OpenCv_FOUND ON)

# create info message block 
get_filename_component(THIS_CMAKE_PATH "${CMAKE_CURRENT_LIST_FILE}" PATH) 
include("${CMAKE_CURRENT_LIST_DIR}/TestoLibFunctions.cmake")
createFindInfo("OpenCV" "${OpenCV_VERSION}" "${OpenCV_INCLUDE_DIRS}" "${OpenCV_LIB_DIR}" "${OpenCV_BIN_DIR}" "${OpenCV_LIBRARIES}")

mark_as_advanced(OpenCV_Config)
