
PROJECT(SoftwareGuide)


# 
# Find Doxygen
#
INCLUDE (${CMAKE_ROOT}/Modules/FindDoxygen.cmake)

# 
# Find LaTeX
#
INCLUDE (${CMAKE_ROOT}/Modules/FindLATEX.cmake)


# 
# Find ITK Sources
#
FIND_PATH(ITK_SOURCE_DIR UseITK.cmake.in)



#
# File that defines the path to .cxx examples in ITK sources
#
CONFIGURE_FILE(
${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in 
${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
)


#
# Configuration file for Doxygen
#
CONFIGURE_FILE(
${SoftwareGuide_SOURCE_DIR}/doxygen.config.in
${SoftwareGuide_BINARY_DIR}/doxygen.config
)




ADD_CUSTOM_TARGET(SoftwareGuideDoxygen  ALL ${DOXYGEN} ${SoftwareGuide_BINARY_DIR}/doxygen.config)


SET( SoftwareGuide_Dox_SRCS 
  ${SoftwareGuide_SOURCE_DIR}/Examples/DataRepresentationImagePage.dox
  ${SoftwareGuide_SOURCE_DIR}/Examples/DataRepresentationMeshPage.dox
  ${SoftwareGuide_SOURCE_DIR}/Examples/DataRepresentationPointSetPage.dox
  ${SoftwareGuide_SOURCE_DIR}/Examples/FilteringImages.dox
)

SET( SoftwareGuide_DoxTex_SRCS 
  ${SoftwareGuide_BINARY_DIR}/Examples/DataRepresentationImagePage.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/DataRepresentationMeshPage.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/DataRepresentationPointSetPage.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/FilteringImages.tex
)


ADD_CUSTOM_COMMAND( 
    SOURCE    ${SoftwareGuide_BINARY_DIR}/doxygen.config
    COMMAND   ${DOXYGEN}
    ARGS      ${SoftwareGuide_BINARY_DIR}/doxygen.config
    TARGET    SoftwareGuideDoxygen
    DEPENDS   ${SoftwareGuide_Dox_SRCS}
    OUTPUTS   ${SoftwareGuide_DoxTex_SRCS}
  )



ADD_CUSTOM_TARGET(SoftwareGuide  ALL echo)


SET( SoftwareGuide_Tex_SRCS 
  ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.tex
  ${SoftwareGuide_SOURCE_DIR}/Abstract.tex
  ${SoftwareGuide_SOURCE_DIR}/Applications.tex
  ${SoftwareGuide_SOURCE_DIR}/DataRepresentation.tex
  ${SoftwareGuide_SOURCE_DIR}/Filtering.tex
  ${SoftwareGuide_SOURCE_DIR}/GUI.tex
  ${SoftwareGuide_SOURCE_DIR}/Infrastructure.tex
  ${SoftwareGuide_SOURCE_DIR}/Installation.tex
  ${SoftwareGuide_SOURCE_DIR}/Introduction.tex
  ${SoftwareGuide_SOURCE_DIR}/IO.tex
  ${SoftwareGuide_SOURCE_DIR}/Iterators.tex
  ${SoftwareGuide_SOURCE_DIR}/Numerics.tex
  ${SoftwareGuide_SOURCE_DIR}/Registration.tex
  ${SoftwareGuide_SOURCE_DIR}/Segmentation.tex
  ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.tex
  ${SoftwareGuide_SOURCE_DIR}/SoftwareProcess.tex
  ${SoftwareGuide_SOURCE_DIR}/SystemOverview.tex
  ${SoftwareGuide_SOURCE_DIR}/Visualization.tex
  ${SoftwareGuide_SOURCE_DIR}/Wrapping.tex
)


 
IF(LATEX_COMPILE)
  SET(ITK_TEXINPUTS ${SoftwareGuide_SOURCE_DIR}:${SoftwareGuide_BINARY_DIR}:${SoftwareGuide_BINARY_DIR}/Examples)
  CONFIGURE_FILE(${SoftwareGuide_SOURCE_DIR}/LaTeXWrapper.sh.in
                 ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh)
  ADD_CUSTOM_COMMAND( 
    SOURCE    ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.tex
    COMMAND   /bin/sh
    ARGS      ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh
              ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.tex
    TARGET    SoftwareGuide
    DEPENDS   SoftwareGuideDoxygen ${SoftwareGuide_SRCS}
    OUTPUTS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
  )


  IF(DVIPDF_COMPILE)
    ADD_CUSTOM_COMMAND( 
      SOURCE    ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
      COMMAND   ${DVIPDF_COMPILE}
      ARGS      ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
      TARGET    SoftwareGuide
      DEPENDS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
      OUTPUTS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.pdf
    )
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuide
      COMMAND   echo
      TARGET    SoftwareGuide
      DEPENDS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.pdf
    )
  ENDIF(DVIPDF_COMPILE)
ENDIF(LATEX_COMPILE)



