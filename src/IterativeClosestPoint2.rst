The source code for this section can be found in the file
``IterativeClosestPoint2.cxx``.

This example illustrates how to perform Iterative Closest Point (ICP)
registration in ITK using sets of 3D points.

::

    [language=C++]
    #include "itkEuler3DTransform.h"
    #include "itkEuclideanDistancePointMetric.h"
    #include "itkLevenbergMarquardtOptimizer.h"
    #include "itkPointSetToPointSetRegistrationMethod.h"
    #include <iostream>
    #include <fstream>


    int main(int argc, char * argv[] )
    {

    if( argc < 3 )
    {
    std::cerr << "Arguments Missing. " << std::endl;
    std::cerr <<
    "Usage:  IterativeClosestPoint1   fixedPointsFile  movingPointsFile "
    << std::endl;
    return 1;
    }

    const unsigned int Dimension = 3;

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
    "Number of fixed Points = " << fixedPointSet->GetNumberOfPoints()
    << std::endl;

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
    std::cout <<
    "Number of moving Points = "
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

    typedef itk::Euler3DTransform< double >      TransformType;

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

    const double translationScale = 1000.0;    dynamic range of translations
    const double rotationScale    =    1.0;    dynamic range of rotations

    scales[0] = 1.0 / rotationScale;
    scales[1] = 1.0 / rotationScale;
    scales[2] = 1.0 / rotationScale;
    scales[3] = 1.0 / translationScale;
    scales[4] = 1.0 / translationScale;
    scales[5] = 1.0 / translationScale;

    unsigned long   numberOfIterations =  2000;
    double          gradientTolerance  =  1e-4;    convergence criterion
    double          valueTolerance     =  1e-4;    convergence criterion
    double          epsilonFunction    =  1e-5;    convergence criterion


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

