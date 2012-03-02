The source code for this section can be found in the file
``ShapeDetectionLevelSetFilter.cxx``.

The use of the {ShapeDetectionLevelSetImageFilter} is illustrated in the
following example. The implementation of this filter in ITK is based on
the paper by Malladi et al . In this implementation, the governing
differential equation has an additional curvature-based term. This term
acts as a smoothing term where areas of high curvature, assumed to be
due to noise, are smoothed out. Scaling parameters are used to control
the tradeoff between the expansion term and the smoothing term. One
consequence of this additional curvature term is that the fast marching
algorithm is no longer applicable, because the contour is no longer
guaranteed to always be expanding. Instead, the level set function is
updated iteratively.

The ShapeDetectionLevelSetImageFilter expects two inputs, the first
being an initial Level Set in the form of an {Image}, and the second
being a feature image. For this algorithm, the feature image is an edge
potential image that basically follows the same rules applicable to the
speed image used for the FastMarchingImageFilter discussed in
Section {sec:FastMarchingImageFilter}.

In this example we use an FastMarchingImageFilter to produce the initial
level set as the distance function to a set of user-provided seeds. The
FastMarchingImageFilter is run with a constant speed value which enables
us to employ this filter as a distance map calculator.

    |image| [ShapeDetectionLevelSetImageFilter collaboration diagram]
    {Collaboration diagram for the ShapeDetectionLevelSetImageFilter
    applied to a segmentation task.}
    {fig:ShapeDetectionCollaborationDiagram}

Figure {fig:ShapeDetectionCollaborationDiagram} shows the major
components involved in the application of the
ShapeDetectionLevelSetImageFilter to a segmentation task. The first
stage involves smoothing using the
{CurvatureAnisotropicDiffusionImageFilter}. The smoothed image is passed
as the input for the {GradientMagnitudeRecursiveGaussianImageFilter} and
then to the {SigmoidImageFilter} in order to produce the edge potential
image. A set of user-provided seeds is passed to an
FastMarchingImageFilter in order to compute the distance map. A constant
value is subtracted from this map in order to obtain a level set in
which the *zero set* represents the initial contour. This level set is
also passed as input to the ShapeDetectionLevelSetImageFilter.

Finally, the level set at the output of the
ShapeDetectionLevelSetImageFilter is passed to an
BinaryThresholdImageFilter in order to produce a binary mask
representing the segmented object.

Let’s start by including the headers of the main filters involved in the
preprocessing.

::

    [language=C++]
    #include "itkCurvatureAnisotropicDiffusionImageFilter.h"
    #include "itkGradientMagnitudeRecursiveGaussianImageFilter.h"
    #include "itkSigmoidImageFilter.h"

The edge potential map is generated using these filters as in the
previous example.

We will need the Image class, the FastMarchingImageFilter class and the
ShapeDetectionLevelSetImageFilter class. Hence we include their headers
here.

::

    [language=C++]
    #include "itkFastMarchingImageFilter.h"
    #include "itkShapeDetectionLevelSetImageFilter.h"

The level set resulting from the ShapeDetectionLevelSetImageFilter will
be thresholded at the zero level in order to get a binary image
representing the segmented object. The BinaryThresholdImageFilter is
used for this purpose.

::

    [language=C++]
    #include "itkBinaryThresholdImageFilter.h"

We now define the image type using a particular pixel type and a
dimension. In this case the {float} type is used for the pixels due to
the requirements of the smoothing filter.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The output image, on the other hand, is declared to be binary.

::

    [language=C++]
    typedef unsigned char                            OutputPixelType;
    typedef itk::Image< OutputPixelType, Dimension > OutputImageType;

The type of the BinaryThresholdImageFilter filter is instantiated below
using the internal image type and the output image type.

::

    [language=C++]
    typedef itk::BinaryThresholdImageFilter< InternalImageType, OutputImageType >
    ThresholdingFilterType;
    ThresholdingFilterType::Pointer thresholder = ThresholdingFilterType::New();

The upper threshold of the BinaryThresholdImageFilter is set to
:math:`0.0` in order to display the zero set of the resulting level
set. The lower threshold is set to a large negative number in order to
ensure that the interior of the segmented object will appear inside the
binary region.

::

    [language=C++]
    thresholder->SetLowerThreshold( -1000.0 );
    thresholder->SetUpperThreshold(     0.0 );

    thresholder->SetOutsideValue(  0  );
    thresholder->SetInsideValue(  255 );

