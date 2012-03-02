Gradient Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:GradientAnisotropicDiffusionImageFilter}

The source code for this section can be found in the file
``GradientAnisotropicDiffusionImageFilter.cxx``. The
{GradientAnisotropicDiffusionImageFilter} implements an
:math:`N`-dimensional version of the classic Perona-Malik anisotropic
diffusion equation for scalar-valued images .

The conductance term for this implementation is chosen as a function of
the gradient magnitude of the image at each point, reducing the strength
of diffusion at edge pixels.

:math:`C(\mathbf{x}) = e^{-(\frac{\parallel \nabla U(\mathbf{x}) \parallel}{K})^2}
`

The numerical implementation of this equation is similar to that
described in the Perona-Malik paper , but uses a more robust technique
for gradient magnitude estimation and has been generalized to
:math:`N`-dimensions.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkGradientAnisotropicDiffusionImageFilter.h"

Types should be selected based on the pixel types required for the input
and output images. The image types are defined using the pixel type and
the dimension.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The filter type is now instantiated using both the input image and the
output image types. The filter object is created by the {New()} method.

::

    [language=C++]
    typedef itk::GradientAnisotropicDiffusionImageFilter<
    InputImageType, OutputImageType >  FilterType;
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

This filter requires three parameters, the number of iterations to be
performed, the time step and the conductance parameter used in the
computation of the level set evolution. These parameters are set using
the methods {SetNumberOfIterations()}, {SetTimeStep()} and
{SetConductanceParameter()} respectively. The filter can be executed by
invoking Update().

::

    [language=C++]
    filter->SetNumberOfIterations( numberOfIterations );
    filter->SetTimeStep( timeStep );
    filter->SetConductanceParameter( conductance );

    filter->Update();

Typical values for the time step are :math:`0.25` in :math:`2D`
images and :math:`0.125` in :math:`3D` images. The number of
iterations is typically set to :math:`5`; more iterations result in
further smoothing and will increase the computing time linearly.

    |image| |image1| [GradientAnisotropicDiffusionImageFilter output]
    {Effect of the GradientAnisotropicDiffusionImageFilter on a slice
    from a MRI Proton Density image of the brain.}
    {fig:GradientAnisotropicDiffusionImageFilterInputOutput}

Figure {fig:GradientAnisotropicDiffusionImageFilterInputOutput}
illustrates the effect of this filter on a MRI proton density image of
the brain. In this example the filter was run with a time step of
:math:`0.25`, and :math:`5` iterations. The figure shows how
homogeneous regions are smoothed and edges are preserved.

-  {BilateralImageFilter}

-  {CurvatureAnisotropicDiffusionImageFilter}

-  {CurvatureFlowImageFilter}

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: GradientAnisotropicDiffusionImageFilterOutput.eps
