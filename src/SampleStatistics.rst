The source code for this section can be found in the file
``SampleStatistics.cxx``.

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

The following headers are for sample statistics algorithms.

::

    [language=C++]
    #include "itkMeanSampleFilter.h"
    #include "itkCovarianceSampleFilter.h"

The following code snippet will create a ListSample object with
three-component float measurement vectors and put five measurement
vectors in the ListSample object.

::

    [language=C++]
    const unsigned int MeasurementVectorLength = 3;
    typedef itk::Vector< float, MeasurementVectorLength > MeasurementVectorType;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    sample->SetMeasurementVectorSize( MeasurementVectorLength );
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

To calculate the mean (vector) of a sample, we instantiate the
{Statistics} {MeanSampleFilter} class that implements the mean algorithm
and plug in the sample using the {SetInputSample(sample\*)} method. By
calling the {Update()} method, we run the algorithm. We get the mean
vector using the {GetMean()} method. The output from the {GetOutput()}
method is the pointer to the mean vector.

::

    [language=C++]
    typedef itk::Statistics::MeanSampleFilter< SampleType > MeanAlgorithmType;

    MeanAlgorithmType::Pointer meanAlgorithm = MeanAlgorithmType::New();

    meanAlgorithm->SetInput( sample );
    meanAlgorithm->Update();

    std::cout << "Sample mean = " << meanAlgorithm->GetMean() << std::endl;

The covariance calculation algorithm will also calculate the mean while
performing the covariance matrix calculation. The mean can be accessed
using the {GetMean()} method while the covariance can be accessed using
the {GetCovarianceMatrix()} method.

::

    [language=C++]
    typedef itk::Statistics::CovarianceSampleFilter< SampleType >
    CovarianceAlgorithmType;
    CovarianceAlgorithmType::Pointer covarianceAlgorithm =
    CovarianceAlgorithmType::New();

    covarianceAlgorithm->SetInput( sample );
    covarianceAlgorithm->Update();

    std::cout << "Mean = " << std::endl;
    std::cout << covarianceAlgorithm->GetMean() << std::endl;

    std::cout << "Covariance = " << std::endl ;
    std::cout << covarianceAlgorithm->GetCovarianceMatrix() << std::endl;

