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



#
#
#  Error checking for all the components
#
#
IF(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)
  MESSAGE("ImageMagick convert utility was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT IMAGEMAGICK_CONVERT_EXECUTABLE)


IF(NOT LATEX_COMPILE)
  MESSAGE("Latex compiler was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT LATEX_COMPILE)

IF(NOT BIBTEX_COMPILE)
  MESSAGE("BibTeX executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT BIBTEX_COMPILE)

IF(NOT DVIPS_COMPILE)
  MESSAGE("dvips executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT DVIPS_COMPILE)

IF(NOT PS2PDF_COMPILE)
  MESSAGE("ps2pdf executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT PS2PDF_COMPILE)

IF(NOT MAKEINDEX_COMPILE)
  MESSAGE("makeindex executable was not found. Please pass to advanced mode and provide its full path")
ENDIF(NOT MAKEINDEX_COMPILE)