The CurvatureAnisotropicDiffusionImageFilter type is instantiated using
the internal image type.

::

    [language=C++]
    typedef   itk::CurvatureAnisotropicDiffusionImageFilter<
    InternalImageType,
    InternalImageType >  SmoothingFilterType;

The filter is instantiated by invoking the {New()} method and assigning
the result to a {SmartPointer}.

::

    [language=C++]
    SmoothingFilterType::Pointer smoothing = SmoothingFilterType::New();

The types of the GradientMagnitudeRecursiveGaussianImageFilter and
SigmoidImageFilter are instantiated using the internal image type.

::

    [language=C++]
    typedef   itk::GradientMagnitudeRecursiveGaussianImageFilter<
    InternalImageType,
    InternalImageType >  GradientFilterType;

    typedef   itk::SigmoidImageFilter<
    InternalImageType,
    InternalImageType >  SigmoidFilterType;

The corresponding filter objects are created with the method {New()}.

::

    [language=C++]
    GradientFilterType::Pointer  gradientMagnitude = GradientFilterType::New();
    SigmoidFilterType::Pointer sigmoid = SigmoidFilterType::New();

The minimum and maximum values of the SigmoidImageFilter output are
defined with the methods {SetOutputMinimum()} and {SetOutputMaximum()}.
In our case, we want these two values to be :math:`0.0` and
:math:`1.0` respectively in order to get a nice speed image to feed to
the FastMarchingImageFilter. Additional details on the use of the
SigmoidImageFilter are presented in
Section {sec:IntensityNonLinearMapping}.

::

    [language=C++]
    sigmoid->SetOutputMinimum(  0.0  );
    sigmoid->SetOutputMaximum(  1.0  );

We now declare the type of the FastMarchingImageFilter that will be used
to generate the initial level set in the form of a distance map.

::

    [language=C++]
    typedef  itk::FastMarchingImageFilter< InternalImageType, InternalImageType >
    FastMarchingFilterType;

Next we construct one filter of this class using the {New()} method.

::

    [language=C++]
    FastMarchingFilterType::Pointer  fastMarching = FastMarchingFilterType::New();

In the following lines we instantiate the type of the
ShapeDetectionLevelSetImageFilter and create an object of this type
using the {New()} method.

::

    [language=C++]
    typedef  itk::ShapeDetectionLevelSetImageFilter< InternalImageType,
    InternalImageType >    ShapeDetectionFilterType;
    ShapeDetectionFilterType::Pointer
    shapeDetection = ShapeDetectionFilterType::New();

The filters are now connected in a pipeline indicated in
Figure {fig:ShapeDetectionCollaborationDiagram} with the following code.

::

    [language=C++]
    smoothing->SetInput( reader->GetOutput() );
    gradientMagnitude->SetInput( smoothing->GetOutput() );
    sigmoid->SetInput( gradientMagnitude->GetOutput() );

    shapeDetection->SetInput( fastMarching->GetOutput() );
    shapeDetection->SetFeatureImage( sigmoid->GetOutput() );

    thresholder->SetInput( shapeDetection->GetOutput() );

    writer->SetInput( thresholder->GetOutput() );

The CurvatureAnisotropicDiffusionImageFilter requires a couple of
parameters to be defined. The following are typical values for
:math:`2D` images. However they may have to be adjusted depending on
the amount of noise present in the input image. This filter has been
discussed in Section {sec:GradientAnisotropicDiffusionImageFilter}.

::

    [language=C++]
    smoothing->SetTimeStep( 0.125 );
    smoothing->SetNumberOfIterations(  5 );
    smoothing->SetConductanceParameter( 9.0 );

The GradientMagnitudeRecursiveGaussianImageFilter performs the
equivalent of a convolution with a Gaussian kernel followed by a
derivative operator. The sigma of this Gaussian can be used to control
the range of influence of the image edges. This filter has been
discussed in Section {sec:GradientMagnitudeRecursiveGaussianImageFilter}

::

    [language=C++]
    gradientMagnitude->SetSigma(  sigma  );

The SigmoidImageFilter requires two parameters that define the linear
transformation to be applied to the sigmoid argument. These parameters
have been discussed in Sections {sec:IntensityNonLinearMapping} and
{sec:FastMarchingImageFilter}.

::

    [language=C++]
    sigmoid->SetAlpha( alpha );
    sigmoid->SetBeta(  beta  );

