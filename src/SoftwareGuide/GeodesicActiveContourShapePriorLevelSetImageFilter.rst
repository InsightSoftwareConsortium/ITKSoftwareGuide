The source code for this section can be found in the file
``GeodesicActiveContourShapePriorLevelSetImageFilter.cxx``.

In medical imaging applications, the general shape, location and
orientation of an anatomical structure of interest is typically known *a
priori*. This information can be used to aid the segmentation process
especially when image contrast is low or when the object boundary is not
distinct.

In , Leventon *et al.* extended the geodesic active contours method with
an additional shape-influenced term in the driving PDE. The
{GeodesicActiveContourShapePriorLevelSetFilter} is a generalization of
Leventon’s approach and its use is illustrated in the following example.

To support shape-guidance, the generic level set equation
(Eqn( {eqn:LevelSetEquation})) is extended to incorporate a shape
guidance term:

:math:`\label{eqn:ShapeInfluenceTerm}
\xi \left(\psi^{*}(\mathbf{x}) - \psi(\mathbf{x})\right)
`

where :math:`\psi^{*}` is the signed distance function of the
“best-fit” shape with respect to a shape model. The new term has the
effect of driving the contour towards the best-fit shape. The scalar
:math:`\xi` weights the influence of the shape term in the overall
evolution. In general, the best-fit shape is not known ahead of time and
has to be iteratively estimated in conjunction with the contour
evolution.

As with the {GeodesicActiveContourLevelSetImageFilter}, the
GeodesicActiveContourShapePriorLevelSetImageFilter expects two input
images: the first is an initial level set and the second a feature image
that represents the image edge potential. The configuration of this
example is quite similar to the example in
Section {sec:GeodesicActiveContourImageFilter} and hence the description
will focus on the new objects involved in the segmentation process as
shown in
Figure {fig:GeodesicActiveContourShapePriorCollaborationDiagram}.

    |image| [GeodesicActiveContourShapePriorLevelSetImageFilter
    collaboration diagram] {Collaboration diagram for the
    GeodesicActiveContourShapePriorLevelSetImageFilter applied to a
    segmentation task.}
    {fig:GeodesicActiveContourShapePriorCollaborationDiagram}

The process pipeline begins with centering the input image using the the
{ChangeInformationImageFilter} to simplify the estimation of the pose of
the shape, to be explained later. The centered image is then smoothed
using non-linear diffusion to remove noise and the gradient magnitude is
computed from the smoothed image. For simplicity, this example uses the
{BoundedReciprocalImageFilter} to produce the edge potential image.

The {FastMarchingImageFilter} creates an initial level set using three
user specified seed positions and a initial contour radius. Three seeds
are used in this example to facilitate the segmentation of long narrow
objects in a smaller number of iterations. The output of the
FastMarchingImageFilter is passed as the input to the
GeodesicActiveContourShapePriorLevelSetImageFilter. At then end of the
segmentation process, the output level set is passed to the
{BinaryThresholdImageFilter} to produce a binary mask representing the
segmented object.

The remaining objects in
Figure {fig:GeodesicActiveContourShapePriorCollaborationDiagram} are
used for shape modeling and estimation. The
{PCAShapeSignedDistanceFunction} represents a statistical shape model
defined by a mean signed distance and the first :math:`K` principal
components modes; while the {Euler2DTransform} is used to represent the
pose of the shape. In this implementation, the best-fit shape estimation
problem is reformulated as a minimization problem where the
{ShapePriorMAPCostFunction} is the cost function to be optimized using
the {OnePlusOneEvolutionaryOptimizer}.

It should be noted that, although particular shape model, transform cost
function, and optimizer are used in this example, the implementation is
generic, allowing different instances of these components to be plugged
in. This flexibility allows a user to tailor the behavior of the
segmentation process to suit the circumstances of the targeted
application.

Let’s start the example by including the headers of the new filters
involved in the segmentation.

