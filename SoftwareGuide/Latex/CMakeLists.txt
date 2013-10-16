
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

if(NOT UNIX)
  set(PS2PDF_CONVERTER_VAL_DELIM "#")
else(NOT UNIX)
  set(PS2PDF_CONVERTER_VAL_DELIM "=")
endif(NOT UNIX)

if( PDF_QUALITY_LEVEL STREQUAL "Screen" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS${PS2PDF_CONVERTER_VAL_DELIM}/screen" -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersionfalse")
endif( PDF_QUALITY_LEVEL STREQUAL "Screen" )

if( PDF_QUALITY_LEVEL STREQUAL "Printer" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS${PS2PDF_CONVERTER_VAL_DELIM}/printer" -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersiontrue")
endif( PDF_QUALITY_LEVEL STREQUAL "Printer" )

if( PDF_QUALITY_LEVEL STREQUAL "PrePress" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS${PS2PDF_CONVERTER_VAL_DELIM}/prepress" "-dColorImageResolution${PS2PDF_CONVERTER_VAL_DELIM}600" "-dGrayImageResolution${PS2PDF_CONVERTER_VAL_DELIM}600" -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersiontrue")
endif( PDF_QUALITY_LEVEL STREQUAL "PrePress" )

set(DVIPS_CONVERTER_OPTIONS  -D600)

#
# File that defines the path to .cxx examples in ITK sources
#
configure_file(
${SoftwareGuide_SOURCE_DIR}/SoftwareGuideConfiguration.tex.in
${SoftwareGuide_BINARY_DIR}/SoftwareGuideConfiguration.tex
)


set( Tex_SRCS
## Front Matter
  00-SoftwareGuide.tex
  01-PrintedPreamble.tex
  02-Cover.tex
  03-Abstract.tex
  04-Contributors.tex
## Introduction
  05-Introduction.tex
  06-Installation.tex
  07-SystemOverview.tex
## -- HACK TODO
#set( NOT_YET_SRCS # This needs to be added one at a time as they are cleaned up
  ImageMetrics.tex
  ImageInterpolators.tex
  Transforms.tex
  Visualization.tex
  WatershedSegmentation.tex

## Users Guide
UG01-DataRepresentation.tex
UG02-SpatialObjects.tex
UG03-Filtering.tex
UG03a-AnisotropicDiffusionFiltering.tex
UG04-IO.tex
UG05-Registration.tex
UG06-Segmentation.tex
UG07-Statistics.tex

## Developers Guide
DG01-Iterators.tex
DG02-ImageAdaptors.tex
DG03-WriteAFilter.tex
DG04-SoftwareProcess.tex
DG05-MarketingMaterial.tex

## Appendix
AP01-Licenses.tex

)


set ( SoftwareGuide_Tex_SRCS "" )
foreach( file ${Tex_SRCS})
#message(STATUS "APPENDING: ${SoftwareGuide_SOURCE_DIR}/Latex/${file}")
  set( SoftwareGuide_Tex_SRCS
   ${SoftwareGuide_Tex_SRCS} ${SoftwareGuide_SOURCE_DIR}/Latex/${file}
 )
endforeach( file )

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

  add_custom_command(
    OUTPUT    00-SoftwareGuide.dvi
    COMMAND   ${LATEX_WRAPPER1}
    ARGS      ${LATEX_WRAPPER2}
              ${SoftwareGuide_SOURCE_DIR}/Latex/00-SoftwareGuide.tex
    DEPENDS   ${SoftwareGuide_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS_NAMES} ${allEPS-DEPS}
  )

  if(DVIPS_CONVERTER)
    add_custom_command(
      OUTPUT    00-SoftwareGuide.ps
      COMMAND   ${DVIPS_WRAPPER1}
      ARGS      ${DVIPS_WRAPPER2}
                00-SoftwareGuide.dvi ${DVIPS_CONVERTER_OPTIONS} -o 00-SoftwareGuide.ps
      DEPENDS   00-SoftwareGuide.idx 00-SoftwareGuide.ind 00-SoftwareGuide.bbl 00-SoftwareGuide.dvi
    )
  endif(DVIPS_CONVERTER)

  if(PS2PDF_CONVERTER)
    add_custom_command(
      OUTPUT    00-SoftwareGuide.pdf
      COMMAND   ${PS2PDF_CONVERTER}
      ARGS      ${PS2PDF_CONVERTER_OPTIONS} 00-SoftwareGuide.ps 00-SoftwareGuide.pdf
      DEPENDS   00-SoftwareGuide.idx 00-SoftwareGuide.ind 00-SoftwareGuide.bbl 00-SoftwareGuide.ps
    )
  endif(PS2PDF_CONVERTER)

  if(MAKEINDEX_COMPILER)
    add_custom_command(
      OUTPUT    00-SoftwareGuide.idx
      COMMAND   ${LATEX_WRAPPER1}
      ARGS      ${LATEX_WRAPPER2}
                ${SoftwareGuide_SOURCE_DIR}/Latex/00-SoftwareGuide.tex
      DEPENDS   00-SoftwareGuide.bbl ${allEPS-DEPS}
    )
    add_custom_command(
      OUTPUT    00-SoftwareGuide.ind
      COMMAND   ${MAKEINDEX_COMPILER}
      ARGS      00-SoftwareGuide
      DEPENDS   00-SoftwareGuide.idx
    )

  endif(MAKEINDEX_COMPILER)

  if(BIBTEX_COMPILER)
    message(STATUS "Running: ${BIBTEX_COMPILER} 00-SoftwareGuide ")
    add_custom_command(
      OUTPUT    00-SoftwareGuide.bbl
      COMMAND   ${BIBTEX_COMPILER}
      ARGS      00-SoftwareGuide
      DEPENDS   ${SoftwareGuide_SOURCE_DIR}/Latex/00-SoftwareGuide.tex ${SoftwareGuide_SOURCE_DIR}/../Latex/Insight.bib
    )
  endif(BIBTEX_COMPILER)


endif(LATEX_COMPILER)

add_custom_target(SoftwareGuideLatex ALL
  COMMAND ${CMAKE_COMMAND} -E echo "Building software Guide PDF"
  DEPENDS 00-SoftwareGuide.pdf )


