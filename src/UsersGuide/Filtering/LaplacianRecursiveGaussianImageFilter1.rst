The source code for this section can be found in the file
``LaplacianRecursiveGaussianImageFilter1.cxx``.

This example illustrates how to use the {RecursiveGaussianImageFilter}
for computing the Laplacian of a 2D image.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkRecursiveGaussianImageFilter.h"

Types should be selected on the desired input and output pixel types.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

The input and output image types are instantiated using the pixel types.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The filter type is now instantiated using both the input image and the
output image types.

::

    [language=C++]
    typedef itk::RecursiveGaussianImageFilter<
    InputImageType, OutputImageType >  FilterType;

This filter applies the approximation of the convolution along a single
dimension. It is therefore necessary to concatenate several of these
filters to produce smoothing in all directions. In this example, we
create a pair of filters since we are processing a :math:`2D` image.
The filters are created by invoking the {New()} method and assigning the
result to a {SmartPointer}.

We need two filters for computing the X component of the Laplacian and
two other filters for computing the Y component.

::

    [language=C++]
    FilterType::Pointer filterX1 = FilterType::New();
    FilterType::Pointer filterY1 = FilterType::New();

    FilterType::Pointer filterX2 = FilterType::New();
    FilterType::Pointer filterY2 = FilterType::New();

Since each one of the newly created filters has the potential to perform
filtering along any dimension, we have to restrict each one to a
particular direction. This is done with the {SetDirection()} method.

::

    [language=C++]
    filterX1->SetDirection( 0 );    0 --> X direction
    filterY1->SetDirection( 1 );    1 --> Y direction

    filterX2->SetDirection( 0 );    0 --> X direction
    filterY2->SetDirection( 1 );    1 --> Y direction

The {RecursiveGaussianImageFilter} can approximate the convolution with
the Gaussian or with its first and second derivatives. We select one of
these options by using the {SetOrder()} method. Note that the argument
is an {enum} whose values can be {ZeroOrder}, {FirstOrder} and
{SecondOrder}. For example, to compute the :math:`x` partial
derivative we should select {FirstOrder} for :math:`x` and {ZeroOrder}
for :math:`y`. Here we want only to smooth in :math:`x` and
:math:`y`, so we select {ZeroOrder} in both directions.

::

    [language=C++]
    filterX1->SetOrder( FilterType::ZeroOrder );
    filterY1->SetOrder( FilterType::SecondOrder );

    filterX2->SetOrder( FilterType::SecondOrder );
    filterY2->SetOrder( FilterType::ZeroOrder );

There are two typical ways of normalizing Gaussians depending on their
application. For scale-space analysis it is desirable to use a
normalization that will preserve the maximum value of the input. This
normalization is represented by the following equation.

:math:`\frac{ 1 }{ \sigma  \sqrt{ 2 \pi } }
`

In applications that use the Gaussian as a solution of the diffusion
equation it is desirable to use a normalization that preserve the
integral of the signal. This last approach can be seen as a conservation
of mass principle. This is represented by the following equation.

:math:`\frac{ 1 }{ \sigma^2  \sqrt{ 2 \pi } }
`

The {RecursiveGaussianImageFilter} has a boolean flag that allows users
to select between these two normalization options. Selection is done
with the method {SetNormalizeAcrossScale()}. Enable this flag to
analyzing an image across scale-space. In the current example, this
setting has no impact because we are actually renormalizing the output
to the dynamic range of the reader, so we simply disable the flag.

::

    [language=C++]
    const bool normalizeAcrossScale = false;
    filterX1->SetNormalizeAcrossScale( normalizeAcrossScale );
    filterY1->SetNormalizeAcrossScale( normalizeAcrossScale );
    filterX2->SetNormalizeAcrossScale( normalizeAcrossScale );
    filterY2->SetNormalizeAcrossScale( normalizeAcrossScale );

The input image can be obtained from the output of another filter. Here,
an image reader is used as the source. The image is passed to the
:math:`x` filter and then to the :math:`y` filter. The reason for
keeping these two filters separate is that it is usual in scale-space
applications to compute not only the smoothing but also combinations of
derivatives at different orders and smoothing. Some factorization is
possible when separate filters are used to generate the intermediate
results. Here this capability is less interesting, though, since we only
want to smooth the image in all directions.

::

    [language=C++]
    filterX1->SetInput( reader->GetOutput() );
    filterY1->SetInput( filterX1->GetOutput() );

    filterY2->SetInput( reader->GetOutput() );
    filterX2->SetInput( filterY2->GetOutput() );

It is now time to select the :math:`\sigma` of the Gaussian used to
smooth the data. Note that :math:`\sigma` must be passed to both
filters and that sigma is considered to be in millimeters. That is, at
the moment of applying the smoothing process, the filter will take into
account the spacing values defined in the image.

::

    [language=C++]
    filterX1->SetSigma( sigma );
    filterY1->SetSigma( sigma );
    filterX2->SetSigma( sigma );
    filterY2->SetSigma( sigma );

Finally the two components of the Laplacian should be added together.
The {AddImageFilter} is used for this purpose.

::

    [language=C++]
    typedef itk::AddImageFilter<
    OutputImageType,
    OutputImageType,
    OutputImageType > AddFilterType;

    AddFilterType::Pointer addFilter = AddFilterType::New();

    addFilter->SetInput1( filterY1->GetOutput() );
    addFilter->SetInput2( filterX2->GetOutput() );

The filters are triggered by invoking {Update()} on the Add filter at
the end of the pipeline.

::

    [language=C++]
    try
    {
    addFilter->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return EXIT_FAILURE;
    }

The resulting image could be saved to a file using the {ImageFileWriter}
class.

::

    [language=C++]
    typedef  float WritePixelType;

    typedef itk::Image< WritePixelType, 2 >    WriteImageType;

    typedef itk::ImageFileWriter< WriteImageType >  WriterType;

    WriterType::Pointer writer = WriterType::New();

    writer->SetInput( addFilter->GetOutput() );

    writer->SetFileName( argv[2] );

    writer->Update();

    |image| |image1| [Output of the
    LaplacianRecursiveGaussianImageFilter.] {Effect of the
    LaplacianRecursiveGaussianImageFilter on a slice from a MRI proton
    density image of the brain.}
    {fig:LaplacianRecursiveGaussianImageFilterInputOutput}

Figure {fig:LaplacianRecursiveGaussianImageFilterInputOutput}
illustrates the effect of this filter on a MRI proton density image of
the brain using :math:`\sigma` values of :math:`3` (left) and
:math:`5` (right). The figure shows how the attenuation of noise can
be regulated by selecting the appropriate standard deviation. This type
of scale-tunable filter is suitable for performing scale-space analysis.

.. |image| image:: LaplacianRecursiveGaussianImageFilterOutput3.eps
.. |image1| image:: LaplacianRecursiveGaussianImageFilterOutput5.eps
