# Make sure this file is included only once by creating globally unique variables
# based on the name of this included file.
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

## External_${extProjName}.cmake files can be recursively included,
## and cmake variables are global, so when including sub projects it
## is important make the extProjName and proj variables
## appear to stay constant in one of these files.
## Store global variables before overwriting (then restore at end of this file.)
ProjectDependancyPush(CACHED_extProjName ${extProjName})
ProjectDependancyPush(CACHED_proj ${proj})

# Make sure that the ExtProjName/IntProjName variables are unique globally
# even if other External_${ExtProjName}.cmake files are sourced by
# SlicerMacroCheckExternalProjectDependency
set(extProjName RunExamples) #The find_package known name
set(proj      RunExamples) #This local name
set(${extProjName}_REQUIRED_VERSION)  #If a required version is necessary, then set this, else leave blank

#if(${USE_SYSTEM_${extProjName}})
#  unset(${extProjName}_DIR CACHE)
#endif()

# Sanity checks
if(DEFINED ${extProjName}_DIR AND NOT EXISTS ${${extProjName}_DIR})
  message(FATAL_ERROR "${extProjName}_DIR variable is defined but corresponds to non-existing directory (${${extProjName}_DIR})")
endif()

# Set dependency list
if( NOT USE_SYSTEM_ITK)
  set(${proj}_DEPENDENCIES ITK)
else()
  set(${proj}_DEPENDENCIES "")
  find_package(ITK 5 REQUIRED ITKReview )
  include(${ITK_USE_FILE})
endif()

# Include dependent projects if any
SlicerMacroCheckExternalProjectDependency(${proj})

# Set CMake OSX variable to pass down the external project
set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
if(APPLE)
  list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
    -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
endif()

string(REPLACE ";" "^^" CMAKE_JOB_POOLS_ARG "${CMAKE_JOB_POOLS}")

set(${proj}_CMAKE_OPTIONS
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
  )
### --- End Project specific additions

ExternalProject_Add(${proj}
  DOWNLOAD_COMMAND ""
  SOURCE_DIR ${ITKSoftwareGuide_SOURCE_DIR}/SoftwareGuide/Examples
  BINARY_DIR ${proj}-build
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    -DSoftwareGuide_BINARY_DIR:PATH=${ITKSoftwareGuide_BINARY_DIR}/ITKSoftwareGuide-build/SoftwareGuide
    -DSoftwareGuide_SOURCE_DIR:PATH=${ITKSoftwareGuide_SOURCE_DIR}/SoftwareGuide
    -DPDF_QUALITY_LEVEL:STRING=${PDF_QUALITY_LEVEL}
    -DITK_SOURCE_DIR:STRING=${ITK_SOURCE_DIR}
    -DITK_BINARY_DIR:STRING=${ITK_BINARY_DIR}
    -DCMAKE_JOB_POOLS:STRING=${CMAKE_JOB_POOLS_ARG}
    -Wno-dev
    --no-warn-unused-cli
    ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
    ${COMMON_EXTERNAL_PROJECT_ARGS}
    ${${proj}_CMAKE_OPTIONS}
  INSTALL_COMMAND ""
  LIST_SEPARATOR "^^"
  DEPENDS
    ${${proj}_DEPENDENCIES}
)
set(${extProjName}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)

list(APPEND ${CMAKE_PROJECT_NAME}_SUPERBUILD_EP_VARS ${extProjName}_DIR:PATH)

ProjectDependancyPop(CACHED_extProjName extProjName)
ProjectDependancyPop(CACHED_proj proj)
