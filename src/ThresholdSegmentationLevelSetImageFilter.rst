The source code for this section can be found in the file
``ThresholdSegmentationLevelSetImageFilter.cxx``.

The {ThresholdSegmentationLevelSetImageFilter} is an extension of the
threshold connected-component segmentation to the level set framework.
The goal is to define a range of intensity values that classify the
tissue type of interest and then base the propagation term on the level
set equation for that intensity range. Using the level set approach, the
smoothness of the evolving surface can be constrained to prevent some of
the “leaking” that is common in connected-component schemes.

The propagation term :math:`P` from Equation {eqn:LevelSetEquation} is
calculated from the {FeatureImage} input :math:`g` with
{UpperThreshold} :math:`U` and {LowerThreshold} :math:`L` according
to the following formula.

:math:`\label{eqn:ThresholdSegmentationLevelSetImageFilterPropagationTerm}
P(\mathbf{x}) = \left\{ \begin{array}{ll} g(\mathbf{x}) - L &
\mbox{if $g(\mathbf{x}) < (U-L)/2 + L$} \\ U - g(\mathbf{x}) &
\mbox{otherwise} \end{array} \right.  `

Figure {fig:ThresholdSegmentationSpeedTerm} illustrates the propagation
term function. Intensity values in :math:`g` between :math:`L` and
:math:`H` yield positive values in :math:`P`, while outside
intensities yield negative values in :math:`P`.

    |image| [ThresholdSegmentationLevelSetImageFilter collaboration
    diagram] {Collaboration diagram for the
    ThresholdSegmentationLevelSetImageFilter applied to a segmentation
    task.} {fig:ThresholdSegmentationLevelSetImageFilterDiagram}

    |image1| [Propagation term for threshold-based level set
    segmentation] {Propagation term for threshold-based level set
    segmentation. From
    Equation {eqn:ThresholdSegmentationLevelSetImageFilterPropagationTerm}.
    {fig:ThresholdSegmentationSpeedTerm}}

The threshold segmentation filter expects two inputs. The first is an
initial level set in the form of an {Image}. The second input is the
feature image :math:`g`. For many applications, this filter requires
little or no preprocessing of its input. Smoothing the input image is
not usually required to produce reasonable solutions, though it may
still be warranted in some cases.

Figure {fig:ThresholdSegmentationLevelSetImageFilterDiagram} shows how
the image processing pipeline is constructed. The initial surface is
generated using the fast marching filter. The output of the segmentation
filter is passed to a {BinaryThresholdImageFilter} to create a binary
representation of the segmented object. Let’s start by including the
appropriate header file.

::

    [language=C++]
    #include "itkThresholdSegmentationLevelSetImageFilter.h"

We define the image type using a particular pixel type and dimension. In
this case we will use 2D {float} images.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The following lines instantiate a
ThresholdSegmentationLevelSetImageFilter using the {New()} method.

::

    [language=C++]
    typedef  itk::ThresholdSegmentationLevelSetImageFilter< InternalImageType,
    InternalImageType > ThresholdSegmentationLevelSetImageFilterType;
    ThresholdSegmentationLevelSetImageFilterType::Pointer thresholdSegmentation =
    ThresholdSegmentationLevelSetImageFilterType::New();

For the ThresholdSegmentationLevelSetImageFilter, scaling parameters are
used to balance the influence of the propagation (inflation) and the
curvature (surface smoothing) terms from
Equation {eqn:LevelSetEquation}. The advection term is not used in this
filter. Set the terms with methods {SetPropagationScaling()} and
{SetCurvatureScaling()}. Both terms are set to 1.0 in this example.

::

    [language=C++]
    thresholdSegmentation->SetPropagationScaling( 1.0 );
    if ( argc > 8 )
    {
    thresholdSegmentation->SetCurvatureScaling( atof(argv[8]) );
    }
    else
    {
    thresholdSegmentation->SetCurvatureScaling( 1.0 );
    }

