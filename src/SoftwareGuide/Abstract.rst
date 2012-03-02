Abstract
========

The Insight Toolkit `(ITK) <http://www.itk.org>`_ is an open-source software
toolkit for performing registration and segmentation.  *Segmentation* is the
process of identifying and classifying data found in a digitally sampled
representation. Typically the sampled representation is an image acquired from
such medical instrumentation as CT or MRI scanners. *Registration* is the task
of aligning or developing correspondences between data. For example, in the
medical environment, a CT scan may be aligned with a MRI scan in order to
combine the information contained in both.

ITK is implemented in C++. It is cross-platform, using a build environment
known as `CMake <http://www.cmake.org>`_ to manage the compilation process in a
platform-independent way. In addition, an automated wrapping process (`Cable
<http://public.kitware.com/Cable/HTML/Index.html>`_) generates interfaces
between C++ and interpreted programming languages such as `Tcl
<http://tcl.sourceforge.net>`_, `Java <http://java.sun.com>`_, and `Python
<http://www.python.org>`_. This enables developers to create software using a
variety of programming languages. ITK's C++ implementation style is referred to
as generic programming, which is to say that it uses templates so that the same
code can be applied *generically* to any class or type that happens to support
the operations used. Such C++ templating means that the code is highly
efficient, and that many software problems are discovered at compile-time,
rather than at run-time during program execution.

Because ITK is an open-source project, developers from around the world can
use, debug, maintain, and extend the software. ITK uses a model of software
development referred to as Extreme Programming. Extreme Programming collapses
the usual software creation methodology into a simultaneous and iterative
process of design-implement-test-release. The key features of Extreme
Programming are communication and testing.  Communication among the members of
the ITK community is what helps manage the rapid evolution of the software.
Testing is what keeps the software stable. In ITK, an extensive testing process
(using a system known as `Dart <http://public.kitware.com/dashboard.php>`_) is
in place that measures the quality on a daily basis. The ITK Testing Dashboard
is posted continuously, reflecting the quality of the software at any moment.

This book is a guide to using and developing with ITK. The sample code in the
`directory <http://www.itk.org/cgi-bin/viewcvs.cgi/Examples/?root=Insight>`_
provides a companion to the material presented here. The most recent version of
this document is available online at http://www.itk.org/ItkSoftwareGuide.pdf.

