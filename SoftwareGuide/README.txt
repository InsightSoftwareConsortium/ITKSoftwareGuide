

   Insight Toolkit Software Guide


Here are some instructions describing how to build
the Software Guide Document.

This document is generated with Latex by using input
from a variety of source. Among them:

1) Latex files in InsightDocuments/SoftwareGuide/Latex
2) JPEG  files in InsightDocuments/SoftwareGuide/Art
3) XFig  files in InsightDocuments/SoftwareGuide/Art
4) Cxx   files in Insight/Examples


The whole build process is orchestrated by CMake.
CMakeLists.txt files are placed in the directories
involved on the build process.

As any other CMake-managed process, the results of the
build process are put in a Binary tree that is in
general independent of the source tree.

The following are, in general lines, the processes 
applied to each one of the component listed above.

1) Latex files are included in a tree hierarchy which
   has "SoftwareGuide.tex" at the top. All of them
   are ultimately processed by latex to generate a 
   SoftwareGuide.dvi file. Thid DVI file is then converted
   to PDF.

2) JPEG files are converted to EPS (encapsulated postscript)
   and then included in the latex files. The ImageMagick 
   tools are used to perform this conversion.
   http://www.imagemagick.org/

   When configuring with CMake, the path to this tools 
   should be provided. In particular the "convert" tool
   is extensively used to convert between image formats.

   The resulting EPS files are writen on the Binary directory
   on the "Art" subdirectory.

3) XFig files are converted to EPS (encapsulated postscript)
   using "fig2dev". When configuring with CMake, the path
   to fig2dev should be provided.

   The resulting EPS files are writen on the Binary directory
   on the "Art" subdirectory.

4) The Cxx files on the Insight/Examples directory has been 
   writen to integrate closely with the software guide document.
   They contain a large amount of documentation in the form
   of C++ comments "//".

   Some of those comments have been delimited with the following
   tags:  

      BeginLatex
      EndLatex  

   and  
 
      BeginCodeSnippet
      EndCodeSnippet


   A PerlScript (provided in SoftwareGuide/ParseCxxExamples.pl)
   is invoked by CMake in order to extract these comments and
   generate latex files (with .tex extension) that will be copied
   onto the Binary directory on the "Examples" subdirectory.

   The regular latex files in SoftwareGuide/Latex will include 
   the generated files in Binary/Examples.



CONFIGURING WITH CMAKE


The following is the process to configure the build process using CMAKE.

1) Select the binary directory where the final text is 
   going to be written.

2) move to this directory and execute "ccmake  source_dir "
   where source_dir is the full path to the directory "SoftwareGuide"
   (e.g.   /home/johndoe/documents/InsightDocuments/SoftwareGuide )

3) Make sure the the following CMake variables are correctly setup

  - LATEX_COMPILE       pointing to the "latex"   executable
  - BIBTEX_COMPILE      pointing to the "bibtex"  executable
  - DVIPDF_COMPILE      pointing to the "dvipdf"  executable
  - FIG2DEV_EXECUTABLE  pointing to the "fig2dev" executable
  - MAKEINDEX_COMPILE   pointing to the "makeindex" executable

  - IMAGEMAGICK_CONVERT_EXECUTABLE pointing to the "convert" executable

  - PERLCXXPARSER       pointing to the perl script ParseCxxExamples.pl

  - ITK_SOURCE_DIR      pointing to the directory where you have ITK sources.


4) configure and generete the Makefiles

5) type "make"

   This should initiate the build process. In particular, 

   - parse all the cxx examples and generate tex files in an
     "Examples" subdirectory

   - convert all the JPEG images into EPS images in a "Art"
     subdirectory

   - convert all the FIG figures into EPS images in a "Art"
     subdirectory

   - run latex



Due to inavoidable circular dependencies in Latex it may be
required from time to time to build manually some components.

In particular the index generation and the bibliography can
lead to circular dependencies. The reason is that first, latex
needs to parse the tex code in order to collect citation 
references and to collect index entries. The index entries are
stored in a file called "SoftwareGuide.idx" and put in the 
"Latex" subdirectory of the binary directory. Then the program 
"makeindex" is used to generate a "SoftwareGuide.ind" which is
the final database of index entries. The circularity arises 
because the file "SoftwareGuide.ind" is included in the main
SoftwareGuide.tex file. The way to avoid the circularity is
to first comment out the inclusion of SoftwareGuide.ind on the
file SoftwareGuide.tex, run latex three times, to resolve all
the references, then run makeindex and finally include 
SoftwareGuide.ind back into SoftwareGuide.tex.

A similar circularity arises with bibliographic references since
bibtex is used here. The actual bibliographic reference is stored
in InsightDocuments/Latex/Insight.bib.

The citations are collected in the first latex passes and stored
in the "SoftwareGuide.aux" file. Then the "bibtex" program is used
to generate a "SoftwareGuide.bbl" file that is finally included by
latex.


Once the system has been build the first time, the circularity
shouldn't be a mayor issue.  It is important however to keep
in mind that CMake will only run latex once, while it should
in fact be executed in several passes. The result of which is
that sometimes the full set of references and citations may not
be updated.




