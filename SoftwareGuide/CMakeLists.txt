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
# Run this CMakeLists.txt file and set BUILD_FIGURES  'ON'. Specify the
# directory containing the Insight executables. Specify ITK data paths.
# The default data path inferred is ITK/Examples/Data. This should suffice
# for building the SoftwareGuide. Should more paths be need add them in a colon
# seperated list.
#
# Make
# Make
#
# More than one make may be necessary to ensure generation of the index
#
# If BUILD_FIGURES is set to ON, the examples source files are parsed for
# command line argument tags and if found executed to generate output
# images, if not the images are expected to be present in the Art/ folder
# in PNG/XFIG/JPEG/EPS format.
#
# Since generating figures may take a while, you may set BUILD_FIGURES to
# OFF. In this case, all figures are expected to be present in the Art/
# folder in PNG/XFIG/JPEG/EPS format.
#
#
cmake_minimum_required(VERSION 2.8.4)

project(SoftwareGuide C)

#
# File that defines the path to .cxx examples in ITK sources
#
configure_file(
${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in
${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
IMMEDIATE
)

# Find ITK Sources
find_path(ITK_SOURCE_DIR UseITK.cmake.in
   ../ITK
   ../../ITK
   ../../../ITK
   ../../../../ITK
   ../../../../../ITK
   ../../../../../../ITK
  )

if( NOT ITK_SOURCE_DIR )
  message(FATAL_ERROR "ITK source directory is not set")
endif( NOT ITK_SOURCE_DIR )

# ITK_DATA_PATHS is searched recursively.. you need not enter sub-directories
set(ITK_DATA_PATHS "${ITK_SOURCE_DIR}/Testing/Data" CACHE STRING "Where the ITK data is. Enter a colon seperated list.")

#
# Rebuild the Software Guide figures or not ?
set(BUILD_FIGURES ON CACHE BOOL "Build Software Guide figures")
if( BUILD_FIGURES )
  set(ITK_EXECUTABLES_DIR "" CACHE PATH "Where the ITK examples executables are")
  set(RUN_EXAMPLES_SCRIPT "${SoftwareGuide_SOURCE_DIR}/Examples/RunExamples.pl" CACHE FILEPATH "Where the RunExamples Script is")
endif( BUILD_FIGURES )


#
# Find ImageMagick tools
# This is used to convert image formats
#
include(${CMAKE_ROOT}/Modules/FindImageMagick.cmake)
if(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)
  message("ImageMagick convert utility was not found. Please pass to advanced mode and provide its full path")
endif(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)


if(BUILD_FIGURES)

  #
  #
  # ADD THE LIST OF INPUT IMAGES YOU WANT FLIPPED HERE.
  #
  # NOTE:
  # If ON, all input images in the list and all outputs that use these images
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
endif( BUILD_FIGURES )

add_subdirectory(Examples)
add_subdirectory(Art)
add_subdirectory(Latex)
#
# Examples Directory is where .cxx files are converted
# into .tex by a perl script.
#
# Art Directory with images and diagrams
#
# Latex Directory with tex files
#
