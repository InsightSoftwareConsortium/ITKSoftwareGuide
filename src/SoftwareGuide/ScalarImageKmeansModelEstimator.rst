The source code for this section can be found in the file
``ScalarImageKmeansModelEstimator.cxx``.

This example shows how to compute the KMeans model of a Scalar Image.

The {Statistics} {KdTreeBasedKmeansEstimator} is used for taking a
scalar image and applying the K-Means algorithm in order to define
classes that represents statistical distributions of intensity values in
the pixels. In the context of Medical Imaging, each class is typically
associated to a particular type of tissue and can therefore be used as a
form of image segmentation. One of the drawbacks of this technique is
that the spatial distribution of the pixels is not considered at all. It
is common therefore to combine the classification resulting from K-Means
with other segmentation techniques that will use the classification as a
prior and add spatial information to it in order to produce a better
segmentation.

::

    [language=C++]

    Create a List from the scalar image
    typedef itk::Statistics::ImageToListSampleAdaptor< ImageType >   AdaptorType;

    AdaptorType::Pointer adaptor = AdaptorType::New();

    adaptor->SetImage(  reader->GetOutput() );



    Define the Measurement vector type from the AdaptorType
    typedef AdaptorType::MeasurementVectorType  MeasurementVectorType;


    Create the K-d tree structure
    typedef itk::Statistics::WeightedCentroidKdTreeGenerator<
    AdaptorType >
    TreeGeneratorType;

    TreeGeneratorType::Pointer treeGenerator = TreeGeneratorType::New();

    treeGenerator->SetSample( adaptor );
    treeGenerator->SetBucketSize( 16 );
    treeGenerator->Update();



    typedef TreeGeneratorType::KdTreeType TreeType;
    typedef itk::Statistics::KdTreeBasedKmeansEstimator<TreeType> EstimatorType;

    EstimatorType::Pointer estimator = EstimatorType::New();

    const unsigned int numberOfClasses = 3;

    EstimatorType::ParametersType initialMeans( numberOfClasses );
    initialMeans[0] = 25.0;
    initialMeans[1] = 125.0;
    initialMeans[2] = 250.0;

    estimator->SetParameters( initialMeans );

    estimator->SetKdTree( treeGenerator->GetOutput() );
    estimator->SetMaximumIteration( 200 );
    estimator->SetCentroidPositionChangesThreshold(0.0);
    estimator->StartOptimization();

    EstimatorType::ParametersType estimatedMeans = estimator->GetParameters();

    for ( unsigned int i = 0 ; i < numberOfClasses ; ++i )
    {
    std::cout << "cluster[" << i << "] " << std::endl;
    std::cout << "    estimated mean : " << estimatedMeans[i] << std::endl;
    }

    |image| [Output of the ScalarImageKmeansModelEstimator] {Test image
    for the KMeans model estimator.}
    {fig:ScalarImageKmeansModelEstimatorTestImage}

The example produces means of 14.8, 91.6, 134.9 on Figure
{fig:ScalarImageKmeansModelEstimatorTestImage}

.. |image| image:: BrainT1Slice.eps