The FastMarchingImageFilter requires the user to provide a seed point
from which the level set will be generated. The user can actually pass
not only one seed point but a set of them. Note the
FastMarchingImageFilter is used here only as a helper in the
determination of an initial level set. We could have used the
{DanielssonDistanceMapImageFilter} in the same way.

The seeds are stored in a container. The type of this container is
defined as {NodeContainer} among the FastMarchingImageFilter traits.

::

    [language=C++]
    typedef FastMarchingFilterType::NodeContainer           NodeContainer;
    typedef FastMarchingFilterType::NodeType                NodeType;
    NodeContainer::Pointer seeds = NodeContainer::New();

Nodes are created as stack variables and initialized with a value and an
{Index} position. Note that we assign the negative of the value of the
user-provided distance to the unique node of the seeds passed to the
FastMarchingImageFilter. In this way, the value will increment as the
front is propagated, until it reaches the zero value corresponding to
the contour. After this, the front will continue propagating until it
fills up the entire image. The initial distance is taken from the
command line arguments. The rule of thumb for the user is to select this
value as the distance from the seed points at which the initial contour
should be.

::

    [language=C++]
    NodeType node;
    const double seedValue = - initialDistance;

    node.SetValue( seedValue );
    node.SetIndex( seedPosition );

The list of nodes is initialized and then every node is inserted using
{InsertElement()}.

::

    [language=C++]
    seeds->Initialize();
    seeds->InsertElement( 0, node );

The set of seed nodes is now passed to the FastMarchingImageFilter with
the method {SetTrialPoints()}.

::

    [language=C++]
    fastMarching->SetTrialPoints(  seeds  );

Since the FastMarchingImageFilter is used here only as a distance map
generator, it does not require a speed image as input. Instead, the
constant value :math:`1.0` is passed using the {SetSpeedConstant()}
method.

::

    [language=C++]
    fastMarching->SetSpeedConstant( 1.0 );

The FastMarchingImageFilter requires the user to specify the size of the
image to be produced as output. This is done using the
{SetOutputSize()}. Note that the size is obtained here from the output
image of the smoothing filter. The size of this image is valid only
after the {Update()} methods of this filter have been called directly or
indirectly.

::

    [language=C++]
    fastMarching->SetOutputSize(
    reader->GetOutput()->GetBufferedRegion().GetSize() );

ShapeDetectionLevelSetImageFilter provides two parameters to control the
competition between the propagation or expansion term and the curvature
smoothing term. The methods {SetPropagationScaling()} and
{SetCurvatureScaling()} defines the relative weighting between the two
terms. In this example, we will set the propagation scaling to one and
let the curvature scaling be an input argument. The larger the the
curvature scaling parameter the smoother the resulting segmentation.
However, the curvature scaling parameter should not be set too large, as
it will draw the contour away from the shape boundaries.

::

    [language=C++]
    shapeDetection->SetPropagationScaling(  propagationScaling );
    shapeDetection->SetCurvatureScaling( curvatureScaling );

Once activated, the level set evolution will stop if the convergence
criteria or the maximum number of iterations is reached. The convergence
criteria are defined in terms of the root mean squared (RMS) change in
the level set function. The evolution is said to have converged if the
RMS change is below a user-specified threshold. In a real application,
it is desirable to couple the evolution of the zero set to a
visualization module, allowing the user to follow the evolution of the
zero set. With this feedback, the user may decide when to stop the
algorithm before the zero set leaks through the regions of low gradient
in the contour of the anatomical structure to be segmented.

::

    [language=C++]
    shapeDetection->SetMaximumRMSError( 0.02 );
    shapeDetection->SetNumberOfIterations( 800 );

The invocation of the {Update()} method on the writer triggers the
execution of the pipeline. As usual, the call is placed in a {try/catch}
block should any errors occur or exceptions be thrown.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

