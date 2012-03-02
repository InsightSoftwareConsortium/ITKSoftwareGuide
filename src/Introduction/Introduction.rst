.. _sec-Welcome:

Welcome
=======

Welcome to the *Insight Segmentation and Registration Toolkit (ITK)
Software Guide*. This book has been updated for ITK 2.4 and later
versions of the Insight Toolkit software.

ITK is an open-source, object-oriented software system for image
processing, segmentation, and registration. Although it is large and
complex, ITK is designed to be easy to use once you learn about its
basic object-oriented and implementation methodology. The purpose of
this Software Guide is to help you learn just this, plus to familiarize
you with the important algorithms and data representations found
throughout the toolkit. The material is taught using an extensive set of
examples that we encourage you to compile and run while you read this
guide.

ITK is a large system. As a result it is not possible to completely
document all ITK objects and their methods in this text. Instead, this
guide will introduce you to important system concepts and lead you up
the learning curve as fast and efficiently as possible. Once you master
the basics, we suggest that you take advantage of the many resources
available including the Doxygen documentation pages
(http://www.itk.org/HTML/Documentation.htm) and the community of ITK
users (see Section :ref:`sec-AdditionalResources`.)

The Insight Toolkit is an open-source software system. What this means
is that the community of ITK users and developers has great impact on
the evolution of the software. Users and developers can make significant
contributions to ITK by providing bug reports, bug fixes, tests, new
classes, and other feedback. Please feel free to contribute your ideas
to the community (the ITK user mailing list is the preferred method; a
developer’s mailing list is also available).

.. _sec-Organization:

Organization
------------

This software guide is divided into three parts, each of which is
further divided into several chapters. Part I is a general introduction
to ITK, with—in the next chapter—a description of how to install the
Insight Toolkit on your computer. This includes installing pre-compiled
libraries and executables, and compiling the software from the source
code. Part I also introduces basic system concepts such as an overview
of the system architecture, and how to build applications in the C++,
Tcl, and Python programming languages. Part II describes the system from
the user point of view. Dozens of examples are used to illustrate
important system features. Part III is for the ITK developer. Part III
explains how to create your own classes, extend the system, and
interface to various windowing and GUI systems.


.. _sec-HowToLearnITK:

How to Learn ITK
----------------

There are two broad categories of users of ITK. First are class
developers, those who create classes in C++. The second, users, employ
existing C++ classes to build applications. Class developers must be
proficient in C++, and if they are extending or modifying ITK, they must
also be familiar with ITK’s internal structures and design (material
covered in Part III). Users may or may not use C++, since the compiled
C++ class library has been *wrapped* with the Tcl and Python interpreted
languages. However, as a user you must understand the external interface
to ITK classes and the relationships between them.

The key to learning how to use ITK is to become familiar with its
palette of objects and the ways of combining them. If you are a new
Insight Toolkit user, begin by installing the software. If you are a
class developer, you’ll want to install the source code and then compile
it. Users may only need the precompiled binaries and executables. We
recommend that you learn the system by studying the examples and then,
if you are a class developer, study the source code. Start by reading
Chapter 3, which provides an overview of some of the key concepts in the
system, and then review the examples in Part II. You may also wish to
compile and run the dozens of examples distributed with the source code
found in the directory {Insight/Examples}. (Please see the file
{Insight/Examples/README.txt} for a description of the examples
contained in the various subdirectories.) There are also several hundred
tests found in the source distribution in {Insight/Testing/Code}, most
of which are minimally documented testing code. However, they may be
useful to see how classes are used together in ITK, especially since
they are designed to exercise as much of the functionality of each class
as possible.

.. _sec-SoftwareOrganization:

Software Organization
---------------------

The following sections describe the directory contents, summarize the
software functionality in each directory, and locate the documentation
and data.


.. _sec-ObtainingTheSoftware:

Obtaining the Software
~~~~~~~~~~~~~~~~~~~~~~

There are three different ways to access the ITK source code (see
Section :ref:`sec-DownloadingITK`.

- from periodic releases available on the ITK Web site,
- from CD-ROM, and
- from direct access to the CVS source code repository.

Official releases are available a few times a year and announced on the
ITK Web pages and mailing lists. However, they may not provide the
latest and greatest features of the toolkit. In general, the periodic
releases and CD-ROM releases are the same, except that the CD release
typically contains additional resources and data. CVS access provides
immediate access to the latest toolkit additions, but on any given day
the source code may not be stable as compared to the official
releases—i.e., the code may not compile, it may crash, or it might even
produce incorrect results.

This software guide assumes that you are working with the official ITK
version 2.4 release (available on the ITK Web site). If you are a new
user, we highly recommend that you use the released version of the
software. It is stable, consistent, and better tested than the code
available from the CVS repository. Later, as you gain experience with
ITK, you may wish to work from the CVS repository. However, if you do
so, please be aware of the ITK quality testing dashboard. The Insight
Toolkit is heavily tested using the open-source DART regression testing
system (http://public.kitware.com/dashboard.php). Before updating the
CVS repository, make sure that the dashboard is *green* indicating
stable code. If not green it is likely that your software update is
unstable. (Learn more about the ITK quality dashboard in Section
:ref:`sec-DART`.)

.. _sec-DownloadingITK:

Downloading ITK
---------------

ITK can be downloaded without cost from the following web site:

    http://www.itk.org/HTML/Download.php

In order to track the kind of applications for which ITK is being used,
you will be asked to complete a form prior to downloading the software.
The information you provide in this form will help developers to get a
better idea of the interests and skills of the toolkit users. It also
assists in future funding requests to sponsoring agencies.

Once you fill out this form you will have access to the download page
where two options for obtaining the software will be found. (This page
can be book marked to facilitate subsequent visits to the download site
without having to complete any form again.) You can get the tarball of a
stable release or you can get the development version through CVS. The
release version is stable and dependable but may lack the latest
features of the toolkit. The CVS version will have the latest additions
but is inherently unstable and may contain components with work in
progress. The following sections describe the details of each one of
these two alternatives.

.. _sec-DownloadingReleases:

Downloading Packaged Releases
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Please read the ``GettingStarted.txt`` [1]_ document first. It will give
you an overview of the download and installation processes. Then choose
the tarball that better fits your system. The options are ``.zip`` and
``.tgz`` files. The first type is better suited for MS-Windows while the
second one is the preferred format for UNIX systems.

Once you unzip or untar the file a directory called ``Insight}` will be
created in your disk and you will be ready for starting the
configuration process described in Section :ref:`sec-CMakeforITK`.

.. _sec-DownloadingFromCVS:

Downloading from CVS
~~~~~~~~~~~~~~~~~~~~

The Concurrent Versions System (CVS) is a tool for software version
control . Generally only developers should be using CVS, so here we
assume that you know what CVS is and how to use it. For more information
about CVS please see Section :ref:`sec-CVSRepository`. (Note: please make sure that you access the
software via CVS only when the ITK Quality Dashboard indicates that the
code is stable. Learn more about the Quality Dashboard at
:ref:`sec-QualityDashboard`.)

Access ITK via CVS using the following commands (under UNIX and Cygwin):

::

    cvs -d :pserver:anonymous@www.itk.org:/cvsroot/Insight login
    (respond with password "insight")

    cvs -d :pserver:anonymous@www.itk.org:/cvsroot/Insight co Insight

This will trigger the download of the software into a directory named
{Insight}. Any time you want to update your version, it will be enough
to change into this directory ``Insight`` and type:

::

    cvs update -d -P

Once you obtain the software you are ready to configure and compile it
(see Section :ref:`sec-CMakeforITK`). First,
however, we recommend that you join the mailing list and read the
following sections describing the organization of the software.

.. _sec-JoinMailList:

Join the Mailing List
~~~~~~~~~~~~~~~~~~~~~

It is strongly recommended that you join the users mailing list. This is
one of the primary resources for guidance and help regarding the use of
the toolkit. You can subscribe to the users list online at

    http://www.itk.org/HTML/MailingLists.htm

The insight-users mailing list is also the best mechanism for expressing
your opinions about the toolkit and to let developers know about
features that you find useful, desirable or even unnecessary. ITK
developers are committed to creating a self-sustaining open-source ITK
community. Feedback from users is fundamental to achieving this goal.


.. _sec-DirectoryStructure:

Directory Structure
~~~~~~~~~~~~~~~~~~~

To begin your ITK odyssey, you will first need to know something about
ITK’s software organization and directory structure. Even if you are
installing pre-compiled binaries, it is helpful to know enough to
navigate through the code base to find examples, code, and
documentation.

ITK is organized into several different modules, or CVS checkouts. If
you are using an official release or CD release, you will see three
important modules: the ``Insight``, ``InsightDocuments`` and
``InsightApplications`` modules. The source code, examples and
applications are found in the ``Insight`` module; documentation,
tutorials, and material related to the design and marketing of ITK are
found in ``InsightDocuments``; and fairly complex applications using ITK
(and other systems such as VTK, Qt, and FLTK) are available from
{InsightApplications}. Usually you will work with the ``Insight`` module
unless you are a developer, are teaching a course, or are looking at the
details of various design documents. The ``InsightApplications`` module
should only be downloaded and compiled once the ``Insight`` module is
functioning properly.

The ``Insight`` module contains the following subdirectories:

- ``Insight/Code``
    the heart of the software; the location of the majority of the source code.

- ``Insight/Documentation``
    a compact subset of documentation to get users started with ITK.

-  ``Insight/Examples``
    a suite of simple, well-documented examples used by this guide and to illustrate important ITK concepts.

- ``Insight/Testing``
    a large number of small programs used to test ITK.
    These examples tend to be minimally documented but may be useful to 
    demonstrate various system concepts. These tests are used by DART to
    produce the ITK Quality Dashboard (see Section :ref:`sec-DART`.)

- ``Insight/Utilities``
    supporting software for the ITK source code. For example, DART and 
    Doxygen support, as well as libraries such as ``png`` and ``zlib``.

- ``Insight/Validation``
    a series of validation case studies including the source code used to produce the results.

- ``Insight/Wrapping``
    support for the CABLE wrapping tool. CABLE is used by ITK to build 
    interfaces between the C++ library and various interpreted languages 
    (currently Tcl and Python are supported).

The source code directory structure—found in ``Insight/Code`` is important
to understand since other directory structures (such as the ``Testing``
and ``Wrapping`` directories) shadow the structure of the ``Insight/Code``
directory.

-  {Insight/Code/Common}—core classes, macro definitions, typedefs, and
   other software constructs central to ITK.

-  {Insight/Code/Numerics}—mathematical library and supporting classes.
   (Note: ITK’s mathematical library is based on the VXL/VNL software
   package http://vxl.sourceforge.net.)

-  {Insight/Code/BasicFilters}—basic image processing filters.

-  {Insight/Code/IO}—classes that support the reading and writing of
   data.

-  {Insight/Code/Algorithms}—the location of most segmentation and
   registration algorithms.

-  {Insight/Code/SpatialObject}—classes that represent and organize data
   using spatial relationships (e.g., the leg bone is connected to the
   hip bone, etc.)

-  {Insight/Code/Patented}—any patented algorithms are placed here.
   Using this code in commercial application requires a patent license.

-  {Insight/Code/Local}—an empty directory used by developers and users
   to experiment with new code.

The {InsightDocuments} module contains the following subdirectories:

-  {InsightDocuments/CourseWare}—material related to teaching ITK.

-  {InsightDocuments/Developer}—historical documents covering the design
   and creation of ITK including progress reports and design documents.

-  {InsightDocuments/Latex}—{} styles to produce this work as well as
   other documents.

-  {InsightDocuments/Marketing}—marketing flyers and literature used to
   succinctly describe ITK.

-  {InsightDocuments/Papers}—papers related to the many algorithms, data
   representations, and software tools used in ITK.

-  {InsightDocuments/SoftwareGuide}—{} files used to create this guide.
   (Note that the code found in {Insight/Examples} is used in
   conjunction with these {} files.)

-  {InsightDocuments/Validation}—validation case studies using ITK.

-  {InsightDocuments/Web}—the source HTML and other material used to
   produce the Web pages found at http://www.itk.org.

Similar to the {Insight} module, access to the {InsightDocuments} module
is also available via CVS using the following commands (under UNIX and
Cygwin):

::

    cvs -d :pserver:anonymous@www.itk.org:/cvsroot/Insight co InsightDocuments

The {InsightApplications} module contains large, relatively complex
examples of ITK usage. See the web pages at
http://www.itk.org/HTML/Applications.htm for a description. Some of
these applications require GUI toolkits such as Qt and FLTK or other
packages such as VTK (*The Visualization Toolkit* http://www.vtk.org).
Do not attempt to compile and build this module until you have
successfully built the core {Insight} module.

Similar to the {Insight} and {InsightDocuments} module, access to the
{InsightApplications} module is also available via CVS using the
following commands (under UNIX and Cygwin):

::

    cvs -d:pserver:anonymous@www.itk.org:/cvsroot/Insight \ 
      co InsightApplications

Documentation
~~~~~~~~~~~~~

{sec:Documentation}

Besides this text, there are other documentation resources that you
should be aware of.

Doxygen Documentation.
    The Doxygen documentation is an essential resource when working with
    ITK. These extensive Web pages describe in detail every class and
    method in the system. The documentation also contains inheritance
    and collaboration diagrams, listing of event invocations, and data
    members. The documentation is heavily hyper-linked to other classes
    and to the source code. The Doxygen documentation is available on
    the companion CD, or on-line at http://www.itk.org. Make sure that
    you have the right documentation for your version of the source
    code.

Header Files.
    Each ITK class is implemented with a .h and .cxx/.hxx file (.hxx
    file for templated classes). All methods found in the .h header
    files are documented and provide a quick way to find documentation
    for a particular method. (Indeed, Doxygen uses the header
    documentation to produces its output.)

Data
~~~~

{sec:Data}

The Insight Toolkit was designed to support the Visible Human Project
and its associated data. This data is available from the National
Library of Medicine at
http://www.nlm.nih.gov/research/visible/visible_human.html.

Another source of data can be obtained from the ITK Web site at either
of the following:

    http://www.itk.org/HTML/Data.htm
    ftp://public.kitware.com/pub/itk/Data/.

The Insight Community and Support
---------------------------------

{sec:AdditionalResources}

ITK was created from its inception as a collaborative, community effort.
Research, teaching, and commercial uses of the toolkit are expected. If
you would like to participate in the community, there are a number of
possibilities.

-  Users may actively report bugs, defects in the system API, and/or
   submit feature requests. Currently the best way to do this is through
   the ITK users mailing list.

-  Developers may contribute classes or improve existing classes. If you
   are a developer, you may request permission to join the ITK
   developers mailing list. Please do so by sending email to
   will.schroeder “at” kitware.com. To become a developer you need to
   demonstrate both a level of competence as well as trustworthiness.
   You may wish to begin by submitting fixes to the ITK users mailing
   list.

-  Research partnerships with members of the Insight Software Consortium
   are encouraged. Both NIH and NLM will likely provide limited funding
   over the next few years, and will encourage the use of ITK in
   proposed work.

-  For those developing commercial applications with ITK, support and
   consulting are available from Kitware at http://www.kitware.com.
   Kitware also offers short ITK courses either at a site of your choice
   or periodically at Kitware.

-  Educators may wish to use ITK in courses. Materials are being
   developed for this purpose, e.g., a one-day, conference course and
   semester-long graduate courses. Watch the ITK web pages or check in
   the {InsightDocuments/CourseWare} directory for more information.

A Brief History of ITK
----------------------

{sec:History}

In 1999 the US National Library of Medicine of the National Institutes
of Health awarded six three-year contracts to develop an open-source
registration and segmentation toolkit, that eventually came to be known
as the Insight Toolkit (ITK) and formed the basis of the Insight
Software Consortium. ITK’s NIH/NLM Project Manager was Dr. Terry Yoo,
who coordinated the six prime contractors composing the Insight
consortium. These consortium members included three commercial
partners—GE Corporate R&D, Kitware, Inc., and MathSoft (the company name
is now Insightful)—and three academic partners—University of North
Carolina (UNC), University of Tennessee (UT) (Ross Whitaker subsequently
moved to University of Utah), and University of Pennsylvania (UPenn).
The Principle Investigators for these partners were, respectively, Bill
Lorensen at GE CRD, Will Schroeder at Kitware, Vikram Chalana at
Insightful, Stephen Aylward with Luis Ibanez at UNC (Luis is now at
Kitware), Ross Whitaker with Josh Cates at UT (both now at Utah), and
Dimitri Metaxas at UPenn (now at Rutgers). In addition, several
subcontractors rounded out the consortium including Peter Raitu at
Brigham & Women’s Hospital, Celina Imielinska and Pat Molholt at
Columbia University, Jim Gee at UPenn’s Grasp Lab, and George Stetten at
the University of Pittsburgh.

In 2002 the first official public release of ITK was made available. In
addition, the National Library of Medicine awarded thirteen contracts to
several organizations to extend ITK’s capabilities. NLM funding of
Insight Toolkit development is continuing through 2003, with additional
application and maintenance support anticipated beyond 2003. If you are
interested in potential funding opportunities, we suggest that you
contact Dr. Terry Yoo at the National Library of Medicine for more
information.

.. [1]
   http://www.itk.org/HTML/GettingStarted.txt
