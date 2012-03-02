The source code for this section can be found in the file
``IterativeClosestPoint1.cxx``.

This example illustrates how to perform Iterative Closest Point (ICP)
registration in ITK. The main class featured in this section is the
{EuclideanDistancePointMetric}.

::

    [language=C++]
    #include "itkTranslationTransform.h"
    #include "itkEuclideanDistancePointMetric.h"
    #include "itkLevenbergMarquardtOptimizer.h"
    #include "itkPointSetToPointSetRegistrationMethod.h"

::

    [language=C++]
    const unsigned int Dimension = 2;

    typedef itk::PointSet< float, Dimension >   PointSetType;

    PointSetType::Pointer fixedPointSet  = PointSetType::New();
    PointSetType::Pointer movingPointSet = PointSetType::New();

    typedef PointSetType::PointType     PointType;

    typedef PointSetType::PointsContainer  PointsContainer;

    PointsContainer::Pointer fixedPointContainer  = PointsContainer::New();
    PointsContainer::Pointer movingPointContainer = PointsContainer::New();

    PointType fixedPoint;
    PointType movingPoint;


    Read the file containing coordinates of fixed points.
    std::ifstream   fixedFile;
    fixedFile.open( argv[1] );
    if( fixedFile.fail() )
    {
    std::cerr << "Error opening points file with name : " << std::endl;
    std::cerr << argv[1] << std::endl;
    return 2;
    }

    unsigned int pointId = 0;
    fixedFile >> fixedPoint;
    while( !fixedFile.eof() )
    {
    fixedPointContainer->InsertElement( pointId, fixedPoint );
    fixedFile >> fixedPoint;
    pointId++;
    }
    fixedPointSet->SetPoints( fixedPointContainer );
    std::cout <<
    "Number of fixed Points = " <<
    fixedPointSet->GetNumberOfPoints() << std::endl;

    Read the file containing coordinates of moving points.
    std::ifstream   movingFile;
    movingFile.open( argv[2] );
    if( movingFile.fail() )
    {
    std::cerr << "Error opening points file with name : " << std::endl;
    std::cerr << argv[2] << std::endl;
    return 2;
    }

    pointId = 0;
    movingFile >> movingPoint;
    while( !movingFile.eof() )
    {
    movingPointContainer->InsertElement( pointId, movingPoint );
    movingFile >> movingPoint;
    pointId++;
    }
    movingPointSet->SetPoints( movingPointContainer );
    std::cout << "Number of moving Points = "
    << movingPointSet->GetNumberOfPoints() << std::endl;


    -----------------------------------------------------------
    Set up  the Metric
    -----------------------------------------------------------
    typedef itk::EuclideanDistancePointMetric<
    PointSetType,
    PointSetType>
    MetricType;

    typedef MetricType::TransformType                 TransformBaseType;
    typedef TransformBaseType::ParametersType         ParametersType;
    typedef TransformBaseType::JacobianType           JacobianType;

    MetricType::Pointer  metric = MetricType::New();


    -----------------------------------------------------------
    Set up a Transform
    -----------------------------------------------------------

    typedef itk::TranslationTransform< double, Dimension >      TransformType;

    TransformType::Pointer transform = TransformType::New();


    Optimizer Type
    typedef itk::LevenbergMarquardtOptimizer OptimizerType;

    OptimizerType::Pointer      optimizer     = OptimizerType::New();
    optimizer->SetUseCostFunctionGradient(false);

    Registration Method
    typedef itk::PointSetToPointSetRegistrationMethod<
    PointSetType,
    PointSetType >
    RegistrationType;


    RegistrationType::Pointer   registration  = RegistrationType::New();

    Scale the translation components of the Transform in the Optimizer
    OptimizerType::ScalesType scales( transform->GetNumberOfParameters() );
    scales.Fill( 0.01 );


    unsigned long   numberOfIterations =  100;
    double          gradientTolerance  =  1e-5;     convergence criterion
    double          valueTolerance     =  1e-5;     convergence criterion
    double          epsilonFunction    =  1e-6;    convergence criterion


    optimizer->SetScales( scales );
    optimizer->SetNumberOfIterations( numberOfIterations );
    optimizer->SetValueTolerance( valueTolerance );
    optimizer->SetGradientTolerance( gradientTolerance );
    optimizer->SetEpsilonFunction( epsilonFunction );

    Start from an Identity transform (in a normal case, the user
    can probably provide a better guess than the identity...
    transform->SetIdentity();

    registration->SetInitialTransformParameters( transform->GetParameters() );

    ------------------------------------------------------
    Connect all the components required for Registration
    ------------------------------------------------------
    registration->SetMetric(        metric        );
    registration->SetOptimizer(     optimizer     );
    registration->SetTransform(     transform     );
    registration->SetFixedPointSet( fixedPointSet );
    registration->SetMovingPointSet(   movingPointSet   );

    Connect an observer
    CommandIterationUpdate::Pointer observer = CommandIterationUpdate::New();
    optimizer->AddObserver( itk::IterationEvent(), observer );

    try
    {
    registration->StartRegistration();
    }
    catch( itk::ExceptionObject & e )
    {
    std::cout << e << std::endl;
    return EXIT_FAILURE;
    }

    std::cout << "Solution = " << transform->GetParameters() << std::endl;

