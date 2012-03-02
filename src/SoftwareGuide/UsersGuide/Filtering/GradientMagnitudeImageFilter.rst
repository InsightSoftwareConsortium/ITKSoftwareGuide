Gradient Magnitude
~~~~~~~~~~~~~~~~~~

{sec:GradientMagnitudeImageFilter}

The source code for this section can be found in the file
``GradientMagnitudeImageFilter.cxx``.

The magnitude of the image gradient is extensively used in image
analysis, mainly to help in the determination of object contours and the
separation of homogeneous regions. The {GradientMagnitudeImageFilter}
computes the magnitude of the image gradient at each pixel location
using a simple finite differences approach. For example, in the case of
:math:`2D` the computation is equivalent to convolving the image with
masks of type

        (200,50) ( 5.0,32.0){(30.0,15.0){-1}}
        (35.0,32.0){(30.0,15.0){0}} (65.0,32.0){(30.0,15.0){1}}
        (105.0,17.0){(20.0,15.0){1}} (105.0,32.0){(20.0,15.0){0}}
        (105.0,47.0){(20.0,15.0){-1}}

then adding the sum of their squares and computing the square root of
the sum.

This filter will work on images of any dimension thanks to the internal
use of {NeighborhoodIterator} and {NeighborhoodOperator}.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkGradientMagnitudeImageFilter.h"

Types should be chosen for the pixels of the input and output images.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

The input and output image types can be defined using the pixel types.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The type of the gradient magnitude filter is defined by the input image
and the output image types.

::

    [language=C++]
    typedef itk::GradientMagnitudeImageFilter<
    InputImageType, OutputImageType >  FilterType;

A filter object is created by invoking the {New()} method and assigning
the result to a {SmartPointer}.

::

    [language=C++]
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
the source is an image reader.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

Finally, the filter is executed by invoking the {Update()} method.

::

    [language=C++]
    filter->Update();

If the output of this filter has been connected to other filters in a
pipeline, updating any of the downstream filters will also trigger an
update of this filter. For example, the gradient magnitude filter may be
connected to an image writer.

::

    [language=C++]
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );
    writer->Update();

    |image| |image1| [GradientMagnitudeImageFilter output] {Effect of
    the GradientMagnitudeImageFilter on a slice from a MRI proton
    density image of the brain.}
    {fig:GradientMagnitudeImageFilterInputOutput}

Figure {fig:GradientMagnitudeImageFilterInputOutput} illustrates the
effect of the gradient magnitude filter on a MRI proton density image of
the brain. The figure shows the sensitivity of this filter to noisy
data.

Attention should be paid to the image type chosen to represent the
output image since the dynamic range of the gradient magnitude image is
usually smaller than the dynamic range of the input image. As always,
there are exceptions to this rule, for example, synthetic images that
contain high contrast objects.

This filter does not apply any smoothing to the image before computing
the gradients. The results can therefore be very sensitive to noise and
may not be best choice for scale space analysis.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: GradientMagnitudeImageFilterOutput.eps
