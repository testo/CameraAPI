#***************************************************************************
#* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
#***************************************************************************
#**@file CMakeLists.txtx
#  @brief<b>Description: </b> cmake file for testo template project
#***************************************************************************

cmake_minimum_required(VERSION 2.8.10)

# accept new (2.8) policy to treat relative paths in link directories beeing relative to source dir
cmake_policy(SET CMP0015 NEW)
if(POLICY CMP0020)
  cmake_policy(SET CMP0020 NEW)
endif()
if(POLICY CMP0028)
  cmake_policy(SET CMP0028 NEW)
endif()

# Set a consistent MACOSX_RPATH default across all CMake versions. 
# When CMake 2.8.12 is required, change this default to 1.
# When CMake 3.0.0 is required, remove this block (see CMP0042).
if(NOT DEFINED CMAKE_MACOSX_RPATH)
  set(CMAKE_MACOSX_RPATH 0)
endif()

#---------------------------------------------------------------------------------------------------# 
# PROJECT NAME
# enter your project name here
# ATTENTION:
#     to make all build scripts work correctly THIS_PROJECTS_NAME should be named the int same way 
#     as the projects root folder (this includes letter cases)
#     (i.e. ROOT_DIR: git/pimpl/template_project -> THIS_PROJECTS_NAME: template_project)
#---------------------------------------------------------------------------------------------------# 
project("CameraApi")
string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPERCASE)

# Debug postfix
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# cmake dirs                                                                                                
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${${PROJECT_NAME}_BINARY_DIR}/bin/"  CACHE PATH "Single output directory for all binaries")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${${PROJECT_NAME}_BINARY_DIR}/lib/"  CACHE PATH "Single output directory for all libraries")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${${PROJECT_NAME}_BINARY_DIR}/bin/"  CACHE PATH "Single output directory for all DLLs")

#---------------------------------------------------------------------------------------------------# 
# PROJECT VARIABLES
#---------------------------------------------------------------------------------------------------# 
set(PROJECT_SOURCE_DIR ${${PROJECT_NAME}_SOURCE_DIR})
set(PROJECT_BINARY_DIR ${${PROJECT_NAME}_BINARY_DIR})

set(PROJECT_BINARY_DIR_DEBUG   "${PROJECT_BINARY_DIR}/bin/Debug" )
set(PROJECT_BINARY_DIR_RELEASE "${PROJECT_BINARY_DIR}/bin/Release" )

set(${PROJECT_NAME_UPPERCASE}_VERSION_MAJOR "1")
set(${PROJECT_NAME_UPPERCASE}_VERSION_MINOR "0")
set(${PROJECT_NAME_UPPERCASE}_VERSION_PATCH "0")
set(${PROJECT_NAME_UPPERCASE}_VERSION_BUILD "0" CACHE STRING "Specify an build tag")
mark_as_advanced(${PROJECT_NAME_UPPERCASE}_VERSION_BUILD)
set(${PROJECT_NAME_UPPERCASE}_VERSION       "${${PROJECT_NAME_UPPERCASE}_VERSION_MAJOR}.${${PROJECT_NAME_UPPERCASE}_VERSION_MINOR}.${${PROJECT_NAME_UPPERCASE}_VERSION_PATCH}.${${PROJECT_NAME_UPPERCASE}_VERSION_BUILD}")

set(CMAKE_DEBUG_POSTFIX   "_${${PROJECT_NAME_UPPERCASE}_VERSION_MAJOR}_${${PROJECT_NAME_UPPERCASE}_VERSION_MINOR}_${${PROJECT_NAME_UPPERCASE}_VERSION_PATCH}d")
set(CMAKE_RELEASE_POSTFIX "_${${PROJECT_NAME_UPPERCASE}_VERSION_MAJOR}_${${PROJECT_NAME_UPPERCASE}_VERSION_MINOR}_${${PROJECT_NAME_UPPERCASE}_VERSION_PATCH}")

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/configure/cmake" "${CMAKE_MODULE_PATH}")
include(configure/cmake/ProjectMacros.cmake)
include(configure/cmake/TestoLibMacros.cmake)
include(configure/cmake/TestoLibFunctions.cmake)


#-----------------------#
# GENERAL SETTINGS
#-----------------------#
# Set the absolut path from the VS Environmental file to the variable VCX_PROJ_IN_FILE_PATH
set(VCX_PROJ_IN_FILE_PATH ${${PROJECT_NAME}_SOURCE_DIR}/configure/VSEnv.vcxproj.user.in)

