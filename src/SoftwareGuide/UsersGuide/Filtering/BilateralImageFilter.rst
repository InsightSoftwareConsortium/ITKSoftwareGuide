The source code for this section can be found in the file
``BilateralImageFilter.cxx``.

The \doxygen{BilateralImageFilter} performs smoothing by using both domain and
range neighborhoods. Pixels that are close to a pixel in the image
domain and similar to a pixel in the image range are used to calculate
the filtered value. Two Gaussian kernels (one in the image domain and
one in the image range) are used to smooth the image. The result is an
image that is smoothed in homogeneous regions yet has edges preserved.
The result is similar to anisotropic diffusion but the implementation in
non-iterative. Another benefit to bilateral filtering is that any
distance metric can be used for kernel smoothing the image range.
Bilateral filtering is capable of reducing the noise in an image by an
order of magnitude while maintaining edges. The bilateral operator used
here was described by Tomasi and Manduchi (*Bilateral Filtering for Gray
and Color Images*. IEEE ICCV. 1998.)

The filtering operation can be described by the following equation

:math:`h(\mathbf{x}) = k(\mathbf{x})^{-1} \int_\omega f(\mathbf{w})
c(\mathbf{x},\mathbf{w}) s( f(\mathbf{x}),f(\mathbf{w})) d \mathbf{w}`

where :math:`\mathbf{x}` holds the coordinates of a :math:`ND`
point, :math:`f(\mathbf{x})` is the input image and
:math:`h(\mathbf{x})` is the output image. The convolution kernels
:math:`c()` and :math:`s()` are associated with the spatial and
intensity domain respectively. The :math:`ND` integral is computed
over :math:`\omega` which is a neighborhood of the pixel located at
:math:`\mathbf{x}`. The normalization factor :math:`k(\mathbf{x})`
is computed as

:math:`k(\mathbf{x}) = \int_\omega c(\mathbf{x},\mathbf{w})
s( f(\mathbf{x}),f(\mathbf{w})) d \mathbf{w}`

The default implementation of this filter uses Gaussian kernels for both
:math:`c()` and :math:`s()`. The :math:`c` kernel can be described
as

:math:`c(\mathbf{x},\mathbf{w}) = e^{(\frac{ {\left|| \mathbf{x} - \mathbf{w} \right||}^2 }{\sigma^2_c} )}`

where :math:`\sigma_c` is provided by the user and defines how close
pixel neighbors should be in order to be considered for the computation
of the output value. The :math:`s` kernel is given by

:math:`s(f(\mathbf{x}),f(\mathbf{w})) = e^{(\frac{ {( f(\mathbf{x}) - f(\mathbf{w})}^2 }{\sigma^2_s} )}`

where :math:`\sigma_s` is provided by the user and defines how close
should the neighbors intensity be in order to be considered for the
computation of the output value.

.. index::
   single:BilateralImageFilter

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkBilateralImageFilter.h"

The image types are instantiated using pixel type and dimension.

::

    [language=C++]
    typedef    unsigned char    InputPixelType;
    typedef    unsigned char    OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The bilateral filter type is now instantiated using both the input image
and the output image types and the filter object is created.

::

    [language=C++]
    typedef itk::BilateralImageFilter<
    InputImageType, OutputImageType >  FilterType;
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as a source.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The Bilateral filter requires two parameters. First, the
:math:`\sigma` to be used for the Gaussian kernel on image
intensities. Second, the set of :math:`\sigma`s to be used along each
dimension in the space domain. This second parameter is supplied as an
array of \code{float} or \code{double} values. The array dimension matches the
image dimension. This mechanism makes possible to enforce more coherence
along some directions. For example, more smoothing can be done along the
:math:`X` direction than along the :math:`Y` direction.

In the following code example, the :math:`\sigma` values are taken
from the command line. Note the use of \code{ImageType::ImageDimension} to
get access to the image dimension at compile time.

::

    [language=C++]
    const unsigned int Dimension = InputImageType::ImageDimension;
    double domainSigmas[ Dimension ];
    for(unsigned int i=0; i<Dimension; i++)
    {
    domainSigmas[i] = atof( argv[3] );
    }
    const double rangeSigma = atof( argv[4] );

The filter parameters are set with the methods SetRangeSigma() and
SetDomainSigma().

.. index::
   pair:BilateralImageFilter;SetRangeSigma
   pair:BilateralImageFilter;SetDomainSigma

::
    [language=C++]
    filter->SetDomainSigma( domainSigmas );
    filter->SetRangeSigma(  rangeSigma   );

The output of the filter is connected here to a intensity rescaler
filter and then to a writer. Invoking \code{Update()} on the writer triggers
the execution of both filters.

::

    [language=C++]
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );
    writer->Update();

    |image| |image1| [BilateralImageFilter output] {Effect of the
    BilateralImageFilter on a slice from a MRI proton density image of
    the brain.} {fig:BilateralImageFilterInputOutput}

Figure \ref{fig:BilateralImageFilterInputOutput} illustrates the effect of
this filter on a MRI proton density image of the brain. In this example
the filter was run with a range sigma of :math:`5.0` and a domain
:math:`\sigma` of :math:`6.0`. The figure shows how homogeneous
regions are smoothed and edges are preserved.

\relatedClasses
- \doxygen{GradientAnisotropicDiffusionImageFilter}
- \doxygen{CurvatureAnisotropicDiffusionImageFilter}
- \doxygen{CurvatureFlowImageFilter}

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: BilateralImageFilterOutput.eps
