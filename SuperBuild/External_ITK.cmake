# Make sure this file is included only once by creating globally unique varibles
# based on the name of this included file.
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

## External_${extProjName}.cmake files can be recurisvely included,
## and cmake variables are global, so when including sub projects it
## is important make the extProjName and proj variables
## appear to stay constant in one of these files.
## Store global variables before overwriting (then restore at end of this file.)
ProjectDependancyPush(CACHED_extProjName ${extProjName})
ProjectDependancyPush(CACHED_proj ${proj})

# Make sure that the ExtProjName/IntProjName variables are unique globally
# even if other External_${ExtProjName}.cmake files are sourced by
# SlicerMacroCheckExternalProjectDependency
set(extProjName ITK) #The find_package known name
set(proj      ITK) #This local name
set(${extProjName}_REQUIRED_VERSION 4)  #If a required version is necessary, then set this, else leave blank

#if(${USE_SYSTEM_${extProjName}})
#  unset(${extProjName}_DIR CACHE)
#endif()

# Sanity checks
if(DEFINED ${extProjName}_DIR AND NOT EXISTS ${${extProjName}_DIR})
  message(FATAL_ERROR "${extProjName}_DIR variable is defined but corresponds to non-existing directory (${${extProjName}_DIR})")
endif()

# Set dependency list
set(${proj}_DEPENDENCIES "")
# Include dependent projects if any
SlicerMacroCheckExternalProjectDependency(${proj})

if(NOT ( DEFINED "${extProjName}_DIR" OR ( DEFINED "USE_SYSTEM_${extProjName}" AND "${USE_SYSTEM_${extProjName}}" ) ) )

  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()

  if(${PROJECT_NAME}_BUILD_FFTWF_SUPPORT)
    set(${proj}_FFTWF_ARGS
      -DITK_USE_FFTWF:BOOL=ON
      )
  endif()
  if(${PROJECT_NAME}_BUILD_FFTWD_SUPPORT)
    set(${proj}_FFTWD_ARGS
      -DITK_USE_FFTWD:BOOL=ON
      )
  endif()

  set(${proj}_WRAP_ARGS)
  #if(foo)
    #set(${proj}_WRAP_ARGS
    #  -DWRAP_float:BOOL=ON
    #  -DWRAP_unsigned_char:BOOL=ON
    #  -DWRAP_signed_short:BOOL=ON
    #  -DWRAP_unsigned_short:BOOL=ON
    #  -DWRAP_complex_float:BOOL=ON
    #  -DWRAP_vector_float:BOOL=ON
    #  -DWRAP_covariant_vector_float:BOOL=ON
    #  -DWRAP_rgb_signed_short:BOOL=ON
    #  -DWRAP_rgb_unsigned_char:BOOL=ON
    #  -DWRAP_rgb_unsigned_short:BOOL=ON
    #  -DWRAP_ITK_TCL:BOOL=OFF
    #  -DWRAP_ITK_JAVA:BOOL=OFF
    #  -DWRAP_ITK_PYTHON:BOOL=ON
    #  -DPYTHON_EXECUTABLE:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}
    #  -DPYTHON_INCLUDE_DIR:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_INCLUDE}
    #  -DPYTHON_LIBRARY:FILEPATH=${${CMAKE_PROJECT_NAME}_PYTHON_LIBRARY}
    #  )
  #endif()

  # HACK This code fixes a loony problem with HDF5 -- it doesn't
  #      link properly if -fopenmp is used.
  string(REPLACE "-fopenmp" "" ITK_CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
  string(REPLACE "-fopenmp" "" ITK_CMAKE_CXX_FLAGS "${CMAKE_CX_FLAGS}")

  string(REPLACE ";" "^^" CMAKE_JOB_POOLS_ARG "${CMAKE_JOB_POOLS}")

  set(${proj}_CMAKE_OPTIONS
      -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_CURRENT_BINARY_DIR}/${proj}-install
      -DBUILD_TESTING:BOOL=ON
      -DBUILD_EXAMPLES:BOOL=ON
      -DITK_USE_BRAINWEB_DATA:BOOL=ON ## Need to build BRAINWEB for software guide
      -DITK_FUTURE_LEGACY_REMOVE:=BOOL=ON
      -DITK_LEGACY_REMOVE:BOOL=OFF
      -DModule_ITKReview:BOOL=ON
      -DITK_BUILD_DEFAULT_MODULES:BOOL=ON
      -DKWSYS_USE_MD5:BOOL=ON # Required by SlicerExecutionModel
      -DITK_WRAPPING:BOOL=OFF #${BUILD_SHARED_LIBS} ## HACK:  QUICK CHANGE
      ${${proj}_WRAP_ARGS}
      ${${proj}_FFTWF_ARGS}
      ${${proj}_FFTWD_ARGS}
    )
  ### --- End Project specific additions
  set(${proj}_REPOSITORY ${git_protocol}://github.com/InsightSoftwareConsortium/ITK.git)
  if("${${proj}_GIT_TAG}" STREQUAL "")
    # ITK release branch 2024-04-17
    set(${proj}_GIT_TAG "v5.4rc04")
  endif()

  ExternalProject_Add(${proj}
    GIT_REPOSITORY ${${proj}_REPOSITORY}
    GIT_TAG ${${proj}_GIT_TAG}
    SOURCE_DIR ${proj}
    BINARY_DIR ${proj}-build
    #${cmakeversion_external_update} "${cmakeversion_external_update_value}"
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      -Wno-dev
      --no-warn-unused-cli
      -DCMAKE_JOB_POOLS:STRING=${CMAKE_JOB_POOLS_ARG}
      ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
      ${COMMON_EXTERNAL_PROJECT_ARGS}
      ${${proj}_CMAKE_OPTIONS}
## We really do want to install in order to limit # of include paths INSTALL_COMMAND ""
    INSTALL_COMMAND ""
    LIST_SEPARATOR "^^"
    DEPENDS
      ${${proj}_DEPENDENCIES}
  )
  set(${extProjName}_DIR ${CMAKE_BINARY_DIR}/${proj}-build)
#set(${extProjName}_DIR ${CMAKE_BINARY_DIR}/${proj}-install/lib/cmake/ITK-4.4)
else()
  message(STATUS "XXXXXXXXXXXXX ${__indent}Adding project ${proj}")
  if(${USE_SYSTEM_${extProjName}})
    find_package(${extProjName} ${${extProjName}_REQUIRED_VERSION} REQUIRED)
    if(NOT ${extProjName}_DIR)
      message(FATAL_ERROR "To use the system ${extProjName}, set ${extProjName}_DIR")
    endif()
    message("USING the system ${extProjName}, set ${extProjName}_DIR=${${extProjName}_DIR}")
  endif()
  # The project is provided using ${extProjName}_DIR, nevertheless since other
  # project may depend on ${extProjName}, let's add an 'empty' one
  SlicerMacroEmptyExternalProject(${proj} "${${proj}_DEPENDENCIES}")
endif()

list(APPEND ${CMAKE_PROJECT_NAME}_SUPERBUILD_EP_VARS ${extProjName}_DIR:PATH)

ProjectDependancyPop(CACHED_extProjName extProjName)
ProjectDependancyPop(CACHED_proj proj)
