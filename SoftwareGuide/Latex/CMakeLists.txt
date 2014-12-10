#
# Find LaTeX
#
find_package(LATEX)

#
# Verify that we found all the components we need
#
if(NOT PDFLATEX_COMPILER)
  message("PDFLatex compiler was not found. Please pass to advanced mode and provide its full path")
endif(NOT PDFLATEX_COMPILER)

if(NOT LATEX_COMPILER)
  message("Latex compiler was not found. Please pass to advanced mode and provide its full path")
endif(NOT LATEX_COMPILER)

if(NOT BIBTEX_COMPILER)
  message("BibTeX executable was not found. Please pass to advanced mode and provide its full path")
endif(NOT BIBTEX_COMPILER)

if(NOT DVIPS_CONVERTER)
  message("dvips executable was not found. Please pass to advanced mode and provide its full path")
endif(NOT DVIPS_CONVERTER)

if(NOT PS2PDF_CONVERTER)
  message("ps2pdf executable was not found. Please pass to advanced mode and provide its full path")
endif(NOT PS2PDF_CONVERTER)

if(NOT MAKEINDEX_COMPILER)
  message("makeindex executable was not found. Please pass to advanced mode and provide its full path")
endif(NOT MAKEINDEX_COMPILER)

set(DVIPS_CONVERTER_OPTIONS  -D600)

if(NOT UNIX)
  set(PS2PDF_CONVERTER_VAL_DELIM "#")
else()
  set(PS2PDF_CONVERTER_VAL_DELIM "=")
endif()

