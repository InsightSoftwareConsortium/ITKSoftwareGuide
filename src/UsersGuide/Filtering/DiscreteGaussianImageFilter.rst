The source code for this section can be found in the file
``DiscreteGaussianImageFilter.cxx``.

    |image| [DiscreteGaussianImageFilter Gaussian diagram.] {Discretized
    Gaussian.{fig:DiscretizedGaussian}}

The {DiscreteGaussianImageFilter} computes the convolution of the input
image with a Gaussian kernel. This is done in :math:`ND` by taking
advantage of the separability of the Gaussian kernel. A one-dimensional
Gaussian function is discretized on a convolution kernel. The size of
the kernel is extended until there are enough discrete points in the
Gaussian to ensure that a user-provided maximum error is not exceeded.
Since the size of the kernel is unknown a priori, it is necessary to
impose a limit to its growth. The user can thus provide a value to be
the maximum admissible size of the kernel. Discretization error is
defined as the difference between the area under the discrete Gaussian
curve (which has finite support) and the area under the continuous
Gaussian.

Gaussian kernels in ITK are constructed according to the theory of Tony
Lindeberg so that smoothing and derivative operations commute before and
after discretization. In other words, finite difference derivatives on
an image :math:`I` that has been smoothed by convolution with the
Gaussian are equivalent to finite differences computed on :math:`I` by
convolving with a derivative of the Gaussian.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkDiscreteGaussianImageFilter.h"

Types should be chosen for the pixels of the input and output images.
Image types can be instantiated using the pixel type and dimension.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The discrete Gaussian filter type is instantiated using the input and
output image types. A corresponding filter object is created.

::

    [language=C++]
    typedef itk::DiscreteGaussianImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as its input.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The filter requires the user to provide a value for the variance
associated with the Gaussian kernel. The method {SetVariance()} is used
for this purpose. The discrete Gaussian is constructed as a convolution
kernel. The maximum kernel size can be set by the user. Note that the
combination of variance and kernel-size values may result in a truncated
Gaussian kernel.

::

    [language=C++]
    filter->SetVariance( gaussianVariance );
    filter->SetMaximumKernelWidth( maxKernelWidth );

Finally, the filter is executed by invoking the {Update()} method.

::

    [language=C++]
    filter->Update();

If the output of this filter has been connected to other filters down
the pipeline, updating any of the downstream filters would have
triggered the execution of this one. For example, a writer could have
been used after the filter.

::

    [language=C++]
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );
    writer->Update();

    |image1| |image2| [DiscreteGaussianImageFilter output] {Effect of
    the DiscreteGaussianImageFilter on a slice from a MRI proton density
    image of the brain.} {fig:DiscreteGaussianImageFilterInputOutput}

Figure {fig:DiscreteGaussianImageFilterInputOutput} illustrates the
effect of this filter on a MRI proton density image of the brain.

Note that large Gaussian variances will produce large convolution
kernels and correspondingly slower computation times. Unless a high
degree of accuracy is required, it may be more desirable to use the
approximating {RecursiveGaussianImageFilter} with large variances.

.. |image| image:: DiscreteGaussian.eps
.. |image1| image:: BrainProtonDensitySlice.eps
.. |image2| image:: DiscreteGaussianImageFilterOutput.eps
