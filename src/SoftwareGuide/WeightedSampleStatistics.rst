The source code for this section can be found in the file
``WeightedSampleStatistics.cxx``.

We include the header file for the {Vector} class that will be our
measurement vector template in this example.

::

    [language=C++]
    #include "itkVector.h"

We will use the {Statistics} {ListSample} as our sample template. We
include the header for the class too.

::

    [language=C++]
    #include "itkListSample.h"

The following headers are for the weighted covariance algorithms.

::

    [language=C++]
    #include "itkWeightedMeanSampleFilter.h"
    #include "itkWeightedCovarianceSampleFilter.h"

The following code snippet will create a ListSample instance with
three-component float measurement vectors and put five measurement
vectors in the ListSample object.

::

    [language=C++]
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    sample->SetMeasurementVectorSize( 3 );
    MeasurementVectorType mv;
    mv[0] = 1.0;
    mv[1] = 2.0;
    mv[2] = 4.0;

    sample->PushBack( mv );

    mv[0] = 2.0;
    mv[1] = 4.0;
    mv[2] = 5.0;
    sample->PushBack( mv );

    mv[0] = 3.0;
    mv[1] = 8.0;
    mv[2] = 6.0;
    sample->PushBack( mv );

    mv[0] = 2.0;
    mv[1] = 7.0;
    mv[2] = 4.0;
    sample->PushBack( mv );

    mv[0] = 3.0;
    mv[1] = 2.0;
    mv[2] = 7.0;
    sample->PushBack( mv );

Robust versions of covariance algorithms require weight values for
measurement vectors. We have two ways of providing weight values for the
weighted mean and weighted covariance algorithms.

The first method is to plug in an array of weight values. The size of
the weight value array should be equal to that of the measurement
vectors. In both algorithms, we use the {SetWeights(weights)}.

::

    [language=C++]
    typedef itk::Statistics::WeightedMeanSampleFilter< SampleType >
    WeightedMeanAlgorithmType;

    WeightedMeanAlgorithmType::WeightArrayType weightArray( sample->Size() );
    weightArray.Fill( 0.5 );
    weightArray[2] = 0.01;
    weightArray[4] = 0.01;

    WeightedMeanAlgorithmType::Pointer weightedMeanAlgorithm =
    WeightedMeanAlgorithmType::New();

    weightedMeanAlgorithm->SetInput( sample );
    weightedMeanAlgorithm->SetWeights( weightArray );
    weightedMeanAlgorithm->Update();

    std::cout << "Sample weighted mean = "
    << weightedMeanAlgorithm->GetMean() << std::endl;

    typedef itk::Statistics::WeightedCovarianceSampleFilter< SampleType >
    WeightedCovarianceAlgorithmType;

    WeightedCovarianceAlgorithmType::Pointer weightedCovarianceAlgorithm =
    WeightedCovarianceAlgorithmType::New();

    weightedCovarianceAlgorithm->SetInput( sample );
    weightedCovarianceAlgorithm->SetWeights( weightArray );
    weightedCovarianceAlgorithm->Update();

    std::cout << "Sample weighted covariance = " << std::endl ;
    std::cout << weightedCovarianceAlgorithm->GetCovarianceMatrix() << std::endl;

The second method for computing weighted statistics is to plug-in a
function that returns a weight value that is usually a function of each
measurement vector. Since the {weightedMeanAlgorithm} and
{weightedCovarianceAlgorithm} already have the input sample plugged in,
we only need to call the {SetWeightingFunction(weights)} method.

::

    [language=C++]
    ExampleWeightFunction::Pointer weightFunction = ExampleWeightFunction::New();

    weightedMeanAlgorithm->SetWeightingFunction( weightFunction );
    weightedMeanAlgorithm->Update();

    std::cout << "Sample weighted mean = "
    << weightedMeanAlgorithm->GetMean() << std::endl;

    weightedCovarianceAlgorithm->SetWeightingFunction( weightFunction );
    weightedCovarianceAlgorithm->Update();

    std::cout << "Sample weighted covariance = " << std::endl ;
    std::cout << weightedCovarianceAlgorithm->GetCovarianceMatrix();

    std::cout << "Sample weighted mean (from WeightedCovarainceSampleFilter) = "
    << std::endl << weightedCovarianceAlgorithm->GetMean() << std::endl;

