The source code for this section can be found in the file
``ImageRegistration20.cxx``.

This example illustrates the use of the {AffineTransform} for performing
registration in :math:`3D`.

Let’s start by including the header file of the AffineTransform.

::

    [language=C++]
    #include "itkAffineTransform.h"

We define then the types of the images to be registered.

::

    [language=C++]
    const    unsigned int    Dimension = 3;
    typedef  float           PixelType;

    typedef itk::Image< PixelType, Dimension >  FixedImageType;
    typedef itk::Image< PixelType, Dimension >  MovingImageType;

The transform type is instantiated using the code below. The template
parameters of this class are the representation type of the space
coordinates and the space dimension.

::

    [language=C++]
    typedef itk::AffineTransform<
    double,
    Dimension  >     TransformType;

The transform object is constructed below and passed to the registration
method.

::

    [language=C++]
    TransformType::Pointer  transform = TransformType::New();
    registration->SetTransform( transform );

In this example, we again use the {CenteredTransformInitializer} helper
class in order to compute a reasonable value for the initial center of
rotation and the translation. The initializer is set to use the center
of mass of each image as the initial correspondence correction.

::

    [language=C++]
    typedef itk::CenteredTransformInitializer<
    TransformType,
    FixedImageType,
    MovingImageType >  TransformInitializerType;
    TransformInitializerType::Pointer initializer = TransformInitializerType::New();
    initializer->SetTransform(   transform );
    initializer->SetFixedImage(  fixedImageReader->GetOutput() );
    initializer->SetMovingImage( movingImageReader->GetOutput() );
    initializer->MomentsOn();
    initializer->InitializeTransform();

Now we pass the parameters of the current transform as the initial
parameters to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters(
    transform->GetParameters() );

Keeping in mind that the scale of units in scaling, rotation and
translation are quite different, we take advantage of the scaling
functionality provided by the optimizers. We know that the first
:math:`N
\times N` elements of the parameters array correspond to the rotation
matrix factor, and the last :math:`N` are the components of the
translation to be applied after multiplication with the matrix is
performed.

::

    [language=C++]
    typedef OptimizerType::ScalesType       OptimizerScalesType;
    OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() );

    optimizerScales[0] =  1.0;
    optimizerScales[1] =  1.0;
    optimizerScales[2] =  1.0;
    optimizerScales[3] =  1.0;
    optimizerScales[4] =  1.0;
    optimizerScales[5] =  1.0;
    optimizerScales[6] =  1.0;
    optimizerScales[7] =  1.0;
    optimizerScales[8] =  1.0;
    optimizerScales[9]  =  translationScale;
    optimizerScales[10] =  translationScale;
    optimizerScales[11] =  translationScale;

    optimizer->SetScales( optimizerScales );

We also set the usual parameters of the optimization method. In this
case we are using an {RegularStepGradientDescentOptimizer}. Below, we
define the optimization parameters like initial step length, minimal
step length and number of iterations. These last two act as stopping
criteria for the optimization.

::

    [language=C++]
    optimizer->SetMaximumStepLength( steplength );
    optimizer->SetMinimumStepLength( 0.0001 );
    optimizer->SetNumberOfIterations( maxNumberOfIterations );

We also set the optimizer to do minimization by calling the
{MinimizeOn()} method.

::

    [language=C++]
    optimizer->MinimizeOn();

Finally we trigger the execution of the registration method by calling
the {Update()} method. The call is placed in a {try/catch} block in case
any exceptions are thrown.

::

    [language=C++]
    try
    {
    registration->Update();
    std::cout << "Optimizer stop condition: "
    << registration->GetOptimizer()->GetStopConditionDescription()
    << std::endl;
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

Once the optimization converges, we recover the parameters from the
registration method. This is done with the
{GetLastTransformParameters()} method. We can also recover the final
value of the metric with the {GetValue()} method and the final number of
iterations with the {GetCurrentIteration()} method.

::

    [language=C++]
    OptimizerType::ParametersType finalParameters =
    registration->GetLastTransformParameters();

    const unsigned int numberOfIterations = optimizer->GetCurrentIteration();
    const double bestValue = optimizer->GetValue();

