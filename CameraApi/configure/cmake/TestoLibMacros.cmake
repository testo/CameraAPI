#***************************************************************************
#* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
#***************************************************************************
#**@file Macros.cmake
#  @brief<b>Description: </b> cmake macros
#
#  <br> $Author:$
#  <br> $Date:$
#  <br> $HeadURL:$
#  <br> $Revision:$
#
#***************************************************************************

# see template at end of file

#-------------------------------------------------------------------------------------------
# add_target_property macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   this macro is a wrapper for cmake's own set_target_properties macro which does not have
#   the flexibility to simply 'add' a property. To add to a targets property we need TOUPPER
#   first get the current value and append the new value to it
#
# USAGE:
#   target:  target name
#   FLAG:    not used
#   prop1:   name of the property
#   value1:  value
#
# AUTHOR:
#   Matthias Schmieder
#
#-------------------------------------------------------------------------------------------
macro(add_target_properties target FLAG prop1 value1)
  get_target_property(CURRENT_PROPERTIES ${target} ${prop1})
  if(NOT CURRENT_PROPERTIES)
    set(CURRENT_PROPERTIES "${value1}")
  else()
    set(CURRENT_PROPERTIES "${CURRENT_PROPERTIES} ${value1}")
  endif()
  set_target_properties(${target}
    PROPERTIES
    ${prop1} ${CURRENT_PROPERTIES})
endmacro(add_target_properties)