Let’s now run this example using as input the image
{BrainProtonDensitySlice.png} provided in the directory {Examples/Data}.
We can easily segment the major anatomical structures by providing seeds
in the appropriate locations.
Table {tab:ShapeDetectionLevelSetFilterOutput} presents the parameters
used for some structures. For all of the examples illustrated in this
table, the propagation scaling was set to :math:`1.0`, and the
curvature scaling set to 0.05.

        +-------------------+----------------------+------------+--------------------+--------------------+-------------------+--------------------------------------------------------------+
        | Structure         | Seed Index           | Distance   | :math:`\sigma`   | :math:`\alpha`   | :math:`\beta`   | Output Image                                                 |
        +===================+======================+============+====================+====================+===================+==============================================================+
        | Left Ventricle    | :math:`(81,114)`   | 5.0        | 1.0                | -0.5               | 3.0               | First in Figure {fig:ShapeDetectionLevelSetFilterOutput2}    |
        +-------------------+----------------------+------------+--------------------+--------------------+-------------------+--------------------------------------------------------------+
        | Right Ventricle   | :math:`(99,114)`   | 5.0        | 1.0                | -0.5               | 3.0               | Second in Figure {fig:ShapeDetectionLevelSetFilterOutput2}   |
        +-------------------+----------------------+------------+--------------------+--------------------+-------------------+--------------------------------------------------------------+
        | White matter      | :math:`(56, 92)`   | 5.0        | 1.0                | -0.3               | 2.0               | Third in Figure {fig:ShapeDetectionLevelSetFilterOutput2}    |
        +-------------------+----------------------+------------+--------------------+--------------------+-------------------+--------------------------------------------------------------+
        | Gray matter       | :math:`(40, 90)`   | 5.0        | 0.5                | -0.3               | 2.0               | Fourth in Figure {fig:ShapeDetectionLevelSetFilterOutput2}   |
        +-------------------+----------------------+------------+--------------------+--------------------+-------------------+--------------------------------------------------------------+

    [ShapeDetection example parameters] {Parameters used for segmenting
    some brain structures shown in
    Figure {fig:ShapeDetectionLevelSetFilterOutput} using the filter
    ShapeDetectionLevelSetFilter. All of them used a propagation scaling
    of :math:`1.0` and curvature scaling of
    :math:`0.05`.{tab:ShapeDetectionLevelSetFilterOutput}}

Figure {fig:ShapeDetectionLevelSetFilterOutput} presents the
intermediate outputs of the pipeline illustrated in
Figure {fig:ShapeDetectionCollaborationDiagram}. They are from left to
right: the output of the anisotropic diffusion filter, the gradient
magnitude of the smoothed image and the sigmoid of the gradient
magnitude which is finally used as the edge potential for the
ShapeDetectionLevelSetImageFilter.

Notice that in Figure {fig:ShapeDetectionLevelSetFilterOutput2} the
segmented shapes are rounder than in
Figure {fig:FastMarchingImageFilterOutput2} due to the effects of the
curvature term in the driving equation. As with the previous example,
segmentation of the gray matter is still problematic.

    |image1| |image2| |image3| |image4|
    [ShapeDetectionLevelSetImageFilter intermediate output] {Images
    generated by the segmentation process based on the
    ShapeDetectionLevelSetImageFilter. From left to right and top to
    bottom: input image to be segmented, image smoothed with an
    edge-preserving smoothing filter, gradient magnitude of the smoothed
    image, sigmoid of the gradient magnitude. This last image, the
    sigmoid, is used to compute the speed term for the front
    propagation.} {fig:ShapeDetectionLevelSetFilterOutput}

A larger number of iterations is reguired for segmenting large
structures since it takes longer for the front to propagate and cover
the structure. This drawback can be easily mitigated by setting many
seed points in the initialization of the FastMarchingImageFilter. This
will generate an initial level set much closer in shape to the object to
be segmented and hence require fewer iterations to fill and reach the
edges of the anatomical structure.

    |image5| |image6| |image7| |image8|
    [ShapeDetectionLevelSetImageFilter segmentations] {Images generated
    by the segmentation process based on the
    ShapeDetectionLevelSetImageFilter. From left to right: segmentation
    of the left ventricle, segmentation of the right ventricle,
    segmentation of the white matter, attempt of segmentation of the
    gray matter.} {fig:ShapeDetectionLevelSetFilterOutput2}

.. |image| image:: ShapeDetectionCollaborationDiagram1.eps
.. |image1| image:: BrainProtonDensitySlice.eps
.. |image2| image:: ShapeDetectionLevelSetFilterOutput1.eps
.. |image3| image:: ShapeDetectionLevelSetFilterOutput2.eps
.. |image4| image:: ShapeDetectionLevelSetFilterOutput3.eps
.. |image5| image:: ShapeDetectionLevelSetFilterOutput5.eps
.. |image6| image:: ShapeDetectionLevelSetFilterOutput6.eps
.. |image7| image:: ShapeDetectionLevelSetFilterOutput7.eps
.. |image8| image:: ShapeDetectionLevelSetFilterOutput8.eps
