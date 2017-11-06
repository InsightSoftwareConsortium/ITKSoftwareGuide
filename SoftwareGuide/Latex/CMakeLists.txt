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

#
# Build HTML version
#
# NOTE: if the error: "\theHchapter undefined" is encountered, see
#
# https://tex.stackexchange.com/questions/140008/latex-error-thehchapter-undefined-when-using-tex4ht-with-hyperref-and-appendix
#
# For a fix for tex4ht's support for the appendix package.
#
option( GENERATE_HTML "Generate HTML version of the code with tex4ht." OFF )
if( GENERATE_HTML )
  find_program( HTLATEX_CONVERTER htlatex )
  if( NOT HTLATEX_CONVERTER )
    message( SEND_ERROR "htlatex script was not found. Please install tex4ht and provide its full path.  Note that the htlatex script is sometimes not installed into the PATH by default." )
  endif()
endif()

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
  ITKSoftwareGuide-Book1.tex
  01-PrintedPreamble-Book1.tex
  02-Cover-Book1.tex
  03-Abstract-Book1.tex
## Introduction
  ./Introduction/Introduction.tex
  ./Introduction/Installation.tex
## Architecture
  ./Architecture/SystemOverview.tex
  ./Architecture/DataRepresentation.tex
  ./Architecture/SpatialObjects.tex
  ./Architecture/Iterators.tex
  ./Architecture/ImageAdaptors.tex
## Development Guidelines
  ./DevelopmentGuidelines/WriteAFilter.tex
  ./DevelopmentGuidelines/CreateAModule.tex
  ./DevelopmentGuidelines/SoftwareProcess.tex
## Appendix
  ./Appendices/Licenses.tex
  ./Appendices/CodingStyleGuide.tex
  )

set( Book2_Tex_SRCS
## Front Matter
  ITKSoftwareGuide-Book2.tex
  01-PrintedPreamble-Book2.tex
  02-Cover-Book2.tex
  03-Abstract-Book2.tex
## Design and Functionality
  ./DesignAndFunctionality/IO.tex
  ./DesignAndFunctionality/Filtering.tex
  #./DesignAndFunctionality/AnisotropicDiffusionFiltering.tex
  ./DesignAndFunctionality/Registration.tex
  ./DesignAndFunctionality/Segmentation.tex
  ./DesignAndFunctionality/Statistics.tex
  )

