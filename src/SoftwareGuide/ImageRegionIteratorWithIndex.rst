The source code for this section can be found in the file
``ImageRegionIteratorWithIndex.cxx``.

The “WithIndex” family of iterators was designed for algorithms that use
both the value and the location of image pixels in calculations. Unlike
{ImageRegionIterator}, which calculates an index only when asked for,
{ImageRegionIteratorWithIndex} maintains its index location as a member
variable that is updated during the increment or decrement process.
Iteration speed is penalized, but the index queries are more efficient.

The following example illustrates the use of
ImageRegionIteratorWithIndex. The algorithm mirrors a 2D image across
its :math:`x`-axis (see {FlipImageFilter} for an ND version). The
algorithm makes extensive use of the {GetIndex()} method.

We start by including the proper header file.

::

    [language=C++]
    #include "itkImageRegionIteratorWithIndex.h"

For this example, we will use an RGB pixel type so that we can process
color images. Like most other ITK image iterator,
ImageRegionIteratorWithIndex class expects the image type as its single
template parameter.

::

    [language=C++]
    const unsigned int Dimension = 2;

    typedef itk::RGBPixel< unsigned char >        RGBPixelType;
    typedef itk::Image< RGBPixelType, Dimension > ImageType;

    typedef itk::ImageRegionIteratorWithIndex< ImageType > IteratorType;

An {ImageType} smart pointer called {inputImage} points to the output of
the image reader. After updating the image reader, we can allocate an
output image of the same size, spacing, and origin as the input image.

::

    [language=C++]
    ImageType::Pointer outputImage = ImageType::New();
    outputImage->SetRegions( inputImage->GetRequestedRegion() );
    outputImage->CopyInformation( inputImage );
    outputImage->Allocate();

Next we create the iterator that walks the output image. This algorithm
requires no iterator for the input image.

::

    [language=C++]
    IteratorType outputIt( outputImage, outputImage->GetRequestedRegion() );

This axis flipping algorithm works by iterating through the output
image, querying the iterator for its index, and copying the value from
the input at an index mirrored across the :math:`x`-axis.

::

    [language=C++]
    ImageType::IndexType requestedIndex =
    outputImage->GetRequestedRegion().GetIndex();
    ImageType::SizeType requestedSize =
    outputImage->GetRequestedRegion().GetSize();

    for ( outputIt.GoToBegin(); !outputIt.IsAtEnd(); ++outputIt)
    {
    ImageType::IndexType idx = outputIt.GetIndex();
    idx[0] =  requestedIndex[0] + requestedSize[0] - 1 - idx[0];
    outputIt.Set( inputImage->GetPixel(idx) );
    }

Let’s run this example on the image {VisibleWomanEyeSlice.png} found in
the {Examples/Data} directory.
Figure {fig:ImageRegionIteratorWithIndexExample} shows how the original
image has been mirrored across its :math:`x`-axis in the output.

    |image| |image1| [Using the ImageRegionIteratorWithIndex] {Results
    of using ImageRegionIteratorWithIndex to mirror an image across an
    axis. The original image is shown at left. The mirrored output is
    shown at right.} {fig:ImageRegionIteratorWithIndexExample}

.. |image| image:: VisibleWomanEyeSlice.eps
.. |image1| image:: ImageRegionIteratorWithIndexOutput.eps
