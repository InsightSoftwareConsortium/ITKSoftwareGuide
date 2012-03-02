The source code for this section can be found in the file
``KdTreeBasedKMeansClustering.cxx``.

K-means clustering is a popular clustering algorithm because it is
simple and usually converges to a reasonable solution. The k-means
algorithm works as follows:

#. 
#. 
#. 
#. 

The most common termination criteria is that if there is no measurement
vector that changes its cluster membership from the previous iteration,
then the algorithm stops.

The {Statistics} {KdTreeBasedKmeansEstimator} is a variation of this
logic. The k-means clustering algorithm is computationally very
expensive because it has to recalculate the mean at each iteration. To
update the mean values, we have to calculate the distance between k
means and each and every measurement vector. To reduce the computational
burden, the KdTreeBasedKmeansEstimator uses a special data structure:
the k-d tree ({Statistics} {KdTree}) with additional information. The
additional information includes the number and the vector sum of
measurement vectors under each node under the tree architecture.

With such additional information and the k-d tree data structure, we can
reduce the computational cost of the distance calculation and means.
Instead of calculating each measurement vectors and k means, we can
simply compare each node of the k-d tree and the k means. This idea of
utilizing a k-d tree can be found in multiple articles . Our
implementation of this scheme follows the article by the Kanungo et al .

We use the {Statistics} {ListSample} as the input sample, the {Vector}
as the measurement vector. The following code snippet includes their
header files.

::

    [language=C++]
    #include "itkVector.h"
    #include "itkListSample.h"

Since our k-means algorithm requires a {Statistics} {KdTree} object as
an input, we include the KdTree class header file. As mentioned above,
we need a k-d tree with the vector sum and the number of measurement
vectors. Therefore we use the {Statistics}
{WeightedCentroidKdTreeGenerator} instead of the {Statistics}
{KdTreeGenerator} that generate a k-d tree without such additional
information.

::

    [language=C++]
    #include "itkKdTree.h"
    #include "itkWeightedCentroidKdTreeGenerator.h"

The KdTreeBasedKmeansEstimator class is the implementation of the
k-means algorithm. It does not create k clusters. Instead, it returns
the mean estimates for the k clusters.

::

    [language=C++]
    #include "itkKdTreeBasedKmeansEstimator.h"

To generate the clusters, we must create k instances of {Statistics}
{DistanceToCentroidMembershipFunction} function as the membership
functions for each cluster and plug that—along with a sample—into an
{Statistics} {SampleClassifierFilter} object to get a {Statistics}
{MembershipSample} that stores pairs of measurement vectors and their
associated class labels (k labels).

::

    [language=C++]
    #include "itkMinimumDecisionRule.h"
    #include "itkSampleClassifierFilter.h"

We will fill the sample with random variables from two normal
distribution using the {Statistics} {NormalVariateGenerator}.

::

    [language=C++]
    #include "itkNormalVariateGenerator.h"

Since the {NormalVariateGenerator} class only supports 1-D, we define
our measurement vector type as one component vector. We then, create a
{ListSample} object for data inputs. Each measurement vector is of
length 1. We set this using the {SetMeasurementVectorSize()} method.

::

    [language=C++]
    typedef itk::Vector< double, 1 > MeasurementVectorType;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    sample->SetMeasurementVectorSize( 1 );

The following code snippet creates a NormalVariateGenerator object.
Since the random variable generator returns values according to the
standard normal distribution (The mean is zero, and the standard
deviation is one), before pushing random values into the {sample}, we
change the mean and standard deviation. We want two normal (Gaussian)
distribution data. We have two for loops. Each for loop uses different
mean and standard deviation. Before we fill the {sample} with the second
distribution data, we call {Initialize(random seed)} method, to recreate
the pool of random variables in the {normalGenerator}.

To see the probability density plots from the two distribution, refer to
the Figure {fig:TwoNormalDensityFunctionPlot}.

    |image| [Two normal distributions plot] {Two normal distributions’
    probability density plot (The means are 100 and 200, and the
    standard deviation is 30 )} {fig:TwoNormalDensityFunctionPlot}

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

We create a k-d tree. To see the details on the k-d tree generation, see
the Section {sec:KdTree}.

::

    [language=C++]
    typedef itk::Statistics::WeightedCentroidKdTreeGenerator< SampleType >
    TreeGeneratorType;
    TreeGeneratorType::Pointer treeGenerator = TreeGeneratorType::New();

    treeGenerator->SetSample( sample );
    treeGenerator->SetBucketSize( 16 );
    treeGenerator->Update();

Once we have the k-d tree, it is a simple procedure to produce k mean
estimates.

We create the KdTreeBasedKmeansEstimator. Then, we provide the initial
mean values using the {SetParameters()}. Since we are dealing with two
normal distribution in a 1-D space, the size of the mean value array is
two. The first element is the first mean value, and the second is the
second mean value. If we used two normal distributions in a 2-D space,
the size of array would be four, and the first two elements would be the
two components of the first normal distribution’s mean vector. We
plug-in the k-d tree using the {SetKdTree()}.

The remaining two methods specify the termination condition. The
estimation process stops when the number of iterations reaches the
maximum iteration value set by the {SetMaximumIteration()}, or the
distances between the newly calculated mean (centroid) values and
previous ones are within the threshold set by the
{SetCentroidPositionChangesThreshold()}. The final step is to call the
{StartOptimization()} method.

