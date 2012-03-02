The source code for this section can be found in the file
``ModelToImageRegistration1.cxx``.

This example illustrates the use of the {SpatialObject} as a component
of the registration framework in order to perform model based
registration. The current example creates a geometrical model composed
of several ellipses. Then, it uses the model to produce a synthetic
binary image of the ellipses. Next, it introduces perturbations on the
position and shape of the model, and finally it uses the perturbed
version as the input to a registration problem. A metric is defined to
evaluate the fitness between the geometric model and the image.

Let’s look first at the classes required to support SpatialObject. In
this example we use the {EllipseSpatialObject} as the basic shape
components and we use the {GroupSpatialObject} to group them together as
a representation of a more complex shape. Their respective headers are
included below.

::

    [language=C++]
    #include "itkEllipseSpatialObject.h"
    #include "itkGroupSpatialObject.h"

In order to generate the initial synthetic image of the ellipses, we use
the {SpatialObjectToImageFilter} that tests—for every pixel in the
image—whether the pixel (and hence the spatial object) is *inside* or
*outside* the geometric model.

::

    [language=C++]
    #include "itkSpatialObjectToImageFilter.h"

A metric is defined to evaluate the fitness between the SpatialObject
and the Image. The base class for this type of metric is the
{ImageToSpatialObjectMetric}, whose header is included below.

::

    [language=C++]

As in previous registration problems, we have to evaluate the image
intensity in non-grid positions. The {LinearInterpolateImageFunction} is
used here for this purpose.

::

    [language=C++]
    #include "itkLinearInterpolateImageFunction.h"

The SpatialObject is mapped from its own space into the image space by
using a {Transform}. In this example, we use the {Euler2DTransform}.

::

    [language=C++]
    #include "itkEuler2DTransform.h"

Registration is fundamentally an optimization problem. Here we include
the optimizer used to search the parameter space and identify the best
transformation that will map the shape model on top of the image. The
optimizer used in this example is the {OnePlusOneEvolutionaryOptimizer}
that implements an `evolutionary
algorithm <http:www.aic.nrl.navy.mil/galist/>`_.

::

    [language=C++]
    #include "itkOnePlusOneEvolutionaryOptimizer.h"

As in previous registration examples, it is important to track the
evolution of the optimizer as it progresses through the parameter space.
This is done by using the Command/Observer paradigm. The following lines
of code implement the {Command} observer that monitors the progress of
the registration. The code is quite similar to what we have used in
previous registration examples.

