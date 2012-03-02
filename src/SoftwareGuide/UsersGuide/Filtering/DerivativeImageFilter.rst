Derivative Without Smoothing
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:DerivativeImageFilter}

The source code for this section can be found in the file
``DerivativeImageFilter.cxx``.

The {DerivativeImageFilter} is used for computing the partial derivative
of an image, the derivative of an image along a particular axial
direction.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkDerivativeImageFilter.h"

Next, the pixel types for the input and output images must be defined
and, with them, the image types can be instantiated. Note that it is
important to select a signed type for the image, since the values of the
derivatives will be positive as well as negative.

::

    [language=C++]
    typedef   float  InputPixelType;
    typedef   float  OutputPixelType;

    const unsigned int Dimension = 2;

    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;

Using the image types, it is now possible to define the filter type and
create the filter object.

::

    [language=C++]
    typedef itk::DerivativeImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The order of the derivative is selected with the {SetOrder()} method.
The direction along which the derivative will be computed is selected
with the {SetDirection()} method.

::

    [language=C++]
    filter->SetOrder(     atoi( argv[4] ) );
    filter->SetDirection( atoi( argv[5] ) );

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example, a writer. An update call on any downstream filter will
trigger the execution of the derivative filter.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );
    writer->Update();

    |image| |image1| [Effect of the Derivative filter.] {Effect of the
    Derivative filter on a slice from a MRI proton density brain image.}
    {fig:DerivativeImageFilterOutput}

Figure {fig:DerivativeImageFilterOutput} illustrates the effect of the
DerivativeImageFilter on a slice of MRI brain image. The derivative is
taken along the :math:`x` direction. The sensitivity to noise in the
image is evident from this result.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: DerivativeImageFilterOutput.eps
