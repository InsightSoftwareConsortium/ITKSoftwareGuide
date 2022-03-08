cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
cmake_policy(VERSION 3.10.2)

set(PRIMARY_PROJECT_NAME ITKSoftwareGuide)

## NOTE THERE SHOULD BE NO PROJECT STATEMENT HERE!
## This file acts as a simple switch to initiate
## two completely independant CMake build environments.

#-----------------------------------------------------------------------------
# Superbuild Option - Enabled by default
#                   Phase I:  ${PRIMARY_PROJECT_NAME}_SUPERBUILD is set to ON, and the
#                             supporting packages defined in "SuperBuild.cmake"
#                             are built.  The last package in "SuperBuild.cmake"
#                             to be built is a recursive call to this
#                             file with ${PRIMARY_PROJECT_NAME}_SUPERBUILD explicitly
#                             set to "OFF" to initiate Phase II
#
#                   Phase II: Build the ${PRIMARY_PROJECT_NAME}, referencing the support
#                             packages built in Phase I.
#-----------------------------------------------------------------------------
option(${PRIMARY_PROJECT_NAME}_SUPERBUILD "Build ${PRIMARY_PROJECT_NAME} and the projects it depends on via SuperBuild.cmake." ON)
mark_as_advanced(${PRIMARY_PROJECT_NAME}_SUPERBUILD)

set(PDF_QUALITY_LEVEL "Screen" CACHE STRING "PDF Quality")
set_property(CACHE PDF_QUALITY_LEVEL PROPERTY STRINGS Screen Printer PrePress)

#-----------------------------------------------------------------------------
# Superbuild script
#-----------------------------------------------------------------------------
project(${PRIMARY_PROJECT_NAME})             # <- NOTE: Here is the main project name setting
if(${PRIMARY_PROJECT_NAME}_SUPERBUILD)
  project(SuperBuild_${PRIMARY_PROJECT_NAME})  # <- NOTE: Project name for pre-requisites is different form main project
  include("${CMAKE_CURRENT_SOURCE_DIR}/SuperBuild.cmake")
  return()
else()
  include("${CMAKE_CURRENT_SOURCE_DIR}/${PRIMARY_PROJECT_NAME}.cmake")
  return()
endif()

message(FATAL_ERROR "You should never reach this point !")