::

    [language=C++]
    #include "itkGeodesicActiveContourShapePriorLevelSetImageFilter.h"
    #include "itkChangeInformationImageFilter.h"
    #include "itkBoundedReciprocalImageFilter.h"

Next, we include the headers of the objects involved in shape modeling
and estimation.

::

    [language=C++]
    #include "itkPCAShapeSignedDistanceFunction.h"
    #include "itkEuler2DTransform.h"
    #include "itkOnePlusOneEvolutionaryOptimizer.h"
    #include "itkNormalVariateGenerator.h"
    #include "vnl/vnl_sample.h"
    #include "itkNumericSeriesFileNames.h"

Given the numerous parameters involved in tuning this segmentation
method it is not uncommon for a segmentation process to run for several
minutes and still produce an unsatisfactory result. For debugging
purposes it is quite helpful to track the evolution of the segmentation
as it progresses. The following defines a custom {Command} class for
monitoring the RMS change and shape parameters at each iteration.

::

    [language=C++]
    #include "itkCommand.h"

    template<class TFilter>
    class CommandIterationUpdate : public itk::Command
    {
    public:
    typedef CommandIterationUpdate   Self;
    typedef itk::Command             Superclass;
    typedef itk::SmartPointer<Self>  Pointer;
    itkNewMacro( Self );
    protected:
    CommandIterationUpdate() {};
    public:

    void Execute(itk::Object *caller, const itk::EventObject & event)
    {
    Execute( (const itk::Object *) caller, event);
    }

    void Execute(const itk::Object * object, const itk::EventObject & event)
    {
    const TFilter * filter =
    dynamic_cast< const TFilter * >( object );
    if( typeid( event ) != typeid( itk::IterationEvent ) )
    { return; }

    std::cout << filter->GetElapsedIterations() << ": ";
    std::cout << filter->GetRMSChange() << " ";
    std::cout << filter->GetCurrentParameters() << std::endl;
    }

    };

We define the image type using a particular pixel type and dimension. In
this case we will use 2D {float} images.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The following line instantiate a
{GeodesicActiveContourShapePriorLevelSetImageFilter} using the {New()}
method.

::

    [language=C++]
    typedef  itk::GeodesicActiveContourShapePriorLevelSetImageFilter<
    InternalImageType,
    InternalImageType >   GeodesicActiveContourFilterType;
    GeodesicActiveContourFilterType::Pointer geodesicActiveContour =
    GeodesicActiveContourFilterType::New();

The {ChangeInformationImageFilter} is the first filter in the
preprocessing stage and is used to force the image origin to the center
of the image.

::

    [language=C++]
    typedef itk::ChangeInformationImageFilter<
    InternalImageType >  CenterFilterType;

    CenterFilterType::Pointer center = CenterFilterType::New();
    center->CenterImageOn();

In this example, we will use the bounded reciprocal :math:`1/(1+x)` of
the image gradient magnitude as the edge potential feature image.

::

    [language=C++]
    typedef   itk::BoundedReciprocalImageFilter<
    InternalImageType,
    InternalImageType >  ReciprocalFilterType;

    ReciprocalFilterType::Pointer reciprocal = ReciprocalFilterType::New();

In the GeodesicActiveContourShapePriorLevelSetImageFilter, scaling
parameters are used to trade off between the propagation (inflation),
the curvature (smoothing), the advection, and the shape influence terms.
These parameters are set using methods {SetPropagationScaling()},
{SetCurvatureScaling()}, {SetAdvectionScaling()} and
{SetShapePriorScaling()}. In this example, we will set the curvature and
advection scales to one and let the propagation and shape prior scale be
command-line arguments.

::

    [language=C++]
    geodesicActiveContour->SetPropagationScaling( propagationScaling );
    geodesicActiveContour->SetShapePriorScaling( shapePriorScaling );
    geodesicActiveContour->SetCurvatureScaling( 1.0 );
    geodesicActiveContour->SetAdvectionScaling( 1.0 );

