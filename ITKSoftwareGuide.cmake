
include(${CMAKE_CURRENT_LIST_DIR}/Common.cmake)

#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------
set(CMAKE_MODULE_PATH
  ${${PROJECT_NAME}_SOURCE_DIR}/CMake
  ${${PROJECT_NAME}_BINARY_DIR}/CMake
  ${CMAKE_MODULE_PATH}
  )

#-----------------------------------------------------------------------------
find_package(ITK REQUIRED)
if(Slicer_BUILD_${PROJECT_NAME})
  set(ITK_NO_IO_FACTORY_REGISTER_MANAGER 1) # Incorporate with Slicer nicely
endif()
include(${ITK_USE_FILE})

if( NOT IS_DIRECTORY "${ITK_SOURCE_DIR}" )
  message(FATAL_ERROR "ITK source directory is not set :${ITK_SOURCE_DIR}:")
endif() 
if( NOT IS_DIRECTORY "${ITK_BINARY_DIR}" )
  message(FATAL_ERROR "ITK build directory is not set :${ITK_BINARY_DIR}:")
endif()

#-----------------------------------------------------------------------------
enable_testing()
include(CTest)

if (NOT ${USE_SYSTEM_ITK})
#-----------------------------------------------------------------------
# Setup locations to find externally maintained test data.
#-----------------------------------------------------------------------
   include(${PROJECT_NAME}ExternalData)

   add_subdirectory(SoftwareGuide)

   ExternalData_Add_Target( ${PROJECT_NAME}FetchData )  # Name of data management target
endif()
