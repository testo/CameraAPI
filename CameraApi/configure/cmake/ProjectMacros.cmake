macro( PREPARE_DEVELOPMENT_ENVIRONMENT VAR_THIRDPARTY_LIBS_DIR_OUT )
  find_package(PythonInterp 3 REQUIRED)

  # CHECK SYSTEM AND COMPILER
  if(WIN32)
    set(SYSTEM "windows")
    if(MSVC10)
      set(COMPILER "msvc10")
    elseif(MSVC12)
      set(COMPILER "msvc12")
    endif()
  elseif(UNIX)
    set(SYSTEM "linux")
    if(CMAKE_COMPILER_IS_GNUCC)
      option(GNU_GCC "DO NOT CHANGE" ON) 
      mark_as_advanced(GNU_GCC)
      execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
                      OUTPUT_VARIABLE GCC_VERSION)  
    
      string(REGEX MATCHALL "[0-9]+" GCC_VERSION_COMPONENTS ${GCC_VERSION})
      list(GET GCC_VERSION_COMPONENTS 0 GCC_MAJOR)
      list(GET GCC_VERSION_COMPONENTS 1 GCC_MINOR)
      set(COMPILER "gcc${GCC_MAJOR}${GCC_MINOR}")
    else()
      message(FATAL_ERROR "unsupported compiler/system combination")
    endif()
  elseif(APPLE)
    set(SYSTEM "macos")
  endif()

  # CHECK ARCHITECTURE
  if(${CMAKE_SIZEOF_VOID_P} EQUAL 4) # check 32bit compiler
    set(ARCHITECTURE i386)
  elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)  # check 64bit compiler
    set(ARCHITECTURE amd64)
  endif()

  #${PYTHON_EXECUTABLE}
  set(THIRDPARTY_CONFIG_FILE "${PROJECT_SOURCE_DIR}/configure/configurations/${SYSTEM}/thirdparty_${ARCHITECTURE}_${SYSTEM}_${COMPILER}.cfg")
  set(${PROJECT_NAME}_PROJECT_ROOT "${PROJECT_SOURCE_DIR}/../")

  if(BUILD_SHARED_LIBS)
    set(${VAR_THIRDPARTY_LIBS_DIR_OUT} "${${PROJECT_NAME}_PROJECT_ROOT}/thirdparty/thirdparty_${ARCHITECTURE}_${SYSTEM}_${COMPILER}/shared") 
  else()
    set(${VAR_THIRDPARTY_LIBS_DIR_OUT} "${${PROJECT_NAME}_PROJECT_ROOT}/thirdparty/thirdparty_${ARCHITECTURE}_${SYSTEM}_${COMPILER}/static")
  endif() 

  file(READ "configure/git_project_dependencies.cfg" GIT_REPOS)
  string(REGEX REPLACE "\n" " " GIT_REPOS ${GIT_REPOS})
  
  message(STATUS "${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/configure/scripts/python/PrepareEnvironment.py --config ${THIRDPARTY_CONFIG_FILE} --dest ${${PROJECT_NAME}_PROJECT_ROOT} --git-repos ${GIT_REPOS}")
  execute_process(COMMAND "${PYTHON_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/configure/scripts/python/PrepareEnvironment.py" --config ${THIRDPARTY_CONFIG_FILE} --dest ${${PROJECT_NAME}_PROJECT_ROOT} --git-repos ${GIT_REPOS}
                  TIMEOUT 300
                  RESULT_VARIABLE variable_RESULT
                  OUTPUT_VARIABLE variable_OUTPUT
                  ERROR_VARIABLE  variable_ERROR)

  message(STATUS "${variable_RESULT}")
  message(STATUS "${variable_OUTPUT}")    
  message("${variable_ERROR}")
endmacro(PREPARE_DEVELOPMENT_ENVIRONMENT)
