The source code for this section can be found in the file
``DeformableRegistration7.cxx``.

This example illustrates the use of the {BSplineTransform} class for
performing registration of two :math:`3D` images. The example code is
for the most part identical to the code presented in
Section {sec:DeformableRegistration}. The major difference is that this
example we set the image dimension to 3 and replace the {LBFGSOptimizer}
optimizer with the {LBFGSBOptimizer}. We made the modification because
we found that LBFGS does not behave well when the starting positions is
at or close to optimal; instead we used LBFGSB in unconstrained mode.

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
    typedef TransformType::RegionType RegionType;

    unsigned int numberOfGridNodes = 8;

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
    meshSize.Fill( numberOfGridNodes - SplineOrder );

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
    transform->SetParameters( finalParameters );

