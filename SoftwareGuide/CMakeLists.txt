
PROJECT(SoftwareGuide)

CONFIGURE_FILE(
${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in 
${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
)


# 
# Find LaTeX
#
INCLUDE (${CMAKE_ROOT}/Modules/FindLATEX.cmake)


# 
# Find ITK
#
INCLUDE (${CMAKE_ROOT}/Modules/FindITK.cmake)
IF (USE_ITK_FILE)
  INCLUDE(${USE_ITK_FILE})
ENDIF(USE_ITK_FILE)

ADD_CUSTOM_TARGET(SoftwareGuide  ALL echo)

IF(LATEX_COMPILE)
  ADD_CUSTOM_COMMAND( 
    SOURCE    ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.tex
    COMMAND   ${LATEX_COMPILE}
    ARGS      ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.tex
    TARGET    SoftwareGuide
    DEPENDS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.tex
    OUTPUTS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
  )


  IF(DVIPDF_COMPILE)
    ADD_CUSTOM_COMMAND( 
      SOURCE    ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.dvi
      COMMAND   ${DVIPDF_COMPILE}
      ARGS      ${SoftwareGuide_SOURCE_DIR}/SoftwareGuide.dvi
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