Each iteration, the current “best-fit” shape is estimated from the edge
potential image and the current contour. To increase speed, only
information within the sparse field layers of the current contour is
used in the estimation. The default number of sparse field layers is the
same as the ImageDimension which does not contain enough information to
get a reliable best-fit shape estimate. Thus, we override the default
and set the number of layers to 4.

::

    [language=C++]
    geodesicActiveContour->SetNumberOfLayers( 4 );

The filters are then connected in a pipeline as illustrated in
Figure {fig:GeodesicActiveContourShapePriorCollaborationDiagram}.

::

    [language=C++]
    center->SetInput( reader->GetOutput() );
    smoothing->SetInput( center->GetOutput() );
    gradientMagnitude->SetInput( smoothing->GetOutput() );
    reciprocal->SetInput( gradientMagnitude->GetOutput() );

    geodesicActiveContour->SetInput(  fastMarching->GetOutput() );
    geodesicActiveContour->SetFeatureImage( reciprocal->GetOutput() );

    thresholder->SetInput( geodesicActiveContour->GetOutput() );
    writer->SetInput( thresholder->GetOutput() );

Next, we define the shape model. In this example, we use an implicit
shape model based on the principal components such that:

:math:`\psi^{*}(\mathbf{x}) = \mu(\mathbf{x}) + \sum_k \alpha_k u_k(\mathbf{x})
`

where :math:`\mu(\mathbf{x})` is the mean signed distance computed
from training set of segmented objects and :math:`u_k(\mathbf{x})` are
the first :math:`K` principal components of the offset (signed
distance - mean). The coefficients :math:`\{\alpha_k\}` form the set
of *shape* parameters.

Given a set of training data, the {ImagePCAShapeModelEstimator} can be
used to obtain the mean and principal mode shape images required by
PCAShapeSignedDistanceFunction.

::

    [language=C++]
    typedef itk::PCAShapeSignedDistanceFunction<
    double,
    Dimension,
    InternalImageType >     ShapeFunctionType;

    ShapeFunctionType::Pointer shape = ShapeFunctionType::New();

    shape->SetNumberOfPrincipalComponents( numberOfPCAModes );

In this example, we will read the mean shape and principal mode images
from file. We will assume that the filenames of the mode images form a
numeric series starting from index 0.

::

    [language=C++]
    ReaderType::Pointer meanShapeReader = ReaderType::New();
    meanShapeReader->SetFileName( argv[13] );
    meanShapeReader->Update();

    std::vector<InternalImageType::Pointer> shapeModeImages( numberOfPCAModes );

    itk::NumericSeriesFileNames::Pointer fileNamesCreator =
    itk::NumericSeriesFileNames::New();

    fileNamesCreator->SetStartIndex( 0 );
    fileNamesCreator->SetEndIndex( numberOfPCAModes - 1 );
    fileNamesCreator->SetSeriesFormat( argv[15] );
    const std::vector<std::string> & shapeModeFileNames =
    fileNamesCreator->GetFileNames();

    for ( unsigned int k = 0; k < numberOfPCAModes; k++ )
    {
    ReaderType::Pointer shapeModeReader = ReaderType::New();
    shapeModeReader->SetFileName( shapeModeFileNames[k].c_str() );
    shapeModeReader->Update();
    shapeModeImages[k] = shapeModeReader->GetOutput();
    }

    shape->SetMeanImage( meanShapeReader->GetOutput() );
    shape->SetPrincipalComponentImages( shapeModeImages );

Further we assume that the shape modes have been normalized by
multiplying with the corresponding singular value. Hence, we can set the
principal component standard deviations to all ones.

::

    [language=C++]
    ShapeFunctionType::ParametersType pcaStandardDeviations( numberOfPCAModes );
    pcaStandardDeviations.Fill( 1.0 );

    shape->SetPrincipalComponentStandardDeviations( pcaStandardDeviations );

