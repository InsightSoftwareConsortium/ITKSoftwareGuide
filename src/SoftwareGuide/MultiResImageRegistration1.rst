The source code for this section can be found in the file
``MultiResImageRegistration1.cxx``.

This example illustrates the use of the
{MultiResolutionImageRegistrationMethod} to solve a simple
multi-modality registration problem. In addition to the two input
images, a transform, a metric, an interpolator and an optimizer, the
multi-resolution framework also requires two image pyramids for creating
the sequence of downsampled images. To begin the example, we include the
headers of the registration components we will use.

::

    [language=C++]
    #include "itkMultiResolutionImageRegistrationMethod.h"
    #include "itkTranslationTransform.h"
    #include "itkMattesMutualInformationImageToImageMetric.h"
    #include "itkRegularStepGradientDescentOptimizer.h"
    #include "itkImage.h"

The MultiResolutionImageRegistrationMethod solves a registration problem
in a coarse to fine manner as illustrated in Figure
{fig:MultiResRegistrationConcept}. The registration is first performed
at the coarsest level using the images at the first level of the fixed
and moving image pyramids. The transform parameters determined by the
registration are then used to initialize the registration at the next
finer level using images from the second level of the pyramids. This
process is repeated as we work up to the finest level of image
resolution.

    |image| [Conceptual representation of Multi-Resolution registration]
    {Conceptual representation of the multi-resolution registration
    process.} {fig:MultiResRegistrationConcept}

In a typical registration scenario, a user will tweak component settings
or even swap out components between multi-resolution levels. For
example, when optimizing at a coarse resolution, it may be possible to
take more aggressive step sizes and have a more relaxed convergence
criterion. Another possible scheme is to use a simple translation
transform for the initial coarse registration and upgrade to an affine
transform at the finer levels.

Tweaking the components between resolution levels can be done using
ITK’s implementation of the *Command/Observer* design pattern. Before
beginning registration at each resolution level,
MultiResolutionImageRegistrationMethod invokes an IterationEvent. The
registration components can be changed by implementing a {Command} which
responds to the event. A brief description the interaction between
events and commands was previously presented in Section
{sec:MonitoringImageRegistration}.

We will illustrate this mechanism by changing the parameters of the
optimizer between each resolution level by way of a simple interface
command. First, we include the header file of the Command class.

::

    [language=C++]
    #include "itkCommand.h"

Our new interface command class is called
{RegistrationInterfaceCommand}. It derives from Command and is templated
over the multi-resolution registration type.