#-------------------------------------------------------------------------------------------
# PREPARE_COMPILER macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
# USAGE:
#
# AUTHOR:
#   scm
#
#-------------------------------------------------------------------------------------------
macro(PREPARE_COMPILER enable_cpp11)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "Macro PREPARE_COMPILER requires 1 arguments but ${ARGC} given.")
  endif()

  if(CMAKE_COMPILER_IS_GNUCC OR GNU_GCC)
    option(GNU_GCC "DO NOT CHANGE" ON)
    mark_as_advanced(GNU_GCC)
    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
      OUTPUT_VARIABLE GCC_VERSION)


    string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
    list(LENGTH GCC_VERSION_COMPONENTS LEN_VERSION)
    list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
    list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)

    if(${LEN_VERSION} GREATER 2)
      list(GET GCC_VERSION_COMPONENTS 2 GCC_PATCH)
    else()
      set(GCC_PATCH "0")
    endif()

    message(STATUS "Using GNUCC Compiler (${GCC_MAJOR}.${GCC_MINOR}.${GCC_PATCH})")
    if(${enable_cpp11})
      if(${GCC_MAJOR} GREATER 4 OR (${GCC_MAJOR} EQUAL 4 AND ${GCC_MINOR} GREATER 7) )
        message(STATUS "  version >= 4.8.0: enabling GNUC++11 features")
        message(STATUS "  version >= 4.8.0: enabling REGEX    features")
        set( CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -std=c++11 -fpermissive")
        set( CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_CXX_FLAGS_DEBUG} -gdwarf-2")
        set( CMAKE_C_FLAGS_DEBUG     "${CMAKE_C_FLAGS_DEBUG} -gdwarf-2")

        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11        "enables C++11 features"                       ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_REGEX  "enables C++11 regular expression features"    ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_FUTURE "enables C++11 regular expression features"    ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_TYPED_ENUM   "enables C++11 strongly typed enums features"                   ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_DECLTYPE   "enables C++11 decltype features"                                 ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_VARIADIC_TEMPLATE   "enables funtions using C++11 variadic templates"        ON)
      elseif(${GCC_MAJOR} EQUAL 4 AND ${GCC_MINOR} GREATER 6)
        message(STATUS "  version >= 4.7.0: enabling GNUC++11 features")
        set( CMAKE_CXX_FLAGS            "${CMAKE_CXX_FLAGS} -std=c++11 -fpermissive")
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11        "enables C++11 features"                       ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_FUTURE "enables C++11 regular expression features"    ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_TYPED_ENUM   "enables C++11 strongly typed enums features"                   ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_DECLTYPE   "enables C++11 decltype features"                                 ON)
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_VARIADIC_TEMPLATE   "enables funtions using C++11 variadic templates"        ON)
      elseif(${GCC_MAJOR} EQUAL 4 AND ${GCC_MINOR} GREATER 5)
        message(STATUS "  version >= 4.6.0: enabling GNUC++0x features")
        set( CMAKE_CXX_FLAGS            "${CMAKE_CXX_FLAGS} -std=c++0x -fpermissive")
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_C0X          "enables C++0x features"                       ON)
      elseif(${GCC_MAJOR} EQUAL 4 AND ${GCC_MINOR} GREATER 4)
        message(STATUS "  version >= 4.5.0: enabling GNUC++0x features")
        set( CMAKE_CXX_FLAGS            "${CMAKE_CXX_FLAGS} -std=c++0x -fpermissive")
        TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_C0X          "enables C++0x features"                       ON)
      endif()
    endif()

    if(UNIX)
      message(STATUS "UNIX System: adding CXX_FLAG -fPIC")
      set( CMAKE_CXX_FLAGS         "${CMAKE_CXX_FLAGS} -fPIC" )
    endif()

    TESTO_OPTION( ${PROJECT_NAME}  ENABLE_GCOV
      "enables code coverage option using gcov. Will add -fprofile-arcs and -ftest-coverage to compiler flas as well as --coverage to linker flags"
      OFF)

    if(ENABLE_GCOV)
      set(CMAKE_CXX_FLAGS                   "${CMAKE_CXX_FLAGS} -O0 -fprofile-arcs -ftest-coverage")
      set(CMAKE_C_FLAGS                     "${CMAKE_C_FLAGS} -O0 -fprofile-arcs -ftest-coverage")
      set(CMAKE_EXE_LINKER_FLAGS            "${CMAKE_EXE_LINKER_FLAGS} -lgcov --coverage")
      set(CMAKE_MODULE_LINKER_FLAGS         "${CMAKE_MODULE_LINKER_FLAGS} -lgcov --coverage")
      set(CMAKE_SHARED_LINKER_FLAGS         "${CMAKE_SHARED_LINKER_FLAGS} -lgcov --coverage")
    endif()

    TESTO_OPTION( ${PROJECT_NAME}  ENABLE_GPROF "enables profiling for GNU builds using gprof tool" )

    if(ENABLE_GPROF)
      set(CMAKE_CXX_FLAGS                   "${CMAKE_CXX_FLAGS} -pg")
      set(CMAKE_C_FLAGS                     "${CMAKE_C_FLAGS} -pg")
    endif()
  elseif(MSVC)
    message(STATUS "Using Visual Studio Compiler (Version ${MSVC_VERSION})")
    if(${MSVC_VERSION} LESS 1700)
      message(STATUS "  version >= 1500: GNUC++0x features available")
      message(STATUS "  version >= 4.8.0: enabling REGEX   features")
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11          "enables C++11 features"                       ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_REGEX    "enables C++11 regular expression features"    ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_TYPED_ENUM   "enables C++11 strongly typed enums features"  OFF)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_VARIADIC_TEMPLATE   "enables C++11 strongly typed enums features"        OFF)
    elseif(${MSVC_VERSION} LESS 1800)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11              "enables C++11 features"                             ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_FUTURE       "enables C++11 regular expression features"          ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_TYPED_ENUM   "enables C++11 strongly typed enums features"        ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_VARIADIC_TEMPLATE   "enables C++11 strongly typed enums features"        OFF)
    elseif(${MSVC_VERSION} LESS 1900)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11              "enables C++11 features"                             ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_FUTURE "enables C++11 regular expression features"                ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_TYPED_ENUM   "enables C++11 strongly typed enums features"                   ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_DECLTYPE   "enables C++11 decltype features"                                 ON)
      TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_VARIADIC_TEMPLATE   "enables funtions using C++11 variadic templates"        ON)
    endif()

    # ENABLE PARALLEL BUILDS IN VISUAL STUDIO AND C++ EXCEPTIONS
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /bigobj /EHsc")

     TESTO_OPTION(${PROJECT_NAME} INSTALL_MSVC_REDISTRIBUTABLES
             "will also install the redistributables"
             ON)

    if(INSTALL_MSVC_REDISTRIBUTABLES)
      # get visual studio install path
      get_filename_component(MSCV_COMPILER_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)

      # create redistributable directory
       if(${CMAKE_SIZEOF_VOID_P} EQUAL 4) # check 32bit compiler
        set(MSCV_REDISTRIBUTABLE_DIR_RELEASE "${MSCV_COMPILER_DIR}/../redist/x86")
         set(MSCV_REDISTRIBUTABLE_DIR_DEBUG   "${MSCV_COMPILER_DIR}/../redist/Debug_NonRedist/x86")
       elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)  # check 64bit compiler
         set(MSCV_REDISTRIBUTABLE_DIR_RELEASE "${MSCV_COMPILER_DIR}/../redist/x64")
         set(MSCV_REDISTRIBUTABLE_DIR_DEBUG   "${MSCV_COMPILER_DIR}/../redist/Debug_NonRedist/x64")
       endif()

       file(GLOB_RECURSE redist_files_release ${MSCV_REDISTRIBUTABLE_DIR_RELEASE}/*.dll)
       file(GLOB_RECURSE redist_files_debug   ${MSCV_REDISTRIBUTABLE_DIR_DEBUG}/*.dll)
            install(FILES ${redist_files_release}
                DESTINATION "bin")
       install(FILES ${redist_files_debug}
                DESTINATION "bin")
    endif()

    TESTO_OPTION( ${PROJECT_NAME}  ENABLE_PROFILING
      "enables instrumentation of binaries in RelWithDebInfo mode using visual studio. Adds /PROFILE to EXE_LINKER_FLAGS, MODULE_LINKER_FLAGS and SHARED_LINKER_FLAGS"
      OFF)

    if(ENABLE_PROFILING)
      set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO} /PROFILE")
      set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO} /PROFILE")
      set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO} /PROFILE")

      # remove potential /INCREMENTAL:YES /INCREMENTAL /INCREMENTAL:NO
      string(REPLACE "/INCREMENTAL:YES" "/INCREMENTAL:NO" CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO})
      string(REPLACE "/INCREMENTAL:YES" "/INCREMENTAL:NO" CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO})
      string(REPLACE "/INCREMENTAL:YES" "/INCREMENTAL:NO" CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO})

      string(REPLACE "/INCREMENTAL " "/INCREMENTAL:NO " CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO})
      string(REPLACE "/INCREMENTAL " "/INCREMENTAL:NO " CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO})
      string(REPLACE "/INCREMENTAL " "/INCREMENTAL:NO " CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO})
    endif()

    if(MSVC)
      get_filename_component(MSVC_BINARY_DIR  ${CMAKE_CXX_COMPILER} PATH)
      get_filename_component(MSVC_DIR         ${MSVC_BINARY_DIR}    PATH)
      set(MSVC_INCLUDE_DIR "${MSVC_DIR}/include")

      include_directories("${MSVC_INCLUDE_DIR}")
    endif()
  elseif( CMAKE_COMPILER_IS_CLANG OR CLANG)
    ########################################################################################################################################
    # SETUP CLANG COMPILER
    ########################################################################################################################################
    TESTO_DEFINE(${PROJECT_NAME}  CLANG                      "indicator for clang compiler"                ON FORCE)
    mark_as_advanced(CLANG)

    ########################################################################################################################################
    # ENABLE (CODE-)ANALYZING
    ########################################################################################################################################
    option(ENABLE_CLANG_ANALYZING "enables clang's internal static code analyzer. This will increase compile-time!" OFF)
    if(ENABLE_CLANG_ANALYZING)
      set(CMAKE_CXX_FLAGS                   "${CMAKE_CXX_FLAGS} --analyze")
      set(CMAKE_CXX_FLAGS                   "${CMAKE_C_FLAGS} --analyze")
    endif()
    ########################################################################################################################################
    # ENABLE CODE COVERAGE
    ########################################################################################################################################
    TESTO_OPTION( ${PROJECT_NAME}  ENABLE_GCOV
      "enables code coverage option using gcov. Will add -fprofile-arcs and -ftest-coverage to compiler flas as well as --coverage to linker flags"
      OFF)

    if(ENABLE_GCOV)
      set(CMAKE_CXX_FLAGS                   "${CMAKE_CXX_FLAGS} --coverage")
      set(CMAKE_C_FLAGS                     "${CMAKE_C_FLAGS} --coverage")
    endif()

    ########################################################################################################################################
    # MAKE NECESSARY DEFINES
    ########################################################################################################################################
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11              "enables C++11 features"                                        ON)
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_FUTURE       "enables C++11 regular expression features"                     ON)
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_TYPED_ENUM   "enables C++11 strongly typed enums features"                   ON)
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_DECLTYPE   "enables C++11 decltype features"                                 ON)
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_VARIADIC_TEMPLATE   "enables funtions using C++11 variadic templates"        ON)

    ########################################################################################################################################
    # ADD COMPILER FLAGS
    ########################################################################################################################################
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  else()
    message("NOT GNU_GCC nor MSV compiler!")
    set( CMAKE_CXX_FLAGS            "${CMAKE_CXX_FLAGS} --c++11 -fpermissive")
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11              "enables C++11 features"                       ON)
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_FUTURE       "enables C++11 regular expression features"          ON)
    TESTO_DEFINE(${PROJECT_NAME}  CONF_EN_CXX11_TYPED_ENUM   "enables C++11 strongly typed enums features"        ON)
  endif()

  if(IOS_PLATFORM)
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O1")
  endif()
endmacro(PREPARE_COMPILER)

#-------------------------------------------------------------------------------------------
# REGISTER_LIB macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   register a library
#
# USAGE:
#   lib_name:           Name of the library as defined with cmake command 'add_library'
#   install_folder:     Relative path where the files of the library should be installed
#   folder_name:        value of the FOLDER property to be set onto the library
#                       (use "" to skip inclusion into folder)
#   cache_file:         cache file to which the library should be appended
#   search_header_path: path to search header files
#                       (use "./" to use current directory)
#   vs_filter_path:
#
# Example -> REGISTER_LIB("TiLibAnalyzing" "include/analyzing" "TiLib" "${TILIB_LIBS_CACHE_FILE}" "./")
#
# AUTHOR:
#   scm, vw
#
#-------------------------------------------------------------------------------------------
macro(REGISTER_LIB lib_name install_folder folder_name prop_name search_header_path vs_filter_path generate_map_files)
  if(NOT ${ARGC} EQUAL 7)
    message(FATAL_ERROR "Macro REGISTER_LIB requires 6 arguments but ${ARGC} given.")
  endif()

  # special linker flags for windows
  if(MSVC)
    if(${generate_map_files})
      add_target_properties("${lib_name}" PROPERTIES LINK_FLAGS "/MAP")
    endif()

    if(${CMAKE_SIZEOF_VOID_P} EQUAL 4) # check 32bit compiler
    add_target_properties("${lib_name}" PROPERTIES STATIC_LIBRARY_FLAGS "/MACHINE:X86")
    add_target_properties("${lib_name}" PROPERTIES LINK_FLAGS "/MACHINE:X86")
    elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)  # check 64bit compiler
    add_target_properties("${lib_name}" PROPERTIES STATIC_LIBRARY_FLAGS "/MACHINE:X64")
    add_target_properties("${lib_name}" PROPERTIES LINK_FLAGS "/MACHINE:X64")
  endif()
endif()

# add folder to target properties so that all libraries
# are sorted within the folder "folder_name"
if(NOT "${folder_name}" STREQUAL "")
  set_target_properties( ${lib_name} PROPERTIES FOLDER ${folder_name})
endif()

# filter files according directory structure
if(NOT "${vs_filter_path}" STREQUAL "")
  get_property(source_files TARGET ${lib_name} PROPERTY SOURCES)
  if(source_files)
    printDebugBlock("source files of library ${lib_name}:" ${source_files})
    set(source_files_to_add)
    foreach(source_file ${source_files})
    ##############anj
    get_property(is_generated SOURCE ${source_file} PROPERTY GENERATED)
    if(NOT is_generated)
      get_source_file_property(element_file_full_path ${source_file} LOCATION)
#      MESSAGE( STATUS "element_file_full_path ${PROJECT_NAME}" ${element_file_full_path})
      set_property(GLOBAL APPEND PROPERTY "PROP_LIBRARY_SOURCES" "${element_file_full_path}")
    endif()

    ##############
      get_property(is_generated SOURCE ${source_file} PROPERTY GENERATED)
      if("${is_generated}" STREQUAL "1")
       get_property(depends SOURCE ${source_file} PROPERTY OBJECT_DEPENDS)
       source_group("Generated Files" FILES ${source_file})
       source_group("Generated\\Sources" FILES ${depends})
     else()
       list(APPEND source_files_to_add ${source_file})
     endif()
   endforeach()

   if("${vs_filter_path}" STREQUAL "./")
     createVsFilter("" ${source_files_to_add})
   else()
     createVsFilter("${vs_filter_path}" ${source_files_to_add})
   endif()
 endif()
endif()

# install target for windows
get_property(excluded TARGET ${lib_name} PROPERTY EXCLUDE_FROM_DEFAULT_BUILD)
if(NOT "${excluded}" STREQUAL "1")
  install(TARGETS ${lib_name}
    RUNTIME DESTINATION "bin"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib")

  set(header_files)
  if("${search_header_path}" STREQUAL "")
    get_property(source_files TARGET ${lib_name} PROPERTY SOURCES)
    foreach(source_file ${source_files})
      if( ${source_file} MATCHES "\\.h$") # find all header files
      if( NOT ${source_file} MATCHES "/src/")
        list( APPEND header_files ${source_file} )
      endif()
    endif()
  endforeach()
else()
  file(GLOB_RECURSE header_files "${search_header_path}*.h")
endif()

foreach(_header ${header_files})
  get_filename_component(abs_path ${_header} PATH)
  if( ${abs_path} AND ${abs_path} STREQUAL "${CMAKE_CURRENT_LIST_DIR}/." )
    set(rel_path "")
  else()
    string(REPLACE "${CMAKE_CURRENT_LIST_DIR}/${search_header_path}" "" rel_path "${abs_path}")
  endif()
  install(FILES ${_header} DESTINATION "${install_folder}/${rel_path}")
endforeach(_header)
endif()

set_property(GLOBAL APPEND PROPERTY "${prop_name}" "${lib_name}" )

# set extra module CXX_CMAKE_FLAGS
string(TOUPPER ${prop_name} MODULE_NAME)
set(${MODULE_NAME}_EXTRA_CXX_FLAGS "" CACHE STRING "insert extra flags that will be added to all libraries in ${MODULE_NAME}")
mark_as_advanced(${MODULE_NAME}_EXTRA_CXX_FLAGS )

# set extra module CXX_CMAKE_FLAGS
string(TOUPPER ${lib_name} LIB_NAME)
set(${MODULE_NAME}_${LIB_NAME}_EXTRA_CXX_FLAGS "" CACHE STRING "insert extra flags that will only be applied to ${lib_name}")
mark_as_advanced(${MODULE_NAME}_${LIB_NAME}_EXTRA_CXX_FLAGS)

# add additional target flags
if(NOT "${${MODULE_NAME}_EXTRA_CXX_FLAGS}" STREQUAL "")
  add_target_properties(${lib_name} PROPERTIES COMPILE_FLAGS "${${MODULE_NAME}_EXTRA_CXX_FLAGS}" )
endif()

# add additional target flags
if(NOT "${${MODULE_NAME}_${LIB_NAME}_EXTRA_CXX_FLAGS}" STREQUAL "")
  add_target_properties(${lib_name} PROPERTIES COMPILE_FLAGS "${${MODULE_NAME}_${LIB_NAME}_EXTRA_CXX_FLAGS}" )
endif()
endmacro(REGISTER_LIB)

#-------------------------------------------------------------------------------------------
# REGISTER_LIBRARY macro definition
#-------------------------------------------------------------------------------------------
# DESCRIPTION:
#   register library to TestoLib
#
# USAGE:
#   library_group:   name of the property where library will be added to
#   lib_name:        Name of the library as defined with cmake command 'add_library'
#   install_dir:     directory where installed header files will be located
# GLOBAL IN:
#   TESTOLIB_LIBS_CACHE_FILE:  File name of FW cache file
#
# Example -> REGISTER_LIBRARY("${PROJECT_NAME}")
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
macro(REGISTER_LIBRARY library_group lib_name ide_sort_folder install_dir generate_map_files)
  if(NOT ${ARGC} EQUAL 5)
    message(FATAL_ERROR "Macro REGISTER_LIBRARY requires 1 arguments but ${ARGC} given.")
  endif()

  REGISTER_LIB(${lib_name} ${install_dir} ${ide_sort_folder} "${library_group}" "" "${TESTOLIB_BINARY_DIR}/${TESTOLIB_NAME}/;${TESTOLIB_BINARY_DIR}/core/;${TESTOLIB_BINARY_DIR}/;${TESTOLIB_SOURCE_DIR}/core/;${TESTOLIB_SOURCE_DIR}/" ${generate_map_files})
endmacro(REGISTER_LIBRARY)


macro(REGISTER_QML_EXTENSION_LIBRARY library_group lib_name ide_sort_folder install_dir generate_map_files module_name)
   REGISTER_LIBRARY("${library_group}" "${lib_name}" "${ide_sort_folder}" "${install_dir}" "${generate_map_files}")

   get_target_property(LIB_RELEASE_POSTFIX "${lib_name}" RELEASE_POSTFIX)
   if( NOT LIB_RELEASE_POSTFIX )
    set( LIB_RELEASE_POSTFIX "${CMAKE_RELEASE_POSTFIX}" )
   endif()

  set_target_properties( "${lib_name}" PROPERTIES
                        LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/qml/${module_name}/"
                        DEBUG_POSTFIX "${LIB_RELEASE_POSTFIX}" )
  if(WIN32)
    if(${CMAKE_GENERATOR} MATCHES "Makefiles")
      set(BINARY_DIR_DEBUG   "${PROJECT_BINARY_DIR}/bin")
      set(BINARY_DIR_RELEASE "${PROJECT_BINARY_DIR}/bin")
    else()
      set(BINARY_DIR_DEBUG   "${PROJECT_BINARY_DIR}/bin/Debug")
      set(BINARY_DIR_RELEASE "${PROJECT_BINARY_DIR}/bin/Release")
    endif()

    add_custom_command(TARGET ${lib_name} POST_BUILD
                       COMMAND if exist ${BINARY_DIR_DEBUG}/${lib_name}${LIB_RELEASE_POSTFIX}.dll 
                       ${CMAKE_COMMAND} -E copy ${BINARY_DIR_DEBUG}/${lib_name}${LIB_RELEASE_POSTFIX}.dll ${PROJECT_BINARY_DIR}/qml/${module_name}/${lib_name}${LIB_RELEASE_POSTFIX}.dll 
                       COMMENT "DEBUG: copying ${lib_name}${LIB_RELEASE_POSTFIX}.dll to ${PROJECT_BINARY_DIR}/qml/${module_name}"
                       VERBATIM
                       )   
    add_custom_command(TARGET ${lib_name} POST_BUILD
                       COMMAND if exist ${BINARY_DIR_RELEASE}/${lib_name}${LIB_RELEASE_POSTFIX}.dll 
                       ${CMAKE_COMMAND} -E copy ${BINARY_DIR_RELEASE}/${lib_name}${LIB_RELEASE_POSTFIX}.dll ${PROJECT_BINARY_DIR}/qml/${module_name}/${lib_name}${LIB_RELEASE_POSTFIX}.dll
                       COMMENT "RELEASE: copying ${lib_name}${LIB_RELEASE_POSTFIX}.dll to ${PROJECT_BINARY_DIR}/qml/${module_name}"
                       VERBATIM )   
  endif()

  configure_file(qmldir.in "${PROJECT_BINARY_DIR}/qml/${module_name}/qmldir")
  configure_file(plugin.qmltypes "${PROJECT_BINARY_DIR}/qml/${module_name}/plugin.qmltypes")

endmacro(REGISTER_QML_EXTENSION_LIBRARY)





#-------------------------------------------------------------------------------------------
# APPEND_SUBDIR macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   Append source files defined in paths CMakeLists.txt file (by variable APPEND_SUBDIR_CurrentSourceFilelist)
#   to variable SOURCE_FILELIST. This macro can be used to collect all source files in
#   different subdirectories (hierarchy). It add the corresponding relative path according
#   given subdir. The SOURCE_FILELIST can be used to forward all files to the add_library
#   command.
#
# USAGE:
#   path:               subdirectory path (relative)
#
# TEMPORARY GLOBAL (for internal use only):
#   APPEND_SUBDIR_CurrentRelPath:                  current relative path to be added to each file
#   APPEND_SUBDIR_CurrentSourceFilelist:           current source filelist
#   APPEND_SUBDIR_CurrentRelPathStack:             relative path stack due to cascaded APPEND_SUBDIR calls
#   APPEND_SUBDIR_CurrentSourceFilelistStack:      filelist stack due to cascaded APPEND_SUBDIR calls
#   APPEND_SUBDIR_CurrentSourceFilelistIndexStack: stack index for filelist due to cascaded APPEND_SUBDIR calls
#
# GLOBAL OUT:
#   SOURCE_FILELIST:  output variable will all added source files
#
# EXAMPLE:
#   APPEND_SUBDIR("my_module")
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
macro(APPEND_SUBDIR path)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "Macro APPEND_SUBDIR requires 1 arguments but ${ARGC} given.")
  endif()

  # append current path to stack if defined (otherwise set to "")
  if(APPEND_SUBDIR_CurrentRelPath)
    list(APPEND APPEND_SUBDIR_CurrentRelPathStack "${APPEND_SUBDIR_CurrentRelPath}")
  else()
    set(APPEND_SUBDIR_CurrentRelPath "")
  endif()

  # append current source files already in list to stack (also remember stack position where added)
  list(LENGTH APPEND_SUBDIR_CurrentSourceFilelist length)
  list(APPEND APPEND_SUBDIR_CurrentSourceFilelistIndexStack ${length})
  if(length)
    list(APPEND APPEND_SUBDIR_CurrentSourceFilelistStack ${APPEND_SUBDIR_CurrentSourceFilelist})
  endif()

  # clear current source file list
  set(APPEND_SUBDIR_CurrentSourceFilelist)

  # change current path
  if(APPEND_SUBDIR_CurrentRelPath STREQUAL "")
    set(APPEND_SUBDIR_CurrentRelPath "${path}")
  else()
    set(APPEND_SUBDIR_CurrentRelPath "${APPEND_SUBDIR_CurrentRelPath}/${path}")
  endif()
  #message(STATUS "changed APPEND_SUBDIR_CurrentRelPath = ${APPEND_SUBDIR_CurrentRelPath}")

  # include CMakeLists.txt from that path
  #message(STATUS "call include ${APPEND_SUBDIR_CurrentRelPath}/CMakeLists.txt")
  include("${APPEND_SUBDIR_CurrentRelPath}/CMakeLists.txt")
  #message(STATUS "returned from include ${APPEND_SUBDIR_CurrentRelPath}/CMakeLists.txt")

  # append current source files (appended in included CMakeLists file) to SOURCE_FILELIST (if not already added)
  foreach(element ${APPEND_SUBDIR_CurrentSourceFilelist})
    list(FIND SOURCE_FILELIST "${APPEND_SUBDIR_CurrentRelPath}/${element}" index)
    if(${index} LESS 0)
      list(APPEND SOURCE_FILELIST "${APPEND_SUBDIR_CurrentRelPath}/${element}")
      #message(STATUS "added element: ${APPEND_SUBDIR_CurrentRelPath}/${element}")
    endif()
  endforeach(element)

  # return to previous path by getting it from stack
  list(LENGTH APPEND_SUBDIR_CurrentRelPathStack length)
  if(length)
    list(GET APPEND_SUBDIR_CurrentRelPathStack -1 APPEND_SUBDIR_CurrentRelPath)
    list(REMOVE_AT APPEND_SUBDIR_CurrentRelPathStack -1)
  else()
    set(APPEND_SUBDIR_CurrentRelPath "")
  endif()
  #message(STATUS "changed back APPEND_SUBDIR_CurrentRelPath = ${APPEND_SUBDIR_CurrentRelPath}")

  # get start index of source file list stack in order to return to old filelist
  list(LENGTH APPEND_SUBDIR_CurrentSourceFilelistIndexStack length)
  if(length)
    list(REMOVE_AT APPEND_SUBDIR_CurrentSourceFilelistIndexStack -1)
    if(length GREATER 1)
      list(GET APPEND_SUBDIR_CurrentSourceFilelistIndexStack -1 APPEND_SUBDIR_CurrentSourceFilelistIndex)
    else()
      set(APPEND_SUBDIR_CurrentSourceFilelistIndex 0)
    endif()
  else()
    message(FATAL_ERROR "Macro APPEND_SUBDIR: no APPEND_SUBDIR_CurrentSourceFilelistIndexStack available")
    set(APPEND_SUBDIR_CurrentSourceFilelistIndex 0)
  endif()

  # now return to previous source file list by getting it from stack
  list(LENGTH APPEND_SUBDIR_CurrentSourceFilelistStack length)
  if(length)
    # get all files from stack starting from given index until end of stack
    set(APPEND_SUBDIR_CurrentSourceFilelist)
    while(${APPEND_SUBDIR_CurrentSourceFilelistIndex} LESS ${length})
      list(GET APPEND_SUBDIR_CurrentSourceFilelistStack ${APPEND_SUBDIR_CurrentSourceFilelistIndex} element)
      list(REMOVE_AT APPEND_SUBDIR_CurrentSourceFilelistStack ${APPEND_SUBDIR_CurrentSourceFilelistIndex})
      list(APPEND APPEND_SUBDIR_CurrentSourceFilelist ${element})
      list(LENGTH APPEND_SUBDIR_CurrentSourceFilelistStack length)
    endwhile()
  else()
    # nothing on stack, clear filelist
    set(APPEND_SUBDIR_CurrentSourceFilelist)
  endif()
endmacro(APPEND_SUBDIR)

#-------------------------------------------------------------------------------------------
# PREPARE_OPENMP macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   find OpenMp and do preparation
#
# USAGE:
#   use_openmp:  flag whether OpenMp should be used
#
# EXAMPLE:
#   PREPARE_OPENMP(${USE_OPENMP})
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
macro(PREPARE_OPENMP use_openmp)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "Macro PREPARE_OPENMP requires 1 argument but ${ARGC} given.")
  endif()
  if(${use_openmp})
    message(STATUS "Check for compiler OpenMP support...")
    include(CheckFunctionExists)
    set(OPENMP_FLAG)
    set(OPENMP_FLAG_FOUND FALSE)
    set(
      OPENMP_FLAGS
      "-openmp"   # cl, icc (/ and - works both)
      "/openmp"   # the above shoudl work, too.
      "-fopenmp"  # gcc
      )

    set(OPENMP_FUNCTION omp_set_num_threads)
    foreach(FLAG ${OPENMP_FLAGS})
      if(NOT OPENMP_FLAG_FOUND)
        set(CMAKE_REQUIRED_FLAGS ${FLAG})
        CHECK_FUNCTION_EXISTS(${OPENMP_FUNCTION} OPENMP_FUNCTION_${FLAG}_FOUND)
        if(OPENMP_FUNCTION_${FLAG}_FOUND)
          set(OPENMP_FLAG ${FLAG})
          set(OPENMP_FLAG_FOUND TRUE)
          set(OPENMP_FOUND TRUE)
        endif(OPENMP_FUNCTION_${FLAG}_FOUND)
      endif(NOT OPENMP_FLAG_FOUND)
    endforeach(FLAG)

    if(OPENMP_FOUND)
      if(CMAKE_COMPILER_IS_CLANG)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -openmp")
      else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OPENMP_FLAG}")
      endif()
      message(STATUS "OpenMP supported by compiler.")
    else()
      message(STATUS "OpenMP required but no supporting compiler flags found.")
    endif()
  endif()
endmacro(PREPARE_OPENMP)




#-------------------------------------------------------------------------------------------
# PREPARE_WARNING_AS_ERROR macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   prepare setting to handle compiler warnings as errors
#
# USAGE:
#   warning_as_error:  threat warning as error flag
#
# EXAMPLE:
#   PREPARE_WARNING_AS_ERROR(${WARNING_AS_ERROR})
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
macro(PREPARE_WARNING_AS_ERROR warning_as_error)
  #message(${CMAKE_CXX_FLAGS})
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "Macro PREPARE_WARNING_AS_ERROR requires 1 argument but ${ARGC} given.")
  endif()
  # functionality
  #message(STATUS "Treating warnings as errors. (PREPARE_WARNING_AS_ERROR (fw/TestoLibMacros.cmake))")
  if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
    string(REPLACE "/W3" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
    string(REPLACE "/W2" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
    string(REPLACE "/W1" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
    string(REPLACE "/W0" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
    if(${warning_as_error})
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /WX")
    endif()
  elseif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_CLANG)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wno-unused-parameter -Wno-error=deprecated-declarations -Wno-error=strict-overflow -Wno-unknown-pragmas -Wno-conversion-null -Wno-error=comment")
   if(${warning_as_error})
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
  endif()
endif()
endmacro(PREPARE_WARNING_AS_ERROR)


#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
# REMOVE_FROM_LIST macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   removes list2 from list1
#
# USAGE:
#   result: resulting list
#   list1:  list to remove from
#   list2:  list to be removed
#
# EXAMPLE:
#   REMOVE_FROM_LIST(${list1} "2")
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
macro(REMOVE_FROM_LIST result list1 list2)
  if(NOT ${ARGC} EQUAL 3)
    message(FATAL_ERROR "Macro REMOVE_FROM_LIST requires at 3 arguments but ${ARGC} given.")
  endif()

  # find all elements which are in list1
  set(item_to_remove)
  foreach(element2 ${list2})
    foreach(element1 ${list1})
      if(${element1} STREQUAL ${element2})
        list(APPEND item_to_remove ${element1})
      endif()
    endforeach(element1)
  endforeach(element2)

  # remove found elements from list1
  set(${result} ${list1})
  if(item_to_remove)
    foreach(element ${item_to_remove})
      if(element)
        list(REMOVE_ITEM ${result} ${element})
      endif()
    endforeach(element)
  endif()
endmacro(REMOVE_FROM_LIST)



#-------------------------------------------------------------------------------------------
# ADD_GLOBAL_OPTIONS macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   add global options
#
# USAGE:
#   build_defaults   default for
#                     - BUILD_SHARED_LIBS
#                     - PRJ_BUILD_TESTS
#                     - PRJ_BUILD_TOOLS
#                     - PRJ_BUILD_EXAMPLES
#   use_defaults     default for
#                     - PRJ_USE_OPENMP
#                     - PRJ_USE_QT
#   warning_default  default for
#                     - PRJ_WARNING_AS_ERROR
#
#   varprefix        project name prefix used for variables
#                    ${PROJECT_NAME} (uppercase) is used by default
#
# EXAMPLE:
#   ADD_GLOBAL_OPTIONS()
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
macro(ADD_GLOBAL_OPTIONS build_defaults use_defaults warning_default)
  if(NOT ${ARGC} LESS 5)
    message(FATAL_ERROR "Macro ADD_GLOBAL_OPTIONS requires no or one arguments but ${ARGC} given.")
  endif()

  # variable prefix
  if(${ARGC} EQUAL 4)
    set(varprefix ${ARGN})
  else()
    string(TOUPPER ${PROJECT_NAME} varprefix)
  endif()

  # global options
  #option(BUILD_SHARED_LIBS                "Shared or static linking"                   ${build_defaults} )
  option(ENABLE_CMAKE_DEBUG_OUTPUT        "Enable debug messages within cmake scripts" OFF               )
  option(${varprefix}_BUILD_TESTS         "Build and enable tests"                     ${build_defaults} )
  option(${varprefix}_BUILD_TOOLS         "Build and enable tools"                     ${build_defaults} )
  option(${varprefix}_BUILD_EXAMPLES      "Build and enable tools"                     ${build_defaults} )
  option(${varprefix}_USE_OPENMP          "compile with OpenMP support"                ${use_defaults}   )
  option(${varprefix}_USE_QT              "Use Qt-toolkit"                             ${use_defaults}   )
  option(${varprefix}_WARNING_AS_ERROR    "Treats Warnings as Errors if enabled"       ${warning_default})
endmacro(ADD_GLOBAL_OPTIONS)


#-------------------------------------------------------------------------------------------
# REMOVE_SVN_FILES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   remove files in .svn subdirectory
#
# USAGE:
#   outfile_list:  file list without .svn files
#   infile_list:   file list to check
#
# EXAMPLE:
#   REMOVE_SVN_FILES(filelist ${allfilelist})
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
macro(REMOVE_SVN_FILES outfile_list)
  if(NOT ${ARGC} GREATER 0)
    message(FATAL_ERROR "Macro REMOVE_SVN_FILES requires at least 1 argument but ${ARGC} given.")
  endif()

  # check each given item against .svn
  set(${outfile_list})
  foreach(item ${ARGN})
    if(${item} MATCHES ".*\\.svn")
      #do nothing
    else()
      list(APPEND ${outfile_list} ${item})
    endif()
  endforeach()
endmacro(REMOVE_SVN_FILES)

#-------------------------------------------------------------------------------------------
# REMOVE_NO_CODE_FILES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   remove all files except source/header files (.c/.cpp/.h)
#
# USAGE:
#   outfile_list:  source/header files
#   infile_list:   file list to check
#
# EXAMPLE:
#   REMOVE_NO_CODE_FILES(filelist ${allfilelist})
#
# AUTHOR:
#   sic
#
#-------------------------------------------------------------------------------------------
macro(REMOVE_NO_CODE_FILES outfile_list)
  if(NOT ${ARGC} GREATER 0)
    message(FATAL_ERROR "Macro REMOVE_NO_CODE_FILES requires at least 1 argument but ${ARGC} given.")
  endif()

  # check each given item against .c/.cpp/.h
  set(${outfile_list})
  foreach(item ${ARGN})
    if(${item} MATCHES ".c" OR ${item} MATCHES ".cpp" OR ${item} MATCHES ".h")
      if(${item} MATCHES ".*\\.svn")
        #do nothing
      else()
        list(APPEND ${outfile_list} ${item})
      endif()
    else()
      #do nothing
    endif()
  endforeach()
endmacro(REMOVE_NO_CODE_FILES)


#-------------------------------------------------------------------------------------------
# MOVEFILE_IF_CHANGED macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   move a file if its content differs
#
# USAGE:
#   srcfile:  source file to move
#   destfile: destination file
#
# EXAMPLE:
#   MOVEFILE_IF_CHANGED(srcfile destfile)
#
# AUTHOR:
#   1000len-vw
#
#-------------------------------------------------------------------------------------------
macro(MOVEFILE_IF_CHANGED infile outfile)
  set(copy_it 0)
  if(NOT EXISTS ${outfile})
    set(copy_it 1)
  else()
    # diff it
    file(STRINGS ${outfile} oldreadlines)
    file(STRINGS ${infile}  newreadlines)

    list(LENGTH oldreadlines oldreadlineno)
    list(LENGTH newreadlines newreadlineno)
    if(${oldreadlineno} EQUAL ${newreadlineno})
      foreach(oldline ${oldreadlines})
        list(GET newreadlines 0 newline)
        list(REMOVE_AT newreadlines 0)
        if(NOT "${oldline}" STREQUAL "${newline}")
          set(copy_it 1)
        endif()
      endforeach()
    else()
      set(copy_it 1)
    endif()
  endif()

  if(${copy_it} EQUAL 1)
    #message(STATUS "moving file ${infile} to ${outfile}")
    file(READ   ${infile}    content )
    file(WRITE  ${outfile} ${content})
    file(REMOVE ${infile})
  endif()
endmacro()

#-------------------------------------------------------------------------------------------
# TESTOLIB_CONFIGURE_FILE_PLATFORMSETTINGS_CMAKE macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   generates a platform setting cmake file
#   - all "set(FWCONF_xxx @FWCONF_xxx@)" lines are replaced using cmake variable (only if variable is defined)
#   - all "set(FWMODULE_xxx @FWMODULE_xxx@)" lines are replaced using cmake variable (only if variable is defined)
#   - in all other lines "@xxx@" is replaced using cmake variable
#   - all other lines are unchanged
#
# USAGE:
#   infile:  input file
#   outfile: output file
#
# EXAMPLE:
#   TESTOLIB_CONFIGURE_FILE_PLATFORMSETTINGS_CMAKE("config.cmake.in" "config.cmake")
#
# AUTHOR:
#   1000len-vw
#
#-------------------------------------------------------------------------------------------
macro(TESTOLIB_CONFIGURE_FILE_PLATFORMSETTINGS_CMAKE infile outfile)
  # cannot use normal configure since undefined values have not to be generated
  file(STRINGS ${infile} readlines)

  set(tmpfile "${outfile}.tmp")
  file(WRITE ${tmpfile} "# cache preload file for platform: this file was generated by cmake, do not edit manually\n")
  foreach(line ${readlines})
    #message("line=${line}")
    set(newline "")

    string(REGEX MATCH "^ *set\\(FW(CONF|MODULE)_([A-Z0-9_]+)( +\"?)@FW(CONF|MODULE)_([A-Z0-9_]+)@(\"? *.*)\\) *$" matched ${line})
    #message("matched=${matched}")
    if(NOT "${matched}" STREQUAL "")
      #line matched format: #define CONF_DI_IDMGR_PAGING                 @FWCONF_DI_IDMGR_PAGING@
      #replacement required according FWCONF setting
      set(pre1 ${CMAKE_MATCH_1})
      set(var1 ${CMAKE_MATCH_2})
      set(gap1 ${CMAKE_MATCH_3})
      set(pre2 ${CMAKE_MATCH_4})
      set(var2 ${CMAKE_MATCH_5})
      set(gap2 ${CMAKE_MATCH_6})
      if(DEFINED FW${pre2}_${var2})
        if("${FW${pre2}_${var2}}" STREQUAL "ON" OR "${FW${pre2}_${var2}}" STREQUAL "On")
          set(newline "set(FW${pre1}_${var1}${gap1}${FW${pre2}_${var2}}${gap2})\n")
        elseif("${FW${pre2}_${var2}}" STREQUAL "OFF" OR "${FW${pre2}_${var2}}" STREQUAL "Off")
          set(newline "set(FW${pre1}_${var1}${gap1}${FW${pre2}_${var2}}${gap2})\n")
        else()
          set(newline "set(FW${pre1}_${var1}${gap1}${FW${pre2}_${var2}}${gap2})\n")
        endif()
      else()
        set(newline "#set(FW${pre1}_${var1}${gap1}${FW${pre2}_${var2}}${gap2})\n")
      endif()
    else()
      # any line requiring only @@ replacement
      set(newline "${line}\n")

      set(loop 1)
      while(${loop} EQUAL 1)
        string(REGEX MATCH "^(.*)@([A-Za-z0-9_]+)@(.*)$" matched ${newline})
        if(NOT "${matched}" STREQUAL "")
          set(prefix ${CMAKE_MATCH_1})
          set(var    ${CMAKE_MATCH_2})
          set(suffix ${CMAKE_MATCH_3})
          if(DEFINED ${var})
            set(newline "${prefix}${${var}}${suffix}")
          else()
            set(newline "#${prefix} #${var} undefined# ${suffix}")
          endif()
        else()
          set(loop 0)
        endif()
      endwhile()
    endif()
    file(APPEND ${tmpfile} ${newline})
  endforeach()

  # use new generated tmpfile if different from existing one
  MOVEFILE_IF_CHANGED(${tmpfile} ${outfile})
endmacro()

#-------------------------------------------------------------------------------------------
# MACRO_TEMPLATE macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   generates a config header file
#   - all "#define xxx @FWxxx@" lines are replaced using cmake variable (only if variable is defined)
#   - if variable is not defined line is commented
#   - all other lines are unchanged
#
# USAGE:
#   infile:  input file
#   outfile: output file
#
# EXAMPLE:
#   TESTOLIB_CONFIGURE_FILE_CONFIG_H("TestoLibConfig.h.in" "config.h")
#
# AUTHOR:
#   1000len-vw
#
#-------------------------------------------------------------------------------------------
macro(TESTOLIB_CONFIGURE_FILE_CONFIG_H infile outfile)
  # cannot use normal configure since defines have to be generated without FW prefix
  file(STRINGS ${infile} readlines)

  set(tmpfile  "${outfile}.tmp")
  set(tmpfile1 "${outfile}1.tmp")
  file(WRITE ${tmpfile} "/* defines for testolib: this file was generated by cmake, do not edit manually */\n")
  foreach(line ${readlines})
    #message("line=${line}")
    set(newline "")
    string(REGEX MATCH "^ *#define +([A-Z0-9_]+)( +\"?)@FW([A-Z0-9_]+)@(\"?) *$" matched ${line})
    #message("matched=${matched}")
    if(NOT "${matched}" STREQUAL "")
      #line matched format: #define CONF_DI_IDMGR_PAGING                 @FWCONF_DI_IDMGR_PAGING@
      #replacement required according FWCONF setting
      set(def  ${CMAKE_MATCH_1})
      set(gap  ${CMAKE_MATCH_2})
      set(var  ${CMAKE_MATCH_3})
      set(gap2 ${CMAKE_MATCH_4})
      #message("gap=${gap}")
      #message("var=${var}")
      #message("FW${var}=${FW${var}}")
      if(DEFINED FW${var})
        if("${FW${var}}" STREQUAL "ON" OR "${FW${var}}" STREQUAL "On")
          set(newline "#define ${def}${gap}1${gap2}\n")
        elseif("${FW${var}}" STREQUAL "OFF" OR "${FW${var}}" STREQUAL "Off")
          set(newline "#define ${def}${gap}0${gap2}\n")
        else()
          set(newline "#define ${def}${gap}${FW${var}}${gap2}\n")
        endif()
      else()
        set(newline "/* #define ${def} */\n")
      endif()
    else()
      string(REGEX MATCH "^ *#cmakedefine +([A-Z0-9_]+) *$" matched ${line})
      if(NOT "${matched}" STREQUAL "")
        #line matched format: #cmakedefine BUILD_SHARED_LIBS
        #replacement required according setting
        set(var  ${CMAKE_MATCH_1})
        #message("var=${var}")
        if(DEFINED ${var})
          if("${${var}}" STREQUAL "ON" OR "${${var}}" STREQUAL "On")
            set(newline "#define ${var}\n")
          elseif("${${var}}" STREQUAL "OFF" OR "${${var}}" STREQUAL "Off")
            set(newline "/* #define ${var} */\n")
          else()
            set(newline "#define ${var} ${${var}}\n")
          endif()
        else()
          set(newline "/* #define ${var} */\n")
        endif()
      else()
        # any line requiring no replacement
        set(newline "${line}\n")
      endif()
    endif()
    file(APPEND ${tmpfile} ${newline})
  endforeach()

  # use new generated tmpfile if different from existing one
  configure_file(${tmpfile} ${tmpfile1})
  MOVEFILE_IF_CHANGED(${tmpfile1} ${outfile})
  file(REMOVE ${tmpfile})
endmacro()


#-------------------------------------------------------------------------------------------
# REGISTER_GOOGLETEST macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
# USAGE:
# EXAMPLE:
# AUTHOR:
#-------------------------------------------------------------------------------------------
macro(REGISTER_GOOGLETEST test_group test_main_in exec_name test_source_var install_directory folder_name property_name vs_filter_path enable_test vcx_file_path generate_map_files)
  set(UnitTestMain "${PROJECT_BINARY_DIR}/UnitTests/${exec_name}Main.cpp")
  configure_file( ${PROJECT_SOURCE_DIR}/configure/${test_main_in} ${UnitTestMain})
  add_executable( "${exec_name}" ${UnitTestMain} ${${test_source_var}} ${test_ressources})

  set(test_source_full_path "")
  foreach(item ${${test_source_var}})
   string(FIND ${item} "${CMAKE_CURRENT_LIST_DIR}" posSrc)
   string(FIND ${item} "${${PROJECT_NAME}_BINARY_DIR}" posBin)

   get_source_file_property(is_generated ${item} GENERATED)
   if(${is_generated})
    set_property(GLOBAL APPEND PROPERTY "${test_group}_gen" "${item}" )
  endif()

  if(${posSrc} LESS 0 AND ${posBin} LESS 0 )
    list(APPEND test_source_full_path ${CMAKE_CURRENT_LIST_DIR}/${item})
  else()
    list(APPEND test_source_full_path                           ${item})
  endif()
endforeach()

set_property(GLOBAL APPEND PROPERTY "${test_group}" "${test_source_full_path}" )

REGISTER_EXECUTABLE( ${exec_name} ${install_directory} "${folder_name}" ${property_name} ${vs_filter_path} ${vcx_file_path} ${generate_map_files} )

if(${enable_test})
  add_test(${exec_name} ${exec_name})
endif()
endmacro(REGISTER_GOOGLETEST)

#-------------------------------------------------------------------------------------------
# GET_TEST_TARGETS macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
# USAGE:
# EXAMPLE:
# AUTHOR:
#-------------------------------------------------------------------------------------------
macro(GET_TEST_GROUP_SOURCES test_group targets_out)
  get_property(${targets_out} GLOBAL PROPERTY "${test_group}")
  get_property(src_generated GLOBAL PROPERTY "${test_group}_gen")

  if(src_generated)
    set_source_files_properties(${src_generated}
      PROPERTIES
      GENERATED 1)
  endif()


endmacro(GET_TEST_GROUP_SOURCES)


#-------------------------------------------------------------------------------------------
# REGISTER_EXECUTABLE macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   registers install pathes and folder names for a given executable
#   further it provides a visual studio configuration that sets the path to all external
#   binary dependencies. This way you won't need to add dll's to the environment paths
#   of your system when using a visual studio solution
#
# USAGE:
#   exec_name:          name of the executable
#   install_directory:  folder where it's intall target lies
#   folder_name:        folder name that is used to sort the executable inside the solution
#
# EXAMPLE:
#   REGISTER_GOOGLETEST("TestoLibUnitTests" "UnitTest_TiLibMath" "bin" "TestoLib/UnitTests")
#
# AUTHOR:
#   Matthias Schmieder
#
#-------------------------------------------------------------------------------------------
macro(REGISTER_EXECUTABLE exec_name install_directory folder_name property_name vs_filter_path vcx_file_path generate_map_files)
  set_property(GLOBAL APPEND PROPERTY "${PROJECT}_EXECUTABLES" "${exec_name}" )
  if(MSVC)
    if(NOT ${ARGC} EQUAL 7)
      message(FATAL_ERROR "Macro REGISTER_EXECUTABLE requires 4 arguments but ${ARGC} given.")
    endif()

    # filter files according directory structure
    if(NOT "${vs_filter_path}" STREQUAL "")
      get_property(source_files TARGET ${exec_name} PROPERTY SOURCES)
      if(source_files)
        printDebugBlock("source files of library ${exec_name}:" ${source_files})

        set(source_files_to_add)
        foreach(source_file ${source_files})
          get_property(is_generated SOURCE ${source_file} PROPERTY GENERATED)
          if("${is_generated}" STREQUAL "1")
           get_property(depends SOURCE ${source_file} PROPERTY OBJECT_DEPENDS)
           source_group("Generated" FILES ${source_file})
           source_group("Generated\\Sources" FILES ${depends})
         else()
           list(APPEND source_files_to_add ${source_file})
         endif()
       endforeach()

       if("${vs_filter_path}" STREQUAL "./")
         createVsFilter("" ${source_files_to_add})
       else()
         createVsFilter("${vs_filter_path}" ${source_files_to_add})
       endif()
     endif()
   endif()


   set_target_properties("${exec_name}" PROPERTIES FOLDER "${folder_name}")

   if(${generate_map_files})
     add_target_properties("${exec_name}" PROPERTIES LINK_FLAGS "/MAP")
   endif()

   get_property(PROPERTY_EXTERN_LIB_DIRECTORIES GLOBAL PROPERTY "${property_name}")

   configure_file("${vcx_file_path}" "${CMAKE_CURRENT_BINARY_DIR}/${exec_name}.vcxproj.user")
   endif() # msvc

   if(MOBILE_BUILD)
    set_target_properties(${exec_name}
      PROPERTIES
      EXCLUDE_FROM_ALL 1)
  endif()

  get_target_property(exclude_from_all "${exec_name}" EXCLUDE_FROM_ALL)
  if(NOT exclude_from_all )
    install(TARGETS "${exec_name}" RUNTIME DESTINATION "${install_directory}" )
  endif()


endmacro(REGISTER_EXECUTABLE)

#-------------------------------------------------------------------------------------------
# APPEND_RELATIVE_INCLUDE_DIR_TO_PROPERTY macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   template for macros
#
# USAGE:
#   arg1:  argument 1
#   arg2:  argument 2
#
# EXAMPLE:
#   MACRO_TEMPLATE(arg1 arg2)
#
# AUTHOR:
#   your name
#
#-------------------------------------------------------------------------------------------
macro(APPEND_RELATIVE_INCLUDE_DIR_TO_PROPERTY prop_name rel_dir)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "Macro APPEND_RELATIVE_INCLUDE_DIR_TO_PROPERTY requires 2 arguments but ${ARGC} given.")
  endif()

  set_property(GLOBAL APPEND PROPERTY "${prop_name}" "${rel_dir}" )
