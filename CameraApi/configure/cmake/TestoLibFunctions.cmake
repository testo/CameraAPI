#***************************************************************************
#* Copyright: Testo AG, 79849 Lenzkirch, Postfach 1140
#***************************************************************************
#**@file Functions.cmake
#  @brief<b>Description: </b> cmake functions
#
#  <br> $Author:$
#  <br> $Date:$
#  <br> $HeadURL:$
#  <br> $Revision:$
#
#***************************************************************************

# see template at end of file

#-------------------------------------------------------------------------------------------
# readFilelist function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   read a filelist from a file
#
# USAGE:
#   var:   variable to store result
#   file:  file to read
# 
# EXAMPLE:
#   readFilelist(arg1 arg2)
#
# AUTHOR:
#   your name
#
#-------------------------------------------------------------------------------------------
function(readFilelist var file)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "Function readFilelist requires 2 arguments but ${ARGC} given.")
  endif()

  # your functionality
  set(result)
  file(STRINGS ${file} file_content)
  foreach(element ${file_content})
    #message(STATUS "element=${element}")
    string(REGEX REPLACE "#.*" " " element1b ${element})
    string(STRIP ${element1b} element1)
    #message(STATUS "element1='${element1}'")
    if(NOT "${element1}" STREQUAL "")
      if(${element1} MATCHES "\\*\\*")
	file(GLOB_RECURSE files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${element1})
      else()
	file(GLOB files RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${element1})
      endif()
      list(LENGTH files length)
      #message(STATUS "length='${length}'")
      if(length)
	foreach(element2 ${files})
	  if(NOT ${element2} MATCHES "/\\.svn/")
	    list(APPEND result ${element2})
	  endif()
	endforeach()
      else()
	message("no file found for ${element1}")
      endif()
    endif()
  endforeach(element)

  set(${var} ${result} PARENT_SCOPE)
endfunction(readFilelist)

#-------------------------------------------------------------------------------------------
# printList function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   print each element of a list
#
# USAGE:
#   header:  headline
#   var:     list variable
# 
# EXAMPLE:
#   printlist("mylist content:" ${mylist})
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
function(printList header)
  if(NOT ${ARGC} GREATER 0)
    message(FATAL_ERROR "Function printList requires at least 1 arguments but ${ARGC} given.")
  endif()

  # functionality
  message(STATUS "${header}")
  foreach(element ${ARGN})
    message(STATUS "   ${element}")
  endforeach(element)
endfunction(printList)


#-------------------------------------------------------------------------------------------
# createVsFilter function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   function to create visual studio filters
#
# USAGE:
#   prefix:  path prefixes to strip away
#   *:       paths
# 
# EXAMPLE:
#   createVsFilter("mylib" ${myfilelist})
#
# AUTHOR:
#   sic
#
#-------------------------------------------------------------------------------------------
function(createVsFilter prefix)
  if(MSVC)
    foreach(filepath ${ARGN})
      set(filepath_short ${filepath})

      # first cut prefix from filepath
      string(LENGTH ${filepath_short} filepath_length)    # get length of complete filepath
      foreach(item ${prefix})
	      #message(STATUS "item: ${item}")
      	if("${item}" STREQUAL "")
      	  set(prefix_length 0)
      	else()
      	  string(LENGTH ${filepath_short} filepath_length)    # get length of complete filepath
      	  string(LENGTH ${item} prefix_length)        # get length of prefix (to remove)
      	  math(EXPR filepath_short_length ${filepath_length}-${prefix_length})
      	  if(${filepath_length} GREATER ${prefix_length})
      	    string(SUBSTRING ${filepath_short} 0 ${prefix_length} filepath_prefix)
      	    if(${filepath_prefix} STREQUAL ${item})
      	      string(SUBSTRING ${filepath_short} ${prefix_length} ${filepath_short_length} filepath_short)
      	    endif()
      	  endif()
      	endif()
      endforeach()  

      # create/add filter 
      string(FIND ${filepath_short} "/" slash_position REVERSE)    # find last "/" to cut filename
      if(${slash_position} LESS 0)
  	    set(path "")
      else()
  	    string(SUBSTRING ${filepath_short} 0 ${slash_position} path) # get substring without filename
      endif()
      string(REPLACE "/" "\\" pathnew "${path}")                     # replace all "/" with "\\"
      
      if(NOT "${pathnew}" STREQUAL "")
  	    source_group(${pathnew} FILES ${filepath})                   # add file to group
      	#message("grouped ${filepath} to filter ${pathnew}")
      endif()
        
      ## for debug info, get filename
      if(${ENABLE_CMAKE_DEBUG_OUTPUT})
  	    string(LENGTH ${filepath_short} filepath_length)              
  	    if(${slash_position} LESS 0)
  	      set(file_length ${filepath_length})
  	      set(file_name_start 0)
  	    else()
  	      math(EXPR file_length ${filepath_length}-${slash_position}-1)
  	      math(EXPR file_name_start ${slash_position}+1)
  	    endif()
  	  
        string(SUBSTRING ${filepath_short} ${file_name_start} ${file_length} filename)                   
  	    printDebug("Add ${filename} to filter ${pathnew}")
  	    #message(STATUS "Add ${filename} to filter ${pathnew}")
      endif()
    endforeach()
  endif()