The for loop will print out the mean estimates from the estimation
process.

::

    [language=C++]
    typedef TreeGeneratorType::KdTreeType TreeType;
    typedef itk::Statistics::KdTreeBasedKmeansEstimator<TreeType> EstimatorType;
    EstimatorType::Pointer estimator = EstimatorType::New();

    EstimatorType::ParametersType initialMeans(2);
    initialMeans[0] = 0.0;
    initialMeans[1] = 0.0;

    estimator->SetParameters( initialMeans );
    estimator->SetKdTree( treeGenerator->GetOutput() );
    estimator->SetMaximumIteration( 200 );
    estimator->SetCentroidPositionChangesThreshold(0.0);
    estimator->StartOptimization();

    EstimatorType::ParametersType estimatedMeans = estimator->GetParameters();

    for ( unsigned int i = 0 ; i < 2 ; ++i )
    {
    std::cout << "cluster[" << i << "] " << std::endl;
    std::cout << "    estimated mean : " << estimatedMeans[i] << std::endl;
    }

If we are only interested in finding the mean estimates, we might stop.
However, to illustrate how a classifier can be formed using the
statistical classification framework. We go a little bit further in this
example.

Since the k-means algorithm is an minimum distance classifier using the
estimated k means and the measurement vectors. We use the
DistanceToCentroidMembershipFunction class as membership functions. Our
choice for the decision rule is the {Statistics} {MinimumDecisionRule}
that returns the index of the membership functions that have the
smallest value for a measurement vector.

After creating a SampleClassifier filter object and a
MinimumDecisionRule object, we plug-in the {decisionRule} and the
{sample} to the classifier filter. Then, we must specify the number of
classes that will be considered using the {SetNumberOfClasses()} method.

The remainder of the following code snippet shows how to use
user-specified class labels. The classification result will be stored in
a MembershipSample object, and for each measurement vector, its class
label will be one of the two class labels, 100 and 200 ({unsigned int}).

::

    [language=C++]
    typedef itk::Statistics::DistanceToCentroidMembershipFunction< MeasurementVectorType >
    MembershipFunctionType;
    typedef itk::Statistics::MinimumDecisionRule DecisionRuleType;
    DecisionRuleType::Pointer decisionRule = DecisionRuleType::New();

    typedef itk::Statistics::SampleClassifierFilter< SampleType > ClassifierType;
    ClassifierType::Pointer classifier = ClassifierType::New();

    classifier->SetDecisionRule( decisionRule );
    classifier->SetInput( sample );
    classifier->SetNumberOfClasses( 2 );

    typedef ClassifierType::ClassLabelVectorObjectType
    ClassLabelVectorObjectType;
    typedef ClassifierType::ClassLabelVectorType ClassLabelVectorType;
    typedef ClassifierType::ClassLabelType ClassLabelType;

    ClassLabelVectorObjectType::Pointer classLabelsObject =
    ClassLabelVectorObjectType::New();
    ClassLabelVectorType& classLabelsVector = classLabelsObject->Get();

    ClassLabelType class1 = 200;
    classLabelsVector.push_back( class1 );
    ClassLabelType class2 = 100;
    classLabelsVector.push_back( class2 );

    classifier->SetClassLabels( classLabelsObject );

The {classifier} is almost ready to do the classification process except
that it needs two membership functions that represents two clusters
respectively.

In this example, the two clusters are modeled by two Euclidean distance
functions. The distance function (model) has only one parameter, its
mean (centroid) set by the {SetCentroid()} method. To plug-in two
distance functions, we create a MembershipFunctionVectorObject that
contains a MembershipFunctionVector with two components and add it using
the {SetMembershipFunctions} method. Then invocation of the {Update()}
method will perform the classification.

::

    [language=C++]

    typedef ClassifierType::MembershipFunctionVectorObjectType
    MembershipFunctionVectorObjectType;
    typedef ClassifierType::MembershipFunctionVectorType
    MembershipFunctionVectorType;

    MembershipFunctionVectorObjectType::Pointer membershipFunctionVectorObject =
    MembershipFunctionVectorObjectType::New();
    MembershipFunctionVectorType& membershipFunctionVector =
    membershipFunctionVectorObject->Get();

    int index = 0;
    for ( unsigned int i = 0 ; i < 2 ; i++ )
    {
    MembershipFunctionType::Pointer membershipFunction = MembershipFunctionType::New();
    MembershipFunctionType::CentroidType centroid( sample->GetMeasurementVectorSize() );
    for ( unsigned int j = 0 ; j < sample->GetMeasurementVectorSize(); j++ )
    {
    centroid[j] = estimatedMeans[index++];
    }
    membershipFunction->SetCentroid( centroid );
    membershipFunctionVector.push_back( membershipFunction.GetPointer() );
    }
    classifier->SetMembershipFunctions( membershipFunctionVectorObject );

    classifier->Update();

The following code snippet prints out the measurement vectors and their
class labels in the {sample}.

::

    [language=C++]
    const ClassifierType::MembershipSampleType* membershipSample =
    classifier->GetOutput();
    ClassifierType::MembershipSampleType::ConstIterator iter = membershipSample->Begin();

    while ( iter != membershipSample->End() )
    {
    std::cout << "measurement vector = " << iter.GetMeasurementVector()
    << " class label = " << iter.GetClassLabel()
    << std::endl;
    ++iter;
    }

.. |image| image:: TwoNormalDensityFunctionPlot.eps