#
# File that defines the path to .cxx examples in ITK sources
#
configure_file(
  ${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in
  ${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
  )

set( CommonBook_Tex_SRCS
## Front Matter
  00-Preamble-Common.tex
  01-PrintedPreamble-Common.tex
  03-Abstract-Common.tex
  04-Contributors.tex
  )

set( Book1_Tex_SRCS
## Front Matter
  000-ITKSoftwareGuide-Book1.tex
  01-PrintedPreamble-Book1.tex
  02-Cover-Book1.tex
  03-Abstract-Book1.tex
## Introduction
  I01-Introduction.tex
  I02-Installation.tex
## Architecture
  A01-SystemOverview.tex
  A02-DataRepresentation.tex
  A03-SpatialObjects.tex
## Development Guidelines
  DG01-Iterators.tex
  DG02-ImageAdaptors.tex
  DG03-WriteAFilter.tex
  DG04-SoftwareProcess.tex
## Appendix
  AP01-Licenses.tex
  )

set( Book2_Tex_SRCS
## Front Matter
  001-ITKSoftwareGuide-Book2.tex
  01-PrintedPreamble-Book2.tex
  02-Cover-Book2.tex
  03-Abstract-Book2.tex
## Design and Functionality
  DF01-IO.tex
  DF02-Filtering.tex
  #A03a-AnisotropicDiffusionFiltering.tex
  DF03-Registration.tex
  DF04-Segmentation.tex
  DF05-Statistics.tex
  )

set( Tex_SRCS
## -- HACK TODO
#set   NOT_YET_SRCS # This needs to be added one at a time as they are cleaned up
  ImageMetrics.tex
  ImageInterpolators.tex
  Transforms.tex
  Visualization.tex
  WatershedSegmentation.tex

  DG05-MarketingMaterial.tex
  )

set( SoftwareGuide_Book1_Tex_SRCS "" )
foreach( _file ${Book1_Tex_SRCS} ${CommonBook_Tex_SRCS} )
  list( APPEND SoftwareGuide_Book1_Tex_SRCS ${SoftwareGuide_SOURCE_DIR}/Latex/${_file} )
endforeach()

set( SoftwareGuide_Book2_Tex_SRCS "" )
foreach( _file ${Book2_Tex_SRCS} ${CommonBook_Tex_SRCS} )
  list( APPEND SoftwareGuide_Book2_Tex_SRCS ${SoftwareGuide_SOURCE_DIR}/Latex/${_file} )
endforeach()

file( GLOB_RECURSE ITK_EXAMPLES_TEX_SRCS_NAMES ${SoftwareGuide_BINARY_DIR}/Examples/*.tex)

if(LATEX_COMPILER)

  if(NOT UNIX)
    set(ITK_TEXINPUTS ${SoftwareGuide_SOURCE_DIR}/../Latex;${SoftwareGuide_SOURCE_DIR};${SoftwareGuide_SOURCE_DIR}/Latex;${SoftwareGuide_SOURCE_DIR}/Art;${SoftwareGuide_BINARY_DIR};${SoftwareGuide_BINARY_DIR}/Examples;${SoftwareGuide_BINARY_DIR}/Art;${SoftwareGuide_BINARY_DIR}/Latex)

    configure_file(${SoftwareGuide_SOURCE_DIR}/LaTeXWrapper.bat.in
                   ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.bat)
    set(LATEX_WRAPPER1 ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.bat)
    set(LATEX_WRAPPER2 "")

    configure_file(${SoftwareGuide_SOURCE_DIR}/DvipsWrapper.bat.in
                   ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.bat)
    set(DVIPS_WRAPPER1 ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.bat)
    set(DVIPS_WRAPPER2 "")
  else(NOT UNIX)
    set(ITK_TEXINPUTS ${SoftwareGuide_SOURCE_DIR}/../Latex:${SoftwareGuide_SOURCE_DIR}:${SoftwareGuide_SOURCE_DIR}/Latex:${SoftwareGuide_SOURCE_DIR}/Art:${SoftwareGuide_BINARY_DIR}:${SoftwareGuide_BINARY_DIR}/Examples:${SoftwareGuide_BINARY_DIR}/Art:${SoftwareGuide_BINARY_DIR}/Latex)

    configure_file(${SoftwareGuide_SOURCE_DIR}/LaTeXWrapper.sh.in
                   ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh)
    set(LATEX_WRAPPER1 /bin/sh)
    set(LATEX_WRAPPER2 ${SoftwareGuide_BINARY_DIR}/LaTeXWrapper.sh)

    configure_file(${SoftwareGuide_SOURCE_DIR}/DvipsWrapper.sh.in
                   ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.sh)
    set(DVIPS_WRAPPER1 /bin/sh)
    set(DVIPS_WRAPPER2 ${SoftwareGuide_BINARY_DIR}/DvipsWrapper.sh)
  endif(NOT UNIX)

  add_custom_command( OUTPUT    000-ITKSoftwareGuide-Book1.dvi 000-ITKSoftwareGuide-Book1.aux
    COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/000-ITKSoftwareGuide-Book1.tex
    DEPENDS   ${SoftwareGuide_Book1_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS_NAMES} ${allEPS-DEPS}
    )
  add_custom_command( OUTPUT    001-ITKSoftwareGuide-Book2.dvi 001-ITKSoftwareGuide-Book2.aux
    COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/001-ITKSoftwareGuide-Book2.tex
    DEPENDS   ${SoftwareGuide_Book2_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS_NAMES} ${allEPS-DEPS}
    )

  if(BIBTEX_COMPILER)
    add_custom_command( OUTPUT    000-ITKSoftwareGuide-Book1.bbl
      COMMAND ${BIBTEX_COMPILER} 000-ITKSoftwareGuide-Book1
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/000-ITKSoftwareGuide-Book1.tex
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/000-ITKSoftwareGuide-Book1.tex
      DEPENDS 000-ITKSoftwareGuide-Book1.aux ${SoftwareGuide_SOURCE_DIR}/../Latex/Insight.bib
      )
    add_custom_command( OUTPUT    001-ITKSoftwareGuide-Book2.bbl
      COMMAND ${BIBTEX_COMPILER} 001-ITKSoftwareGuide-Book2
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/001-ITKSoftwareGuide-Book2.tex
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/001-ITKSoftwareGuide-Book2.tex
      DEPENDS 001-ITKSoftwareGuide-Book2.aux ${SoftwareGuide_SOURCE_DIR}/../Latex/Insight.bib
      )
  endif()

  if(MAKEINDEX_COMPILER)
    add_custom_command( OUTPUT    000-ITKSoftwareGuide-Book1.idx
      COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/000-ITKSoftwareGuide-Book1.tex
      DEPENDS   000-ITKSoftwareGuide-Book1.bbl ${allEPS-DEPS}
      )
    add_custom_command( OUTPUT    001-ITKSoftwareGuide-Book2.idx
      COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/001-ITKSoftwareGuide-Book2.tex
      DEPENDS   001-ITKSoftwareGuide-Book2.bbl ${allEPS-DEPS}
      )
    add_custom_command( OUTPUT    000-ITKSoftwareGuide-Book1.ind
      COMMAND   ${MAKEINDEX_COMPILER} 000-ITKSoftwareGuide-Book1
      DEPENDS   000-ITKSoftwareGuide-Book1.idx
      )
    add_custom_command( OUTPUT    001-ITKSoftwareGuide-Book2.ind
      COMMAND   ${MAKEINDEX_COMPILER} 001-ITKSoftwareGuide-Book2
      DEPENDS   001-ITKSoftwareGuide-Book2.idx
      )
  endif()

  if(DVIPS_CONVERTER)
    add_custom_command( OUTPUT    000-ITKSoftwareGuide-Book1.ps
      COMMAND   ${DVIPS_WRAPPER1} ${DVIPS_WRAPPER2} 000-ITKSoftwareGuide-Book1.dvi ${DVIPS_CONVERTER_OPTIONS} -o 000-ITKSoftwareGuide-Book1.ps
      DEPENDS   000-ITKSoftwareGuide-Book1.ind 000-ITKSoftwareGuide-Book1.bbl 000-ITKSoftwareGuide-Book1.dvi
      )
    add_custom_command( OUTPUT    001-ITKSoftwareGuide-Book2.ps
      COMMAND   ${DVIPS_WRAPPER1} ${DVIPS_WRAPPER2} 001-ITKSoftwareGuide-Book2.dvi ${DVIPS_CONVERTER_OPTIONS} -o 001-ITKSoftwareGuide-Book2.ps
      DEPENDS   001-ITKSoftwareGuide-Book2.ind 001-ITKSoftwareGuide-Book2.bbl 001-ITKSoftwareGuide-Book2.dvi
      )
  endif()

  if(PS2PDF_CONVERTER)
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book1.pdf
      COMMAND   ${PS2PDF_CONVERTER} ${PS2PDF_CONVERTER_OPTIONS} 000-ITKSoftwareGuide-Book1.ps ITKSoftwareGuide-Book1.pdf
      DEPENDS   000-ITKSoftwareGuide-Book1.ps
      )
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book2.pdf
      COMMAND   ${PS2PDF_CONVERTER} ${PS2PDF_CONVERTER_OPTIONS} 001-ITKSoftwareGuide-Book2.ps ITKSoftwareGuide-Book2.pdf
      DEPENDS   001-ITKSoftwareGuide-Book2.ps
      )
  endif()

endif(LATEX_COMPILER)

add_custom_target(SoftwareGuideBook1PDF ALL
  COMMAND ${CMAKE_COMMAND} -E echo "Building Software Guide Book1 PDF"
  DEPENDS ITKSoftwareGuide-Book1.pdf )
add_custom_target(SoftwareGuideBook2PDF ALL
  COMMAND ${CMAKE_COMMAND} -E echo "Building Software Guide Book2 PDF"
  DEPENDS ITKSoftwareGuide-Book2.pdf )
