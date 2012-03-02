Installation
============

{chapter:Installation}

This section describes the process for installing ITK on your system.
Keep in mind that ITK is a toolkit, and as such, once it is installed in
your computer there will be no application to run. Rather, you will use
ITK to build your own applications. What ITK does provide—besides the
toolkit proper—is a large set of test files and examples that will
introduce you to ITK concepts and will show you how to use ITK in your
own projects.

Some of the examples distributed with ITK require third party libraries
that you may have to download. For an initial installation of ITK you
may want to ignore these extra libraries and just build the toolkit
itself. In the past, a large fraction of the traffic on the
insight-users mailing list has originated from difficulties in getting
third party libraries compiled and installed rather than with actual
problems building ITK.

ITK has been developed and tested across different combinations of
operating systems, compilers, and hardware platforms including
MS-Windows, Linux on Intel-compatible hardware, Solaris, IRIX, Mac OSX,
and Cygwin. It is known to work with the following compilers:

-  Visual Studio 6, .NET 2002, .NET 2003

-  GCC 2.95.x, 2.96, 3.x

-  SGI MIPSpro 7.3x

-  Borland 5.5

Given the advanced usage of C++ features in the toolkit, some compilers
may have difficulties processing the code. If you are currently using an
outdated compiler this may be an excellent excuse for upgrading this old
piece of software!

Configuring ITK
---------------

{sec:ConfiguringITK}

The challenge of supporting ITK across platforms has been solved through
the use of CMake, a cross-platform, open-source build system. CMake is
used to control the software compilation process using simple platform
and compiler independent configuration files. CMake generates native
makefiles and workspaces that can be used in the compiler environment of
your choice. CMake is quite sophisticated—it supports complex
environments requiring system configuration, compiler feature testing,
and code generation.

CMake generates Makefiles under UNIX and Cygwin systems and generates
Visual Studio workspaces under Windows (and appropriate build files for
other compilers like Borland). The information used by CMake is provided
by {CMakeLists.txt} files that are present in every directory of the ITK
source tree. These files contain information that the user provides to
CMake at configuration time. Typical information includes paths to
utilities in the system and the selection of software options specified
by the user.

Preparing CMake
~~~~~~~~~~~~~~~

{sec:CMakeforITK}

CMake can be downloaded at no cost from

    http://www.cmake.org

ITK requires at least CMake version 2.0. You can download binary
versions for most of the popular platforms including Windows, Solaris,
IRIX, HP, Mac and Linux. Alternatively you can download the source code
and build CMake on your system. Follow the instructions in the CMake Web
page for downloading and installing the software.

Running CMake initially requires that you provide two pieces of
information: where the source code directory is located
(ITK\_SOURCE\_DIR), and where the object code is to be produced
(ITK\_BINARY\_DIR). These are referred to as the *source directory* and
the *binary directory*. We recommend setting the binary directory to be
different than the source directory (an *out-of-source* build), but ITK
will still build if they are set to the same directory (an *in-source*
build). On Unix, the binary directory is created by the user and CMake
is invoked with the path to the source directory. For example:

::

    mkdir Insight-binary
    cd Insight-binary
    ccmake ../Insight

On Windows, the CMake GUI is used to specify the source and build
directories (Figure {fig:CMakeGUI}).

CMake runs in an interactive mode in that you iteratively select options
and configure according to these options. The iteration proceeds until
no more options remain to be selected. At this point, a generation step
produces the appropriate build files for your configuration.

This interactive configuration process can be better understood if you
imagine that you are walking through a decision tree. Every option that
you select introduces the possibility that new, dependent options may
become relevant. These new options are presented by CMake at the top of
the options list in its interface. Only when no new options appear after
a configuration iteration can you be sure that the necessary decisions
have all been made. At this point build files are generated for the
current configuration.

Configuring ITK
~~~~~~~~~~~~~~~

{sec:ConfiguringITKwithVTK}

    |image| |image1| [CMake user interface] {CMake interface. Top)
    ``ccmake``, the UNIX version based on ``curses``. Bottom)
    ``CMakeSetup``, the MS-Windows version based on MFC.} {fig:CMakeGUI}

Figure {fig:CMakeGUI} shows the CMake interface for UNIX and MS-Windows.
In order to speed up the build process you may want to disable the
compilation of the testing and examples. This is done with the variables
{BUILD\_TESTING=OFF} and {BUILD\_EXAMPLES=OFF}. The examples distributed
with the toolkit are a helpful resource for learning how to use ITK
components but are not essential for the use of the toolkit itself. The
testing section includes a large number of small programs that exercise
the capabilities of ITK classes. Due to the large number of tests,
enabling the testing option will considerably increase the build time.
It is not desirable to enable this option for a first build of the
toolkit.

