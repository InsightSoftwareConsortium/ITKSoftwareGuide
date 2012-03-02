The source code for this section can be found in the file
``ImageRegistration11.cxx``.

This example illustrates how to combine the MutualInformation metric
with an Evolutionary algorithm for optimization. Evolutionary algorithms
are naturally well-suited for optimizing the Mutual Information metric
given its random and noisy behavior.

The structure of the example is almost identical to the one illustrated
in ImageRegistration4. Therefore we focus here on the setup that is
specifically required for the evolutionary optimizer.

::

    [language=C++]
    #include "itkImageRegistrationMethod.h"
    #include "itkTranslationTransform.h"
    #include "itkMattesMutualInformationImageToImageMetric.h"
    #include "itkOnePlusOneEvolutionaryOptimizer.h"
    #include "itkNormalVariateGenerator.h"

In this example the image types and all registration components, except
the metric, are declared as in Section
{sec:IntroductionImageRegistration}. The Mattes mutual information
metric type is instantiated using the image types.

::

    [language=C++]
    typedef itk::MattesMutualInformationImageToImageMetric<
    FixedImageType,
    MovingImageType >    MetricType;

Evolutionary algorithms are based on testing random variations of
parameters. In order to support the computation of random values, ITK
provides a family of random number generators. In this example, we use
the {NormalVariateGenerator} which generates values with a normal
distribution.

::

    [language=C++]
    typedef itk::Statistics::NormalVariateGenerator  GeneratorType;

    GeneratorType::Pointer generator = GeneratorType::New();

The random number generator must be initialized with a seed.

::

    [language=C++]
    generator->Initialize(12345);

Another significant difference in the metric is that it computes the
negative mutual information and hence we need to minimize the cost
function in this case. In this example we will use the same optimization
parameters as in Section {sec:IntroductionImageRegistration}.

::

    [language=C++]
    optimizer->MaximizeOff();

    optimizer->SetNormalVariateGenerator( generator );
    optimizer->Initialize( 10 );
    optimizer->SetEpsilon( 1.0 );
    optimizer->SetMaximumIteration( 4000 );

This example is executed using the same multi-modality images as in the
previous one. The registration converges after :math:`24` iterations
and produces the following results:

::

    Translation X = 13.1719
    Translation Y = 16.9006

These values are a very close match to the true misalignment introduced
in the moving image.
