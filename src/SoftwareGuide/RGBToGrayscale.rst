The source code for this section can be found in the file
``RGBToGrayscale.cxx``.

This example illustrates how to convert an RGB image into a grayscale
one. The {RGBToLuminanceImageFilter} is the central piece of this
example.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkRGBToLuminanceImageFilter.h"

