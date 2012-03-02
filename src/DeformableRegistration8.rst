The source code for this section can be found in the file
``DeformableRegistration8.cxx``.

This example illustrates the use of the {BSplineTransform} class for
performing registration of two :math:`3D` images and for the case of
multi-modality images. The image metric of choice in this case is the
{MattesMutualInformationImageToImageMetric}.

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
    OptimizerType::BoundSelectionType boundSelect( transform->GetNumberOfParameters() );
    OptimizerType::BoundValueType upperBound( transform->GetNumberOfParameters() );
    OptimizerType::BoundValueType lowerBound( transform->GetNumberOfParameters() );

    boundSelect.Fill( 0 );
    upperBound.Fill( 0.0 );
    lowerBound.Fill( 0.0 );

    optimizer->SetBoundSelection( boundSelect );
    optimizer->SetUpperBound( upperBound );
    optimizer->SetLowerBound( lowerBound );

    optimizer->SetCostFunctionConvergenceFactor( 1.e7 );
    optimizer->SetProjectedGradientTolerance( 1e-6 );
    optimizer->SetMaximumNumberOfIterations( 200 );
    optimizer->SetMaximumNumberOfEvaluations( 30 );
    optimizer->SetMaximumNumberOfCorrections( 5 );

Next we set the parameters of the Mattes Mutual Information Metric.

::

    [language=C++]
    metric->SetNumberOfHistogramBins( 50 );

    const unsigned int numberOfSamples =
    static_cast<unsigned int>( fixedRegion.GetNumberOfPixels() * 20.0 / 100.0 );

    metric->SetNumberOfSpatialSamples( numberOfSamples );

Given that the Mattes Mutual Information metric uses a random iterator
in order to collect the samples from the images, it is usually
convenient to initialize the seed of the random number generator.

::

    [language=C++]
    metric->ReinitializeSeed( 76926294 );

::

    [language=C++]
    transform->SetParameters( finalParameters );