::

    [language=C++]
    template <typename TRegistration>
    class RegistrationInterfaceCommand : public itk::Command
    {

We then define {Self}, {Superclass}, {Pointer}, {New()} and a
constructor in a similar fashion to the {CommandIterationUpdate} class
in Section {sec:MonitoringImageRegistration}.

::

    [language=C++]
    public:
    typedef  RegistrationInterfaceCommand   Self;
    typedef  itk::Command                   Superclass;
    typedef  itk::SmartPointer<Self>        Pointer;
    itkNewMacro( Self );
    protected:
    RegistrationInterfaceCommand() {};

For convenience, we declare types useful for converting pointers in the
{Execute()} method.

::

    [language=C++]
    public:
    typedef   TRegistration                              RegistrationType;
    typedef   RegistrationType *                         RegistrationPointer;
    typedef   itk::RegularStepGradientDescentOptimizer   OptimizerType;
    typedef   OptimizerType *                            OptimizerPointer;

Two arguments are passed to the {Execute()} method: the first is the
pointer to the object which invoked the event and the second is the
event that was invoked.

::

    [language=C++]
    void Execute(itk::Object * object, const itk::EventObject & event)
    {

First we verify if that the event invoked is of the right type. If not,
we return without any further action.

::

    [language=C++]
    if( !(itk::IterationEvent().CheckEvent( &event )) )
    {
    return;
    }

We then convert the input object pointer to a RegistrationPointer. Note
that no error checking is done here to verify if the {dynamic\_cast} was
successful since we know the actual object is a multi-resolution
registration method.

::

    [language=C++]
    RegistrationPointer registration =
    dynamic_cast<RegistrationPointer>( object );

If this is the first resolution level we set the maximum step length
(representing the first step size) and the minimum step length
(representing the convergence criterion) to large values. At each
subsequent resolution level, we will reduce the minimum step length by a
factor of 10 in order to allow the optimizer to focus on progressively
smaller regions. The maximum step length is set up to the current step
length. In this way, when the optimizer is reinitialized at the
beginning of the registration process for the next level, the step
length will simply start with the last value used for the previous
level. This will guarantee the continuity of the path taken by the
optimizer through the parameter space.

::

    [language=C++]
    OptimizerPointer optimizer = dynamic_cast< OptimizerPointer >(
    registration->GetOptimizer() );

    std::cout << "-------------------------------------" << std::endl;
    std::cout << "MultiResolution Level : "
    << registration->GetCurrentLevel()  << std::endl;
    std::cout << std::endl;

    if ( registration->GetCurrentLevel() == 0 )
    {
    optimizer->SetMaximumStepLength( 16.00 );
    optimizer->SetMinimumStepLength( 0.01 );
    }
    else
    {
    optimizer->SetMaximumStepLength( optimizer->GetMaximumStepLength() / 4.0 );
    optimizer->SetMinimumStepLength( optimizer->GetMinimumStepLength() / 10.0 );
    }
    }

Another version of the {Execute()} method accepting a {const} input
object is also required since this method is defined as pure virtual in
the base class. This version simply returns without taking any action.

::

    [language=C++]
    void Execute(const itk::Object * , const itk::EventObject & )
    { return; }
    };

The fixed and moving image types are defined as in previous examples.
Due to the recursive nature of the process by which the downsampled
images are computed by the image pyramids, the output images are
required to have real pixel types. We declare this internal image type
to be {InternalPixelType}:

::

    [language=C++]
    typedef   float                                    InternalPixelType;
    typedef itk::Image< InternalPixelType, Dimension > InternalImageType;

The types for the registration components are then derived using the
internal image type.

::

    [language=C++]
    typedef itk::TranslationTransform< double, Dimension > TransformType;
    typedef itk::RegularStepGradientDescentOptimizer       OptimizerType;
    typedef itk::LinearInterpolateImageFunction<
    InternalImageType,
    double             > InterpolatorType;
    typedef itk::MattesMutualInformationImageToImageMetric<
    InternalImageType,
    InternalImageType >   MetricType;
    typedef itk::MultiResolutionImageRegistrationMethod<
    InternalImageType,
    InternalImageType >   RegistrationType;

In the multi-resolution framework, a {MultiResolutionPyramidImageFilter}
is used to create a pyramid of downsampled images. The size of each
downsampled image is specified by the user in the form of a schedule of
shrink factors. A description of the filter and the format of the
schedules are found in Section {sec:ImagePyramids}. For this example, we
will simply use the default schedules.

::

    [language=C++]
    typedef itk::MultiResolutionPyramidImageFilter<
    InternalImageType,
    InternalImageType >   FixedImagePyramidType;
    typedef itk::MultiResolutionPyramidImageFilter<
    InternalImageType,
    InternalImageType >   MovingImagePyramidType;

The fixed and moving images are read from a file. Before connecting
these images to the registration we need to cast them to the internal
image type using {CastImageFilters}.

::

    [language=C++]
    typedef itk::CastImageFilter<
    FixedImageType, InternalImageType > FixedCastFilterType;
    typedef itk::CastImageFilter<
    MovingImageType, InternalImageType > MovingCastFilterType;

    FixedCastFilterType::Pointer fixedCaster   = FixedCastFilterType::New();
    MovingCastFilterType::Pointer movingCaster = MovingCastFilterType::New();

The output of the readers is connected as input to the cast filters. The
inputs to the registration method are taken from the cast filters.

