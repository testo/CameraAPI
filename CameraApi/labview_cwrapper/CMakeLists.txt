set(module_name "labview_cwrapper")

string(TOUPPER "${module_name}" module_name_uppercase)

set(CMAKE_AUTOMOC ON)

set(MODULE_SOURCES
  c_connector.h c_connector.cpp)

###########################
# add library
###########################
# add files to library
add_library("${module_name}"  ${MODULE_SOURCES})

# get all libraries that need to be linked against FWLibrary
target_link_libraries("${module_name}" ${THIRD_PARTY_LIBRARIES})

# register the library
REGISTER_LIBRARY("${PROJECT_NAME}"
 ${module_name}
 "${PROJECT_NAME}/Libraries"
 "include/labview_cwrapper"
 FALSE)

