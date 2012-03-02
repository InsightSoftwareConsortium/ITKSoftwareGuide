The source code for this section can be found in the file
``BinaryMedianImageFilter.cxx``.

The \doxgeyn{BinaryMedianImageFilter} is commonly used as a robust approach for
noise reduction. BinaryMedianImageFilter computes the value of each
output pixel as the statistical median of the neighborhood of values
around the corresponding input pixel. When the input images are binary,
the implementation can be optimized by simply counting the number of
pixels ON/OFF around the current pixel.

This filter will work on images of any dimension thanks to the internal
use of \doxygen{NeighborhoodIterator} and \doxygen{NeighborhoodOperator}. The size of
the neighborhood over which the median is computed can be set by the
user.


.. index::
   single: BinaryMedianImageFilter

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkBinaryMedianImageFilter.h"

Then the pixel and image types of the input and output must be defined.

::

    [language=C++]
    typedef   unsigned char  InputPixelType;
    typedef   unsigned char  OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

Using the image types, it is now possible to define the filter type and
create the filter object.

::

    [language=C++]
    typedef itk::BinaryMedianImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The size of the neighborhood is defined along every dimension by passing
a \code{SizeType} object with the corresponding values. The value on each
dimension is used as the semi-size of a rectangular box. For example, in
:math:`2D` a size of :math:`1,2` will result in a :math:`3 \times
5` neighborhood.

::

    [language=C++]
    InputImageType::SizeType indexRadius;

    indexRadius[0] = radiusX;  radius along x
    indexRadius[1] = radiusY;  radius along y

    filter->SetRadius( indexRadius );

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example, a writer. An update call on any downstream filter will
trigger the execution of the median filter.

.. index::
   pair: BinaryMedianImageFilter;SetInput
   pair: BinaryMedianImageFilter;GetOutput

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );
    writer->Update();

    |image| |image1| [Effect of the BinaryMedian filter.] {Effect of the
    BinaryMedianImageFilter on a slice from a MRI proton density brain
    image that has been thresholded in order to produce a binary image.}
    {fig:BinaryMedianImageFilterOutput}

Figure \ref{fig:BinaryMedianImageFilterOutput} illustrates the effect of the
BinaryMedianImageFilter filter on a slice of MRI brain image using a
neighborhood radius of :math:`2,2`, which corresponds to a
:math:` 5 \times 5 ` classical neighborhood. The filtered image
demonstrates the capability of this filter for reducing noise both in
the background and foreground of the image, as well as smoothing the
contours of the regions.

.. |image| image:: BinaryThresholdImageFilterOutput.eps
.. |image1| image:: BinaryMedianImageFilterOutput.eps