::

    [language=C++]
    fixedCaster->SetInput(  fixedImageReader->GetOutput() );
    movingCaster->SetInput( movingImageReader->GetOutput() );

    registration->SetFixedImage(    fixedCaster->GetOutput()    );
    registration->SetMovingImage(   movingCaster->GetOutput()   );

Given that the Mattes Mutual Information metric uses a random iterator
in order to collect the samples from the images, it is usually
convenient to initialize the seed of the random number generator.

::

    [language=C++]
    metric->ReinitializeSeed( 76926294 );

Once all the registration components are in place we can create an
instance of our interface command and connect it to the registration
object using the {AddObserver()} method.

::

    [language=C++]
    typedef RegistrationInterfaceCommand<RegistrationType> CommandType;
    CommandType::Pointer command = CommandType::New();
    registration->AddObserver( itk::IterationEvent(), command );

We set the number of multi-resolution levels to three and trigger the
registration process by calling {StartRegistration()}.

::

    [language=C++]
    registration->SetNumberOfLevels( 3 );

    try
    {
    registration->StartRegistration();
    std::cout << "Optimizer stop condition: "
    << registration->GetOptimizer()->GetStopConditionDescription()
    << std::endl;
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return EXIT_FAILURE;
    }

Let’s execute this example using the following images

-  BrainT1SliceBorder20.png

-  BrainProtonDensitySliceShifted13x17y.png

The output produced by the execution of the method is

::

    0   -0.419408   [11.0796, 11.5431]
    1   -0.775143   [18.0515, 25.9442]
    2   -0.621443   [15.2813, 18.4392]
    3   -1.00688    [7.81465, 15.567]
    4   -0.733843   [11.7844, 16.0582]
    5   -1.17593    [15.2929, 17.9792]

    0   -0.902265   [13.4257, 17.2627]
    1   -1.21519    [11.6959, 16.2588]
    2   -1.04207    [12.6029, 16.68]
    3   -1.21741    [13.4286, 17.2439]
    4   -1.21605    [12.9899, 17.0041]
    5   -1.26825    [13.163,  16.8237]

    0   -1.25692    [13.0716, 16.909]
    1   -1.29465    [12.9896, 17.0033]
    2   -1.30922    [13.0513, 16.9934]
    3   -1.30722    [13.0205, 16.9987]
    4   -1.30978    [12.9897, 17.0039]

    Result =
    Translation X = 12.9897
    Translation Y = 17.0039
    Iterations    = 6
    Metric value  = -1.30921

These values are a close match to the true misalignment of
:math:`(13,17)` introduced in the moving image.

    |image1| |image2| |image3| [Multi-Resolution registration input
    images] {Mapped moving image (left) and composition of fixed and
    moving images before (center) and after (right) registration.}
    {fig:MultiResImageRegistration1Output}

The result of resampling the moving image is presented in the left image
of Figure {fig:MultiResImageRegistration1Output}. The center and right
images of the figure depict a checkerboard composite of the fixed and
moving images before and after registration.

    |image4| |image5| [Multi-Resolution registration output images]
    {Sequence of translations and metric values at each iteration of the
    optimizer.} {fig:MultiResImageRegistration1Trace}

Figure {fig:MultiResImageRegistration1Trace} (left) shows the sequence
of translations followed by the optimizer as it searched the parameter
space. The right side of the same figure shows the sequence of metric
values computed as the optimizer searched the parameter space. From the
trace, we can see that with the more aggressive optimization parameters
we get quite close to the optimal value within 4 iterations with the
remaining iterations just doing fine adjustments. It is interesting to
compare these results with the ones of the single resolution example in
Section {sec:MultiModalityRegistrationMattes}, where 24 iterations were
required as more conservative optimization parameters had to be used.

.. |image| image:: MultiResRegistrationConcept.eps
.. |image1| image:: MultiResImageRegistration1Output.eps
.. |image2| image:: MultiResImageRegistration1CheckerboardBefore.eps
.. |image3| image:: MultiResImageRegistration1CheckerboardAfter.eps
.. |image4| image:: MultiResImageRegistration1TraceTranslations.eps
.. |image5| image:: MultiResImageRegistration1TraceMetric.eps
