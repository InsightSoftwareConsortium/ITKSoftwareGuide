Signed Danielsson Distance Map
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``SignedDanielssonDistanceMapImageFilter.cxx``.

This example illustrates the use of the
{SignedDanielssonDistanceMapImageFilter}. This filter generates a
distance map by running Danielsson distance map twice, once on the input
image and once on the flipped image.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkSignedDanielssonDistanceMapImageFilter.h"

Then we must decide what pixel types to use for the input and output
images. Since the output will contain distances measured in pixels, the
pixel type should be able to represent at least the width of the image,
or said in :math:`N-D` terms, the maximum extension along all the
dimensions. The input and output image types are now defined using their
respective pixel type and dimension.

::

    [language=C++]
    typedef  unsigned char   InputPixelType;
    typedef  float           OutputPixelType;
    typedef  unsigned short  VoronoiPixelType;
    const unsigned int Dimension = 2;

    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;
    typedef itk::Image< VoronoiPixelType, Dimension >  VoronoiImageType;

The only change with respect to the previous example is to replace the
DanielssonDistanceMapImageFilter with the
SignedDanielssonDistanceMapImageFilter

::

    [language=C++]
    typedef itk::SignedDanielssonDistanceMapImageFilter<
    InputImageType,
    OutputImageType,
    VoronoiImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The inside is considered as having negative distances. Outside is
treated as having positive distances. To change the convention, use the
InsideIsPositive(bool) function.

    |image| |image1| [SignedDanielssonDistanceMapImageFilter output]
    {SignedDanielssonDistanceMapImageFilter applied on a binary circle
    image. The intensity has been rescaled for purposes of display.}
    {fig:SignedDanielssonDistanceMapImageFilterInputOutput}

Figure {fig:SignedDanielssonDistanceMapImageFilterInputOutput}
illustrates the effect of this filter. The input image and the distance
map are shown.

.. |image| image:: Circle.eps
.. |image1| image:: SignedDanielssonDistanceMapImageFilterOutput.eps
