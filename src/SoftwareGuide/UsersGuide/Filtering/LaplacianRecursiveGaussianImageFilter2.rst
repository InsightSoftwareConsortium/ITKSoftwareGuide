The source code for this section can be found in the file
``LaplacianRecursiveGaussianImageFilter2.cxx``.

The previous exampled showed how to use the
{RecursiveGaussianImageFilter} for computing the equivalent of a
Laplacian of an image after smoothing with a Gaussian. The elements used
in this previous example have been packaged together in the
{LaplacianRecursiveGaussianImageFilter} in order to simplify its usage.
This current example shows how to use this convenience filter for
achieving the same results as the previous example.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkLaplacianRecursiveGaussianImageFilter.h"

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
    typedef itk::LaplacianRecursiveGaussianImageFilter<
    InputImageType, OutputImageType >  FilterType;

This filter packages all the components illustrated in the previous
example. The filter is created by invoking the {New()} method and
assigning the result to a {SmartPointer}.

::

    [language=C++]
    FilterType::Pointer laplacian = FilterType::New();

The option for normalizing across scale space can also be selected in
this filter.

::

    [language=C++]
    laplacian->SetNormalizeAcrossScale( false );

The input image can be obtained from the output of another filter. Here,
an image reader is used as the source.

::

    [language=C++]
    laplacian->SetInput( reader->GetOutput() );

It is now time to select the :math:`\sigma` of the Gaussian used to
smooth the data. Note that :math:`\sigma` must be passed to both
filters and that sigma is considered to be in millimeters. That is, at
the moment of applying the smoothing process, the filter will take into
account the spacing values defined in the image.

::

    [language=C++]
    laplacian->SetSigma( sigma );

Finally the pipeline is executed by invoking the {Update()} method.

::

    [language=C++]
    try
    {
    laplacian->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return EXIT_FAILURE;
    }

    |image| |image1| [Output of the
    LaplacianRecursiveGaussianImageFilter.] {Effect of the
    LaplacianRecursiveGaussianImageFilter on a slice from a MRI proton
    density image of the brain.}
    {fig:RecursiveGaussianImageFilter2InputOutput}

Figure {fig:RecursiveGaussianImageFilter2InputOutput} illustrates the
effect of this filter on a MRI proton density image of the brain using
:math:`\sigma` values of :math:`3` (left) and :math:`5` (right).
The figure shows how the attenuation of noise can be regulated by
selecting the appropriate standard deviation. This type of scale-tunable
filter is suitable for performing scale-space analysis.

.. |image| image:: LaplacianRecursiveGaussianImageFilter2Output3.eps
.. |image1| image:: LaplacianRecursiveGaussianImageFilter2Output5.eps