Next, we instantiate a {Euler2DTransform} and connect it to the
PCASignedDistanceFunction. The transform represent the pose of the
shape. The parameters of the transform forms the set of *pose*
parameters.

::

    [language=C++]
    typedef itk::Euler2DTransform<double>    TransformType;
    TransformType::Pointer transform = TransformType::New();

    shape->SetTransform( transform );

Before updating the level set at each iteration, the parameters of the
current best-fit shape is estimated by minimizing the
{ShapePriorMAPCostFunction}. The cost function is composed of four
terms: contour fit, image fit, shape prior and pose prior. The user can
specify the weights applied to each term.

::

    [language=C++]
    typedef itk::ShapePriorMAPCostFunction<
    InternalImageType,
    InternalPixelType >     CostFunctionType;

    CostFunctionType::Pointer costFunction = CostFunctionType::New();

    CostFunctionType::WeightsType weights;
    weights[0] =  1.0;   weight for contour fit term
    weights[1] =  20.0;  weight for image fit term
    weights[2] =  1.0;   weight for shape prior term
    weights[3] =  1.0;   weight for pose prior term

    costFunction->SetWeights( weights );

Contour fit measures the likelihood of seeing the current evolving
contour for a given set of shape/pose parameters. This is computed by
counting the number of pixels inside the current contour but outside the
current shape.

Image fit measures the likelihood of seeing certain image features for a
given set of shape/pose parameters. This is computed by assuming that (
1 - edge potential ) approximates a zero-mean, unit variance Gaussian
along the normal of the evolving contour. Image fit is then computed by
computing the Laplacian goodness of fit of the Gaussian:

:math:`\sum \left( G(\psi(\mathbf{x})) - |1 - g(\mathbf{x})| \right)^2
`

where :math:`G` is a zero-mean, unit variance Gaussian and :math:`g`
is the edge potential feature image.

The pose parameters are assumed to have a uniform distribution and hence
do not contribute to the cost function. The shape parameters are assumed
to have a Gaussian distribution. The parameters of the distribution are
user-specified. Since we assumed the principal modes have already been
normalized, we set the distribution to zero mean and unit variance.

::

    [language=C++]
    CostFunctionType::ArrayType mean(   shape->GetNumberOfShapeParameters() );
    CostFunctionType::ArrayType stddev( shape->GetNumberOfShapeParameters() );

    mean.Fill( 0.0 );
    stddev.Fill( 1.0 );
    costFunction->SetShapeParameterMeans( mean );
    costFunction->SetShapeParameterStandardDeviations( stddev );

In this example, we will use the {OnePlusOneEvolutionaryOptimizer} to
optimize the cost function.

::

    [language=C++]
    typedef itk::OnePlusOneEvolutionaryOptimizer    OptimizerType;
    OptimizerType::Pointer optimizer = OptimizerType::New();

The evolutionary optimization algorithm is based on testing random
permutations of the parameters. As such, we need to provide the
optimizer with a random number generator. In the following lines, we
create a {NormalVariateGenerator}, seed it, and connect it to the
optimizer.

::

    [language=C++]
    typedef itk::Statistics::NormalVariateGenerator GeneratorType;
    GeneratorType::Pointer generator = GeneratorType::New();

    generator->Initialize( 20020702 );

    optimizer->SetNormalVariateGenerator( generator );

The cost function has :math:`K+3` parameters. The first :math:`K`
parameters are the principal component multipliers, followed by the 2D
rotation parameter (in radians) and the x- and y- translation parameters
(in mm). We need to carefully scale the different types of parameters to
compensate for the differences in the dynamic ranges of the parameters.

::

    [language=C++]
    OptimizerType::ScalesType scales( shape->GetNumberOfParameters() );
    scales.Fill( 1.0 );
    for( unsigned int k = 0; k < numberOfPCAModes; k++ )
    {
    scales[k] = 20.0;   scales for the pca mode multiplier
    }
    scales[numberOfPCAModes] = 350.0;   scale for 2D rotation
    optimizer->SetScales( scales );