endfunction()


#-------------------------------------------------------------------------------------------
# copyFiles function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   function to copy files from given list ignoring .svn files
#
# USAGE:
#   source_dir:  source directory
#   dest_dir:    destination directory
#   *:           files/paths
# 
# EXAMPLE:
#   copyFiles("c:/svn/pl/t88x/trunk/" "destdir" ${myfilelist})
#
# AUTHOR:
#   sic/vw
#
#-------------------------------------------------------------------------------------------
function(copyFiles source_dir dest_dir) 
  string(LENGTH ${source_dir} source_dir_length)

  #filter svn files and copy files to destination 
  foreach(item ${ARGN})
    if(${item} MATCHES ".*\\.svn")
      #do nothing
    else()
      #cut source path from item (c:/snv/pl/t88x/trunk/)
      string(LENGTH ${item} item_length)       
      math(EXPR short_item_length ${item_length}-${source_dir_length}-1)
      math(EXPR item_start ${source_dir_length}+1)  
      string(SUBSTRING ${item} ${item_start} ${short_item_length} item_path)
      
      #cut filename from path
	  #message(STATUS "Copy: ${item_path}")
      string(FIND ${item_path} "/" slash_position REVERSE)    # find last "/" to cut filename
	  if(${slash_position} EQUAL -1)
		set(path "")
	  else()
		string(SUBSTRING ${item_path} 0 ${slash_position} path) # get substring without filename
	  endif()
      
      #copy file to destination
      #message(STATUS "Copy: ${path}")
      file(COPY ${item} DESTINATION "${dest_dir}/${path}")
    endif()
  endforeach()  
endfunction()


#-------------------------------------------------------------------------------------------
# installFiles function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   function to copy resource files without .svn files into install directory
#
# USAGE:
#   source_dir:  source directory
#   dest_dir:    destination directory
#   *:           files/paths
# 
# EXAMPLE:
#   installFiles("c:/svn/pl/t88x/trunk/" ${myfilelist})
#
# AUTHOR:
#   sic
#
#-------------------------------------------------------------------------------------------
function(installFiles source_dir dest_dir) 
  string(LENGTH ${source_dir} source_dir_length)

  #filter svn files and copy files to destination 
  foreach(item ${ARGN})
    if(${item} MATCHES ".*\\.svn")
      #do nothing
    else()
      #cut source path from item (c:/snv/pl/t88x/trunk/)
      string(LENGTH ${item} item_length)       
      math(EXPR short_item_length ${item_length}-${source_dir_length}-1)
      math(EXPR item_start ${source_dir_length}+1)  
      string(SUBSTRING ${item} ${item_start} ${short_item_length} item_path)
      
      #cut filename from path
      string(FIND ${item_path} "/" slash_position REVERSE)    # find last "/" to cut filename
	  if(${slash_position} EQUAL -1)
		set(path "")
	  else()
	    string(SUBSTRING ${item_path} 0 ${slash_position} path) # get substring without filename
	  endif()
      
      #copy file to destination
      #message(STATUS "Install: ${ITEM_PATH}")
      install(FILES ${item} DESTINATION "${CMAKE_INSTALL_PREFIX}/${dest_dir}/${path}")
    endif()
  endforeach()  
endfunction()


#-------------------------------------------------------------------------------------------
# printDebugStart function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   starts a block for debug output if debug output is enabled
#
# USAGE:
#   blockname:  name of debug block
# 
# EXAMPLE:
#   printDebugStart("Debug Block")
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
function(printDebugStart blockname)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "Function printDebugStart requires 1 argument but ${ARGC} given.")
  endif()

  # start of debug block
  if(${ENABLE_CMAKE_DEBUG_OUTPUT})
    message("DBG-START: ${blockname}")
  endif()

endfunction(printDebugStart)


#-------------------------------------------------------------------------------------------
# printDebug function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   print out debug message if debug output is enabled
#
# USAGE:
#   msg:  debug message
# 
# EXAMPLE:
#   printDebug("debug message")
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
function(printDebug)
  if(${ARGC} LESS 1)
    message(FATAL_ERROR "Function printDebug requires at least 1 argument but ${ARGC} given.")
  endif()

  # debug output
  if(${ENABLE_CMAKE_DEBUG_OUTPUT})
    foreach(item ${ARGN})
      message("DBG-OUT  : ${item}")
    endforeach()
  endif()

endfunction(printDebug)


#-------------------------------------------------------------------------------------------
# printDebugEnd function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   print out end of debug if debug output is enabled
#
# USAGE:
#   no argument required
# 
# EXAMPLE:
#   printDebugEnd()
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
function(printDebugEnd)
  if(NOT ${ARGC} EQUAL 0)
    message(FATAL_ERROR "Function printDebugEnd requires no arguments but ${ARGC} given.")
  endif()

  # end of debug block
  if(${ENABLE_CMAKE_DEBUG_OUTPUT})
    message("DBG-END")
  endif()
endfunction(printDebugEnd)


