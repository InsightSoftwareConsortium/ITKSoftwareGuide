The source code for this section can be found in the file
``ExpectationMaximizationMixtureModelEstimator.cxx``.

In this example, we present an implementation of the expectation
maximization (EM) process to generates parameter estimates for a two
Gaussian component mixture model.

The Bayesian plug-in classifier example (see Section
{sec:BayesianPluginClassifier}) used two Gaussian probability density
functions (PDF) to model two Gaussian distribution classes (two models
for two class). However, in some cases, we want to model a distribution
as a mixture of several different distributions. Therefore, the
probability density function (:math:`p(x)`) of a mixture model can be
stated as follows :

:math:`p(x) = \sum^{c}_{i=0}\alpha_{i}f_{i}(x)
` where :math:`i` is the index of the component, :math:`c` is the
number of components, :math:`\alpha_{i}` is the proportion of the
component, and :math:`f_{i}` is the probability density function of
the component.

Now the task is to find the parameters(the component PDF’s parameters
and the proportion values) to maximize the likelihood of the parameters.
If we know which component a measurement vector belongs to, the
solutions to this problem is easy to solve. However, we don’t know the
membership of each measurement vector. Therefore, we use the expectation
of membership instead of the exact membership. The EM process splits
into two steps:

#. 
#. 

The E step is basically a step that calculates the *a posteriori*
probability for each measurement vector.

The M step is dependent on the type of each PDF. Most of distributions
belonging to exponential family such as Poisson, Binomial, Exponential,
and Normal distributions have analytical solutions for updating the
parameter set. The {Statistics}
{ExpectationMaximizationMixtureModelEstimator} class assumes that such
type of components.

In the following example we use the {Statistics} {ListSample} as the
sample (test and training). The {Vector} is our measurement vector
class. To store measurement vectors into two separate sample container,
we use the {Statistics} {Subsample} objects.

::

    [language=C++]
    #include "itkVector.h"
    #include "itkListSample.h"

The following two files provides us the parameter estimation algorithms.

::

    [language=C++]
    #include "itkGaussianMixtureModelComponent.h"
    #include "itkExpectationMaximizationMixtureModelEstimator.h"

We will fill the sample with random variables from two normal
distribution using the {Statistics} {NormalVariateGenerator}.

::

    [language=C++]
    #include "itkNormalVariateGenerator.h"

Since the NormalVariateGenerator class only supports 1-D, we define our
measurement vector type as a one component vector. We then, create a
ListSample object for data inputs.

We also create two Subsample objects that will store the measurement
vectors in the {sample} into two separate sample containers. Each
Subsample object stores only the measurement vectors belonging to a
single class. This *class sample* will be used by the parameter
estimation algorithms.

::

    [language=C++]
    unsigned int numberOfClasses = 2;
    typedef itk::Vector< double, 1 > MeasurementVectorType;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    sample->SetMeasurementVectorSize( 1 );  length of measurement vectors
    in the sample.

The following code snippet creates a NormalVariateGenerator object.
Since the random variable generator returns values according to the
standard normal distribution (the mean is zero, and the standard
deviation is one) before pushing random values into the {sample}, we
change the mean and standard deviation. We want two normal (Gaussian)
distribution data. We have two for loops. Each for loop uses different
mean and standard deviation. Before we fill the {sample} with the second
distribution data, we call {Initialize()} method to recreate the pool of
random variables in the {normalGenerator}. In the second for loop, we
fill the two class samples with measurement vectors using the
{AddInstance()} method.

To see the probability density plots from the two distribution, refer to
Figure {fig:TwoNormalDensityFunctionPlot}.

::

    [language=C++]
    typedef itk::Statistics::NormalVariateGenerator NormalGeneratorType;
    NormalGeneratorType::Pointer normalGenerator = NormalGeneratorType::New();

    normalGenerator->Initialize( 101 );

    MeasurementVectorType mv;
    double mean = 100;
    double standardDeviation = 30;
    for ( unsigned int i = 0 ; i < 100 ; ++i )
    {
    mv[0] = ( normalGenerator->GetVariate() * standardDeviation ) + mean;
    sample->PushBack( mv );
    }

    normalGenerator->Initialize( 3024 );
    mean = 200;
    standardDeviation = 30;
    for ( unsigned int i = 0 ; i < 100 ; ++i )
    {
    mv[0] = ( normalGenerator->GetVariate() * standardDeviation ) + mean;
    sample->PushBack( mv );
    }

In the following code snippet notice that the template argument for the
MeanCalculator and CovarianceCalculator is {ClassSampleType} (i.e., type
of Subsample) instead of {SampleType} (i.e., type of ListSample). This
is because the parameter estimation algorithms are applied to the class
sample.

::

    [language=C++]
    typedef itk::Array< double > ParametersType;
    ParametersType params( 2 );

    std::vector< ParametersType > initialParameters( numberOfClasses );
    params[0] = 110.0;
    params[1] = 800.0;
    initialParameters[0] = params;

    params[0] = 210.0;
    params[1] = 850.0;
    initialParameters[1] = params;

    typedef itk::Statistics::GaussianMixtureModelComponent< SampleType >
    ComponentType;

    std::vector< ComponentType::Pointer > components;
    for ( unsigned int i = 0 ; i < numberOfClasses ; i++ )
    {
    components.push_back( ComponentType::New() );
    (components[i])->SetSample( sample );
    (components[i])->SetParameters( initialParameters[i] );
    }

We run the estimator.

::

    [language=C++]
    typedef itk::Statistics::ExpectationMaximizationMixtureModelEstimator<
    SampleType > EstimatorType;
    EstimatorType::Pointer estimator = EstimatorType::New();

    estimator->SetSample( sample );
    estimator->SetMaximumIteration( 200 );

    itk::Array< double > initialProportions(numberOfClasses);
    initialProportions[0] = 0.5;
    initialProportions[1] = 0.5;

    estimator->SetInitialProportions( initialProportions );

    for ( unsigned int i = 0 ; i < numberOfClasses ; i++)
    {
    estimator->AddComponent( (ComponentType::Superclass*)
    (components[i]).GetPointer() );
    }

    estimator->Update();

We then print out the estimated parameters.

::

    [language=C++]
    for ( unsigned int i = 0 ; i < numberOfClasses ; i++ )
    {
    std::cout << "Cluster[" << i << "]" << std::endl;
    std::cout << "    Parameters:" << std::endl;
    std::cout << "         " << (components[i])->GetFullParameters()
    << std::endl;
    std::cout << "    Proportion: ";
    std::cout << "         " << estimator->GetProportions()[i] << std::endl;
    }

