#################################################################################
# add new device tests here
#################################################################################

set(APP_NAME CameraApiTest)

add_executable(${APP_NAME} CameraApiTest.cpp)

target_link_libraries(${APP_NAME} ${THIRD_PARTY_LIBRARIES})

REGISTER_EXECUTABLE("${APP_NAME}"
                    "bin" 
                    "Project/Application"
                    "PROPERTY_THIRD_PARTY_BINARY_DIRECTORIES"
                    "${CMAKE_CURRENT_LIST_DIR}"
                    ${VCX_PROJ_IN_FILE_PATH}
                    FALSE)





set(APP_NAME LabviewWrapperTest)

add_executable(${APP_NAME} LabviewWrapperTest.cpp)

target_link_libraries(${APP_NAME} labview_cwrapper ${THIRD_PARTY_LIBRARIES})

REGISTER_EXECUTABLE("${APP_NAME}"
                    "bin" 
                    "Project/Application"
                    "PROPERTY_THIRD_PARTY_BINARY_DIRECTORIES"
                    "${CMAKE_CURRENT_LIST_DIR}"
                    ${VCX_PROJ_IN_FILE_PATH}
                    FALSE)