endmacro(APPEND_RELATIVE_INCLUDE_DIR_TO_PROPERTY)

#-------------------------------------------------------------------------------------------
# TESTOLIB_OPTION macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   adds an option to your cmake project. This option will be stored in a property so you can
#   iterate over them.
#
# USAGE:
#   var       :  variable
#   descrition:  option description
#   value     :  either TRUE or FALSE
#
#-------------------------------------------------------------------------------------------
macro(TESTO_OPTION GROUP VARIABLE_NAME DESCRIPTION)
  option(${VARIABLE_NAME} ${DESCRIPTION} ON)
  set_property(GLOBAL APPEND PROPERTY "PROP_${GROUP}_OPTIONS" "${VARIABLE_NAME}" )
  set_property(GLOBAL PROPERTY "${VARIABLE_NAME}_DESCRIPION" "${DESCRIPTION}" )
endmacro(TESTO_OPTION)

macro(TESTO_MODULE_OPTION GROUP MODULE VARIABLE_NAME DESCRIPTION)
  option(${VARIABLE_NAME} ${DESCRIPTION} OFF)
  set_property(GLOBAL APPEND PROPERTY "PROP_${GROUP}_${MODULE}_OPTIONS" "${VARIABLE_NAME}" )
  set_property(GLOBAL PROPERTY "${VARIABLE_NAME}_DESCRIPION" "${DESCRIPTION}" )
