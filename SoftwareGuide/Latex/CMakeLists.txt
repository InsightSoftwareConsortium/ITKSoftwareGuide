
# 
# Find LaTeX
#
INCLUDE (${CMAKE_ROOT}/Modules/FindLATEX.cmake)


#
# Options for PDF generation. 
# resolution in dpi.
#
SET(DVIPDF_COMPILE_OPTIONS "-r600x600")

#
# File that defines the path to .cxx examples in ITK sources
#
CONFIGURE_FILE(
${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in 
${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
)



ADD_CUSTOM_TARGET(SoftwareGuideLatex  ALL echo)



SET( Tex_SRCS 
  Abstract.tex
  Applications.tex
  AnisotropicDiffusionFiltering.tex
  DataRepresentation.tex
  Filtering.tex
  GUI.tex
  ImageMetrics.tex
  ImageInterpolators.tex
  Infrastructure.tex
  Installation.tex
  Introduction.tex
  IO.tex
  Iterators.tex
  Numerics.tex
  Registration.tex
  Segmentation.tex
  SoftwareGuide.tex
  SoftwareProcess.tex
  SystemOverview.tex
  Visualization.tex
  Wrapping.tex
  WatershedSegmentation.tex
)

FOREACH( file ${Tex_SRCS})
SET( SoftwareGuide_Tex_SRCS  
   ${SoftwareGuide_Tex_SRCS} ${SoftwareGuide_SOURCE_DIR}/Latex/${file}
 )
ENDFOREACH( file )


SET( ITK_EXAMPLES_TEX_SRCS ${SoftwareGuide_BINARY_DIR}/Examples/*.tex )

SET( CxxExamplesListFile  
  ${SoftwareGuide_BINARY_DIR}/Examples/ExamplesList.txt
 )



IF(LATEX_COMPILE)

  SET(ITK_TEXINPUTS ${SoftwareGuide_SOURCE_DIR}:${SoftwareGuide_SOURCE_DIR}/Latex:${SoftwareGuide_SOURCE_DIR}/Art:${SoftwareGuide_BINARY_DIR}:${SoftwareGuide_BINARY_DIR}/Examples:${SoftwareGuide_BINARY_DIR}/Art:${SoftwareGuide_BINARY_DIR}/Latex)

  CONFIGURE_FILE(${SoftwareGuide_SOURCE_DIR}/LaTeXWrapper.sh.in
                 ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh)

  MESSAGE("test for dependencies on the examples tex")
  MESSAGE(${ITK_EXAMPLES_TEX_SRCS})

  ADD_CUSTOM_COMMAND( 
    SOURCE    ${SoftwareGuide_Tex_SRCS}  ${ITK_EXAMPLES_TEX_SRCS} ${ITK_EXAMPLES_TEX_SRCS}
    COMMAND   /bin/sh
    ARGS      ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh
              ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
    TARGET    SoftwareGuideLatex
    DEPENDS   ${SoftwareGuide_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS}
    OUTPUTS   SoftwareGuide.dvi
  )

  IF(DVIPDF_COMPILE)
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuide.dvi
      COMMAND   ${DVIPDF_COMPILE}
      ARGS      ${DVIPDF_COMPILE_OPTIONS} SoftwareGuide.dvi
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.ind SoftwareGuide.bbl
      OUTPUTS   SoftwareGuide.pdf
    )
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuideLatex
      COMMAND   echo
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.pdf
    )
  ENDIF(DVIPDF_COMPILE)

  IF(MAKEINDEX_COMPILE)
    ADD_CUSTOM_COMMAND( 
      SOURCE    ${SoftwareGuide_Tex_SRCS}  ${ITK_EXAMPLES_TEX_SRCS} 
      COMMAND   /bin/sh
      ARGS      ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh
                ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
      TARGET    SoftwareGuideLatex
      OUTPUTS   SoftwareGuide.idx
    )
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuide.idx
      COMMAND   ${MAKEINDEX_COMPILE}
      ARGS      SoftwareGuide
      TARGET    SoftwareGuideLatex
      OUTPUTS   SoftwareGuide.ind
    )

  ENDIF(MAKEINDEX_COMPILE)

  IF(BIBTEX_COMPILE)
    ADD_CUSTOM_COMMAND( 
      SOURCE    SoftwareGuide.aux
      COMMAND   ${BIBTEX_COMPILE}
      ARGS      SoftwareGuide
      TARGET    SoftwareGuideLatex
      OUTPUTS   SoftwareGuide.bbl
    )
  ENDIF(BIBTEX_COMPILE)


ENDIF(LATEX_COMPILE)



