The source code for this section can be found in the file
``SmoothingRecursiveGaussianImageFilter2.cxx``.

Setting up a pipeline of :math:`m` filters in order to smooth an
N-dimensional image may be a lot of work to do for achieving a simple
goal. In order to avoid this inconvenience, a filter packaging this
:math:`m` filters internally is available. This filter is the
{SmoothingRecursiveGaussianImageFilter}.

In order to use this filter the following header file must be included.

::

    [language=C++]
    #include "itkSmoothingRecursiveGaussianImageFilter.h"

Appropriate pixel types must be selected to support input and output
images.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

With them, the input and output image types can be instantiated.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The filter type is now instantiated using both the input image and the
output image types. If the second template parameter is omitted, the
filter will assume that the output image has the same type as the input
image.

::

    [language=C++]
    typedef itk::SmoothingRecursiveGaussianImageFilter<
    InputImageType, OutputImageType >  FilterType;

Now a single filter is enough for smoothing the image along all the
dimensions. The filter is created by invoking the {New()} method and
assigning the result to a {SmartPointer}.

::

    [language=C++]
    FilterType::Pointer filter = FilterType::New();

As in the previous examples we should decide what type of normalization
to use during the computation of the Gaussians. The method
{SetNormalizeAcrossScale()} serves this purpose.

::

    [language=C++]
    filter->SetNormalizeAcrossScale( false );

The input image can be obtained from the output of another filter. Here,
an image reader is used as source. The image is passed directly to the
smoothing filter.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

It is now time for selecting the :math:`\sigma` of the Gaussian to use
for smoothing the data. Note that :math:`\sigma` is considered to be
in millimeters. That is, at the moment of applying the smoothing
process, the filter will take into account the spacing values defined in
the image.

::

    [language=C++]
    filter->SetSigma( sigma );

Finally the pipeline is executed by invoking the {Update()} method.

::

    [language=C++]
    filter->Update();

    |image| |image1| [SmoothingRecursiveGaussianImageFilter output]
    {Effect of the SmoothingRecursiveGaussianImageFilter on a slice from
    a MRI proton density image of the brain.}
    {fig:SmoothingRecursiveGaussianImageFilterInputOutput}

Figure {fig:SmoothingRecursiveGaussianImageFilterInputOutput}
illustrates the effect of this filter on a MRI proton density image of
the brain using a :math:`\sigma` value of :math:`3` (left) and a
value of :math:`5` (right). The figure shows how the attenuation of
noise can be regulated by selecting an appropriate sigma. This type of
scale-tunable filter is suitable for performing scale-space analysis.

.. |image| image:: SmoothingRecursiveGaussianImageFilterOutput3.eps
.. |image1| image:: SmoothingRecursiveGaussianImageFilterOutput5.eps