Next, we specify the initial radius, the shrink and grow mutation
factors and termination criteria of the optimizer. Since the best-fit
shape is re-estimated each iteration of the curve evolution, we do not
need to spend too much time finding the true minimizing solution each
time; we only need to head towards it. As such, we only require a small
number of optimizer iterations.

::

    [language=C++]
    double initRadius = 1.05;
    double grow = 1.1;
    double shrink = pow(grow, -0.25);
    optimizer->Initialize(initRadius, grow, shrink);

    optimizer->SetEpsilon(1.0e-6);  minimal search radius

    optimizer->SetMaximumIteration(15);

Before starting the segmentation process we need to also supply the
initial best-fit shape estimate. In this example, we start with the
unrotated mean shape with the initial x- and y- translation specified
through command-line arguments.

::

    [language=C++]
    ShapeFunctionType::ParametersType parameters( shape->GetNumberOfParameters() );
    parameters.Fill( 0.0 );
    parameters[numberOfPCAModes + 1] = atof( argv[16] );  startX
    parameters[numberOfPCAModes + 2] = atof( argv[17] );  startY

Finally, we connect all the components to the filter and add our
observer.

::

    [language=C++]
    geodesicActiveContour->SetShapeFunction( shape );
    geodesicActiveContour->SetCostFunction( costFunction );
    geodesicActiveContour->SetOptimizer( optimizer );
    geodesicActiveContour->SetInitialParameters( parameters );

    typedef CommandIterationUpdate<GeodesicActiveContourFilterType> CommandType;
    CommandType::Pointer observer = CommandType::New();
    geodesicActiveContour->AddObserver( itk::IterationEvent(), observer );

The invocation of the {Update()} method on the writer triggers the
execution of the pipeline. As usual, the call is placed in a {try/catch}
block to handle exceptions should errors occur.

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

Deviating from previous examples, we will demonstrate this example using
{BrainMidSagittalSlice.png}
(Figure {fig:GeodesicActiveContourShapePriorImageFilterOutput}, left)
from the {Examples/Data} directory. The aim here is to segment the
corpus callosum from the image using a shape model defined by
{CorpusCallosumMeanShape.mha} and the first three principal components
{CorpusCallosumMode0.mha}, {CorpusCallosumMode1.mha} and
{CorpusCallosumMode12.mha}. As shown in
Figure {fig:CorpusCallosumPCAModes}, the first mode captures scaling,
the second mode captures the shifting of mass between the rostrum and
the splenium and the third mode captures the degree of curvature.
Segmentation results with and without shape guidance are shown in
Figure {fig:GeodesicActiveContourShapePriorImageFilterOutput2}.

    |image1| |image2| [GeodesicActiveContourShapePriorImageFilter input
    image and initial model] { The input image to the
    GeodesicActiveContourShapePriorLevelSetImageFilter is a synthesized
    MR-T1 mid-sagittal slice (:math:`217 \times 180` pixels,
    :math:`1 \times 1` mm spacing) of the brain (left) and the initial
    best-fit shape (right) chosen to roughly overlap the corpus callosum
    in the image to be segmented.}

    {fig:GeodesicActiveContourShapePriorImageFilterOutput}

    +-----------+----------------------+-------------+----------------------+
    |           | :math:`-3\sigma`   | mean        | :math:`+3\sigma`   |
    +-----------+----------------------+-------------+----------------------+
    | mode 0:   | |image12|            | |image13|   | |image14|            |
    +-----------+----------------------+-------------+----------------------+
    | mode 1:   | |image15|            | |image16|   | |image17|            |
    +-----------+----------------------+-------------+----------------------+
    | mode 2:   | |image18|            | |image19|   | |image20|            |
    +-----------+----------------------+-------------+----------------------+

    [Corpus callosum PCA modes] {First three PCA modes of a
    low-resolution (:math:`58 \times 31` pixels, :math:`2 \times 2`
    mm spacing) corpus callosum model used in the shape guided geodesic
    active contours example.}

    {fig:CorpusCallosumPCAModes}

