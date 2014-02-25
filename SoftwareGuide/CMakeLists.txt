#####################################################
#
#   This is the root SoftwareGuide CMakeLists file.
#
#####################################################
#
# To Build the ITK Software Guide,
#
# Compile and build the ITK binaries. You will need to build the Examples in
# the Insight directory with the CMakeLists.txt file in ITK/
#
# Run this CMakeLists.txt file and specify the
# directory containing the Insight executables. Specify ITK data paths.
# The default data path inferred is ITK/Examples/Data. This should suffice
# for building the SoftwareGuide. Should more paths be need add them in a colon
# seperated list.
#
# Make
#
# More than one make may be necessary to ensure generation of the index
#
# The examples source files are parsed for
# command line argument tags and if found executed to generate output
# images, if not the images are expected to be present in the Art/ folder
# in PNG/XFIG/JPEG/EPS format.
#
cmake_minimum_required(VERSION 2.8.10)

project(SoftwareGuide C)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/CMake ${CMAKE_MODULE_PATH})

find_package(ITK 4 REQUIRED)
include(${ITK_USE_FILE})
find_path(ITK_EXECUTABLES_DIR
  NAMES ImageReadWrite ImageReadWrite.exe
  PATHS
  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release"
  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug"
  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo"
  "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/MinSizeRel"
  DOC "Where the ITK examples executables are"
  )

#
# Generate .cmake files containing those macros defined above.
#
# First make a directory to store generated images
set(ART_GENERATED_FOLDER "${SoftwareGuide_BINARY_DIR}/Art/Generated" )
make_directory( "${ART_GENERATED_FOLDER}" )

#
# Rebuild the Software Guide figures
set(RUN_EXAMPLES_SCRIPT "${SoftwareGuide_SOURCE_DIR}/Examples/RunExamples.py" CACHE FILEPATH "Where the RunExamples Script is")


#
# Find ImageMagick tools
# This is used to convert image formats
#
#
# Find ImageMagick tools
# This is used to convert image formats
#
#include(${CMAKE_ROOT}/Modules/FindImageMagick.cmake)
find_package(ImageMagick REQUIRED)
if(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)
  message("ImageMagick convert utility was not found. Please pass to advanced mode and provide its full path")
endif(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)


#
# ADD THE LIST OF INPUT IMAGES YOU WANT FLIPPED HERE.
#
# NOTE:
# All input images in the list and all outputs that use these images
# as inputs in cmd line args will be flipped about 'y'. The command line
# argument itself does not run using the flipped images; instead the eps
# images corresponding to the inputs mentioned in the list and their output
# dependencies are flipped for inclusion in the TEX document.

option(ITK_FLIP_INPUTS_AND_THEIR_OUTPUTS "Flip the input images specified in CMakeLists and their corresponding outputs" ON)
set(ITK_FLIP_IMG
  BrainProtonDensitySlice
  BrainT1Slice
  BrainT1SliceBorder20
  BrainProtonDensitySliceBorder20
  BrainProtonDensitySliceRotated10
  BrainProtonDensitySliceR10X13Y17
  BrainProtonDensitySliceR10X13Y17S12
  VisibleWomanEyeSlice
  VisibleWomanHeadSlice
  FatMRISlice
  BinaryImage
  VentricleModel
  FivePoints
  ThresholdSegmentationLevelSetImageFilterVentricle
  BrainProtonDensitySliceShifted13x17y
)
# END FLIP_INPUTS LIST

# Convert an image from some file format to EPS for inclusion in Latex using
# ImageMagick. This image is an input image. A seperate macro is necessary
# cause input images do not have any dependecies
macro(CONVERT_INPUT_IMG SOME_IMG EPS_IMG IMAGEMAGICK_FLAGS)
  if( NOT DEFINED ${EPS_IMG}_HAS_CUSTOM_COMMAND)
    add_custom_command(
        SOURCE      "${SOME_IMG}"
        COMMAND     ${IMAGEMAGICK_CONVERT_EXECUTABLE}
        ARGS        ${FLAGS} -flip -quality 100 "${SOME_IMG}" "${EPS_IMG}"
        DEPENDS     ${RUN_EXAMPLES_SCRIPT}
        OUTPUT      "${EPS_IMG}"
    )
    set(${EPS_IMG}_HAS_CUSTOM_COMMAND 1)
  endif()