#---------------------------------------------------------------------------------------------------# 
# PROJECT OPTIONS
#---------------------------------------------------------------------------------------------------# 
option( BUILD_SHARED_LIBS                   "If enabled this option enables shared, if deactivated static linking"            ON  )
option( ${PROJECT_NAME_UPPERCASE}_GENERATE_MAP_FILES       "enables the building process of map files for apps"               OFF )

set(${PROJECT_NAME_UPPERCASE}_THIRD_PARTY_LIBS_DIR  "${PROJECT_SOURCE_DIR}/../thirdparty"      CACHE PATH "path to the third party libs directory")

option( INSTALL_THIRD_PARTY_LIBRARIES  "If enabled this option enables shared, if deactivated static linking"  ON  )


#---------------------------------------------------------------------------------------------------# 
# VALIDITY CHECKS
#---------------------------------------------------------------------------------------------------# 
if(NOT EXISTS ${${PROJECT_NAME_UPPERCASE}_THIRD_PARTY_LIBS_DIR}/CMakeLists.txt )
  message(FATAL_ERROR "${PROJECT_NAME_UPPERCASE}_THIRD_PARTY_LIBS_DIR not set correctly. Please specify third party directory.") 
endif()

#-----------------------#
# BUILD options
#-----------------------#

#---------------------------------------------------------------------------------------------------#
# PROJECT C/CXX FLAGS
# PREPARE COMPILER AND COMPILE FLAGS 
# this has to be called after testolib is configured or else the PREPARE_WARNING_AS_ERROR and
# PREPARE_COMPILER macros are not available in this context
#---------------------------------------------------------------------------------------------------#
PREPARE_COMPILER( TRUE )

set(${PROJECT_NAME_UPPERCASE}_WARNING_AS_ERROR  ON  CACHE   BOOL "HANDLE WARNING AS ERROR")
PREPARE_WARNING_AS_ERROR(${${PROJECT_NAME_UPPERCASE}_WARNING_AS_ERROR})

#---------------------------------------------------------------------------------------------------# 
# PROJECT LOAD THIRD_PARTY_LIBS
#---------------------------------------------------------------------------------------------------# 
include("${${PROJECT_NAME_UPPERCASE}_THIRD_PARTY_LIBS_DIR}/CMakeLists.txt")

LOAD_THIRDPARTY_LIBRARIES(THIRD_PARTY_MODULES THIRD_PARTY_LIBRARIES THIRD_PARTY_BINARY_DIRS)

set_property(GLOBAL APPEND PROPERTY "PROPERTY_THIRD_PARTY_BINARY_DIRECTORIES" "${THIRD_PARTY_BINARY_DIRS}") 


#---------------------------------------------------------------------------------------------------# 
# PROJECT INCLUDES
#---------------------------------------------------------------------------------------------------# 
include_directories( "${PROJECT_BINARY_DIR}")
include_directories( "${PROJECT_SOURCE_DIR}")

#---------------------------------------------------------------------------------------------------# 
# PROJECT CONFIGURE FILES
#---------------------------------------------------------------------------------------------------# 
if( ${PROJECT_NAME_UPPERCASE}_BUILD_TESTS )
  enable_testing()
endif()

#---------------------------------------------------------------------------------------------------# 
# PROJECT MODULES
#---------------------------------------------------------------------------------------------------# 
#project main source last, because everything else has to be finished when the .pro file is created!

TESTO_OPTION(${PROJECT_NAME} ${PROJECT_NAME_UPPERCASE}_BUILD_LABVIEW_CWRAPPER "enables labview cwrapper")
if(${PROJECT_NAME_UPPERCASE}_BUILD_LABVIEW_CWRAPPER)
  ADD_LIBRARY_MODULE(labview_cwrapper)
endif()

TESTO_OPTION(${PROJECT_NAME} ${PROJECT_NAME_UPPERCASE}_BUILD_TEST "enables build test")
if(${PROJECT_NAME_UPPERCASE}_BUILD_TEST)
  add_subdirectory("test")
endif()

message(STATUS "CMake version file: ${PROJECT_BINARY_DIR}/version.txt")
file(WRITE "${PROJECT_BINARY_DIR}/version.txt" "VERSION=${${PROJECT_NAME_UPPERCASE}_VERSION_NUMBER}")

