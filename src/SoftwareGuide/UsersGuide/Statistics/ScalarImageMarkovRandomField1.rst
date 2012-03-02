The source code for this section can be found in the file
``ScalarImageMarkovRandomField1.cxx``.

This example shows how to use the Markov Random Field approach for
classifying the pixel of a scalar image.

The {Statistics} {MRFImageFilter} is used for refining an initial
classification by introducing the spatial coherence of the labels. The
user should provide two images as input. The first image is the one to
be classified while the second image is an image of labels representing
an initial classification.

The following headers are related to reading input images, writing the
output image, and making the necessary conversions between scalar and
vector images.

::

    [language=C++]
    #include "itkImage.h"
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkComposeImageFilter.h"

The following headers are related to the statistical classification
classes.

::

    [language=C++]
    #include "itkMRFImageFilter.h"
    #include "itkDistanceToCentroidMembershipFunction.h"
    #include "itkMinimumDecisionRule.h"

First we define the pixel type and dimension of the image that we intend
to classify. With this image type we can also declare the
{ImageFileReader} needed for reading the input image, create one and set
its input filename. In this particular case we choose to use {signed
short} as pixel type, which is typical for MicroMRI and CT data sets.

::

    [language=C++]
    typedef signed short        PixelType;
    const unsigned int          Dimension = 2;

    typedef itk::Image<PixelType, Dimension > ImageType;

    typedef itk::ImageFileReader< ImageType > ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( inputImageFileName );

As a second step we define the pixel type and dimension of the image of
labels that provides the initial classification of the pixels from the
first image. This initial labeled image can be the output of a K-Means
method like the one illustrated in section {sec:KMeansClassifier}.

::

    [language=C++]
    typedef unsigned char       LabelPixelType;

    typedef itk::Image<LabelPixelType, Dimension > LabelImageType;

    typedef itk::ImageFileReader< LabelImageType > LabelReaderType;
    LabelReaderType::Pointer labelReader = LabelReaderType::New();
    labelReader->SetFileName( inputLabelImageFileName );

Since the Markov Random Field algorithm is defined in general for images
whose pixels have multiple components, that is, images of vector type,
we must adapt our scalar image in order to satisfy the interface
expected by the {MRFImageFilter}. We do this by using the
{ComposeImageFilter}. With this filter we will present our scalar image
as a vector image whose vector pixels contain a single component.

::

    [language=C++]
    typedef itk::FixedArray<LabelPixelType,1>  ArrayPixelType;

    typedef itk::Image< ArrayPixelType, Dimension > ArrayImageType;

    typedef itk::ComposeImageFilter<
    ImageType, ArrayImageType > ScalarToArrayFilterType;

    ScalarToArrayFilterType::Pointer
    scalarToArrayFilter = ScalarToArrayFilterType::New();
    scalarToArrayFilter->SetInput( reader->GetOutput() );

With the input image type {ImageType} and labeled image type
{LabelImageType} we instantiate the type of the {MRFImageFilter} that
will apply the Markov Random Field algorithm in order to refine the
pixel classification.

::

    [language=C++]
    typedef itk::MRFImageFilter< ArrayImageType, LabelImageType > MRFFilterType;

    MRFFilterType::Pointer mrfFilter = MRFFilterType::New();

    mrfFilter->SetInput( scalarToArrayFilter->GetOutput() );

We set now some of the parameters for the MRF filter. In particular, the
number of classes to be used during the classification, the maximum
number of iterations to be run in this filter and the error tolerance
that will be used as a criterion for convergence.

::

    [language=C++]
    mrfFilter->SetNumberOfClasses( numberOfClasses );
    mrfFilter->SetMaximumNumberOfIterations( numberOfIterations );
    mrfFilter->SetErrorTolerance( 1e-7 );

The smoothing factor represents the tradeoff between fidelity to the
observed image and the smoothness of the segmented image. Typical
smoothing factors have values between 1 5. This factor will multiply the
weights that define the influence of neighbors on the classification of
a given pixel. The higher the value, the more uniform will be the
regions resulting from the classification refinement.

::

    [language=C++]
    mrfFilter->SetSmoothingFactor( smoothingFactor );

Given that the MRF filter need to continually relabel the pixels, it
needs access to a set of membership functions that will measure to what
degree every pixel belongs to a particular class. The classification is
performed by the {ImageClassifierBase} class, that is instantiated using
the type of the input vector image and the type of the labeled image.

::

    [language=C++]
    typedef itk::ImageClassifierBase<
    ArrayImageType,
    LabelImageType >   SupervisedClassifierType;

    SupervisedClassifierType::Pointer classifier =
    SupervisedClassifierType::New();

The classifier need a decision rule to be set by the user. Note that we
must use {GetPointer()} in the call of the {SetDecisionRule()} method
because we are passing a SmartPointer, and smart pointer cannot perform
polymorphism, we must then extract the raw pointer that is associated to
the smart pointer. This extraction is done with the GetPointer() method.

::

    [language=C++]
    typedef itk::Statistics::MinimumDecisionRule DecisionRuleType;

    DecisionRuleType::Pointer  classifierDecisionRule = DecisionRuleType::New();

    classifier->SetDecisionRule( classifierDecisionRule.GetPointer() );