endmacro(CONVERT_INPUT_IMG)


#
# Find Python executable
include(${CMAKE_ROOT}/Modules/FindPythonInterp.cmake)
if( NOT PYTHONINTERP_FOUND )
  message(FATAL_ERROR "Python executable was not found")
endif( NOT PYTHONINTERP_FOUND )
find_program(PYTHONCXXPARSER NAMES ${SoftwareGuide_SOURCE_DIR}/ParseCxxExamples.py)
if( NOT EXISTS ${SoftwareGuide_SOURCE_DIR}/ParseCxxExamples.py )
  message(FATAL_ERROR "Missing script: ${SoftwareGuide_SOURCE_DIR}/ParseCxxExamples.py")
endif()

add_custom_target(SoftwareGuideExamples  ALL echo)

#
# Search for all the example sources
#
file( GLOB_RECURSE all_sources  ${ITK_SOURCE_DIR}/Examples/*.cxx)
# Exclude the RegistrationITKv3 sources.
set( ITK_EXAMPLES_SRCS )
foreach( source ${all_sources} )
  if( NOT "${source}" MATCHES "RegistrationITKv3" )
    list( APPEND ITK_EXAMPLES_SRCS "${source}" )
  endif()
endforeach()

message(STATUS "PRE_RUN_PYTHON ART GENERATION.")
message(STATUS "Running: ${PYTHON_EXECUTABLE} ${RUN_EXAMPLES_SCRIPT} --itkSource ${ITK_SOURCE_DIR} --itkBuildDir ${ITK_BINARY_DIR} --itkExecDir ${ITK_EXECUTABLES_DIR} --SWGuidBaseOutput ${SoftwareGuide_BINARY_DIR} "
  )
execute_process(
  COMMAND ${PYTHON_EXECUTABLE}
  ${RUN_EXAMPLES_SCRIPT}
  --itkSource ${ITK_SOURCE_DIR}
  --itkBuildDir ${ITK_BINARY_DIR}
  --itkExecDir ${ITK_EXECUTABLES_DIR}
  --SWGuidBaseOutput ${SoftwareGuide_BINARY_DIR}
  WORKING_DIRECTORY "${ART_GENERATED_FOLDER}"
  RESULT_VARIABLE    RUN_EXAMPLES_RESULT
    )
if( NOT ${RUN_EXAMPLES_RESULT} EQUAL 0)
  message(FATAL_ERROR "POST_RUN_PYTHON ART GENERATION ${RUN_EXAMPLES_RESULT}.")
endif()

include(${SoftwareGuide_BINARY_DIR}/Examples/GeneratedDependancies.cmake)

#
# Parse Latex file for latex includes
#
set(TEX_DEPENDENCIES "")
foreach(example ${ITK_EXAMPLES_SRCS})
  get_filename_component(TEX_FILE_BASE ${example} NAME_WE)
  set(TEX_FILE ${SoftwareGuide_BINARY_DIR}/Examples/${TEX_FILE_BASE}.tex)
  #message(STATUS "File ${TEX_FILE} depends on: ${${TEX_FILE_BASE}-DEPS}")
  add_custom_command(
    SOURCE    ${example}
    COMMAND   ${PYTHON_EXECUTABLE}
    ARGS      ${PYTHONCXXPARSER} ${example} ${TEX_FILE}
    TARGET    SoftwareGuideExamples
    DEPENDS   ${PYTHONCXXPARSER} ${example} ${${TEX_FILE_BASE}-DEPS}
    OUTPUTS   ${TEX_FILE}
  )
  set(TEX_DEPENDENCIES ${TEX_DEPENDENCIES} ${TEX_FILE})
endforeach(example)

add_custom_target(BuildTexFiles ALL DEPENDS ${TEX_DEPENDENCIES})


add_subdirectory(Examples)
add_subdirectory(Art)
add_subdirectory(Latex)
#
# Examples Directory is where .cxx files are converted
# into .tex by a python script.
#
# Art Directory with images and diagrams
#
# Latex Directory with tex files
#
