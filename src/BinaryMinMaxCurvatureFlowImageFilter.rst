The source code for this section can be found in the file
``BinaryMinMaxCurvatureFlowImageFilter.cxx``.

The \doxygen{BinaryMinMaxCurvatureFlowImageFilter} applies a variant of the
CurvatureFlow algorithm. Which means that the speed of propagation is
proportional to the curvature :math:`\kappa` of iso-contours. This
filter adds however, the restriction that negative curvatures are only
accepted in regions of the image having low intensities. The user should
provide an intensity threshold over which negative curvatures are not
considered for the propagation.

In practice the algorithm do the following for each pixel. First, the
curvature :math:`\kappa` is computed on the current pixel. If the
computed curvature is null this is returned as value. Otherwise, an
average of neighbor pixel intensities is computed and it is compared
against a user-provided threshold. If this average is less than the
threshold then the algorithm returns :math:`\min(\kappa,0)`. If the
average intensity is greater or equal than user-provided threshold, then
the returned value is :math:`\max(\kappa,0)`.

:math:`I_t = F |\nabla I|
`

where :math:`F` is defined as

:math:`F = \left\{ \begin{array} {r@{\quad:\quad}l} \min(\kappa,0) &
\mbox{Average} < \mbox{Threshold} \\ \max(\kappa,0) & \mbox{Average} \ge
\mbox{Threshold} \end{array} \right.
`

.. index::
   single: BinaryMinMaxCurvatureFlowImageFilter

The first step required for using this filter is to include its header
file

::

    [language=C++]
    #include "itkBinaryMinMaxCurvatureFlowImageFilter.h"

Types should be chosen for the pixels of the input and output images and
with them the image types are instantiated.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The BinaryMinMaxCurvatureFlowFilter type is now instantiated using both
the input image and the output image types. The filter is then created
using the \code{New()} method.

::

    [language=C++]
    typedef itk::BinaryMinMaxCurvatureFlowImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The \doxygen{BinaryMinMaxCurvatureFlowImageFilter} requires the same parameters
of the MinMaxCurvatureFlowImageFilter plus the value of the threshold
against which the neighborhood average will be compared. The threshold
is passed using the \code{SetThreshold()} method. Then the filter can be
executed by invoking \code{Update()}.

::

    [language=C++]
    filter->SetTimeStep( timeStep );
    filter->SetNumberOfIterations( numberOfIterations );

    filter->SetStencilRadius( radius );
    filter->SetThreshold( threshold );

    filter->Update();

Typical values for the time step are :math:`0.125` in :math:`2D`
images and :math:`0.0625` in :math:`3D` images. The number of
iterations can be usually around :math:`10`, more iterations will
result in further smoothing and will increase linearly the computing
time. The radius of the stencil can be typically :math:`1`. The value
of the threshold should be selected according to the gray levels of the
object of interest and the gray level of its background.

    |image| |image1| [BinaryMinMaxCurvatureFlowImageFilter output]
    {Effect of the BinaryMinMaxCurvatureFlowImageFilter on a slice from
    a MRI proton density image of the brain.}
    {fig:BinaryMinMaxCurvatureFlowImageFilterInputOutput}

Figure \ref{fig:BinaryMinMaxCurvatureFlowImageFilterInputOutput} illustrates
the effect of this filter on a MRI proton density image of the brain. In
this example the filter was run with a time step of :math:`0.125`,
:math:`10` iterations, a stencil radius of :math:`1` and a threshold
of :math:`128`.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: BinaryMinMaxCurvatureFlowImageFilterOutput.eps
