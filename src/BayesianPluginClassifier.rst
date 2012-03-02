The source code for this section can be found in the file
``BayesianPluginClassifier.cxx``.

.. index::
   pair: Statistics; Bayesian plugin classifier
   pair: Statistics; SampleClassifier
   pair: Statistics; GaussianMembershipFunction
   pair: Statistics; NormalVariateGenerator

In this example, we present a system that places measurement vectors
into two Gaussian classes. The Figure~\ref{fig:BayesianPluginClassifier}
shows all the components of the classifier system and the data flow.
This system differs with the previous k-means clustering algorithms in
several ways. The biggest difference is that this classifier uses the
\subdoxygen{Statistics}{GaussianDensityFunction}s as membership functions instead
of the \subdoxygen{Statistics}{DistanceToCentroidMembershipFunction}. Since the
membership function is different, the membership function requires a
different set of parameters, mean vectors and covariance matrices. We
choose the \subdoxygen{Statistics}{CovarianceSampleFilter} (sample covariance) for
the estimation algorithms of the two parameters. If we want a more
robust estimation algorithm, we can replace this estimation algorithm
with more alternatives without changing other components in the
classifier system.

It is a bad idea to use the same sample for test and training (parameter
estimation) of the parameters. However, for simplicity, in this example,
we use a sample for test and training.

.. figure:: BayesianPluginClassifier.png
   :scale: 50%
   :alt: Bayesian plug-in classifier for two Gaussian classes

    Bayesian plug-in classifier for two Gaussian classes.

We use the \subdoxygen{Statistics}{ListSample} as the sample (test and training).
The \doxygen{Vector} is our measurement vector class. To store measurement
vectors into two separate sample containers, we use the \subdoxygen{Statistics}{Subsample} objects.

::

    [language=C++]
    #include "itkVector.h"
    #include "itkListSample.h"
    #include "itkSubsample.h"

The following file provides us the parameter estimation algorithm.

::

    [language=C++]
    #include "itkCovarianceSampleFilter.h"

The following files define the components required by ITK statistical
classification framework: the decision rule, the membership function,
and the classifier.

::

    [language=C++]
    #include "itkMaximumRatioDecisionRule.h"
    #include "itkGaussianMembershipFunction.h"
    #include "itkSampleClassifierFilter.h"

We will fill the sample with random variables from two normal
distribution using the \subdoxygen{Statistics}{NormalVariateGenerator}.

::

    [language=C++]
    #include "itkNormalVariateGenerator.h"

Since the NormalVariateGenerator class only supports 1-D, we define our
measurement vector type as a one component vector. We then, create a
ListSample object for data inputs.

We also create two Subsample objects that will store the measurement
vectors in \code{sample} into two separate sample containers. Each Subsample
object stores only the measurement vectors belonging to a single class.
This class sample will be used by the parameter estimation algorithms.

::

    [language=C++]
    const unsigned int measurementVectorLength = 1;
    typedef itk::Vector< double, measurementVectorLength > MeasurementVectorType;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    sample->SetMeasurementVectorSize( measurementVectorLength );  length of measurement
    vectors in the sample.

    typedef itk::Statistics::Subsample< SampleType > ClassSampleType;
    std::vector< ClassSampleType::Pointer > classSamples;
    for ( unsigned int i = 0 ; i < 2 ; ++i )
    {
    classSamples.push_back( ClassSampleType::New() );
    classSamples[i]->SetSample( sample );
    }

The following code snippet creates a NormalVariateGenerator object.
Since the random variable generator returns values according to the
standard normal distribution (the mean is zero, and the standard
deviation is one) before pushing random values into the \code{sample}, we
change the mean and standard deviation. We want two normal (Gaussian)
distribution data. We have two for loops. Each for loop uses different
mean and standard deviation. Before we fill the \code{sample} with the second
distribution data, we call \code{Initialize(random seed)} method, to recreate
the pool of random variables in the \code{normalGenerator}. In the second for
loop, we fill the two class samples with measurement vectors using the
\code{AddInstance()} method.

To see the probability density plots from the two distributions, refer
to Figure~\ref{fig:TwoNormalDensityFunctionPlot}.

::

    [language=C++]
    typedef itk::Statistics::NormalVariateGenerator NormalGeneratorType;
    NormalGeneratorType::Pointer normalGenerator = NormalGeneratorType::New();

    normalGenerator->Initialize( 101 );

    MeasurementVectorType mv;
    double mean = 100;
    double standardDeviation = 30;
    SampleType::InstanceIdentifier id = 0UL;
    for ( unsigned int i = 0 ; i < 100 ; ++i )
    {
    mv.Fill( (normalGenerator->GetVariate() * standardDeviation ) + mean);
    sample->PushBack( mv );
    classSamples[0]->AddInstance( id );
    ++id;
    }

    normalGenerator->Initialize( 3024 );
    mean = 200;
    standardDeviation = 30;
    for ( unsigned int i = 0 ; i < 100 ; ++i )
    {
    mv.Fill( (normalGenerator->GetVariate() * standardDeviation ) + mean);
    sample->PushBack( mv );
    classSamples[1]->AddInstance( id );
    ++id;
    }

In the following code snippet, notice that the template argument for the
CovarianceCalculator is \code{ClassSampleType} (i.e., type of Subsample)
instead of SampleType (i.e., type of ListSample). This is because the
parameter estimation algorithms are applied to the class sample.

::

    [language=C++]
    typedef itk::Statistics::CovarianceSampleFilter< ClassSampleType >
    CovarianceEstimatorType;

    std::vector< CovarianceEstimatorType::Pointer > covarianceEstimators;

    for ( unsigned int i = 0 ; i < 2 ; ++i )
    {
    covarianceEstimators.push_back( CovarianceEstimatorType::New() );
    covarianceEstimators[i]->SetInput( classSamples[i] );
    covarianceEstimators[i]->Update();
    }