GET_TESTO_DEFINES(${PROJECT_NAME} ${PROJECT_NAME}_DEFINES)
foreach( define ${${PROJECT_NAME}_DEFINES} )
  set(${PROJECT_NAME}_CMAKE_DEFINES "${${PROJECT_NAME}_CMAKE_DEFINES}#ifndef ${define}\n")
  if ( "${${define}}" STREQUAL "ON" OR "${${define}}" STREQUAL "OFF")
    set(${PROJECT_NAME}_CMAKE_DEFINES "${${PROJECT_NAME}_CMAKE_DEFINES}#cmakedefine ${define}\n")
  elseif( "${${define}}" MATCHES "^[0-9]+$" )
    set(${PROJECT_NAME}_CMAKE_DEFINES "${${PROJECT_NAME}_CMAKE_DEFINES}#define ${define} ${${define}}\n")
  else()
    set(${PROJECT_NAME}_CMAKE_DEFINES "${${PROJECT_NAME}_CMAKE_DEFINES}# define ${define} asdfasdf\"${${define}}\"\n")
  endif()
  set(${PROJECT_NAME}_CMAKE_DEFINES "${${PROJECT_NAME}_CMAKE_DEFINES}#endif //${define}\n")
endforeach()

GET_TESTO_OPTIONS(${PROJECT_NAME} ${PROJECT_NAME}_OPTIONS) 
foreach(opt ${${PROJECT_NAME}_OPTIONS})
   set(${PROJECT_NAME}_CMAKE_OPTIONS "${${PROJECT_NAME}_CMAKE_OPTIONS}#cmakedefine ${opt} \n")
endforeach()  

#---------------------------------------------------------------------------------------------------# 
# PROJECT CONFIGURE FILES
#---------------------------------------------------------------------------------------------------# 
configure_file( ${PROJECT_SOURCE_DIR}/configure/project_config.h.in ${PROJECT_BINARY_DIR}/${PROJECT_NAME}_config.h.in1 @ONLY)
configure_file( ${PROJECT_BINARY_DIR}/${PROJECT_NAME}_config.h.in1  ${PROJECT_BINARY_DIR}/${PROJECT_NAME}_config.h.in2      )
configure_file( ${PROJECT_BINARY_DIR}/${PROJECT_NAME}_config.h.in2  ${PROJECT_BINARY_DIR}/${PROJECT_NAME}_config.h          ) # third pass for cmakedefines

#-------------------------------------#
# SAVE THIRD PARTY BINARY DIRECTORIES
#-------------------------------------#
GET_THIRD_PARTY_BIN_DIRS(THIRDPARTY_BINARY_DIRS)  
file(WRITE "${${PROJECT_NAME}_BINARY_DIR}/ThirdPartyBinaryDirs.cmake")  

foreach(dir ${THIRDPARTY_BINARY_DIRS})
  file(APPEND "${${PROJECT_NAME}_BINARY_DIR}/ThirdPartyBinaryDirs.cmake" "\"${dir}\"\n")
endforeach()

#---------------------------------------------------------------------------------------------------# 
# PROJECT INSTALL FILES
#---------------------------------------------------------------------------------------------------# 
install( FILES        "${PROJECT_BINARY_DIR}/${PROJECT_NAME}_config.h" DESTINATION  "include")

# THIRD PARTY LIBS INSTALL
if(INSTALL_THIRD_PARTY_LIBRARIES)
  foreach(dir ${THIRD_PARTY_BINARY_DIRS})   
    if(${dir} STREQUAL "/") 
    else()
     FILE(GLOB binaries "${dir}/*.*")
     if(APPLE)
      FILE(GLOB apple_app "${dir}/*.app")
     endif()
     if(apple_app)
       list(REMOVE_ITEM binaries ${apple_app})    
     endif() 
     
     foreach( file ${binaries} )
        if(NOT IS_DIRECTORY ${file})
          install(FILES ${file} DESTINATION "bin")
        endif()
     endforeach()
    endif()
  endforeach()
endif()

#------------------------------------------------------------------#
# DOXYGEN
#------------------------------------------------------------------#
TESTO_OPTION(${PROJECT_NAME} ${PROJECT_NAME_UPPERCASE}_BUILD_DOCUMENTATION "Use doxygen to create documentation" OFF)
if(${PROJECT_NAME_UPPERCASE}_BUILD_DOCUMENTATION )
  if(TESTCLIENT_BUILD_TEST)
    CONFIGURE_DOCUMENTATION( "camera_api" "test" )  
  endif()
endif()
