
include(CMakeDependentOption)

option(${PRIMARY_PROJECT_NAME}_INSTALL_DEVELOPMENT "Install development support include and libraries for external packages." OFF)
mark_as_advanced(${PRIMARY_PROJECT_NAME}_INSTALL_DEVELOPMENT)

#-----------------------------------------------------------------------------
# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

#-----------------------------------------------------------------------------
# Build option(s)
#-----------------------------------------------------------------------------
option(USE_OPTION1           "Build OPTION1"           ON)

#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------
set(CMAKE_MODULE_PATH
  ${${PROJECT_NAME}_SOURCE_DIR}/CMake
  ${${PROJECT_NAME}_BINARY_DIR}/CMake
  ${CMAKE_MODULE_PATH}
  )

#-----------------------------------------------------------------------------
# Sanity checks
#------------------------------------------------------------------------------
include(PreventInSourceBuilds)
include(PreventInBuildInstalls)

#-----------------------------------------------------------------------------
# Platform check
#-----------------------------------------------------------------------------
set(PLATFORM_CHECK true)
if(PLATFORM_CHECK)
  # See CMake/Modules/Platform/Darwin.cmake)
  #   6.x == Mac OSX 10.2 (Jaguar)
  #   7.x == Mac OSX 10.3 (Panther)
  #   8.x == Mac OSX 10.4 (Tiger)
  #   9.x == Mac OSX 10.5 (Leopard)
  #  10.x == Mac OSX 10.6 (Snow Leopard)
  if (DARWIN_MAJOR_VERSION LESS "9")
    message(FATAL_ERROR "Only Mac OSX >= 10.5 are supported !")
  endif()
endif()


#-----------------------------------------------------------------------------
if(NOT COMMAND SETIFEMPTY)
  macro(SETIFEMPTY)
    set(KEY ${ARGV0})
    set(VALUE ${ARGV1})
    if(NOT ${KEY})
      set(${ARGV})
    endif()
  endmacro()
endif()

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_INSTALL_LIBRARY_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_ARCHIVE_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_RUNTIME_DESTINATION bin)

#-------------------------------------------------------------------------
# Augment compiler flags
#-------------------------------------------------------------------------
include(ITKSetStandardCompilerFlags)
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_DEBUG_DESIRED_FLAGS}" )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_DEBUG_DESIRED_FLAGS}" )
else() # Release, or anything else
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_RELEASE_DESIRED_FLAGS}" )
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_RELEASE_DESIRED_FLAGS}" )
endif()

#-----------------------------------------------------------------------------
# Add needed flag for gnu on linux like environments to build static common libs
# suitable for linking with shared object libs.
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
  if(NOT "${CMAKE_CXX_FLAGS}" MATCHES "-fPIC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  endif()
  if(NOT "${CMAKE_C_FLAGS}" MATCHES "-fPIC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
  endif()
endif()