#-------------------------------------------------------------------------------------------
# printDebugBlock function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   print out debug message as block if debug output is enabled
#
# USAGE:
#   blockname:  name of debug block
#   msg:        debug message(s)
# 
# EXAMPLE:
#   printDebugBlock("debug block" "debug message")
#
# AUTHOR:
#   vw
#
#-------------------------------------------------------------------------------------------
function(printDebugBlock blockname)
  if(${ARGC} LESS 2)
    message(FATAL_ERROR "Function printDebugBlock requires at least 2 arguments but ${ARGC} given.")
  endif()

  # functionality
  printDebugStart(${blockname})
  printDebug(${ARGN})
  printDebugEnd()
endfunction(printDebugBlock)

#-------------------------------------------------------------------------------------------
# createFindInfo
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   creates info message block in findscripts
#
# USAGE:
#   name:         name of library
#   version:      version of library
#   include_dirs: include directories
#   library_dirs: library directories
#   binary_dirs:  binary directories
#   libraries:    list of all debug and optimized libraries
# 
# EXAMPLE:
#   createFindInfo("Guiliani" "${GUILIANI_VERSION}" "${GUILIANI_INCLUDE_DIR}" "${GUILIANI_LIBRARY_DIR}" "" "${GUILIANI_LIBRARIES}") 
#
# AUTHOR:
#   Christian Simon (sic)
#
#-------------------------------------------------------------------------------------------
function(createFindInfo name version include_dirs library_dirs binary_dirs libraries)
  if(NOT ${ARGC} EQUAL 6)
    message(FATAL_ERROR "Function createFindInfo requires 6 arguments but ${ARGC} given.")
  endif() 
  # separate debug and optimized libs
  set(debug_libs "")
  set(optimized_libs "")
  foreach(lib ${libraries})
    if((${lib} STREQUAL "debug") OR (${lib} STREQUAL "optimized"))
      set(next_lib_type "${lib}")
    else()
      if("${next_lib_type}" STREQUAL "debug")
        list(APPEND debug_libs "${lib}")
      elseif("${next_lib_type}" STREQUAL "optimized")
        list(APPEND optimized_libs "${lib}")
      else()
        list(APPEND optimized_libs "${lib}")
        list(APPEND debug_libs     "${lib}")
      endif()
      
    endif()
  endforeach()
  
  #message
  message(STATUS "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
  message(STATUS "|  ${name}"                                                                                 )
  message(STATUS "|     Version:                 ${version}"                                                  ) 
  
  # show all include directories
  list(LENGTH include_dirs number_includes)
  if(${number_includes} GREATER 1)
    list(GET include_dirs 0 dir )
    message(STATUS "|     Include Dirs:            ${dir}"                                                    )
  
    list(LENGTH include_dirs number_includes )
    math(EXPR cnt ${number_includes}-1)
  
    foreach(item RANGE 1 ${cnt})
        list(GET include_dirs ${item} dir )
      message(STATUS "|                              ${dir}"                                                  )
    endforeach ()
  else()
    list(GET include_dirs 0 dir )
    message(STATUS "|     Include Dir:             ${dir}"                                                    )
  endif()
  
  # show all library directories
  foreach(dir ${library_dirs})
    message(STATUS "|     Library Dir:             ${dir}"                                                    )
  endforeach()
  
  # show all binary directories
  foreach(dir ${binary_dirs})
    message(STATUS "|     Binary Dir:              ${dir}"                                                    )
  endforeach()
  
  # show all debug and optimized libraries
  list(GET debug_libs 0 dir )
    message(STATUS "|     Libraries (debug):       ${dir}"                                                    )
  list(LENGTH debug_libs number_includes )
  math(EXPR cnt ${number_includes}-1)
  if(${cnt} GREATER 0)
    foreach(item RANGE 1 ${cnt})
        list(GET debug_libs ${item} dir )
      message(STATUS "|                              ${dir}"                                                  )
    endforeach ()
  endif()
  
  list(GET optimized_libs 0 dir )
    message(STATUS "|     Libraries (optimized):   ${dir}"                                                    )
  list(LENGTH optimized_libs number_includes )
  math(EXPR cnt ${number_includes}-1)
  if(${cnt} GREATER 0)
    foreach(item RANGE 1 ${cnt})
        list(GET optimized_libs ${item} dir )
      message(STATUS "|                              ${dir}"                                                  )
    endforeach ()
  endif()
  
  message(STATUS "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
endfunction(createFindInfo)


# !!! always add new macros before this line (copy template above) !!!


#-------------------------------------------------------------------------------------------
# functionTemplate function definition
#-------------------------------------------------------------------------------------------
#
# DESCRIPTION:
#   template for function
#
# USAGE:
#   arg1:  argument 1
#   arg2:  argument 2
# 
# EXAMPLE:
#   functionTemplate(arg1 arg2)
#
# AUTHOR:
#   your name
#
#-------------------------------------------------------------------------------------------
function(functionTemplate arg1 arg2)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "Function functionTemplate requires 2 arguments but ${ARGC} given.")
  endif()

  # your functionality
endfunction(functionTemplate)