We now instantiate the membership functions. In this case we use the
{Statistics} {DistanceToCentroidMembershipFunction} class templated over
the pixel type of the vector image, that in our example happens to be a
vector of dimension 1.

::

    [language=C++]
    typedef itk::Statistics::DistanceToCentroidMembershipFunction<
    ArrayPixelType >
    MembershipFunctionType;

    typedef MembershipFunctionType::Pointer MembershipFunctionPointer;


    double meanDistance = 0;
    MembershipFunctionType::CentroidType centroid(1);
    for( unsigned int i=0; i < numberOfClasses; i++ )
    {
    MembershipFunctionPointer membershipFunction =
    MembershipFunctionType::New();

    centroid[0] = atof( argv[i+numberOfArgumentsBeforeMeans] );

    membershipFunction->SetCentroid( centroid );

    classifier->AddMembershipFunction( membershipFunction );
    meanDistance += static_cast< double > (centroid[0]);
    }
    meanDistance /= numberOfClasses;

We set the Smoothing factor. This factor will multiply the weights that
define the influence of neighbors on the classification of a given
pixel. The higher the value, the more uniform will be the regions
resulting from the classification refinement.

::

    [language=C++]
    mrfFilter->SetSmoothingFactor( smoothingFactor );

and we set the neighborhood radius that will define the size of the
clique to be used in the computation of the neighbors’ influence in the
classification of any given pixel. Note that despite the fact that we
call this a radius, it is actually the half size of an hypercube. That
is, the actual region of influence will not be circular but rather an
N-Dimensional box. For example, a neighborhood radius of 2 in a 3D image
will result in a clique of size 5x5x5 pixels, and a radius of 1 will
result in a clique of size 3x3x3 pixels.

::

    [language=C++]
    mrfFilter->SetNeighborhoodRadius( 1 );

We should now set the weights used for the neighbors. This is done by
passing an array of values that contains the linear sequence of weights
for the neighbors. For example, in a neighborhood of size 3x3x3, we
should provide a linear array of 9 weight values. The values are
packaged in a {std::vector} and are supposed to be {double}. The
following lines illustrate a typical set of values for a 3x3x3
neighborhood. The array is arranged and then passed to the filter by
using the method {SetMRFNeighborhoodWeight()}.

::

    [language=C++]
    std::vector< double > weights;
    weights.push_back(1.5);
    weights.push_back(2.0);
    weights.push_back(1.5);
    weights.push_back(2.0);
    weights.push_back(0.0);  This is the central pixel
    weights.push_back(2.0);
    weights.push_back(1.5);
    weights.push_back(2.0);
    weights.push_back(1.5);

We now scale weights so that the smoothing function and the image
fidelity functions have comparable value. This is necessary since the
label image and the input image can have different dynamic ranges. The
fidelity function is usually computed using a distance function, such as
the {DistanceToCentroidMembershipFunction} or one of the other
membership functions. They tend to have values in the order of the means
specified.

::

    [language=C++]
    double totalWeight = 0;
    for(std::vector< double >::const_iterator wcIt = weights.begin();
    wcIt != weights.end(); ++wcIt )
    {
    totalWeight += *wcIt;
    }
    for(std::vector< double >::iterator wIt = weights.begin();
    wIt != weights.end(); wIt++ )
    {
    *wIt = static_cast< double > ( (*wIt) * meanDistance / (2 * totalWeight));
    }

    mrfFilter->SetMRFNeighborhoodWeight( weights );

Finally, the classifier class is connected to the Markof Random Fields
filter.

::

    [language=C++]
    mrfFilter->SetClassifier( classifier );

The output image produced by the {MRFImageFilter} has the same pixel
type as the labeled input image. In the following lines we use the
{OutputImageType} in order to instantiate the type of a
{ImageFileWriter}. Then create one, and connect it to the output of the
classification filter after passing it through an intensity rescaler to
rescale it to an 8 bit dynamic range

::

    [language=C++]
    typedef MRFFilterType::OutputImageType  OutputImageType;

::

    [language=C++]
    typedef itk::ImageFileWriter< OutputImageType > WriterType;

    WriterType::Pointer writer = WriterType::New();

    writer->SetInput( intensityRescaler->GetOutput() );

    writer->SetFileName( outputImageFileName );

We are now ready for triggering the execution of the pipeline. This is
done by simply invoking the {Update()} method in the writer. This call
will propagate the update request to the reader and then to the MRF
filter.

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

    |image| [Output of the ScalarImageMarkovRandomField] {Effect of the
    MRF filter on a T1 slice of the brain.}
    {fig:ScalarImageMarkovRandomFieldInputOutput}

Figure {fig:ScalarImageMarkovRandomFieldInputOutput} illustrates the
effect of this filter with three classes. In this example the filter was
run with a smoothing factor of 3. The labeled image was produced by
ScalarImageKmeansClassifier.cxx and the means were estimated by
ScalarImageKmeansModelEstimator.cxx.

.. |image| image:: ScalarImageMarkovRandomField1Output.eps
