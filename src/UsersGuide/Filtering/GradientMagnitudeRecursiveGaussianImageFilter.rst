The source code for this section can be found in the file
``GradientMagnitudeRecursiveGaussianImageFilter.cxx``.

Differentiation is an ill-defined operation over digital data. In
practice it is convenient to define a scale in which the differentiation
should be performed. This is usually done by preprocessing the data with
a smoothing filter. It has been shown that a Gaussian kernel is the most
convenient choice for performing such smoothing. By choosing a
particular value for the standard deviation (:math:`\sigma`) of the
Gaussian, an associated scale is selected that ignores high frequency
content, commonly considered image noise.

The {GradientMagnitudeRecursiveGaussianImageFilter} computes the
magnitude of the image gradient at each pixel location. The
computational process is equivalent to first smoothing the image by
convolving it with a Gaussian kernel and then applying a differential
operator. The user selects the value of :math:`\sigma`.

Internally this is done by applying an IIR  [1]_ filter that
approximates a convolution with the derivative of the Gaussian kernel.
Traditional convolution will produce a more accurate result, but the IIR
approach is much faster, especially using large :math:`\sigma`s .

GradientMagnitudeRecursiveGaussianImageFilter will work on images of any
dimension by taking advantage of the natural separability of the
Gaussian kernel and its derivatives.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkGradientMagnitudeRecursiveGaussianImageFilter.h"

Types should be instantiated based on the pixels of the input and output
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
output image types.

::

    [language=C++]
    typedef itk::GradientMagnitudeRecursiveGaussianImageFilter<
    InputImageType, OutputImageType >  FilterType;

A filter object is created by invoking the {New()} method and assigning
the result to a {SmartPointer}.

::

    [language=C++]
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The standard deviation of the Gaussian smoothing kernel is now set.

::

    [language=C++]
    filter->SetSigma( sigma );

Finally the filter is executed by invoking the {Update()} method.

::

    [language=C++]
    filter->Update();

If connected to other filters in a pipeline, this filter will
automatically update when any downstream filters are updated. For
example, we may connect this gradient magnitude filter to an image file
writer and then update the writer.

::

    [language=C++]
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );
    writer->Update();

    |image| |image1| [GradientMagnitudeRecursiveGaussianImageFilter
    output] {Effect of the GradientMagnitudeRecursiveGaussianImageFilter
    on a slice from a MRI proton density image of the brain.}
    {fig:GradientMagnitudeRecursiveGaussianImageFilterInputOutput}

Figure {fig:GradientMagnitudeRecursiveGaussianImageFilterInputOutput}
illustrates the effect of this filter on a MRI proton density image of
the brain using :math:`\sigma` values of :math:`3` (left) and
:math:`5` (right). The figure shows how the sensitivity to noise can
be regulated by selecting an appropriate :math:`\sigma`. This type of
scale-tunable filter is suitable for performing scale-space analysis.

/ Attention should be paid to the image type chosen to represent the
output image since the dynamic range of the gradient magnitude image is
usually smaller than the dynamic range of the input image.

.. [1]
   Infinite Impulse Response

.. |image| image:: GradientMagnitudeRecursiveGaussianImageFilterOutput3.eps
.. |image1| image:: GradientMagnitudeRecursiveGaussianImageFilterOutput5.eps