We print out the estimated parameters.

::

    [language=C++]
    for ( unsigned int i = 0 ; i < 2 ; ++i )
    {
    std::cout << "class[" << i << "] " << std::endl;
    std::cout << "    estimated mean : "
    << covarianceEstimators[i]->GetMean()
    << "    covariance matrix : "
    << covarianceEstimators[i]->GetCovarianceMatrix() << std::endl;
    }

After creating a SampleClassifier object and a MaximumRatioDecisionRule
object, we plug in the \code{decisionRule} and the \code{sample} to the
classifier. Then, we specify the number of classes that will be
considered using the \code{SetNumberOfClasses()} method.

The MaximumRatioDecisionRule requires a vector of *a priori* probability
values. Such *a priori* probability will be the :math:`P(\omega_{i})`
of the following variation of the Bayes decision rule:
:math:`\textrm{Decide } \omega_{i} \textrm{ if }
\frac{p(\overrightarrow{x}|\omega_{i})}
{p(\overrightarrow{x}|\omega_{j})}
> \frac{P(\omega_{j})}{P(\omega_{i})} \textrm{ for all } j \not= i
\label{eq:bayes2}`

The remainder of the code snippet shows how to use user-specified class
labels. The classification result will be stored in a MembershipSample
object, and for each measurement vector, its class label will be one of
the two class labels, 100 and 200 (\code{unsigned int}).

::

    [language=C++]
    typedef itk::Statistics::GaussianMembershipFunction< MeasurementVectorType >
    MembershipFunctionType;
    typedef itk::Statistics::MaximumRatioDecisionRule DecisionRuleType;
    DecisionRuleType::Pointer decisionRule = DecisionRuleType::New();

    DecisionRuleType::PriorProbabilityVectorType aPrioris;
    aPrioris.push_back( (double)classSamples[0]->GetTotalFrequency()
    / (double)sample->GetTotalFrequency() ) ;
    aPrioris.push_back( (double)classSamples[1]->GetTotalFrequency()
    / (double)sample->GetTotalFrequency() ) ;
    decisionRule->SetPriorProbabilities( aPrioris );

    typedef itk::Statistics::SampleClassifierFilter< SampleType > ClassifierType;
    ClassifierType::Pointer classifier = ClassifierType::New();

    classifier->SetDecisionRule( decisionRule);
    classifier->SetInput( sample );
    classifier->SetNumberOfClasses( 2 );

    typedef ClassifierType::ClassLabelVectorObjectType ClassLabelVectorObjectType;
    typedef ClassifierType::ClassLabelVectorType ClassLabelVectorType;

    ClassLabelVectorObjectType::Pointer classLabelVectorObject =
    ClassLabelVectorObjectType::New();
    ClassLabelVectorType classLabelVector = classLabelVectorObject->Get();

    ClassifierType::ClassLabelType class1 = 100;
    classLabelVector.push_back( class1 );
    ClassifierType::ClassLabelType class2 = 200;
    classLabelVector.push_back( class2 );

    classLabelVectorObject->Set( classLabelVector );
    classifier->SetClassLabels( classLabelVectorObject );

The \code{classifier} is almost ready to perform the classification except
that it needs two membership functions that represent the two clusters.

In this example, we can imagine that the two clusters are modeled by two
Gaussian distribution functions. The distribution functions have two
parameters, the mean, set by the \code{SetMean()} method, and the covariance,
set by the \code{SetCovariance()} method. To plug-in two distribution
functions, we create a new instance of
\code{MembershipFunctionVectorObjectType} and populate its internal vector
with new instances of \code{MembershipFunction} (i.e.
GaussianMembershipFunction). This is done by calling the {Get()} method
of \code{membershipFunctionVectorObject} to get the internal vector,
populating this vector with two new membership functions and then
calling \code{membershipFunctionVectorObject->Set( membershipFunctionVector
)}. Finally, the invocation of the \code{Update()} method will perform the
classification.

::

    [language=C++]
    typedef ClassifierType::MembershipFunctionVectorObjectType
    MembershipFunctionVectorObjectType;
    typedef ClassifierType::MembershipFunctionVectorType
    MembershipFunctionVectorType;

    MembershipFunctionVectorObjectType::Pointer membershipFunctionVectorObject =
    MembershipFunctionVectorObjectType::New();
    MembershipFunctionVectorType membershipFunctionVector =
    membershipFunctionVectorObject->Get();

    for ( unsigned int i = 0 ; i < 2 ; i++ )
    {
    MembershipFunctionType::Pointer membershipFunction =
    MembershipFunctionType::New();
    membershipFunction->SetMean( covarianceEstimators[i]->GetMean() );
    membershipFunction->SetCovariance(
    covarianceEstimators[i]->GetCovarianceMatrix() );
    membershipFunctionVector.push_back( membershipFunction.GetPointer() );
    }
    membershipFunctionVectorObject->Set( membershipFunctionVector );
    classifier->SetMembershipFunctions( membershipFunctionVectorObject );

    classifier->Update();

The following code snippet prints out pairs of a measurement vector and
its class label in the \code{sample}.

::

    [language=C++]
    const ClassifierType::MembershipSampleType* membershipSample = classifier->GetOutput();
    ClassifierType::MembershipSampleType::ConstIterator iter = membershipSample->Begin();

    while ( iter != membershipSample->End() )
    {
    std::cout << "measurement vector = " << iter.GetMeasurementVector()
    << " class label = " << iter.GetClassLabel() << std::endl;
    ++iter;
    }
