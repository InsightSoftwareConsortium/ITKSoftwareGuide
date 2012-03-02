The source code for this section can be found in the file
``CurvatureFlowImageFilter.cxx``.

The {CurvatureFlowImageFilter} performs edge-preserving smoothing in a
similar fashion to the classical anisotropic diffusion. The filter uses
a level set formulation where the iso-intensity contours in a image are
viewed as level sets, where pixels of a particular intensity form one
level set. The level set function is then evolved under the control of a
diffusion equation where the speed is proportional to the curvature of
the contour:

:math:`I_t = \kappa |\nabla I|
`

where :math:` \kappa ` is the curvature.

Areas of high curvature will diffuse faster than areas of low curvature.
Hence, small jagged noise artifacts will disappear quickly, while large
scale interfaces will be slow to evolve, thereby preserving sharp
boundaries between objects. However, it should be noted that although
the evolution at the boundary is slow, some diffusion still occur. Thus,
continual application of this curvature flow scheme will eventually
result is the removal of information as each contour shrinks to a point
and disappears.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkCurvatureFlowImageFilter.h"

Types should be selected based on the pixel types required for the input
and output images.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

With them, the input and output image types can be instantiated.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The CurvatureFlow filter type is now instantiated using both the input
image and the output image types.

::

    [language=C++]
    typedef itk::CurvatureFlowImageFilter<
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

The CurvatureFlow filter requires two parameters, the number of
iterations to be performed and the time step used in the computation of
the level set evolution. These two parameters are set using the methods
{SetNumberOfIterations()} and {SetTimeStep()} respectively. Then the
filter can be executed by invoking {Update()}.

::

    [language=C++]
    filter->SetNumberOfIterations( numberOfIterations );
    filter->SetTimeStep( timeStep );
    filter->Update();

Typical values for the time step are :math:`0.125` in :math:`2D`
images and :math:`0.0625` in :math:`3D` images. The number of
iterations can be usually around :math:`10`, more iterations will
result in further smoothing and will increase linearly the computing
time. Edge-preserving behavior is not guaranteed by this filter, some
degradation will occur on the edges and will increase as the number of
iterations is increased.

If the output of this filter has been connected to other filters down
the pipeline, updating any of the downstream filters will triggered the
execution of this one. For example, a writer filter could have been used
after the curvature flow filter.

::

    [language=C++]
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );
    writer->Update();

    |image| |image1| [CurvatureFlowImageFilter output] {Effect of the
    CurvatureFlowImageFilter on a slice from a MRI proton density image
    of the brain.} {fig:CurvatureFlowImageFilterInputOutput}

Figure {fig:CurvatureFlowImageFilterInputOutput} illustrates the effect
of this filter on a MRI proton density image of the brain. In this
example the filter was run with a time step of :math:`0.25` and
:math:`10` iterations. The figure shows how homogeneous regions are
smoothed and edges are preserved.

-  {GradientAnisotropicDiffusionImageFilter}

-  {CurvatureAnisotropicDiffusionImageFilter}

-  {BilateralImageFilter}

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: CurvatureFlowImageFilterOutput.eps
