#####################################################
#
#   This is the root SoftwareGuide CMakeLists file.
#
#####################################################

CMAKE_MINIMUM_REQUIRED(VERSION 1.6)

PROJECT(SoftwareGuide)


#
# File that defines the path to .cxx examples in ITK sources
#
CONFIGURE_FILE(
${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in 
${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
)



# 
# Directory where .cxx files are converted 
# into .tex by a perl script.
#
SUBDIRS(Examples)



# 
# Directory with images and diagrams
#
SUBDIRS(Art)



# 
# Directory with tex files 
#
SUBDIRS(Latex)



