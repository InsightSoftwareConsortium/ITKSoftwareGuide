The source code for this section can be found in the file
``LandmarkWarping2.cxx``.

This example illustrates how to deform an image using a KernelBase
spline and two sets of landmarks.

::

    [language=C++]
    #include "itkVector.h"
    #include "itkImage.h"
    #include "itkLandmarkDisplacementFieldSource.h"
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkWarpImageFilter.h"

