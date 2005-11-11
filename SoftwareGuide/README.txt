

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

  - LATEX_COMPILER       pointing to the "latex"   executable
  - BIBTEX_COMPILER      pointing to the "bibtex"  executable
  - DVIPDF_COMPILER      pointing to the "dvipdf"  executable
  - FIG2DEV_EXECUTABLE  pointing to the "fig2dev" executable
  - MAKEINDEX_COMPILE   pointing to the "makeindex" executable
  - IMAGEMAGICK_CONVERT_EXECUTABLE pointing to the "convert" executable
  - PERLCXXPARSER       pointing to the perl script ParseCxxExamples.pl
  - ITK_SOURCE_DIR      pointing to the directory where you have ITK sources.
  - ITK_EXECUTABLES_DIR pointing to the directory where you have the ITK executables. 
                        (This path specifies the directories where the built examples are,
                        so they can be executed and figures and text and graphs 
                        extracted from them)
  - ITK_DATA_PATHS      Additional paths where you might find input data for the examples
                        By default you will find the string ${ITK_SOURCE_DIR}/Examples/Data
                        While this should be sufficient for the examples currently in the 
                        ITK toolkit, other paths containing data may in future be added in 
                        a double colon seperated list such as
                        c:/ITK/src/Examples/Data::c:/Data/BrainWebData/
                        Note that you need the BrainWeb data to run.


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



-------------------------------------------------------------------------------

Building on Windows
-------------------

The Software Guide builds on Windows and Unix.

On Windows, you may have go through a few inconveniences as below:

1. Installing tools required

 - Install Latex, BibTeX (www.miktex.org) 
 - Install Perl (may use cygwin's perl or Active perl, make sure its in the path). 
 - Install ImageMagick (may use cygwin tools or windows tools)
 - Install fig2dev (convenient to use cygwin tools)
 - Install transfig
 - Install ps2pdf, dvipdf, ps2pdf, dvips, Ghostscript libraries

2. Building "Insight"
   
   Build ITK examples including the ones in the Patented directory 
   Configure ITK with BUILD_EXAMPLES=ON and ITK_USE_PATENTED=ON and build

3. Getting Data
   
   Most of the data to run the examples is in Insight/Examples/Data
   Upon requests from users, examples which run on 3D data were added. The data
   was taken from the BrainWeb repository. You may get it from
 
   ftp://public.kitware.com/pub/itk/Data/BrainWeb/

   The ones you need are BrainPart1.tgz and BrainPart1Rotated10Translated15.tgz 

   Unzip them. 

4. Building the Software Guide:

   Configure the Guide using CMake. 

   Pay attention to the following variables

   ITK_EXECUTABLES_DIR : Where the examples executables are. 
                         On unix this might be /ITK/binaries/
                         On windows this might be c:/ITK/bin/Release
                         
   ITK_DATA_PATHS :  A double colon seperated list such as
                     c:/ITK/src/Examples/Data::c:/Data/BrainWebData/
                     Make sure you have the paths for the BrainWebData
                     you just extracted as well.

   BUILD_FIGURES : Set this to ON.. Recommended, to ensure that the figures
                   are in sync with the toolkit to ensure reproducability.
   

5. Open the generated project in VS and build it.
-------------------------------------------------------------------------------

KNOWN issues:

1. Miktex seems to ignore the TEXINPUTS env var on Windows. A workaround is to 
   go through Steps 1 to 5 above. Watch your build fail. And open LaTeXWrapper.bat 
   file present in the binary folder. 

   Copy the list of paths and append them to the LaTeX and BibTeX paths manually in
   c:\texmf\miktex\config\miktex.ini
   
   This file should now contain lines like

   <snip>
   [BibTeX]

    ;; where BiBTeX searches for input files (both databases and style
    ;; files)
    Input Dirs=.;%R\bibtex//;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide\..\Latex//;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide//;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide\Latex//;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide\Art//;C:\cygwin\ITK\binaries\InsightDocuments2;C:\cygwin\ITK\binaries\InsightDocuments2\Examples//;C:\cygwin\ITK\binaries\InsightDocuments2\Art//;C:\cygwin\ITK\binaries\InsightDocuments2\Latex//
   </snip>

   <snip>
   [LaTeX]

    ;; input file name extensions recognized by LaTeX
    Extensions=.tex;.src;.ltx

    ;; where LaTeX searches for input files
    Input Dirs=.
    Input Dirs+=;%R\etex\latex//
    Input Dirs+=;%R\etex\generic//
    Input Dirs+=;%R\etex//
    Input Dirs+=;%R\tex\latex//
    Input Dirs+=;%R\tex\generic//
    Input Dirs+=;%R\tex//
    Input Dirs+=;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide\..\Latex//;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide//;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide\Latex//;c:\cygwin\ITK\src\InsightDocuments\SoftwareGuide\Art//;C:\cygwin\ITK\binaries\InsightDocuments2;C:\cygwin\ITK\binaries\InsightDocuments2\Examples//;C:\cygwin\ITK\binaries\InsightDocuments2\Art//;C:\cygwin\ITK\binaries\InsightDocuments2\Latex//
   </snip>

   
  Thanks to  http://www.murdoch-sutherland.com/Rtools/miktex.html


-------------------------------------------------------------------------------

ISSUES YOU MAY RUN INTO:

1. Cannot find InsightSoftwareGuide.cls
    
   Look at the known issues above.

2. Build error in ImageRegistrationHistogramPlotter

   - Update your "Insight" repository and build ITK. There was a bug in one of the examples

3. Build error in ImageRegistration8

   - Do you have the BrainWeb data and its path specified correctly. Open Examples/ImageRegistration8.cmake
     in the binary folder and ensure that you can run the line commented out:
   # Cmake macro to invoke: LineThatWillBeRun 

   If the line does not run, make sure that you can find all the brainweb data specified in that line.

4. The pdf built fine.. I cannot see the references or the Index. 
   
    Rerun the project "SoftwareGuideLatex". 
    on unix, run "make" again

   LaTeX has some cross-referencing issues which require the dependencies to be generated prior to build.

5. Frustrated that the build takes a long time
  
    - no solution here... 
                          