The convergence criteria {MaximumRMSError} and {MaximumIterations} are
set as in previous examples. We now set the upper and lower threshold
values :math:`U` and :math:`L`, and the isosurface value to use in
the initial model.

::

    [language=C++]
    thresholdSegmentation->SetUpperThreshold( ::atof(argv[7]) );
    thresholdSegmentation->SetLowerThreshold( ::atof(argv[6]) );
    thresholdSegmentation->SetIsoSurfaceValue(0.0);

The filters are now connected in a pipeline indicated in
Figure {fig:ThresholdSegmentationLevelSetImageFilterDiagram}. Remember
that before calling {Update()} on the file writer object, the fast
marching filter must be initialized with the seed points and the output
from the reader object. See previous examples and the source code for
this section for details.

::

    [language=C++]
    thresholdSegmentation->SetInput( fastMarching->GetOutput() );
    thresholdSegmentation->SetFeatureImage( reader->GetOutput() );
    thresholder->SetInput( thresholdSegmentation->GetOutput() );
    writer->SetInput( thresholder->GetOutput() );

Invoking the {Update()} method on the writer triggers the execution of
the pipeline. As usual, the call is placed in a {try/catch} block should
any errors occur or exceptions be thrown.

::

    [language=C++]
    try
    {
    reader->Update();
    const InternalImageType * inputImage = reader->GetOutput();
    fastMarching->SetOutputRegion( inputImage->GetBufferedRegion() );
    fastMarching->SetOutputSpacing( inputImage->GetSpacing() );
    fastMarching->SetOutputOrigin( inputImage->GetOrigin() );
    fastMarching->SetOutputDirection( inputImage->GetDirection() );
    writer->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

Let’s run this application with the same data and parameters as the
example given for {ConnectedThresholdImageFilter} in
Section {sec:ConnectedThreshold}. We will use a value of 5 as the
initial distance of the surface from the seed points. The algorithm is
relatively insensitive to this initialization. Compare the results in
Figure {fig:ThresholdSegmentationLevelSetImageFilter} with those in
Figure {fig:ConnectedThresholdOutput}. Notice how the smoothness
constraint on the surface prevents leakage of the segmentation into both
ventricles, but also localizes the segmentation to a smaller portion of
the gray matter.

    |image2| |image3| |image4| |image5| [ThresholdSegmentationLevelSet
    segmentations] {Images generated by the segmentation process based
    on the ThresholdSegmentationLevelSetImageFilter. From left to right:
    segmentation of the left ventricle, segmentation of the right
    ventricle, segmentation of the white matter, attempt of segmentation
    of the gray matter. The parameters used in this segmentations are
    presented in Table {tab:ThresholdSegmentationLevelSetImageFilter}}
    {fig:ThresholdSegmentationLevelSetImageFilter}

            Structure & Seed Index & Lower & Upper & Output Image
             White matter & :math:`(60,116)` & 150 & 180 & Second from
            left
             Ventricle & :math:`(81,112)` & 210 & 250 & Third from
            left
             Gray matter & :math:`(107,69)` & 180 & 210 & Fourth from
            left

        [ThresholdSegmentationLevelSet segmentation parameters]
        {Segmentation results using the
        ThresholdSegmentationLevelSetImageFilter for various seed
        points. The resulting images are shown in
        Figure {fig:ThresholdSegmentationLevelSetImageFilter}
        {tab:ThresholdSegmentationLevelSetImageFilter} }.

.. |image| image:: ThresholdSegmentationLevelSetImageFilterCollaborationDiagram1.eps
.. |image1| image:: ThresholdSegmentationLevelSetImageFilterFigure1.eps
.. |image2| image:: BrainProtonDensitySlice.eps
.. |image3| image:: ThresholdSegmentationLevelSetImageFilterWhiteMatter.eps
.. |image4| image:: ThresholdSegmentationLevelSetImageFilterVentricle.eps
.. |image5| image:: ThresholdSegmentationLevelSetImageFilterGrayMatter.eps
