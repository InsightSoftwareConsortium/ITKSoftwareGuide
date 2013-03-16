
#
# Find LaTeX
#
include(${CMAKE_ROOT}/Modules/FindLATEX.cmake)


#
# Verify that we found all the components we need
#
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
if( PDF_QUALITY_LEVEL STREQUAL "Screen" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS=/screen" -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersionfalse")
endif( PDF_QUALITY_LEVEL STREQUAL "Screen" )

if( PDF_QUALITY_LEVEL STREQUAL "Printer" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS=/printer" -r600)
  set(SoftwareGuide_PRINTED_VERSION_LATEX_BOOLEAN "\\itkPrintedVersiontrue")
endif( PDF_QUALITY_LEVEL STREQUAL "Printer" )

if( PDF_QUALITY_LEVEL STREQUAL "PrePress" )
  set(PS2PDF_CONVERTER_OPTIONS "-dPDFSETTINGS=/prepress" "-dColorImageResolution=600" "-dGrayImageResolution=600" -r600)
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

add_custom_target(SoftwareGuideLatex  ALL echo)

set( Tex_SRCS
  Abstract.tex
  Applications.tex
  AnisotropicDiffusionFiltering.tex
  Contributors.tex
  DataRepresentation.tex
  Filtering.tex
)
set( NOT_YET_SRCS # This needs to be added one at a time as they are cleaned up
  GUI.tex
  ImageMetrics.tex
  ImageInterpolators.tex
  ImageAdaptors.tex
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
  SpatialObjects.tex
  Statistics.tex
  SystemOverview.tex
  Transforms.tex
  Visualization.tex
  Wrapping.tex
  WatershedSegmentation.tex
)

foreach( file ${Tex_SRCS})
set( SoftwareGuide_Tex_SRCS
   ${SoftwareGuide_Tex_SRCS} ${SoftwareGuide_SOURCE_DIR}/Latex/${file}
 )
endforeach( file )

file( GLOB_RECURSE ITK_EXAMPLES_TEX_SRCS_NAMES ${CMAKE_CURRENT_SOURCE_DIR}/Examples/*.tex)

foreach( exampletexname ${ITK_EXAMPLES_TEX_SRCS_NAMES})
  set( ITK_EXAMPLES_TEX_SRCS ${ITK_EXAMPLES_TEX_SRCS} ${SoftwareGuide_BINARY_DIR}/Examples/${exampletexname} )
endforeach( exampletexname )

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
    SOURCE    ${SoftwareGuide_Tex_SRCS}  ${ITK_EXAMPLES_TEX_SRCS} ${ITK_EXAMPLES_TEX_SRCS}
    COMMAND   ${LATEX_WRAPPER1}
    ARGS      ${LATEX_WRAPPER2}
              ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
    TARGET    SoftwareGuideLatex
    DEPENDS   ${SoftwareGuide_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS}
    OUTPUTS   SoftwareGuide.dvi
  )

  if(DVIPS_CONVERTER)
    add_custom_command(
      SOURCE    SoftwareGuide.dvi
      COMMAND   ${DVIPS_WRAPPER1}
      ARGS      ${DVIPS_WRAPPER2}
                SoftwareGuide.dvi ${DVIPS_CONVERTER_OPTIONS} -o  SoftwareGuide.ps
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.ind SoftwareGuide.bbl
      OUTPUTS   SoftwareGuide.ps
    )
  endif(DVIPS_CONVERTER)

  if(PS2PDF_CONVERTER)
    add_custom_command(
      SOURCE    SoftwareGuide.ps
      COMMAND   ${PS2PDF_CONVERTER}
      ARGS      ${PS2PDF_CONVERTER_OPTIONS} SoftwareGuide.ps
      TARGET    SoftwareGuideLatex
      OUTPUTS   SoftwareGuide.pdf
    )
    add_custom_command(
      SOURCE    SoftwareGuideLatex
      COMMAND   echo
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.pdf
    )
  endif(PS2PDF_CONVERTER)

  if(MAKEINDEX_COMPILER)
    add_custom_command(
      SOURCE    ${SoftwareGuide_Tex_SRCS}  ${ITK_EXAMPLES_TEX_SRCS}
      COMMAND   ${LATEX_WRAPPER1}
      ARGS      ${LATEX_WRAPPER2}
                ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
      TARGET    SoftwareGuideLatex
      DEPENDS   SoftwareGuide.bbl
      OUTPUTS   SoftwareGuide.idx
    )
    add_custom_command(
      SOURCE    SoftwareGuide.idx
      COMMAND   ${MAKEINDEX_COMPILER}
      ARGS      SoftwareGuide
      TARGET    SoftwareGuideLatex
      OUTPUTS   SoftwareGuide.ind
    )

  endif(MAKEINDEX_COMPILER)

  if(BIBTEX_COMPILER)
    add_custom_command(
      SOURCE    ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex
      COMMAND   ${BIBTEX_COMPILER}
      ARGS      SoftwareGuide
      TARGET    SoftwareGuideLatex
      DEPENDS   ${SoftwareGuide_SOURCE_DIR}/Latex/SoftwareGuide.tex ${SoftwareGuide_SOURCE_DIR}/../Latex/Insight.bib
      OUTPUTS   SoftwareGuide.bbl
    )
  endif(BIBTEX_COMPILER)


endif(LATEX_COMPILER)



