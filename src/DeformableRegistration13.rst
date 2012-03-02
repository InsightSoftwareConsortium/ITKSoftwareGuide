The source code for this section can be found in the file
``DeformableRegistration13.cxx``.

This example is almost identical to
Section {sec:DeformableRegistration12}, with the difference that it
illustrates who to use the RegularStepGradientDescentOptimizer for a
deformable registration task.

The following are the most relevant headers to this example.

::

    [language=C++]
    #include "itkBSplineTransform.h"
    #include "itkRegularStepGradientDescentOptimizer.h"

We instantiate now the type of the {BSplineTransform} using as template
parameters the type for coordinates representation, the dimension of the
space, and the order of the BSpline. We also intantiate the type of the
optimizer.

::

    [language=C++]
    const unsigned int SpaceDimension = ImageDimension;
    const unsigned int SplineOrder = 3;
    typedef double CoordinateRepType;

    typedef itk::BSplineTransform<
    CoordinateRepType,
    SpaceDimension,
    SplineOrder >     TransformType;

    typedef itk::RegularStepGradientDescentOptimizer       OptimizerType;

::

    [language=C++]

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

    registration->SetInitialTransformParameters( transform->GetParameters() );

Next we set the parameters of the RegularStepGradientDescentOptimizer.

::

    [language=C++]
    optimizer->SetMaximumStepLength( 10.0   );
    optimizer->SetMinimumStepLength(  0.01 );

    optimizer->SetRelaxationFactor( 0.7 );
    optimizer->SetNumberOfIterations( 200 );