endmacro(TESTO_MODULE_OPTION)

macro(TESTO_THIRDPARTY_OPTION GROUP VARIABLE_NAME DESCRIPTION VALUE)
  option(${VARIABLE_NAME} ${DESCRIPTION} ${VALUE})
  set_property(GLOBAL APPEND PROPERTY "PROP_${GROUP}_OPTIONS" "${VARIABLE_NAME}" )
  set_property(GLOBAL PROPERTY "${VARIABLE_NAME}_DESCRIPION" "${DESCRIPTION}" )
endmacro(TESTO_THIRDPARTY_OPTION)
#-------------------------------------------------------------------------------------------
# TESTO_DEFINE macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   adds an option that will be put to TestoLibConfig.h
#
# USAGE:
#   var       :  variable
#   descrition:  option description
#   value     :  either TRUE or FALSE
#
#-------------------------------------------------------------------------------------------
macro(TESTO_DEFINE GROUP VAR DESCRIPTION VALUE)
  if ( "${VALUE}" STREQUAL "ON" OR "${VALUE}" STREQUAL "OFF")
    OPTION(${VAR} ${DESCRIPTION} ${VALUE})
  else()
    set(${VAR} ${VALUE} CACHE STRING ${DESCRIPTION})
  endif()

  SET_PROPERTY(GLOBAL APPEND PROPERTY "PROP_${GROUP}_DEFINE" "${VAR}" )
  SET_PROPERTY(GLOBAL PROPERTY "${VAR}_DESCRIPION" "${DESCRIPTION}" )