::

    [language=C++]
    #include "itkCommand.h"
    template < class TOptimizer >
    class IterationCallback : public itk::Command
    {
    public:
    typedef IterationCallback             Self;
    typedef itk::Command                  Superclass;
    typedef itk::SmartPointer<Self>       Pointer;
    typedef itk::SmartPointer<const Self> ConstPointer;

    itkTypeMacro( IterationCallback, Superclass );
    itkNewMacro( Self );

    /** Type defining the optimizer. */
    typedef    TOptimizer     OptimizerType;

    /** Method to specify the optimizer. */
    void SetOptimizer( OptimizerType * optimizer )
    {
    m_Optimizer = optimizer;
    m_Optimizer->AddObserver( itk::IterationEvent(), this );
    }

    /** Execute method will print data at each iteration */
    void Execute(itk::Object *caller, const itk::EventObject & event)
    {
    Execute( (const itk::Object *)caller, event);
    }

    void Execute(const itk::Object *, const itk::EventObject & event)
    {
    if( typeid( event ) == typeid( itk::StartEvent ) )
    {
    std::cout << std::endl << "Position              Value";
    std::cout << std::endl << std::endl;
    }
    else if( typeid( event ) == typeid( itk::IterationEvent ) )
    {
    std::cout << m_Optimizer->GetCurrentIteration() << "   ";
    std::cout << m_Optimizer->GetValue() << "   ";
    std::cout << m_Optimizer->GetCurrentPosition() << std::endl;
    }
    else if( typeid( event ) == typeid( itk::EndEvent ) )
    {
    std::cout << std::endl << std::endl;
    std::cout << "After " << m_Optimizer->GetCurrentIteration();
    std::cout << "  iterations " << std::endl;
    std::cout << "Solution is    = " << m_Optimizer->GetCurrentPosition();
    std::cout << std::endl;
    }
    }

This command will be invoked at every iteration of the optimizer and
will print out the current combination of transform parameters.

Consider now the most critical component of this new registration
approach: the metric. This component evaluates the match between the
SpatialObject and the Image. The smoothness and regularity of the metric
determine the difficulty of the task assigned to the optimizer. In this
case, we use a very robust optimizer that should be able to find its way
even in the most discontinuous cost functions. The metric to be
implemented should derive from the ImageToSpatialObjectMetric class.

The following code implements a simple metric that computes the sum of
the pixels that are inside the spatial object. In fact, the metric
maximum is obtained when the model and the image are aligned. The metric
is templated over the type of the SpatialObject and the type of the
Image.

::

    [language=C++]
    template <typename TFixedImage, typename TMovingSpatialObject>
    class SimpleImageToSpatialObjectMetric :
    public itk::ImageToSpatialObjectMetric<TFixedImage,TMovingSpatialObject>
    {

The fundamental operation of the metric is its {GetValue()} method. It
is in this method that the fitness value is computed. In our current
example, the fitness is computed over the points of the SpatialObject.
For each point, its coordinates are mapped through the transform into
image space. The resulting point is used to evaluate the image and the
resulting value is accumulated in a sum. Since we are not allowing scale
changes, the optimal value of the sum will result when all the
SpatialObject points are mapped on the white regions of the image. Note
that the argument for the {GetValue()} method is the array of parameters
of the transform.

::

    [language=C++]
    MeasureType    GetValue( const ParametersType & parameters ) const
    {
    double value;
    this->m_Transform->SetParameters( parameters );

    PointListType::const_iterator it = m_PointList.begin();

    value = 0;
    while( it != m_PointList.end() )
    {
    PointType transformedPoint = this->m_Transform->TransformPoint(*it);
    if( this->m_Interpolator->IsInsideBuffer( transformedPoint ) )
    {
    value += this->m_Interpolator->Evaluate( transformedPoint );
    }
    it++;
    }
    return value;
    }

Having defined all the registration components we are ready to put the
pieces together and implement the registration process.

First we instantiate the GroupSpatialObject and EllipseSpatialObject.
These two objects are parameterized by the dimension of the space. In
our current example a :math:`2D` instantiation is created.

::

    [language=C++]
    typedef itk::GroupSpatialObject< 2 >     GroupType;
    typedef itk::EllipseSpatialObject< 2 >   EllipseType;

The image is instantiated in the following lines using the pixel type
and the space dimension. This image uses a {float} pixel type since we
plan to blur it in order to increase the capture radius of the
optimizer. Images of real pixel type behave better under blurring than
those of integer pixel type.

::

    [language=C++]
    typedef itk::Image< float, 2 >      ImageType;

Here is where the fun begins! In the following lines we create the
EllipseSpatialObjects using their {New()} methods, and assigning the
results to SmartPointers. These lines will create three ellipses.

::

    [language=C++]
    EllipseType::Pointer ellipse1 = EllipseType::New();
    EllipseType::Pointer ellipse2 = EllipseType::New();
    EllipseType::Pointer ellipse3 = EllipseType::New();

Every class deriving from SpatialObject has particular parameters
enabling the user to tailor its shape. In the case of the
EllipseSpatialObject, {SetRadius()} is used to define the ellipse size.
An additional {SetRadius(Array)} method allows the user to define the
ellipse axes independently.

::

    [language=C++]
    ellipse1->SetRadius(  10.0  );
    ellipse2->SetRadius(  10.0  );
    ellipse3->SetRadius(  10.0  );

The ellipses are created centered in space by default. We use the
following lines of code to arrange the ellipses in a triangle. The
spatial transform intrinsically associated with the object is accessed
by the {GetTransform()} method. This transform can define a translation
in space with the {SetOffset()} method. We take advantage of this
feature to place the ellipses at particular points in space.

::

    [language=C++]
    EllipseType::TransformType::OffsetType offset;
    offset[ 0 ] = 100.0;
    offset[ 1 ] =  40.0;

    ellipse1->GetObjectToParentTransform()->SetOffset(offset);
    ellipse1->ComputeObjectToWorldTransform();

    offset[ 0 ] =  40.0;
    offset[ 1 ] = 150.0;
    ellipse2->GetObjectToParentTransform()->SetOffset(offset);
    ellipse2->ComputeObjectToWorldTransform();

    offset[ 0 ] = 150.0;
    offset[ 1 ] = 150.0;
    ellipse3->GetObjectToParentTransform()->SetOffset(offset);
    ellipse3->ComputeObjectToWorldTransform();

Note that after a change has been made in the transform, the
SpatialObject invokes the method {ComputeGlobalTransform()} in order to
update its global transform. The reason for doing this is that
SpatialObjects can be arranged in hierarchies. It is then possible to
change the position of a set of spatial objects by moving the parent of
the group.

Now we add the three EllipseSpatialObjects to a GroupSpatialObject that
will be subsequently passed on to the registration method. The
GroupSpatialObject facilitates the management of the three ellipses as a
higher level structure representing a complex shape. Groups can be
nested any number of levels in order to represent shapes with higher
detail.

::

    [language=C++]
    GroupType::Pointer group = GroupType::New();
    group->AddSpatialObject( ellipse1 );
    group->AddSpatialObject( ellipse2 );
    group->AddSpatialObject( ellipse3 );

Having the geometric model ready, we proceed to generate the binary
image representing the imprint of the space occupied by the ellipses.
The SpatialObjectToImageFilter is used to that end. Note that this
filter is instantiated over the spatial object used and the image type
to be generated.

::

    [language=C++]
    typedef itk::SpatialObjectToImageFilter< GroupType, ImageType >
    SpatialObjectToImageFilterType;

With the defined type, we construct a filter using the {New()} method.
The newly created filter is assigned to a SmartPointer.

::

    [language=C++]
    SpatialObjectToImageFilterType::Pointer imageFilter =
    SpatialObjectToImageFilterType::New();

The GroupSpatialObject is passed as input to the filter.

::

    [language=C++]
    imageFilter->SetInput(  group  );

The {SpatialObjectToImageFilter} acts as a resampling filter. Therefore
it requires the user to define the size of the desired output image.
This is specified with the {SetSize()} method.

::

    [language=C++]
    ImageType::SizeType size;
    size[ 0 ] = 200;
    size[ 1 ] = 200;
    imageFilter->SetSize( size );

Finally we trigger the execution of the filter by calling the {Update()}
method.

::

    [language=C++]
    imageFilter->Update();

In order to obtain a smoother metric, we blur the image using a
{DiscreteGaussianImageFilter}. This extends the capture radius of the
metric and produce a more continuous cost function to optimize. The
following lines instantiate the Gaussian filter and create one object of
this type using the {New()} method.

::

    [language=C++]
    typedef itk::DiscreteGaussianImageFilter< ImageType, ImageType >
    GaussianFilterType;
    GaussianFilterType::Pointer   gaussianFilter =   GaussianFilterType::New();

The output of the SpatialObjectToImageFilter is connected as input to
the DiscreteGaussianImageFilter.

::

    [language=C++]
    gaussianFilter->SetInput(  imageFilter->GetOutput()  );

The variance of the filter is defined as a large value in order to
increase the capture radius. Finally the execution of the filter is
triggered using the {Update()} method.

::

    [language=C++]
    const double variance = 20;
    gaussianFilter->SetVariance(variance);
    gaussianFilter->Update();

Below we instantiate the type of the
{ImageToSpatialObjectRegistrationMethod} method and instantiate a
registration object with the {New()} method. Note that the registration
type is templated over the Image and the SpatialObject types. The
spatial object in this case is the group of spatial objects.

::

    [language=C++]
    typedef itk::ImageToSpatialObjectRegistrationMethod< ImageType, GroupType >
    RegistrationType;
    RegistrationType::Pointer registration = RegistrationType::New();

Now we instantiate the metric that is templated over the image type and
the spatial object type. As usual, the {New()} method is used to create
an object.

::

    [language=C++]
    typedef SimpleImageToSpatialObjectMetric< ImageType, GroupType > MetricType;
    MetricType::Pointer metric = MetricType::New();

An interpolator will be needed to evaluate the image at non-grid
positions. Here we instantiate a linear interpolator type.

::

    [language=C++]
    typedef itk::LinearInterpolateImageFunction< ImageType, double >
    InterpolatorType;
    InterpolatorType::Pointer interpolator = InterpolatorType::New();

The following lines instantiate the evolutionary optimizer.

::

    [language=C++]
    typedef itk::OnePlusOneEvolutionaryOptimizer  OptimizerType;
    OptimizerType::Pointer optimizer  = OptimizerType::New();

Next, we instantiate the transform class. In this case we use the
Euler2DTransform that implements a rigid transform in :math:`2D`
space.

::

    [language=C++]
    typedef itk::Euler2DTransform<> TransformType;
    TransformType::Pointer transform = TransformType::New();

Evolutionary algorithms are based on testing random variations of
parameters. In order to support the computation of random values, ITK
provides a family of random number generators. In this example, we use
the {NormalVariateGenerator} which generates values with a normal
distribution.

::

    [language=C++]
    itk::Statistics::NormalVariateGenerator::Pointer generator
    = itk::Statistics::NormalVariateGenerator::New();

The random number generator must be initialized with a seed.

::

    [language=C++]
    generator->Initialize(12345);

The OnePlusOneEvolutionaryOptimizer is initialized by specifying the
random number generator, the number of samples for the initial
population and the maximum number of iterations.

::

    [language=C++]
    optimizer->SetNormalVariateGenerator( generator );
    optimizer->Initialize( 10 );
    optimizer->SetMaximumIteration( 400 );

As in previous registration examples, we take care to normalize the
dynamic range of the different transform parameters. In particular, the
we must compensate for the ranges of the angle and translations of the
Euler2DTransform. In order to achieve this goal, we provide an array of
scales to the optimizer.

::

    [language=C++]
    TransformType::ParametersType parametersScale;
    parametersScale.set_size(3);
    parametersScale[0] = 1000;  angle scale

    for( unsigned int i=1; i<3; i++ )
    {
    parametersScale[i] = 2;  offset scale
    }
    optimizer->SetScales( parametersScale );

Here we instantiate the Command object that will act as an observer of
the registration method and print out parameters at each iteration.
Earlier, we defined this command as a class templated over the optimizer
type. Once it is created with the {New()} method, we connect the
optimizer to the command.

::

    [language=C++]
    typedef IterationCallback< OptimizerType >   IterationCallbackType;
    IterationCallbackType::Pointer callback = IterationCallbackType::New();
    callback->SetOptimizer( optimizer );

All the components are plugged into the
ImageToSpatialObjectRegistrationMethod object. The typical {Set()}
methods are used here. Note the use of the {SetMovingSpatialObject()}
method for connecting the spatial object. We provide the blurred version
of the original synthetic binary image as the input image.

::

    [language=C++]
    registration->SetFixedImage( gaussianFilter->GetOutput() );
    registration->SetMovingSpatialObject( group );
    registration->SetTransform( transform );
    registration->SetInterpolator( interpolator );
    registration->SetOptimizer( optimizer );
    registration->SetMetric( metric );

The initial set of transform parameters is passed to the registration
method using the {SetInitialTransformParameters()} method. Note that
since our original model is already registered with the synthetic image,
we introduce an artificial mis-registration in order to initialize the
optimization at some point away from the optimal value.

::

    [language=C++]
    TransformType::ParametersType initialParameters(
    transform->GetNumberOfParameters() );

    initialParameters[0] = 0.2;      Angle
    initialParameters[1] = 7.0;      Offset X
    initialParameters[2] = 6.0;      Offset Y
    registration->SetInitialTransformParameters(initialParameters);

Due to the character of the metric used to evaluate the fitness between
the spatial object and the image, we must tell the optimizer that we are
interested in finding the maximum value of the metric. Some metrics
associate low numeric values with good matching, while others associate
high numeric values with good matching. The {MaximizeOn()} and
{MaximizeOff()} methods allow the user to deal with both types of
metrics.

::

    [language=C++]
    optimizer->MaximizeOn();

Finally, we trigger the execution of the registration process with the
{StartRegistration()} method. We place this call in a {try/catch} block
in case any exception is thrown during the process.

::

    [language=C++]
    try
    {
    registration->StartRegistration();
    std::cout << "Optimizer stop condition: "
    << registration->GetOptimizer()->GetStopConditionDescription()
    << std::endl;
    }
    catch( itk::ExceptionObject & exp )
    {
    std::cerr << "Exception caught ! " << std::endl;
    std::cerr << exp << std::endl;
    }

The set of transform parameters resulting from the registration can be
recovered with the {GetLastTransformParameters()} method. This method
returns the array of transform parameters that should be interpreted
according to the implementation of each transform. In our current
example, the Euler2DTransform has three parameters: the rotation angle,
the translation in :math:`x` and the translation in :math:`y`.

::

    [language=C++]
    RegistrationType::ParametersType finalParameters
    = registration->GetLastTransformParameters();

    std::cout << "Final Solution is : " << finalParameters << std::endl;

    |image| |image1| [SpatialObject to Image Registration results]
    {Plots of the angle and translation parameters for a registration
    process between an spatial object and an image.}
    {fig:ModelToImageRegistrationPlots}

The results are presented in Figure {fig:ModelToImageRegistrationPlots}.
The left side shows the evolution of the angle parameter as a function
of iteration numbers, while the right side shows the :math:`(x,y)`
translation.

.. |image| image:: ModelToImageRegistrationTraceAngle.eps
.. |image1| image:: ModelToImageRegistrationTraceTranslations.eps
