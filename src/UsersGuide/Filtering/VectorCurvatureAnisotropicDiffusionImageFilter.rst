The source code for this section can be found in the file
``VectorCurvatureAnisotropicDiffusionImageFilter.cxx``.

The {VectorCurvatureAnisotropicDiffusionImageFilter} performs
anisotropic diffusion on a vector image using a modified curvature
diffusion equation (MCDE). The MCDE is the same described in
{sec:CurvatureAnisotropicDiffusionImageFilter}.

Typically in vector-valued diffusion, vector components are diffused
independently of one another using a conductance term that is linked
across the components.

This filter is designed to process images of {Vector} type. The code
relies on various typedefs and overloaded operators defined in Vector.
It is perfectly reasonable, however, to apply this filter to images of
other, user-defined types as long as the appropriate typedefs and
operator overloads are in place. As a general rule, follow the example
of the Vector class in defining your data types.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkVectorCurvatureAnisotropicDiffusionImageFilter.h"

Types should be selected based on required pixel type for the input and
output images. The image types are defined using the pixel type and the
dimension.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef itk::CovariantVector<float,2>    VectorPixelType;
    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< VectorPixelType, 2 >   VectorImageType;

The filter type is now instantiated using both the input image and the
output image types. The filter object is created by the {New()} method.

::

    [language=C++]
    typedef itk::VectorCurvatureAnisotropicDiffusionImageFilter<
    VectorImageType, VectorImageType >  FilterType;
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source and its data is passed through a
gradient filter in order to generate an image of vectors.

::

    [language=C++]
    gradient->SetInput( reader->GetOutput() );
    filter->SetInput( gradient->GetOutput() );

This filter requires two parameters, the number of iterations to be
performed and the time step used in the computation of the level set
evolution. These parameters are set using the methods
{SetNumberOfIterations()} and {SetTimeStep()} respectively. The filter
can be executed by invoking {Update()}.

::

    [language=C++]
    filter->SetNumberOfIterations( numberOfIterations );
    filter->SetTimeStep( timeStep );
    filter->SetConductanceParameter(1.0);
    filter->Update();

Typical values for the time step are :math:`0.125` in :math:`2D`
images and :math:`0.0625` in :math:`3D` images. The number of
iterations can be usually around :math:`5`, more iterations will
result in further smoothing and will increase linearly the computing
time.

    |image| |image1| [VectorCurvatureAnisotropicDiffusionImageFilter
    output] {Effect of the
    VectorCurvatureAnisotropicDiffusionImageFilter on the :math:`X`
    component of the gradient from a MRIproton density brain image.}
    {fig:VectorCurvatureAnisotropicDiffusionImageFilterInputOutput}

Figure {fig:VectorCurvatureAnisotropicDiffusionImageFilterInputOutput}
illustrates the effect of this filter on a MRI proton density image of
the brain. The images show the :math:`X` component of the gradient
before (left) and after (right) the application of the filter. In this
example the filter was run with a time step of 0.25, and 5 iterations.

.. |image| image:: VectorCurvatureAnisotropicDiffusionImageFilterInput.eps
.. |image1| image:: VectorCurvatureAnisotropicDiffusionImageFilterOutput.eps