A sigma value of :math:`1.0` was used to compute the image gradient
and the propagation and shape prior scaling are respectively set to
:math:`0.5` and :math:`0.02`. An initial level set was created by
placing one seed point in the rostrum :math:`(60,102)`, one in the
splenium :math:`(120, 85)` and one centrally in the body
:math:`(88,83)` of the corpus callosum with an initial radius of
:math:`6` pixels at each seed position. The best-fit shape was
initially placed with a translation of :math:`(10,0)`mm so that it
roughly overlapped the corpus callosum in the image as shown in
Figure {fig:GeodesicActiveContourShapePriorImageFilterOutput} (right).

From Figure {fig:GeodesicActiveContourShapePriorImageFilterOutput2} it
can be observed that without shape guidance (left), segmentation using
geodesic active contour leaks in the regions where the corpus callosum
blends into the surrounding brain tissues. With shape guidance (center),
the segmentation is constrained by the global shape model to prevent
leaking.

The final best-fit shape parameters after the segmentation process is:

::

    Parameters: [-0.384988, -0.578738, 0.557793, 0.275202, 16.9992, 4.73473]

and is shown in
Figure {fig:GeodesicActiveContourShapePriorImageFilterOutput2} (right).
Note that a :math:`0.28` radian (:math:`15.8` degree) rotation has
been introduced to match the model to the corpus callosum in the image.
Additionally, a negative weight for the first mode shrinks the size
relative to the mean shape. A negative weight for the second mode shifts
the mass to splenium, and a positive weight for the third mode increases
the curvature. It can also be observed that the final segmentation is a
combination of the best-fit shape with additional local deformation. The
combination of both global and local shape allows the segmentation to
capture fine details not represented in the shape model.

    |image21| |image22| |image23|
    [GeodesicActiveContourShapePriorImageFilter segmentations] {Corpus
    callosum segmentation using geodesic active contours without (left)
    and with (center) shape guidance. The image on the right represents
    the best-fit shape at the end of the segmentation process.}

    {fig:GeodesicActiveContourShapePriorImageFilterOutput2}

.. |image| image:: GeodesicActiveContourShapePriorCollaborationDiagram.eps
.. |image1| image:: BrainMidSagittalSlice.eps
.. |image2| image:: GeodesicActiveContourShapePriorImageFilterOutput5.eps
.. |image3| image:: CorpusCallosumModeMinus0.eps
.. |image4| image:: CorpusCallosumMeanShape.eps
.. |image5| image:: CorpusCallosumModePlus0.eps
.. |image6| image:: CorpusCallosumModeMinus1.eps
.. |image7| image:: CorpusCallosumMeanShape.eps
.. |image8| image:: CorpusCallosumModePlus1.eps
.. |image9| image:: CorpusCallosumModeMinus2.eps
.. |image10| image:: CorpusCallosumMeanShape.eps
.. |image11| image:: CorpusCallosumModePlus2.eps
.. |image12| image:: CorpusCallosumModeMinus0.eps
.. |image13| image:: CorpusCallosumMeanShape.eps
.. |image14| image:: CorpusCallosumModePlus0.eps
.. |image15| image:: CorpusCallosumModeMinus1.eps
.. |image16| image:: CorpusCallosumMeanShape.eps
.. |image17| image:: CorpusCallosumModePlus1.eps
.. |image18| image:: CorpusCallosumModeMinus2.eps
.. |image19| image:: CorpusCallosumMeanShape.eps
.. |image20| image:: CorpusCallosumModePlus2.eps
.. |image21| image:: GeodesicActiveContourShapePriorImageFilterOutput1.eps
.. |image22| image:: GeodesicActiveContourShapePriorImageFilterOutput2.eps
.. |image23| image:: GeodesicActiveContourShapePriorImageFilterOutput6.eps