An additional resource is available in the {InsightApplications} module,
which contains multiple applications incorporating GUIs and different
levels of visualization. However, due to the large number of
applications and the fact that some of them rely on third party
libraries, building this module should be postponed until you are
familiar with the basic structure of the toolkit and the building
process.

Begin running CMake by using ccmake on Unix, and CMakeSetup on Windows.
Remember to run ccmake from the binary directory on Unix. On Windows,
specify the source and binary directories in the GUI, then begin to set
the build variables in the GUI as necessary. Most variables should have
default values that are sensible. Each time you change a set of
variables in CMake, it is necessary to proceed to another configuration
step. In the Windows version this is done by clicking on the “Configure”
button. In the UNIX version this is done in an interface using the
curses library, where you can configure by hitting the “c” key.

When no new options appear in CMake, you can proceed to generate
Makefiles or Visual Studio projects (or appropriate build file(s)
depending on your compiler). This is done in Windows by clicking on the
“Ok” button. In the UNIX version this is done by hitting the “g” key.
After the generation process CMake will quit silently. To initiate the
build process on UNIX, simply type {make} in the binary directory. Under
Windows, load the workspace named {ITK.dsw} (if using MSDEV) or
{ITK.sln} (if using the .NET compiler) from the binary directory you
specified in the CMake GUI.

The build process will typically take anywhere from 15 to 30 minutes
depending on the performance of your system. If you decide to enable
testing as part of the normal build process, about 600 small test
programs will be compiled. This will verify that the basic components of
ITK have been correctly built on your system.

Getting Started With ITK
------------------------

{sec:GettingStartedWithITK}

The simplest way to create a new project with ITK is to create a new
directory somewhere in your disk and create two files in it. The first
one is a {CMakeLists.txt} file that will be used by CMake to generate a
Makefile (if you are using UNIX) or a Visual Studio workspace (if you
are using MS-Windows). The second file is an actual C++ program that
will exercise some of the large number of classes available in ITK. The
details of these files are described in the following section.

Once both files are in your directory you can run CMake in order to
configure your project. Under UNIX, you can cd to your newly created
directory and type “{ccmake .}”. Note the “.” in the command line for
indicating that the {CMakeLists.txt} file is in the current directory.
The curses interface will require you to provide the directory where ITK
was built. This is the same path that you indicated for the
{ITK\_BINARY\_DIR} variable at the time of configuring ITK. Under
Windows you can run CMakeSetup and provide your newly created directory
as being both the source directory and the binary directory for your new
project (i.e., an in-source build). Then CMake will require you to
provide the path to the binary directory where ITK was built. The ITK
binary directory will contain a file named {ITKConfig.cmake} generated
during the configuration process at the time ITK was built. From this
file, CMake will recover all the information required to configure your
new ITK project.

Hello World !
~~~~~~~~~~~~~

{sec:HelloWorldITK}

Here is the content of the two files to write in your new project. These
two files can be found in the {Insight/Examples/Installation} directory.
The {CMakeLists.txt} file contains the following lines:

::

    PROJECT(HelloWorld)

    FIND_PACKAGE(ITK REQUIRED)
    IF(ITK_FOUND)
      INCLUDE(${ITK_USE_FILE})
    ENDIF(ITK_FOUND)

    ADD_EXECUTABLE(HelloWorld HelloWorld.cxx )

    TARGET_LINK_LIBRARIES(HelloWorld ITKCommon)

The first line defines the name of your project as it appears in Visual
Studio (it will have no effect with UNIX Makefiles). The second line
loads a CMake file with a predefined strategy for finding ITK  [1]_. If
the strategy for finding ITK fails, CMake will prompt you for the
directory where ITK is installed in your system. In that case you will
write this information in the {ITK\_BINARY\_DIR} variable. The line
{INCLUDE(${USE\_ITK\_FILE})} loads the {UseITK.cmake} file to set all
the configuration information from ITK. The line {ADD\_EXECUTABLE}
defines as its first argument the name of the executable that will be
produced as result of this project. The remaining arguments of
{ADD\_EXECUTABLE} are the names of the source files to be compiled and
linked. Finally, the {TARGET\_LINK\_LIBRARIES} line specifies which ITK
libraries will be linked against this project.

HelloWorld.tex

At this point you have successfully installed and compiled ITK, and
created your first simple program. If you have difficulties, please join
the insight-users mailing list (Section {sec:JoinMailList} on page
{sec:JoinMailList}) and pose questions there.

.. [1]
   Similar files are provided in CMake for other commonly used
   libraries, all of them named {Find\*.cmake}

.. |image| image:: ccmakeScreenShot.eps
.. |image1| image:: CMakeSetupScreenShot.eps
