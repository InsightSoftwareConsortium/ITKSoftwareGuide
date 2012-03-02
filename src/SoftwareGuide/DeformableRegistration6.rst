The source code for this section can be found in the file
``DeformableRegistration6.cxx``.

This example illustrates the use of the {BSplineTransform} class in a
manually controlled multi-resolution scheme. Here we define two
transforms at two different resolution levels. A first registration is
performed with the spline grid of low resolution, and the results are
then used for initializing a higher resolution grid. Since this example
is quite similar to the previous example on the use of the
{BSplineTransform} we omit here most of the details already discussed
and will focus on the aspects related to the multi-resolution approach.

We include the header files for the transform and the optimizer.

::

    [language=C++]
    #include "itkBSplineTransform.h"
    #include "itkLBFGSOptimizer.h"

We instantiate now the type of the {BSplineTransform} using as template
parameters the type for coordinates representation, the dimension of the
space, and the order of the BSpline.

::

    [language=C++]
    const unsigned int SpaceDimension = ImageDimension;
    const unsigned int SplineOrder = 3;
    typedef double CoordinateRepType;

    typedef itk::BSplineTransform<
    CoordinateRepType,
    SpaceDimension,
    SplineOrder >     TransformType;

We construct two transform objects, each one will be configured for a
resolution level. Notice than in this multi-resolution scheme we are not
modifying the resolution of the image, but rather the flexibility of the
deformable transform itself.

::

    [language=C++]
    TransformType::Pointer  transformLow = TransformType::New();
    registration->SetTransform( transformLow );

::

    [language=C++]
    TransformType::Pointer  transformLow = TransformType::New();
    registration->SetTransform( transformLow );

We now pass the parameters of the current transform as the initial
parameters to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters( transformLow->GetParameters() );


    optimizer->SetGradientConvergenceTolerance( 0.05 );
    optimizer->SetLineSearchAccuracy( 0.9 );
    optimizer->SetDefaultStepLength( 1.5 );
    optimizer->TraceOn();
    optimizer->SetMaximumNumberOfFunctionEvaluations( 1000 );


    std::cout << "Starting Registration with low resolution transform" << std::endl;

    try
    {
    registration->Update();
    std::cout << "Optimizer stop condition = "
    << registration->GetOptimizer()->GetStopConditionDescription()
    << std::endl;
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

Once the registration has finished with the low resolution grid, we
proceed to instantiate a higher resolution {BSplineTransform}.

Now we need to initialize the BSpline coefficients of the higher
resolution transform. This is done by first computing the actual
deformation field at the higher resolution from the lower resolution
BSpline coefficients. Then a BSpline decomposition is done to obtain the
BSpline coefficient of the higher resolution transform.

We now pass the parameters of the high resolution transform as the
initial parameters to be used in a second stage of the registration
process.

Typically, we will also want to tighten the optimizer parameters when we
move from lower to higher resolution grid.

::

    [language=C++]

    Typically, we will also want to tighten the optimizer parameters
    when we move from lower to higher resolution grid.

