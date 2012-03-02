The source code for this section can be found in the file
``DeformableRegistration14.cxx``.

This example illustrates the use of the
{RegularStepGradientDescentOptimizer} in the context of a deformable
registration problem. The code of this example is almost identical to
the one in Section {sec:DeformableRegistration8}.

The following are the most relevant headers to this example.

::

    [language=C++]
    #include "itkBSplineTransform.h"
    #include "itkRegularStepGradientDescentOptimizer.h"

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

Next we set the parameters of the RegularStepGradientDescentOptimizer
object.

::

    [language=C++]
    optimizer->SetMaximumStepLength( 10.0 );
    optimizer->SetMinimumStepLength(  0.01 );

    optimizer->SetRelaxationFactor( 0.7 );
    optimizer->SetNumberOfIterations( 50 );

