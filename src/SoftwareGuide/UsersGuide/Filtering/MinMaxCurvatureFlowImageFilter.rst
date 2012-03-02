The source code for this section can be found in the file
``MinMaxCurvatureFlowImageFilter.cxx``.

    |image| [MinMaxCurvatureFlow computation] {Elements involved in the
    computation of min-max curvature flow.}
    {fig:MinMaxCurvatureFlowFunctionDiagram}

The MinMax curvature flow filter applies a variant of the curvature flow
algorithm where diffusion is turned on or off depending of the scale of
the noise that one wants to remove. The evolution speed is switched
between :math:`\min(\kappa,0)` and :math:`\max(\kappa,0)` such that:

:math:`I_t = F |\nabla I|
`

where :math:`F` is defined as

:math:`F = \left\{ \begin{array} {r@{\quad:\quad}l}
\max(\kappa,0) & \mbox{Average} < Threshold \\ \min(\kappa,0) & \mbox{Average} \ge Threshold
\end{array} \right.
`

The :math:`Average` is the average intensity computed over a
neighborhood of a user specified radius of the pixel. The choice of the
radius governs the scale of the noise to be removed. The
:math:`Threshold` is calculated as the average of pixel intensities
along the direction perpendicular to the gradient at the *extrema* of
the local neighborhood.

A speed of :math:`F = max(\kappa,0)` will cause small dark regions in
a predominantly light region to shrink. Conversely, a speed of
:math:`F =
min(\kappa,0)`, will cause light regions in a predominantly dark region
to shrink. Comparison between the neighborhood average and the threshold
is used to select the the right speed function to use. This switching
prevents the unwanted diffusion of the simple curvature flow method.

Figure {fig:MinMaxCurvatureFlowFunctionDiagram} shows the main elements
involved in the computation. The set of square pixels represent the
neighborhood over which the average intensity is being computed. The
gray pixels are those lying close to the direction perpendicular to the
gradient. The pixels which intersect the neighborhood bounds are used to
compute the threshold value in the equation above. The integer radius of
the neighborhood is selected by the user.

The first step required to use the {MinMaxCurvatureFlowImageFilter} is
to include its header file.

::

    [language=C++]
    #include "itkMinMaxCurvatureFlowImageFilter.h"

Types should be selected based on the pixel types required for the input
and output images. The input and output image types are instantiated.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The {MinMaxCurvatureFlowImageFilter} type is now instantiated using both
the input image and the output image types. The filter is then created
using the {New()} method.

::

    [language=C++]
    typedef itk::MinMaxCurvatureFlowImageFilter<
    InputImageType, OutputImageType >  FilterType;
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The {MinMaxCurvatureFlowImageFilter} requires the two normal parameters
of the CurvatureFlow image, the number of iterations to be performed and
the time step used in the computation of the level set evolution. In
addition to them, the radius of the neighborhood is also required. This
last parameter is passed using the {SetStencilRadius()} method. Note
that the radius is provided as an integer number since it is referring
to a number of pixels from the center to the border of the neighborhood.
Then the filter can be executed by invoking {Update()}.

::

    [language=C++]
    filter->SetTimeStep( timeStep );
    filter->SetNumberOfIterations( numberOfIterations );
    filter->SetStencilRadius( radius );
    filter->Update();

Typical values for the time step are :math:`0.125` in :math:`2D`
images and :math:`0.0625` in :math:`3D` images. The number of
iterations can be usually around :math:`10`, more iterations will
result in further smoothing and will increase the computing time
linearly. The radius of the stencil can be typically :math:`1`. The
*edge-preserving* characteristic is not perfect on this filter, some
degradation will occur on the edges and will increase as the number of
iterations is increased.

If the output of this filter has been connected to other filters down
the pipeline, updating any of the downstream filters would have
triggered the execution of this one. For example, a writer filter could
have been used after the curvature flow filter.

::

    [language=C++]
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );
    writer->Update();

    |image1| |image2| [MinMaxCurvatureFlowImageFilter output] {Effect of
    the MinMaxCurvatureFlowImageFilter on a slice from a MRI proton
    density image of the brain.}
    {fig:MinMaxCurvatureFlowImageFilterInputOutput}

Figure {fig:MinMaxCurvatureFlowImageFilterInputOutput} illustrates the
effect of this filter on a MRI proton density image of the brain. In
this example the filter was run with a time step of :math:`0.125`,
:math:`10` iterations and a radius of :math:`1`. The figure shows
how homogeneous regions are smoothed and edges are preserved. Notice
also, that the results in the figure has sharper edges than the same
example using simple curvature flow in Figure
{fig:CurvatureFlowImageFilterInputOutput}.

-  {CurvatureFlowImageFilter}

.. |image| image:: MinMaxCurvatureFlowFunctionDiagram.eps
.. |image1| image:: BrainProtonDensitySlice.eps
.. |image2| image:: MinMaxCurvatureFlowImageFilterOutput.eps
