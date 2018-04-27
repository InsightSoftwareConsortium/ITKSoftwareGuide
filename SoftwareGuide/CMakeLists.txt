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
cmake_minimum_required(VERSION 3.10.2 FATAL_ERROR)
cmake_policy(VERSION 3.10.2)

project(SoftwareGuide C)

set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/CMake ${CMAKE_MODULE_PATH})

find_package(ITK 4 REQUIRED)
include(${ITK_USE_FILE})

set(PDF_QUALITY_LEVEL "Screen" CACHE STRING "PDF Quality. Options are: Screen, Printer, PrePress")
#
# Options for PDF generation.
# resolution in dpi.
#
#  /screen   = low    resolution = Distiller "Screen" optimized
#  /ebook    = medium resolution = Distiller "eBook"
#  /printer  = high   resolution = Distiller "Print" optimized
#  /prepress = high   resolution = Distiller like "Print" with some error checking differences
#
if( PDF_QUALITY_LEVEL STREQUAL "Screen" OR PDF_QUALITY_LEVEL STREQUAL "" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS${PS2PDF_CONVERTER_VAL_DELIM}/screen" -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersionfalse")
endif()

if( PDF_QUALITY_LEVEL STREQUAL "Printer" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS${PS2PDF_CONVERTER_VAL_DELIM}/printer" -dUseCIEColor -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersiontrue")
endif()

if( PDF_QUALITY_LEVEL STREQUAL "PrePress" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS${PS2PDF_CONVERTER_VAL_DELIM}/prepress" "-dColorImageResolution${PS2PDF_CONVERTER_VAL_DELIM}600" "-dGrayImageResolution${PS2PDF_CONVERTER_VAL_DELIM}600" -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersiontrue")
endif()

option(DRAFT_WATERMARK "Add a draft watermark to the output." ON)
if(DRAFT_WATERMARK)
  set(SoftwareGuide_DRAFT_WATERMARK_LATEX_BOOLEAN "\\itkDraftWatermarktrue")
else()
  set(SoftwareGuide_DRAFT_WATERMARK_LATEX_BOOLEAN "\\itkDraftWatermarkfalse")
endif()

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