endmacro(TESTO_DEFINE)

macro(TESTO_MODULE_DEFINE GROUP MODULE VAR DESCRIPTION VALUE)
  set(${VAR} ${VALUE} CACHE STRING ${DESCRIPTION})
  SET_PROPERTY(GLOBAL APPEND PROPERTY "PROP_${GROUP}_${MODULE}_DEFINE" "${VAR}" )
  SET_PROPERTY(GLOBAL PROPERTY "${VAR}_DESCRIPION" "${DESCRIPTION}" )
endmacro(TESTO_MODULE_DEFINE)
#-------------------------------------------------------------------------------------------
# APPEND_GLOBAL_INCLUDE_DIRECTORIES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   adds a global include directory. Only add relative path from ${${PROJECT_NAME}_SOURCE_DIR}
#
# USAGE:
#   var       :  relative path to the include directory
#-------------------------------------------------------------------------------------------
macro(APPEND_GLOBAL_INCLUDE_DIRECTORIES var )
  set_property(GLOBAL APPEND PROPERTY "PROP_TESTOLIB_ADDITIONAL_REL_INCLUDE_PATHES" "${var}" )
endmacro(APPEND_GLOBAL_INCLUDE_DIRECTORIES)

#-------------------------------------------------------------------------------------------
# ADD_GLOBAL_INCLUDE_DIRECTORIES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   includes the directories stored in PROP_TESTOLIB_ADDITIONAL_REL_INCLUDE_PATHES
#-------------------------------------------------------------------------------------------
macro(ADD_GLOBAL_INCLUDE_DIRECTORIES)
  get_property(PROP_ADDITIONAL_INCLUDE_DIRS GLOBAL PROPERTY "PROP_TESTOLIB_ADDITIONAL_REL_INCLUDE_PATHES")
  foreach( path ${PROP_ADDITIONAL_INCLUDE_DIRS})
    include_directories( "${${PROJECT_NAME}_SOURCE_DIR}/${path}" )
  endforeach()
endmacro(ADD_GLOBAL_INCLUDE_DIRECTORIES)

#-------------------------------------------------------------------------------------------
# ADD_GLOBAL_INCLUDE_DIRECTORIES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   includes the directories stored in PROP_TESTOLIB_ADDITIONAL_REL_INCLUDE_PATHES
#-------------------------------------------------------------------------------------------
macro(GET_GLOBAL_INCLUDE_DIRECTORIES dirs)
  get_property(${dirs} GLOBAL PROPERTY "PROP_TESTOLIB_ADDITIONAL_REL_INCLUDE_PATHES")
endmacro(GET_GLOBAL_INCLUDE_DIRECTORIES)


#-------------------------------------------------------------------------------------------
# GET_LIBRARIES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
#-------------------------------------------------------------------------------------------
macro(GET_LIBRARIES library_group libraries_out)
  get_property(${libraries_out} GLOBAL PROPERTY "${library_group}")
endmacro(GET_LIBRARIES)

#-------------------------------------------------------------------------------------------
# GET_TESTOLIB_OPTIONS macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
#-------------------------------------------------------------------------------------------
macro(GET_TESTO_OPTIONS GROUP OPTIONS_OUT)
  get_property(${OPTIONS_OUT} GLOBAL PROPERTY "PROP_${GROUP}_OPTIONS")
endmacro(GET_TESTO_OPTIONS)

macro(GET_TESTO_MODULE_OPTIONS GROUP MODULE OPTIONS_OUT)
  get_property(${OPTIONS_OUT} GLOBAL PROPERTY "PROP_${GROUP}_${MODULE}_OPTIONS")
endmacro(GET_TESTO_MODULE_OPTIONS)

#-------------------------------------------------------------------------------------------
# GET_TESTOLIB_DEFINES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
#-------------------------------------------------------------------------------------------
macro(GET_TESTO_DEFINES GROUP DEFINES_OUT)
  get_property(${DEFINES_OUT} GLOBAL PROPERTY "PROP_${GROUP}_DEFINE")
endmacro(GET_TESTO_DEFINES)

macro(GET_TESTO_MODULE_DEFINES GROUP MODULE DEFINES_OUT)
  get_property(${DEFINES_OUT} GLOBAL PROPERTY "PROP_${GROUP}_${MODULE}_DEFINE")
endmacro(GET_TESTO_MODULE_DEFINES)

#-------------------------------------------------------------------------------------------
# GET_THIRD_PARTY_BIN_DIRS macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
#-------------------------------------------------------------------------------------------
macro(GET_THIRD_PARTY_BIN_DIRS dirs_out)
  get_property(${dirs_out} GLOBAL PROPERTY "PROPERTY_TESTOLIB_THIRD_PARTY_BINARY_DIRECTORIES")
endmacro(GET_THIRD_PARTY_BIN_DIRS)

#-------------------------------------------------------------------------------------------
# GET_TESTOLIB_EXECUTABLES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#
#-------------------------------------------------------------------------------------------
macro(GET_TESTO_EXECUTABLES group execs_out)
  get_property(${execs_out} GLOBAL PROPERTY "${group}_EXECUTABLES")
endmacro(GET_TESTO_EXECUTABLES)