set( Tex_SRCS
## -- HACK TODO
#set   NOT_YET_SRCS # This needs to be added one at a time as they are cleaned up
  ./DesignAndFunctionality/ImageMetrics.tex
  ./DesignAndFunctionality/ImageInterpolators.tex
  ./DesignAndFunctionality/Transforms.tex
  Visualization.tex
  ./DesignAndFunctionality/WatershedSegmentation.tex

  MarketingMaterial.tex
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

  add_custom_command( OUTPUT    ITKSoftwareGuide-Book1.dvi ITKSoftwareGuide-Book1.aux
    COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book1.tex
    DEPENDS   ${SoftwareGuide_Book1_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS_NAMES}
    )
  add_custom_command( OUTPUT    ITKSoftwareGuide-Book2.dvi ITKSoftwareGuide-Book2.aux
    COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book2.tex
    DEPENDS   ${SoftwareGuide_Book2_Tex_SRCS} ${ITK_EXAMPLES_TEX_SRCS_NAMES}
    )

  if(BIBTEX_COMPILER)
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book1.bbl
      COMMAND ${BIBTEX_COMPILER} ITKSoftwareGuide-Book1
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book1.tex
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book1.tex
      DEPENDS ITKSoftwareGuide-Book1.aux ${SoftwareGuide_SOURCE_DIR}/../Latex/Insight.bib
      )
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book2.bbl
      COMMAND ${BIBTEX_COMPILER} ITKSoftwareGuide-Book2
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book2.tex
      COMMAND ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book2.tex
      DEPENDS ITKSoftwareGuide-Book2.aux ${SoftwareGuide_SOURCE_DIR}/../Latex/Insight.bib
      )
  endif()

  if(MAKEINDEX_COMPILER)
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book1.idx
      COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book1.tex
      DEPENDS   ITKSoftwareGuide-Book1.bbl
      )
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book2.idx
      COMMAND   ${LATEX_WRAPPER1} ${LATEX_WRAPPER2} ${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book2.tex
      DEPENDS   ITKSoftwareGuide-Book2.bbl
      )
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book1.ind
      COMMAND   ${MAKEINDEX_COMPILER} ITKSoftwareGuide-Book1
      DEPENDS   ITKSoftwareGuide-Book1.idx
      )
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book2.ind
      COMMAND   ${MAKEINDEX_COMPILER} ITKSoftwareGuide-Book2
      DEPENDS   ITKSoftwareGuide-Book2.idx
      )
  endif()

  if(DVIPS_CONVERTER)
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book1.ps
      COMMAND   ${DVIPS_WRAPPER1} ${DVIPS_WRAPPER2} ITKSoftwareGuide-Book1.dvi ${DVIPS_CONVERTER_OPTIONS} -o ITKSoftwareGuide-Book1.ps
      DEPENDS   ITKSoftwareGuide-Book1.ind ITKSoftwareGuide-Book1.bbl ITKSoftwareGuide-Book1.dvi
      )
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book2.ps
      COMMAND   ${DVIPS_WRAPPER1} ${DVIPS_WRAPPER2} ITKSoftwareGuide-Book2.dvi ${DVIPS_CONVERTER_OPTIONS} -o ITKSoftwareGuide-Book2.ps
      DEPENDS   ITKSoftwareGuide-Book2.ind ITKSoftwareGuide-Book2.bbl ITKSoftwareGuide-Book2.dvi
      )
  endif()

  if(PS2PDF_CONVERTER)
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book1.pdf
      COMMAND   ${PS2PDF_CONVERTER} ${PS2PDF_CONVERTER_OPTIONS} ITKSoftwareGuide-Book1.ps ITKSoftwareGuide-Book1.pdf
      DEPENDS   ITKSoftwareGuide-Book1.ps
      )
    add_custom_command( OUTPUT    ITKSoftwareGuide-Book2.pdf
      COMMAND   ${PS2PDF_CONVERTER} ${PS2PDF_CONVERTER_OPTIONS} ITKSoftwareGuide-Book2.ps ITKSoftwareGuide-Book2.pdf
      DEPENDS   ITKSoftwareGuide-Book2.ps
      )
  endif()

  if(GENERATE_HTML)
    configure_file(${SoftwareGuide_SOURCE_DIR}/HTLaTeXWrapper.sh.in
                   ${SoftwareGuide_BINARY_DIR}/HTLaTeXWrapper.sh)
    configure_file(${SoftwareGuide_SOURCE_DIR}/HTLaTeXWrapper.bat.in
                   ${SoftwareGuide_BINARY_DIR}/HTLaTeXWrapper.bat)
    set(_html_output_dir "${CMAKE_CURRENT_BINARY_DIR}/html" )
    file(MAKE_DIRECTORY "${_html_output_dir}/Book1" "${_html_output_dir}/Book2")
    file(COPY index.html DESTINATION "${_html_output_dir}")
    if(NOT UNIX)
      add_custom_command( OUTPUT ${_html_output_dir}/Book1/ITKSoftwareGuide-Book1.html
        COMMAND ${SoftwareGuide_BINARY_DIR}/HTLaTeXWrapper.bat "${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book1.tex"
        DEPENDS ITKSoftwareGuide-Book1.pdf
        WORKING_DIRECTORY "${_html_output_dir}/Book1"
        )
      add_custom_command( OUTPUT ${_html_output_dir}/Book2/ITKSoftwareGuide-Book2.html
        COMMAND ${SoftwareGuide_BINARY_DIR}/HTLaTeXWrapper.bat "${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book2.tex"
        DEPENDS ITKSoftwareGuide-Book2.pdf
        WORKING_DIRECTORY "${_html_output_dir}/Book2"
        )
    else()
      add_custom_command( OUTPUT ${_html_output_dir}/Book1/ITKSoftwareGuide-Book1.html
        COMMAND ${SoftwareGuide_BINARY_DIR}/HTLaTeXWrapper.sh "${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book1.tex"
        DEPENDS ITKSoftwareGuide-Book1.pdf
        WORKING_DIRECTORY "${_html_output_dir}/Book1"
        )
      add_custom_command( OUTPUT ${_html_output_dir}/Book2/ITKSoftwareGuide-Book2.html
        COMMAND ${SoftwareGuide_BINARY_DIR}/HTLaTeXWrapper.sh "${SoftwareGuide_SOURCE_DIR}/Latex/ITKSoftwareGuide-Book2.tex"
        DEPENDS ITKSoftwareGuide-Book2.pdf
        WORKING_DIRECTORY "${_html_output_dir}/Book2"
        )
    endif()
    add_custom_target(SoftwareGuideBook1HTML ALL
      COMMAND ${CMAKE_COMMAND} -E echo "Building Software Guide Book1 HTML"
      DEPENDS "${_html_output_dir}/Book1/ITKSoftwareGuide-Book1.html"
      )
    add_custom_target(SoftwareGuideBook2HTML ALL
      COMMAND ${CMAKE_COMMAND} -E echo "Building Software Guide Book2 HTML"
      DEPENDS "${_html_output_dir}/Book2/ITKSoftwareGuide-Book2.html"
      )
  endif()

endif(LATEX_COMPILER)

add_custom_target(SoftwareGuideBook1PDF ALL
  COMMAND ${CMAKE_COMMAND} -E echo "Building Software Guide Book1 PDF"
  DEPENDS ITKSoftwareGuide-Book1.pdf )
add_custom_target(SoftwareGuideBook2PDF ALL
  COMMAND ${CMAKE_COMMAND} -E echo "Building Software Guide Book2 PDF"
  DEPENDS ITKSoftwareGuide-Book2.pdf )
