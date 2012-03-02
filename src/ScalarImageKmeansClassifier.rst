The source code for this section can be found in the file
``ScalarImageKmeansClassifier.cxx``.

This example shows how to use the KMeans model for classifying the pixel
of a scalar image.

The {Statistics} {ScalarImageKmeansImageFilter} is used for taking a
scalar image and applying the K-Means algorithm in order to define
classes that represents statistical distributions of intensity values in
the pixels. The classes are then used in this filter for generating a
labeled image where every pixel is assigned to one of the classes.

::

    [language=C++]
    #include "itkImage.h"
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkScalarImageKmeansImageFilter.h"

First we define the pixel type and dimension of the image that we intend
to classify. With this image type we can =also declare the
{ImageFileReader} needed for reading the input image, create one and set
its input filename.

::

    [language=C++]
    typedef signed short       PixelType;
    const unsigned int          Dimension = 2;

    typedef itk::Image<PixelType, Dimension > ImageType;

    typedef itk::ImageFileReader< ImageType > ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( inputImageFileName );

With the {ImageType} we instantiate the type of the
{ScalarImageKmeansImageFilter} that will compute the K-Means model and
then classify the image pixels.

::

    [language=C++]
    typedef itk::ScalarImageKmeansImageFilter< ImageType > KMeansFilterType;

    KMeansFilterType::Pointer kmeansFilter = KMeansFilterType::New();

    kmeansFilter->SetInput( reader->GetOutput() );

    const unsigned int numberOfInitialClasses = atoi( argv[4] );

In general the classification will produce as output an image whose
pixel values are integers associated to the labels of the classes. Since
typically these integers will be generated in order (0,1,2,...N), the
output image will tend to look very dark when displayed with naive
viewers. It is therefore convenient to have the option of spreading the
label values over the dynamic range of the output image pixel type. When
this is done, the dynamic range of the pixels is divide by the number of
classes in order to define the increment between labels. For example, an
output image of 8 bits will have a dynamic range of [0:256], and when it
is used for holding four classes, the non-contiguous labels will be
(0,64,128,192). The selection of the mode to use is done with the method
{SetUseContiguousLabels()}.

::

    [language=C++]
    const unsigned int useNonContiguousLabels = atoi( argv[3] );

    kmeansFilter->SetUseNonContiguousLabels( useNonContiguousLabels );

For each one of the classes we must provide a tentative initial value
for the mean of the class. Given that this is a scalar image, each one
of the means is simply a scalar value. Note however that in a general
case of K-Means, the input image would be a vector image and therefore
the means will be vectors of the same dimension as the image pixels.

::

    [language=C++]
    for( unsigned k=0; k < numberOfInitialClasses; k++ )
    {
    const double userProvidedInitialMean = atof( argv[k+argoffset] );
    kmeansFilter->AddClassWithInitialMean( userProvidedInitialMean );
    }

The {ScalarImageKmeansImageFilter} is predefined for producing an 8 bits
scalar image as output. This output image contains labels associated to
each one of the classes in the K-Means algorithm. In the following lines
we use the {OutputImageType} in order to instantiate the type of a
{ImageFileWriter}. Then create one, and connect it to the output of the
classification filter.

::

    [language=C++]
    typedef KMeansFilterType::OutputImageType  OutputImageType;

    typedef itk::ImageFileWriter< OutputImageType > WriterType;

    WriterType::Pointer writer = WriterType::New();

    writer->SetInput( kmeansFilter->GetOutput() );

    writer->SetFileName( outputImageFileName );

We are now ready for triggering the execution of the pipeline. This is
done by simply invoking the {Update()} method in the writer. This call
will propagate the update request to the reader and then to the
classifier.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Problem encountered while writing ";
    std::cerr << " image file : " << argv[2] << std::endl;
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

At this point the classification is done, the labeled image is saved in
a file, and we can take a look at the means that were found as a result
of the model estimation performed inside the classifier filter.

::

    [language=C++]
    KMeansFilterType::ParametersType estimatedMeans =
    kmeansFilter->GetFinalMeans();

    const unsigned int numberOfClasses = estimatedMeans.Size();

    for ( unsigned int i = 0 ; i < numberOfClasses ; ++i )
    {
    std::cout << "cluster[" << i << "] ";
    std::cout << "    estimated mean : " << estimatedMeans[i] << std::endl;
    }

    |image| [Output of the KMeans classifier] {Effect of the KMeans
    classifier on a T1 slice of the brain.}
    {fig:ScalarImageKMeansClassifierOutput}

Figure {fig:ScalarImageKMeansClassifierOutput} illustrates the effect of
this filter with three classes. The means were estimated by
ScalarImageKmeansModelEstimator.cxx.

.. |image| image:: BrainT1Slice_labelled.eps