#-------------------------------------------------------------------------------------------
# MAKE_DECLSPEC macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#-------------------------------------------------------------------------------------------
macro(MAKE_DECLSPEC library_group declspec_prefix module_name declspec_txt_var )
  GET_LIBRARIES( ${library_group} libs )
  list(APPEND ${declspec_txt_var} "#if defined (WIN32) && defined(BUILD_SHARED_LIBS) \n")
  foreach(lib ${libs})
    string(FIND ${lib} ${module_name} FOUND_MODULE)
    if(NOT ${FOUND_MODULE} LESS 0)
      if(TESTOLIB_PLATFORM_IDENTIFIER)
        string(REPLACE "_${TESTOLIB_PLATFORM_IDENTIFIER}" ""  module ${lib})
      else()
        set(module ${lib})
      endif()
      string(TOUPPER ${module} MODULE)
      set(${declspec_txt_var} "${${declspec_txt_var}}#  if defined (${lib}_EXPORTS) \n")
      set(${declspec_txt_var} "${${declspec_txt_var}}#   define ${declspec_prefix}${MODULE}_DECL __declspec(dllexport) \n")
      set(${declspec_txt_var} "${${declspec_txt_var}}#  endif \n")
      set(${declspec_txt_var} "${${declspec_txt_var}}#  if !defined (${declspec_prefix}${MODULE}_DECL) \n")
      set(${declspec_txt_var} "${${declspec_txt_var}}#   define ${declspec_prefix}${MODULE}_DECL __declspec(dllimport) \n")
      set(${declspec_txt_var} "${${declspec_txt_var}}#  endif \n")
    endif()
  endforeach()
  set(${declspec_txt_var} "${${declspec_txt_var}}#else \n")
  foreach( lib ${libs})
    string(FIND ${lib} ${module_name} FOUND_MODULE)
    #    if(NOT ${FOUND_MODULE} LESS 0)
    if(TESTOLIB_PLATFORM_IDENTIFIER)
      string(REPLACE "_${TESTOLIB_PLATFORM_IDENTIFIER}" "" module ${lib})
    else()
      set(module ${lib})
    endif()
    string(TOUPPER ${module} MODULE)
    set(${declspec_txt_var} "${${declspec_txt_var}}# define ${declspec_prefix}${MODULE}_DECL \n")
    #    endif()
  endforeach()
  set(${declspec_txt_var} "${${declspec_txt_var}}#endif \n")
endmacro(MAKE_DECLSPEC)

#-------------------------------------------------------------------------------------------
# STRIP_BUILD_TYPE_INDENTIFIERS macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   template for macros
#
# USAGE:
#   arg1:  argument 1
#   arg2:  argument 2
#
# EXAMPLE:
#   MACRO_TEMPLATE(arg1 arg2)
#
# AUTHOR:
#   your name
#
#-------------------------------------------------------------------------------------------
macro(STRIP_BUILD_TYPE_INDENTIFIERS list_in list_out)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "Macro STRIP_BUILD_TYPE_INDENTIFIERS requires 2 arguments but ${ARGC} given.")
  endif()

  foreach(lib ${${list_in}})
    if( NOT "optimized" STREQUAL ${lib} AND NOT  "debug" STREQUAL ${lib} )
      list(APPEND ${list_out} ${lib} )
    endif()
  endforeach()

  # your functionality
endmacro(STRIP_BUILD_TYPE_INDENTIFIERS)

#-------------------------------------------------------------------------------------------
# GLOB_ADDITIONAL_UI_FILES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   globs all files that follow the "patterns" defined by the user
#
# USAGE:
#   VAR:       return value (variable)
#   DIR:       directory to start search in
#   PATTERNS:  globbing patterns to look foreach(VAR items)
#
#
# EXAMPLE:
#   GLOB_ADDITIONAL_UI_FILES( CORE_QT_FILES "core" "*.qml;*.js")
#
# AUTHOR:
#   scm, dli
#
#-------------------------------------------------------------------------------------------
macro(GLOB_ADDITIONAL_UI_FILES VAR DIR PATTERNS)
  foreach(pattern ${PATTERNS})
    file(GLOB result "${DIR}/${pattern}")
    list(APPEND ${VAR} ${result})
  endforeach()
endmacro(GLOB_ADDITIONAL_UI_FILES)

#-------------------------------------------------------------------------------------------
# GLOB_RECURSE_ADDITIONAL_UI_FILES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   globs all files (recursive) that follow the "patterns" defined by the user
#
# USAGE:
#   VAR:       return value (variable)
#   DIR:       directory to start search in
#   PATTERNS:  globbing patterns to look foreach(VAR items)
#
#
# EXAMPLE:
#   GLOB_RECURSE_ADDITIONAL_UI_FILES( CORE_QT_FILES "core" "*.qml;*.js")
#
# AUTHOR:
#   scm, dli
#
#-------------------------------------------------------------------------------------------
macro(GLOB_RECURSE_ADDITIONAL_UI_FILES VAR DIR PATTERNS)
  foreach(pattern ${PATTERNS})
    file(GLOB_RECURSE result "${DIR}/${pattern}")
    list(APPEND ${VAR} ${result})
  endforeach()
endmacro(GLOB_RECURSE_ADDITIONAL_UI_FILES)

#-------------------------------------------------------------------------------------------
# LOAD_THIRDPARTY_LIBRARIES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   loads all libraries that are defined by each entry 'module' in 'var_search_modules' by calling f
#   find_package( ${${module}_FIND_PACKAGE_NAME} ) adding the libraries to 'var_lib_out' as
#   well as the binary directories as 'var_bin_dirs_out'
#
# AUTHOR:
#   scm
#
#-------------------------------------------------------------------------------------------
macro(LOAD_THIRDPARTY_LIBRARIES var_search_modules var_lib_out var_bin_dirs_out)
  foreach(module ${${var_search_modules}})
    if( USE_${module} )
      find_package( "${${module}_FIND_PACKAGE_NAME}" REQUIRED )

      # BINARY DIRECTORIES
      if(DEFINED "${module}_BINARY_DIR")
       list(APPEND ${var_bin_dirs_out} "${${module}_BINARY_DIR}" )
     elseif(DEFINED "${module}_BIN_DIR")
       list(APPEND ${var_bin_dirs_out} "${${module}_BIN_DIR}" )
     else()
     endif()

     if(DEFINED "${module}_LIBRARY_DIR")
       list(APPEND ${var_bin_dirs_out} "${${module}_LIBRARY_DIR}" )
     elseif(DEFINED "${module}_LIBRARY_DIRECTORY")
       list(APPEND ${var_bin_dirs_out} "${${module}_LIBRARY_DIRECTORY}" )
     elseif(DEFINED "${module}_LIB_DIR")
       list(APPEND ${var_bin_dirs_out} "${${module}_LIB_DIR}" )
     else()
     endif()

     # LINK LIBRARIES
     if(DEFINED "${module}_LIBRARIES")
      #message( "${module}: ${module}_LIBRARIES" )
      set(_libs         ${${module}_LIBRARIES})
      set(_libs_DEBUG   ${${module}_LIBRARIES_DEBUG})
      set(_libs_RELEASE ${${module}_LIBRARIES_RELEASE})
    elseif(DEFINED "${module}_LIBS")
      #message( "${module}: ${module}_LIBS" )
      set(_libs         ${${module}_LIBS})
      set(_libs_DEBUG   ${${module}_LIBRARIES_DEBUG})
      set(_libs_RELEASE ${${module}_LIBRARIES_RELEASE})
    endif()

    if(DEFINED "${module}_INCLUDE_DIR}")
      include_directories(BEFORE ${${module}_INCLUDE_DIR})
    endif()

    set(${module}_USE_RELEASE_ONLY OFF CACHE BOOL "enable this to link only against release libs, even in debug mode")
    mark_as_advanced(${module}_USE_RELEASE_ONLY)
    if(${module}_USE_RELEASE_ONLY)
     set(_libs_name)
     STRIP_BUILD_TYPE_INDENTIFIERS(_libs_RELEASE _libs_name)
     list(APPEND ${var_lib_out} ${_libs_name})
   else()
     list(APPEND ${var_lib_out} ${_libs})
   endif()
 endif()
endforeach()

endmacro(LOAD_THIRDPARTY_LIBRARIES)

#-------------------------------------------------------------------------------------------
# GET_LIBRARY_MODULE macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   This macro returns all the module names added to the specific project
#
# AUTHOR:
#   scm/sma
#
#-------------------------------------------------------------------------------------------
macro(GET_LIBRARY_MODULES PROJECTNAME VAR_MODULES)
  get_property(${VAR_MODULES} GLOBAL PROPERTY "PROP_${PROJECTNAME}_LIBRARY_MODULES")
endmacro(GET_LIBRARY_MODULES)

