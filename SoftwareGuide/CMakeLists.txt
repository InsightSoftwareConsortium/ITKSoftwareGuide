
PROJECT(SoftwareGuide)


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



SUBDIRS(Examples)

#
# Find perl script for parsing cxx files and generate latex
#
FIND_PROGRAM(PERLCXXPARSER
  NAMES ParseCxxExamples.pl ${SoftwareGuide_SOURCE_DIR}/ParseCxxExamples.pl
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


SET( ITK_EXAMPLES_SRCS
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image2.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image3.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Image/Image4.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/PointSet1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/PointSet2.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/Mesh1.cxx
  ${ITK_SOURCE_DIR}/Examples/DataRepresentation/Mesh/Mesh2.cxx
  ${ITK_SOURCE_DIR}/Examples/Filtering/*.cxx
)


SET( ITK_EXAMPLES_TEX_SRCS
  ${SoftwareGuide_BINARY_DIR}/Examples/Image1.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/Image2.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/Image3.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/Image4.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/PointSet1.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/PointSet2.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/Mesh1.tex
  ${SoftwareGuide_BINARY_DIR}/Examples/Mesh2.tex
)




SET( CxxExamplesListFile  
  ${SoftwareGuide_BINARY_DIR}/Examples/ExamplesList.txt
 )



IF( PERLCXXPARSER )

  ADD_CUSTOM_COMMAND( 
    SOURCE    ${ITK_EXAMPLES_SRCS}
    COMMAND   find
    ARGS      ${ITK_SOURCE_DIR}/Examples   -name '*.cxx' -print > ${CxxExamplesListFile}
    TARGET    SoftwareGuide
    DEPENDS   ${ITK_EXAMPLES_SRCS} 
    OUTPUTS   ${CxxExamplesListFile}
  )

  ADD_CUSTOM_COMMAND( 
    SOURCE    ${ITK_EXAMPLES_SRCS}
    COMMAND   ${PERLCXXPARSER}
    ARGS      ${CxxExamplesListFile}   ${SoftwareGuide_BINARY_DIR}/Examples 
    TARGET    SoftwareGuide
    DEPENDS   ${ITK_EXAMPLES_SRCS} ${CxxExamplesListFile}
    OUTPUTS   ${ITK_EXAMPLES_TEX_SRCS}
  )

ENDIF( PERLCXXPARSER )





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
    DEPENDS   ${SoftwareGuide_Tex_SRCS}  ${ITK_EXAMPLES_TEX_SRCS}
    OUTPUTS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
  )


  IF(DVIPDF_COMPILE)
    ADD_CUSTOM_COMMAND( 
      SOURCE    ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
      COMMAND   ${DVIPDF_COMPILE}
      ARGS      ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi
      TARGET    SoftwareGuide
      DEPENDS   ${SoftwareGuide_BINARY_DIR}/SoftwareGuide.dvi ${SoftwareGuide_Tex_SRCS}
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



