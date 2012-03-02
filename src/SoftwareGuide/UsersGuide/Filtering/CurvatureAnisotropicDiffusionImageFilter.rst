Curvature Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:CurvatureAnisotropicDiffusionImageFilter}

The source code for this section can be found in the file
``CurvatureAnisotropicDiffusionImageFilter.cxx``.

The {CurvatureAnisotropicDiffusionImageFilter} performs anisotropic
diffusion on an image using a modified curvature diffusion equation
(MCDE).

MCDE does not exhibit the edge enhancing properties of classic
anisotropic diffusion, which can under certain conditions undergo a
“negative” diffusion, which enhances the contrast of edges. Equations of
the form of MCDE always undergo positive diffusion, with the conductance
term only varying the strength of that diffusion.

Qualitatively, MCDE compares well with other non-linear diffusion
techniques. It is less sensitive to contrast than classic Perona-Malik
style diffusion, and preserves finer detailed structures in images.
There is a potential speed trade-off for using this function in place of
itkGradientNDAnisotropicDiffusionFunction. Each iteration of the
solution takes roughly twice as long. Fewer iterations, however, may be
required to reach an acceptable solution.

The MCDE equation is given as:

:math:`f_t = \mid \nabla f \mid \nabla \cdot c( \mid \nabla f \mid ) \frac{
\nabla f }{ \mid \nabla f \mid }
`

where the conductance modified curvature term is

:math:`\nabla \cdot \frac{\nabla f}{\mid \nabla f \mid}
`

The first step required for using this filter is to include its header
file

::

    [language=C++]
    #include "itkCurvatureAnisotropicDiffusionImageFilter.h"

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
    typedef itk::CurvatureAnisotropicDiffusionImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

This filter requires three parameters, the number of iterations to be
performed, the time step used in the computation of the level set
evolution and the value of conductance. These parameters are set using
the methods {SetNumberOfIterations()}, {SetTimeStep()} and
{SetConductance()} respectively. The filter can be executed by invoking
{Update()}.

::

    [language=C++]
    filter->SetNumberOfIterations( numberOfIterations );
    filter->SetTimeStep( timeStep );
    filter->SetConductanceParameter( conductance );
    if (useImageSpacing)
    {
    filter->UseImageSpacingOn();
    }
    filter->Update();

Typical values for the time step are 0.125 in :math:`2D` images and
0.0625 in :math:`3D` images. The number of iterations can be usually
around :math:`5`, more iterations will result in further smoothing and
will increase linearly the computing time. The conductance parameter is
usually around :math:`3.0`.

    |image| |image1| [CurvatureAnisotropicDiffusionImageFilter output]
    {Effect of the CurvatureAnisotropicDiffusionImageFilter on a slice
    from a MRI Proton Density image of the brain.}
    {fig:CurvatureAnisotropicDiffusionImageFilterInputOutput}

Figure {fig:CurvatureAnisotropicDiffusionImageFilterInputOutput}
illustrates the effect of this filter on a MRI proton density image of
the brain. In this example the filter was run with a time step of
:math:`0.125`, :math:`5` iterations and a conductance value of
:math:`3.0`. The figure shows how homogeneous regions are smoothed and
edges are preserved.

-  {BilateralImageFilter}

-  {CurvatureFlowImageFilter}

-  {GradientAnisotropicDiffusionImageFilter}

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: CurvatureAnisotropicDiffusionImageFilterOutput.eps