#-------------------------------------------------------------------------------------------
# ADD_TESTO_MODULE macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   This macro adds a subdirectory that holds a new library part. It will create
#   a ModuleConfig.h containing all declspecs as well as the defines associated with
#   the module
#
# AUTHOR:
#   scm
#
#-------------------------------------------------------------------------------------------
macro(ADD_LIBRARY_MODULE MODULE_NAME)
  string(TOUPPER ${MODULE_NAME} MODULE_NAME_UPPER_CASE)
  string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER_CASE)

  set_property(GLOBAL APPEND PROPERTY "PROP_${PROJECT_NAME}_LIBRARY_MODULES" "${MODULE_NAME}" )

  # add the directory
  add_subdirectory(${MODULE_NAME})

  # convert first letter to upper case
  string(SUBSTRING ${MODULE_NAME} 0 1 FIRST_LETTER)
  string(TOUPPER ${FIRST_LETTER} FIRST_LETTER)
  string(REGEX REPLACE "^.(.*)" "${FIRST_LETTER}\\1" MODULE_NAME_STR "${MODULE_NAME}")

  # convert first letter to upper case
  string(SUBSTRING ${PROJECT_NAME} 0 1 FIRST_LETTER)
  string(TOUPPER ${FIRST_LETTER} FIRST_LETTER)
  string(REGEX REPLACE "^.(.*)" "${FIRST_LETTER}\\1" PROJECT_NAME_STR "${PROJECT_NAME}")

  MAKE_DECLSPEC("${PROJECT_NAME}" "${PROJECT_NAME_UPPER_CASE}_" ${MODULE_NAME} ${MODULE_NAME_UPPER_CASE}_DECL)

  GET_TESTO_MODULE_OPTIONS( ${PROJECT_NAME} ${MODULE_NAME} OPTS )
  foreach(opt ${OPTS})
    set(${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES "${${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES}#cmakedefine ${opt} \n")
  endforeach()

  GET_TESTO_MODULE_DEFINES( ${PROJECT_NAME} ${MODULE_NAME} DEFS )
  foreach( def ${DEFS} )
    set(${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES "${${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES}#ifndef ${def}\n")
    if ( "${${def}}" STREQUAL "ON" OR "${${def}}" STREQUAL "OFF")
      set(${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES "${${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES}#cmakedefine ${def}\n")
    elseif( "${${def}}" MATCHES "^[0-9]+$" )
      set(${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES "${${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES}#define ${def} ${${def}}\n")
    else()
      set(${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES "${${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES}# define ${def} \"${${def}}\"\n")
    endif()
    set(${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES "${${MODULE_NAME_UPPER_CASE}_CMAKE_DEFINES}#endif //${def}\n")
  endforeach()


  configure_file("${${PROJECT_NAME}_SOURCE_DIR}/configure/${PROJECT_NAME_STR}ModuleConfig.h.in" "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}/${MODULE_NAME}/${MODULE_NAME_STR}Config.h.in1" @ONLY)
  configure_file("${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}/${MODULE_NAME}/${MODULE_NAME_STR}Config.h.in1"        "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}/${MODULE_NAME}/${MODULE_NAME_STR}Config.h.in2")
  configure_file("${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}/${MODULE_NAME}/${MODULE_NAME_STR}Config.h.in2"        "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}/${MODULE_NAME}/${MODULE_NAME_STR}Config.h")

  install(FILES "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}/${MODULE_NAME}/${MODULE_NAME_STR}Config.h"
   DESTINATION "include/${PROJECT_NAME}/${MODULE_NAME}")

endmacro(ADD_LIBRARY_MODULE)


#-------------------------------------------------------------------------------------------
# list_subdirectories macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   returns a list of all subdirectories in the current folder
#
# EXAMPLE:
#   SUBDIRLIST(SUBDIRS ${MY_CURRENT_DIR})
#
# AUTHOR:
#   Matthias Schmieder
#
#-------------------------------------------------------------------------------------------
macro(list_subdirectories retval curdir)
  set(list_of_dirs "")
  file(GLOB_RECURSE sub-dir "${curdir}/*")
  foreach(dir ${sub-dir})
    get_filename_component(res "${dir}" DIRECTORY)
    if(IS_DIRECTORY ${res})
      list(APPEND list_of_dirs ${res})
    endif()
  endforeach()

  set(tmplist "")
  list(REMOVE_DUPLICATES list_of_dirs)
  foreach(dir ${list_of_dirs})
    string(REPLACE "${curdir}" "" reldir ${dir})
    list(APPEND tmplist ${reldir})
  endforeach()
  set(${retval} ${tmplist})
endmacro(list_subdirectories)

macro(parent_group retval group_name)
  string(FIND ${group_name} "_" POSITION REVERSE)
  if(POSITION GREATER 0)
    string(SUBSTRING ${group_name} 0 ${POSITION} ${retval})
  endif()
endmacro(parent_group)

#-------------------------------------------------------------------------------------------
# CONFIGURE_DOCUMENTATION macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   template for macros
#
# USAGE:
#   arg1:  argument 1
#   arg2:  argument 2
#
# EXAMPLE:
#   MACRO_TEMPLATE(arg1 arg2)
#
# AUTHOR:
#   your name
#
#-------------------------------------------------------------------------------------------
macro(CONFIGURE_DOCUMENTATION)
  find_package(Doxygen REQUIRED)
  TESTO_OPTION( ${PROJECT_NAME}  DOXYGEN_USE_MATHJAX
   "enables forumla generetion via Mathjax"
   ON)
  if(DOXYGEN_USE_MATHJAX)
    set(DOXYGEN_USE_MATHJAX_TXT "YES")
  endif()

  TESTO_OPTION( ${PROJECT_NAME}  DOXYGEN_WARNING_LOG
   "The WARN_LOGFILE tag can be used to specify if warnings and error messages should be written to a file. If left blank the output is written to stderr. If enabled they will be stored by default in ${${PROJECT_NAME}_BINARY_DIR}/doxyerror.txt"
   OFF)

  TESTO_OPTION( ${PROJECT_NAME}  DOXYGEN_USE_DOXYQML
    "enables generation of doxygen code for *.qml files"
    OFF)

  if(DOXYGEN_USE_DOXYQML)
    if(WIN32)
     find_package(PythonInterp REQUIRED)
     set(DOXYGE_QML_FILTER_PATTERN "*.qml=${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/doxyqml.bat")
     configure_file( docs/doxygen/doxyqml.bat.in "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/doxyqml.bat")
   elseif(UNIX)
     set(DOXYGE_QML_FILTER_PATTERN "*.qml=doxyqml")
   else()
     message(WARNING "System not supported by doxyqml")
   endif()
 endif()

 if(DOXYGEN_WARN_LOGFILE)
  set(DOXYGEN_WARN_LOGFILE_PATH "${${PROJECT_NAME}_BINARY_DIR}/${PROJECT_NAME}/doxyerror.txt" CACHE FILEPATH  "The WARN_LOGFILE tag can be used to specify if warnings and error messages should be written to a file")
endif()

if(DOXYGEN_DOT_FOUND)
  TESTO_OPTION( ${PROJECT_NAME}  DOXYGEN_USE_GRAPHVIZ "enable drawing of class diagrams" )
  TESTO_OPTION( ${PROJECT_NAME}  DOXYGEN_USE_INTERACTIVE_SVG "enable interactive svg graphics for all graphviz generated graphes. Depends on 'DOXYGEN_USE_GRAPHVIZ'" )
  if(DOXYGEN_USE_GRAPHVIZ)
    set(DOXYGEN_USE_DOT_TXT "YES")
  endif()
  if( DOXYGEN_USE_INTERACTIVE_SVG )
    set(DOXYGEN_INTERACTIVE_SVG "YES")
    set(DOXYGEN_DOT_IMAGE_FORMAT "svg")
  else()
    set(DOXYGEN_INTERACTIVE_SVG "NO")
    set(DOXYGEN_DOT_IMAGE_FORMAT "png")
  endif()
  TESTO_OPTION( ${PROJECT_NAME}  DOXYGEN_USE_LATEX "enable latex pdf creation and formulas" )
  if(DOXYGEN_USE_LATEX)
    find_package(LATEX)
    if(LATEX_FOUND)
      set(DOXYGEN_USE_LATEX_TXT "YES")
    endif()
  endif()
else()
  set(DOXYGEN_DOT_FOUND_ "NO")
  message("Could not find dot doxygen programm.")
endif()

#GLOB FOR DOX FILES
set(DOXGEN_GROUP_DEFINITIONS "")
foreach(module ${ARGN})
  file(GLOB_RECURSE dox_module_files "${module}/*.dox"  )
  list(APPEND DOX_MODULES_FILES ${dox_module_files})

  set(ADDITIONAL_DOXYGEN_FILES "\"${${PROJECT_NAME}_SOURCE_DIR}/${module}\" \\\n${ADDITIONAL_DOXYGEN_FILES}")

  list_subdirectories(SUBDIRS "${CMAKE_CURRENT_LIST_DIR}/${module}" 0)

  get_filename_component(module_name "${module}" NAME_WE)
  if(NOT module_name)
    set(module_name ${module})
  endif()

  set(DOXGEN_GROUP_DEFINITIONS "${DOXGEN_GROUP_DEFINITIONS}@defgroup module_${module_name} ${module_name}\n")

  foreach(item ${SUBDIRS})
    string(REPLACE "/" "_" sub_module_group  "_${module_name}${item}")
    string(REPLACE "\\" "_" sub_module_group ${sub_module_group})
    get_filename_component(sub_module_name "${item}" NAME_WE)
    # define group
    set(DOXGEN_GROUP_DEFINITIONS "${DOXGEN_GROUP_DEFINITIONS}@defgroup module${sub_module_group} ${sub_module_name}\n")
    # check if there is a parent group
    parent_group(parent_group_name ${sub_module_group})
    if(parent_group_name)
      set(DOXGEN_GROUP_DEFINITIONS "${DOXGEN_GROUP_DEFINITIONS}@ingroup module${parent_group_name}\n\n")
    endif()
  endforeach()
  set(DOXGEN_GROUP_DEFINITIONS "${DOXGEN_GROUP_DEFINITIONS}\n")
endforeach()

file(GLOB_RECURSE DOX_EXAMPLES         "examples/*.dox" )
file(GLOB_RECURSE DOX_DOC_FILES        "docs/doxygen/*.dox")
file(GLOB_RECURSE DOX_DOC_IN_FILES     "docs/doxygen/*.dox.in")
set(DOX_FILES ${DOX_TEST_FILES} ${DOX_core_FILES} ${DOX_DOC_FILES})

#GLOB ALL DIRECTORIES THAT SHOULD BE USED TO SEARCH FOR SNIPPETS. SEE @Doxygen EXAMPLE_PATH
FILE(GLOB_RECURSE TEST_DIRS    "testolib/core/*/tests/*.*")
FILE(GLOB_RECURSE EXAMPLE_DIRS "examples/*.*")
set( example_paths ${TEST_DIRS} ${EXAMPLE_DIRS} )
foreach( path ${example_paths} )
  get_filename_component(PNAME ${path} PATH)
  list(APPEND list_of_paths ${PNAME})
endforeach()
list(REMOVE_DUPLICATES list_of_paths)
foreach( path ${list_of_paths} )
  set(DOXYGEN_EXAMPLE_PATH "${DOXYGEN_EXAMPLE_PATH}\"${path}\" \\\n")
endforeach()

foreach( dox ${DOX_FILES} )
  get_filename_component(FNAME ${dox} NAME_WE)
  get_filename_component(PNAME ${dox} PATH)
  string(REPLACE "\\" "/" PNAME "${PNAME}")
  set(ADDITIONAL_DOXYGEN_FILES "\"${PNAME}\" \\ \n${ADDITIONAL_DOXYGEN_FILES}")

  # get tests documentations
  if( ${PNAME} MATCHES "tests/docs" )
    list(APPEND DOX_TEST_FILES ${dox})
  endif()
endforeach()

foreach( dox ${DOX_core_FILES} )
  get_filename_component(FNAME ${dox} NAME_WE)
  get_filename_component(PNAME ${dox} PATH)

  if( ${PNAME} MATCHES "tests/docs" )
  else()
    list(APPEND DOX_ADDITIONAL_FILES ${dox})
  endif()
endforeach()

foreach( dox ${DOX_TEST_FILES} )
  get_filename_component(FNAME ${dox} NAME_WE)
  set(DOXYGEN_LIST_OF_UNITTESTS_SUBPAGES "\\subpage ${FNAME} \\n \n${DOXYGEN_LIST_OF_UNITTESTS_SUBPAGES}")
endforeach()

foreach( dox ${DOX_EXAMPLES} )
  #message(${dox})
  get_filename_component(FNAME ${dox} NAME_WE)
  set(DOXYGEN_LIST_OF_EXAMPLE_SUBPAGES "\\subpage ${FNAME} \\n \n${DOXYGEN_LIST_OF_EXAMPLE_SUBPAGES}")
endforeach()

foreach( dox ${DOX_ADDITIONAL_FILES} )
  get_filename_component(FNAME ${dox} NAME_WE)
  set(DOXYGEN_LIST_OF_ADDITIONAL_SUBPAGES "\\subpage ${FNAME} \\n \n${DOXYGEN_LIST_OF_ADDITIONAL_SUBPAGES}")
endforeach()

# get all options
GET_TESTO_OPTIONS(${PROJECT_NAME} _opts)
foreach(opt ${_opts})
  get_property(DESCR GLOBAL PROPERTY "${opt}_DESCRIPION")
  set(DOXYGEN_BUILD_OPTIONS "${DOXYGEN_BUILD_OPTIONS}- <b>${opt}</b> \\n ${DESCR} \n")
endforeach()

GET_TESTO_DEFINES(${PROJECT_NAME} _defines)
foreach( define ${_defines} )
  get_property(DESCR GLOBAL PROPERTY "${define}_DESCRIPION")
  set(DOXYGEN_CMAKE_DEFINES "${DOXYGEN_CMAKE_DEFINES}- <b>${define}</b> \\n ${DESCR} \n")
endforeach()

option(INSTALL_DOCS "installs docs when " ON)
configure_file("${${PROJECT_NAME}_SOURCE_DIR}/docs/doxygen/DoxygenConfig.dox.in"       "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/DoxygenConfig.dox"            )
configure_file("${${PROJECT_NAME}_SOURCE_DIR}/docs/doxygen/DoxyMainPage.txt.in"        "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/DoxyMainPage.txt"             )
configure_file("${${PROJECT_NAME}_SOURCE_DIR}/docs/doxygen/AdditionalDocuments.dox.in" "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/AdditionalDocuments.dox" @ONLY)
configure_file("${${PROJECT_NAME}_SOURCE_DIR}/docs/doxygen/UnitTests.dox.in"           "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/UnitTests.dox"           @ONLY)
configure_file("${${PROJECT_NAME}_SOURCE_DIR}/docs/doxygen/Examples.dox.in"            "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/Examples.dox"            @ONLY)
configure_file("${${PROJECT_NAME}_SOURCE_DIR}/docs/doxygen/Configuration.dox.in"       "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/Configuration.dox"       @ONLY)
configure_file("${${PROJECT_NAME}_SOURCE_DIR}/docs/doxygen/make_doc.sh.in"             "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/make_doc.sh"                          )

separate_arguments(GFX_EXPORT_PARAMETERS_LIST WINDOWS_COMMAND "${GFX_EXPORT_PARAMETERS}")

string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UC)

add_custom_target(${PROJECT_NAME_UC}_BUILD_DOC
  SOURCES ${DOX_TEST_FILES} ${DOX_DOC_IN_FILES} ${DOX_SRC_FILES})

add_custom_command(TARGET ${PROJECT_NAME_UC}_BUILD_DOC
 COMMAND ${DOXYGEN_EXECUTABLE} ${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/doxygen/DoxygenConfig.dox
 COMMENT "builds doxygen documentation,")

if(DOXYGEN_USE_LATEX AND LATEX_FOUND)
  add_custom_command(TARGET ${PROJECT_NAME_UC}_BUILD_DOC
   COMMAND make
   WORKING_DIRECTORY ${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/latex
   COMMENT "builds latex documentation,")
endif()

set_target_properties( ${PROJECT_NAME_UC}_BUILD_DOC PROPERTIES FOLDER Documentation/${PROJECT_NAME})
get_property(dox_files TARGET ${PROJECT_NAME_UC}_BUILD_DOC PROPERTY SOURCES)

if(dox_files)
 foreach(dox_file ${dox_files})
   get_property(is_generated SOURCE ${dox_file} PROPERTY GENERATED)
   if("${is_generated}" STREQUAL "1")
     get_property(depends SOURCE ${dox_file} PROPERTY OBJECT_DEPENDS)
     source_group("Generated" FILES ${dox_file})
     source_group("Generated\\Sources" FILES ${depends})
   else()
     set(dox_files_to_add ${dox_files_to_add} ${dox_file})
   endif()
 endforeach()
 createVsFilter("${${PROJECT_NAME}_SOURCE_DIR};${${PROJECT_NAME}_BINARY_DIR}" ${dox_files_to_add})
endif()

if(INSTALL_DOCS)
  install(DIRECTORY "${${PROJECT_NAME}_BINARY_DIR}/doc/${PROJECT_NAME}/HTML"
    DESTINATION "docs") # directly into the CMAKE_INSTALL_PREFIX
endif()

# your functionality
endmacro(CONFIGURE_DOCUMENTATION)

#-------------------------------------------------------------------------------------------
# ADD_IOS_LIBRARIES macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   add ios libraries for mobile build
#
# USAGE:
#   IOS_MODULE_NAME:  Module name of application
#
# EXAMPLE:
#   ADD_IOS_LIBRARIES(t3xxapp)
#
# AUTHOR:
#   dli
#
#-------------------------------------------------------------------------------------------
macro(ADD_IOS_LIBRARIES var_lib_out)
  message("+------- IOS libraries ---------------------------------------------------------")
  message("| CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT} ")
  message("+-------------------------------------------------------------------------------")

  include_directories(${CMAKE_OSX_SYSROOT})

  find_library(ADDRESS_BOOK_UI AddressBookUI)

  if( NOT ADDRESS_BOOK_UI )
    message(FATAL_ERROR "AddressBookUI not found")
  endif()

  find_library(ADDRESS_BOOK AddressBook)

  if( NOT ADDRESS_BOOK )
    message(FATAL_ERROR "AddressBook not found")
  endif()

  find_library(CORE_FOUNDATION CoreFoundation)

  if( NOT CORE_FOUNDATION )
    message(FATAL_ERROR "CoreFoundation not found")
  endif()

  find_library(CORE_GRAPHICS CoreGraphics)

  if( NOT CORE_GRAPHICS )
    message(FATAL_ERROR "CoreGraphics not found")
  endif()

  find_library(CORE_BLUETOOTH CoreBluetooth)

  if( NOT CORE_BLUETOOTH )
    message(FATAL_ERROR "CoreBluetooth not found")
  endif()

  find_library(CORE_TEXT CoreText)

  if( NOT CORE_TEXT )
    message(FATAL_ERROR "CoreText not found")
  endif()

  find_library(CORE_DATA CoreData)

  if( NOT CORE_DATA )
    message(FATAL_ERROR "CoreData not found")
  endif()

  find_library(FOUNDATION Foundation)

  if( NOT FOUNDATION )
    message(FATAL_ERROR "Foundation not found")
  endif()

  find_library(UIKIT UIKit)

  if( NOT UIKIT )
    message(FATAL_ERROR "UIKit not found")
  endif()

  find_library(MESSAGEUI MessageUI)

  if( NOT MESSAGEUI )
    message(FATAL_ERROR "MessageUI not found")
  endif()

  find_library(SECURITY Security)

  if( NOT SECURITY )
    message(FATAL_ERROR "Security not found")
  endif()

  find_library(ZLIB z)

  if( NOT ZLIB )
    message(FATAL_ERROR "zlib not found")
  endif()

  find_library(OPENGLES OpenGLES)

  if( NOT OPENGLES )
    message(FATAL_ERROR "OpenGLES not found")
  endif()

  message("| AddressBookUI: ${ADDRESS_BOOK_UI}")
  message("| AddressBook: ${ADDRESS_BOOK}")
  message("| CoreFoundation: ${CORE_FOUNDATION}")
  message("| CoreBluetooth: ${CORE_BLUETOOTH}")
  message("| CoreText: ${CORE_TEXT}")
  message("| CoreData: ${CORE_DATA}")
  message("| Foundation: ${FOUNDATION}")
  message("| UIKit: ${UIKIT}")
  message("| MessageUI: ${MESSAGEUI}")
  message("| Security: ${SECURITY}")
  message("| OpenGLES: ${OPENGLES}")
  message("| ZLib: ${ZLIB}")
  message("+-------------------------------------------------------------------------------")

  list(APPEND ${var_lib_out}
               ${ADDRESS_BOOK_UI}
               ${ADDRESS_BOOK}
               ${CORE_FOUNDATION}
               ${CORE_GRAPHICS}
               ${CORE_BLUETOOTH}
               ${CORE_TEXT}
               ${CORE_DATA}
               ${FOUNDATION}
               ${UIKIT}
               ${MESSAGEUI}
               ${SECURITY}
               ${OPENGLES}
               ${ZLIB}
               )

endmacro(ADD_IOS_LIBRARIES)

#-------------------------------------------------------------------------------------------
# READ_LIBRARY_VERSION macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   reads the library version from a file. The function will parse only lines that do
#   not start with '#''
#
# USAGE:
#   VAR_VERSION_MAJOR:  will hold major version
#   VAR_VERSION_MINOR:  will hold minor version
#   VAR_VERSION_PATCH:  will hold patch version
#   VERSION_FILE_PATH:  path to the version file
# EXAMPLE:
#   MACRO_TEMPLATE(arg1 arg2)
#
# AUTHOR:
#   your name
#
#-------------------------------------------------------------------------------------------
macro(READ_LIBRARY_VERSION VAR_VERSION_MAJOR VAR_VERSION_MINOR VAR_VERSION_PATCH VERSION_FILE_PATH)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "Macro READ_LIBRARY_VERSION requires 2 arguments but ${ARGC} given.")
  endif()

  FILE(READ "${VERSION_FILE_PATH}" file_content)

  # Convert file contents into a CMake list (where each element in the list
    # is one line of the file)
STRING(REGEX REPLACE ";" "\\\\;" file_content "${file_content}")
STRING(REGEX REPLACE "\n" ";" file_content "${file_content}")

foreach(line ${file_content})
  # skipt lines that start with
  string(FIND ${line} "#" POSITION)
  if( NOT ${POSITION} EQUAL 0 )
    string(REGEX MATCHALL "[0-9]+" VERSION_COMPONENTS ${line})
    list(GET VERSION_COMPONENTS 0 ${VAR_VERSION_MAJOR})
    list(GET VERSION_COMPONENTS 1 ${VAR_VERSION_MINOR})
    list(GET VERSION_COMPONENTS 2 ${VAR_VERSION_PATCH})
    break()
  endif()
endforeach()


# your functionality
endmacro(READ_LIBRARY_VERSION)

#-------------------------------------------------------------------------------------------
# add_deployment_file macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   add_qtcreator_deployment_file: Adds a file to the QtCreatorDeployment.txt and tells QtCreator so, where to remotely deploy thirdparties.
#
# USAGE:
#   arg1: SRC: Source file to be added in QtCreatorDeployment.txt
#   arg2: DEST: Destination file to be added in QtCreatorDeployment.txt
#
# EXAMPLE:
#   foreach(dir ${THIRD_PARTY_BINARY_DIRS})
#    add_qtcreator_deployment_file( ${dir} ${CMAKE_SYSROOT}/lib)
#   endforeach()
#
# AUTHOR:
#   1000len-dim
#
#-------------------------------------------------------------------------------------------
macro(add_qtcreator_deployment_file WORKDIR_DIR SRC DEST)
  file(APPEND "${WORKDIR_DIR}/QtCreatorDeployment.txt" "${SRC}:${DEST}\n")
endmacro()

#-------------------------------------------------------------------------------------------
# add_qtcreator_deployment_directory macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   add_qtcreator_deployment_directory: Adds a directory to the QtCreatorDeployment.txt and tells QtCreator so, where to remotelydeploy thirdparties.
#   All files and directories in the given directory are deployed in their original folder structure.
# USAGE:
#   arg1: WORKDIR: Current directory where the function file(GLOB ... will generate a list of all files that match the globbing expressions and store it into the variable.
#   arg2: SRC: Source directory to be added in QtCreatorDeployment.txt
#   arg3: DEST: Destination directory to be added in QtCreatorDeployment.txt
#   arg4: OMIT_KEYWORDS: Keywords, that if found in path, will omit the directory to be added to add_qtcreator_deployment_file().
#   arg5: KEEP_FOLDER_STRUCT: Set to '1' if you want the keep the folder hierarchy of the source folder, '0' if not. 
#
# EXAMPLE:
#   foreach(dir ${THIRD_PARTY_BINARY_DIRS})
#   add_qtcreator_deployment_directory( ${dir} ${CMAKE_SYSROOT}/lib)
#   endforeach()
#
# AUTHOR:
#   1000len-dim
#
#-------------------------------------------------------------------------------------------
macro(add_qtcreator_deployment_directory WORKDIR SRC DEST OMIT_KEYWORDS KEEP_FOLDER_STRUCT)

if(NOT EXISTS "${WORKDIR}/QtCreatorDeployment.txt")
  message("No ex")
  #file(WRITE "${WORKDIR}/QtCreatorDeployment.txt" "\n")
endif()

string(LENGTH ${SRC} length)
MATH(EXPR length_1 "${length}-1")
string(SUBSTRING ${SRC} ${length_1} 1 LAST_LETTER)
if(NOT "/" STREQUAL "${LAST_LETTER}")                                       # append "/" behind path if not existent
	set(SRC_CORRECTED "${SRC}/")
else()
	set(SRC_CORRECTED "${SRC}")
endif()

string(LENGTH ${DEST} length)
MATH(EXPR length_1 "${length}-1")
string(SUBSTRING ${DEST} ${length_1} 1 LAST_LETTER)                         # append "/" behind path if not existant
if(NOT "/" STREQUAL "${LAST_LETTER}")
	set(DEST_CORRECTED "${DEST}/")
else()
  set(DEST_CORRECTED "${DEST}")
endif()

string(REGEX MATCH "${OMIT_KEYWORDS}" matched "${SRC_CORRECTED}")           # REGEX MATCH will match the regular expression once and store the match in the output variable. 'OMIT_KEYWORDS' is the regular expression
  if( "${matched}" STREQUAL "")																						# if the source directory does not match the OMIT_KEYWORDS
     file(GLOB_RECURSE files RELATIVE "${WORKDIR}" "${SRC_CORRECTED}*")     # GLOB will generate a list of all files that match the globbing expressions and store it into the variable.
     																																			# If RELATIVE flag is specified for an expression, the results will be returned as a relative path to the given path. 
     foreach(file ${files})       
       get_filename_component(path ${file} PATH)                            # Directory without file name
       if("1" STREQUAL ${KEEP_FOLDER_STRUCT} )                              # If folder strcture shall be kept,...

         string(SUBSTRING ${DEST_CORRECTED} 0 1 FIRST_LETTER)
         if("/" STREQUAL "${FIRST_LETTER}")                                 # Cut leading "/"
           string(LENGTH ${DEST_CORRECTED}} length)
           MATH(EXPR length_2 "${length}-2")
           string(SUBSTRING ${DEST_CORRECTED} 1 ${length_2} DEST_CORRECTED)
         endif()

         string(FIND ${path} "/" cutpos)                                    # cut away first part of path before "/", because this way you can deploy into a dir named differently than source dir
         string(LENGTH ${path} path_length)
         if( -1 LESS ${cutpos})
           MATH(EXPR cutpos "${cutpos}+1")
           MATH(EXPR path_length "${path_length}-${cutpos}")

           string(SUBSTRING ${path} ${cutpos} ${path_length} path)
           add_qtcreator_deployment_file("${WORKDIR}" "${file}" "${DEST_CORRECTED}${path}")  # If folder structure shall be kept, add the path of file to deploy relative to the WORKDIR. WORKDIR is the place where "QtCreatorDeployment.txt" lies, so realtive paths have to be related to this file.
         endif()
       else()
         add_qtcreator_deployment_file("${WORKDIR}" "${file}" "${DEST_CORRECTED}")           # If folder structure shall NOT be kept, symply use the filename of the file to deploy
       endif()
     endforeach(file)
  endif()
endmacro()


# !!! always add new macros before this line (copy template above) !!!

#-------------------------------------------------------------------------------------------
# MACRO_TEMPLATE macro definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   template for macros
#
# USAGE:
#   arg1:  argument 1
#   arg2:  argument 2
#
# EXAMPLE:
#   MACRO_TEMPLATE(arg1 arg2)
#
# AUTHOR:
#   your name
#
#-------------------------------------------------------------------------------------------
macro(MACRO_TEMPLATE arg1 arg2)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "Macro MACRO_TEMPLATE requires 2 arguments but ${ARGC} given.")
  endif()

  # your functionality
endmacro(MACRO_TEMPLATE)
