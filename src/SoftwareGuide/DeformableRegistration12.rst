The source code for this section can be found in the file
``DeformableRegistration12.cxx``.

This example illustrates the use of the {BSplineTransform} class for
performing registration of two :math:`2D` images. The example code is
for the most part identical to the code presented in
Section {sec:DeformableRegistration8}. The major difference is that this
example we set the image dimension to 2.

The following are the most relevant headers to this example.

::

    [language=C++]
    #include "itkBSplineTransform.h"
    #include "itkLBFGSBOptimizer.h"

The parameter space of the {BSplineTransform} is composed by the set of
all the deformations associated with the nodes of the BSpline grid. This
large number of parameters makes possible to represent a wide variety of
deformations, but it also has the price of requiring a significant
amount of computation time.

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

The transform object is constructed below and passed to the registration
method.

::

    [language=C++]
    TransformType::Pointer  transform = TransformType::New();
    registration->SetTransform( transform );

::

    [language=C++]

    unsigned int numberOfGridNodesInOneDimension = 7;

    TransformType::PhysicalDimensionsType   fixedPhysicalDimensions;
    TransformType::MeshSizeType             meshSize;
    TransformType::OriginType               fixedOrigin;

    for( unsigned int i=0; i< SpaceDimension; i++ )
    {
    fixedOrigin = fixedImage->GetOrigin()[i];
    fixedPhysicalDimensions[i] = fixedImage->GetSpacing()[i] *
    static_cast<double>(
    fixedImage->GetLargestPossibleRegion().GetSize()[i] - 1 );
    }
    meshSize.Fill( numberOfGridNodesInOneDimension - SplineOrder );

    transform->SetTransformDomainOrigin( fixedOrigin );
    transform->SetTransformDomainPhysicalDimensions(
    fixedPhysicalDimensions );
    transform->SetTransformDomainMeshSize( meshSize );
    transform->SetTransformDomainDirection( fixedImage->GetDirection() );

    typedef TransformType::ParametersType     ParametersType;

    const unsigned int numberOfParameters =
    transform->GetNumberOfParameters();

    ParametersType parameters( numberOfParameters );

    parameters.Fill( 0.0 );

    transform->SetParameters( parameters );

We now pass the parameters of the current transform as the initial
parameters to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters( transform->GetParameters() );

Next we set the parameters of the LBFGSB Optimizer.

::

    [language=C++]
    OptimizerType::BoundSelectionType boundSelect(
    transform->GetNumberOfParameters() );
    OptimizerType::BoundValueType upperBound( transform->GetNumberOfParameters() );
    OptimizerType::BoundValueType lowerBound( transform->GetNumberOfParameters() );

    boundSelect.Fill( 0 );
    upperBound.Fill( 0.0 );
    lowerBound.Fill( 0.0 );

    optimizer->SetBoundSelection( boundSelect );
    optimizer->SetUpperBound( upperBound );
    optimizer->SetLowerBound( lowerBound );

    optimizer->SetCostFunctionConvergenceFactor( 1.e7 );
    optimizer->SetProjectedGradientTolerance( 1e-35);
    optimizer->SetMaximumNumberOfIterations( 200 );
    optimizer->SetMaximumNumberOfEvaluations( 200 );
    optimizer->SetMaximumNumberOfCorrections( 7 );

::

    [language=C++]
    transform->SetParameters( finalParameters );

