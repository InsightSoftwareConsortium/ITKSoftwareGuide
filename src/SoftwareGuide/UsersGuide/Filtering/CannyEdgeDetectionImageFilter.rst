.. _sec-CannyEdgeDetection:

Canny Edge Detection
~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``CannyEdgeDetectionImageFilter.cxx``.

This example introduces the use of the \doxygen{CannyEdgeDetectionImageFilter}.
This filter is widely used for edge detection since it is the optimal
solution satisfying the constraints of good sensitivity, localization
and noise robustness.

.. index:
   single: CannyEdgeDetectionImageFilter

The first step required for using this filter is to include its header
file

::

    [language=C++]
    #include "itkCannyEdgeDetectionImageFilter.h"

This filter operates on image of pixel type float. It is then necessary
to cast the type of the input images that are usually of integer type.
The \doxygen{CastImageFilter} is used here for that purpose. Its image template
parameters are defined for casting from the input type to the float type
using for processing.

::

    [language=C++]
    typedef itk::CastImageFilter< CharImageType, RealImageType> CastToRealFilterType;

The \doxygen{CannyEdgeDetectionImageFilter} is instantiated using the float
image type.
