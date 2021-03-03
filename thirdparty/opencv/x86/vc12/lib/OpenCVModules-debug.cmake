#----------------------------------------------------------------
# Generated CMake target import file for configuration "Debug".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "opencv_core" for configuration "Debug"
set_property(TARGET opencv_core APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(opencv_core PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_core248d.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG ""
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_core248d.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS opencv_core )
list(APPEND _IMPORT_CHECK_FILES_FOR_opencv_core "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_core248d.lib" "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_core248d.dll" )

# Import target "opencv_imgproc" for configuration "Debug"
set_property(TARGET opencv_imgproc APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(opencv_imgproc PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_imgproc248d.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG "opencv_core"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_imgproc248d.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS opencv_imgproc )
list(APPEND _IMPORT_CHECK_FILES_FOR_opencv_imgproc "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_imgproc248d.lib" "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_imgproc248d.dll" )

# Import target "opencv_highgui" for configuration "Debug"
set_property(TARGET opencv_highgui APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(opencv_highgui PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_highgui248d.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG "opencv_core;opencv_imgproc"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_highgui248d.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS opencv_highgui )
list(APPEND _IMPORT_CHECK_FILES_FOR_opencv_highgui "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_highgui248d.lib" "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_highgui248d.dll" )

# Import target "opencv_video" for configuration "Debug"
set_property(TARGET opencv_video APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
set_target_properties(opencv_video PROPERTIES
  IMPORTED_IMPLIB_DEBUG "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_video248d.lib"
  IMPORTED_LINK_INTERFACE_LIBRARIES_DEBUG "opencv_core;opencv_imgproc"
  IMPORTED_LOCATION_DEBUG "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_video248d.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS opencv_video )
list(APPEND _IMPORT_CHECK_FILES_FOR_opencv_video "${_IMPORT_PREFIX}/x86/vc12/lib/opencv_video248d.lib" "${_IMPORT_PREFIX}/x86/vc12/bin/opencv_video248d.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
