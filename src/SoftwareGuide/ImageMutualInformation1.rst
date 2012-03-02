The source code for this section can be found in the file
``ImageMutualInformation1.cxx``.

This example illustrates how to compute the Mutual Information between
two images using classes from the Statistics framework. Note that you
could also use for this purpose the ImageMetrics designed for the image
registration framework.

For example, you could use:

-  {MutualInformationImageToImageMetric}

-  {MattesMutualInformationImageToImageMetric}

-  {MutualInformationHistogramImageToImageMetric}

-  {MutualInformationImageToImageMetric}

-  {NormalizedMutualInformationHistogramImageToImageMetric}

-  {KullbackLeiblerCompareHistogramImageToImageMetric}

Mutual Information as computed in this example, and as commonly used in
the context of image registration provides a measure of how much
uncertainty on the value of a pixel in one image is reduced by measuring
the homologous pixel in the other image. Note that Mutual Information as
used here does not measures the amount of information that one image
provides on the other image, such measure would have required to take
into account the spatial structures in the images as well as the
semantics of the image context in terms of an observer.

This implies that there is still an enormous unexploited potential on
the use of the Mutual Information concept in the domain of medical
images. Probably the most interesting of which would be the semantic
description of image on terms of anatomical structures.

In this particular example we make use of classes from the Statistics
framework in order to compute the measure of Mutual Information between
two images. We assume that both images have the same number of pixels
along every dimension and that they have the same origin and spacing.
Therefore the pixels from one image are perfectly aligned with those of
the other image.

We must start by including the header files of the image, histogram
filter, reader and Join image filter. We will read both images and use
the Join image filter in order to compose an image of two components
using the information of each one of the input images in one component.
This is the natural way of using the Statistics framework in ITK given
that the fundamental statistical classes are expecting to receive
multi-valued measures.

::

    [language=C++]
    #include "itkImage.h"
    #include "itkImageFileReader.h"
    #include "itkJoinImageFilter.h"
    #include "itkImageToHistogramFilter.h"

We define the pixel type and dimension of the images to be read.

::

    [language=C++]
    typedef unsigned char                                 PixelComponentType;
    const unsigned int                                    Dimension = 2;

    typedef itk::Image< PixelComponentType, Dimension >   ImageType;

Using the image type we proceed to instantiate the readers for both
input images. Then, we take their filenames from the command line
arguments.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >             ReaderType;

    ReaderType::Pointer reader1 = ReaderType::New();
    ReaderType::Pointer reader2 = ReaderType::New();

    reader1->SetFileName( argv[1] );
    reader2->SetFileName( argv[2] );

Using the {JoinImageFilter} we use the two input images and put them
together in an image of two components.

::

    [language=C++]
    typedef itk::JoinImageFilter< ImageType, ImageType >  JoinFilterType;

    JoinFilterType::Pointer joinFilter = JoinFilterType::New();

    joinFilter->SetInput1( reader1->GetOutput() );
    joinFilter->SetInput2( reader2->GetOutput() );

At this point we trigger the execution of the pipeline by invoking the
{Update()} method on the Join filter. We must put the call inside a
try/catch block because the Update() call may potentially result in
exceptions being thrown.

::

    [language=C++]
    try
    {
    joinFilter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return -1;
    }

We prepare now the types to be used for the computation of the Joint
histogram. For this purpose, we take the type of the image resulting
from the JoinImageFilter and use it as template argument of the
{ImageToHistogramFilter}. We then construct one by invoking the {New()}
method.

::

    [language=C++]
    typedef JoinFilterType::OutputImageType               VectorImageType;

    typedef itk::Statistics::ImageToHistogramFilter<
    VectorImageType >  HistogramFilterType;

    HistogramFilterType::Pointer histogramFilter = HistogramFilterType::New();

We pass the multiple components image as input to the histogram filter,
and setup the marginal scale value that will define the precision to be
used for classifying values into the histogram bins.

::

    [language=C++]
    histogramFilter->SetInput(  joinFilter->GetOutput()  );

    histogramFilter->SetMarginalScale( 10.0 );

We must now define the number of bins to use for each one of the
components in the joint image. For this purpose we take the
{HistogramSizeType} from the traits of the histogram filter type.

::

    [language=C++]
    typedef HistogramFilterType::HistogramSizeType   HistogramSizeType;

    HistogramSizeType size( 2 );

    size[0] = 255;   number of bins for the first  channel
    size[1] = 255;   number of bins for the second channel

    histogramFilter->SetHistogramSize( size );

Finally, we must specify the upper and lower bounds for the histogram
using the {SetHistogramBinMinimum()} and {SetHistogramBinMaximum()}
methods. The {Update()} method is then called in order to trigger the
computation of the histogram.

::

    [language=C++]
    typedef HistogramFilterType::HistogramMeasurementVectorType
    HistogramMeasurementVectorType;

    HistogramMeasurementVectorType binMinimum( 3 );
    HistogramMeasurementVectorType binMaximum( 3 );

    binMinimum[0] = -0.5;
    binMinimum[1] = -0.5;
    binMinimum[2] = -0.5;

    binMaximum[0] = 255.5;
    binMaximum[1] = 255.5;
    binMaximum[2] = 255.5;

    histogramFilter->SetHistogramBinMinimum( binMinimum );
    histogramFilter->SetHistogramBinMaximum( binMaximum );

    histogramFilter->Update();

The histogram can be recovered from the filter by creating a variable
with the histogram type taken from the filter traits.

::

    [language=C++]
    typedef HistogramFilterType::HistogramType  HistogramType;

    const HistogramType * histogram = histogramFilter->GetOutput();

We now walk over all the bins of the joint histogram and compute their
contribution to the value of the joint Entropy. For this purpose we use
histogram iterators, and the {Begin()} and {End()} methods. Since the
values returned from the histogram are measuring frequency we must
convert them to an estimation of probability by dividing them over the
total sum of frequencies returned by the {GetTotalFrequency()} method.

::

    [language=C++]
    HistogramType::ConstIterator itr = histogram->Begin();
    HistogramType::ConstIterator end = histogram->End();

    const double Sum = histogram->GetTotalFrequency();

We initialize to zero the variable to use for accumulating the value of
the joint entropy, and then use the iterator for visiting all the bins
of the joint histogram. For every bin we compute their contribution to
the reduction of uncertainty. Note that in order to avoid logarithmic
operations on zero values, we skip over those bins that have less than
one count. The entropy contribution must be computed using logarithms in
base two in order to be able express entropy in **bits**.

::

    [language=C++]
    double JointEntropy = 0.0;

    while( itr != end )
    {
    const double count = itr.GetFrequency();
    if( count > 0.0 )
    {
    const double probability = count / Sum;
    JointEntropy += - probability * vcl_log( probability ) / vcl_log( 2.0 );
    }
    ++itr;
    }

Now that we have the value of the joint entropy we can proceed to
estimate the values of the entropies for each image independently. This
can be done by simply changing the number of bins and then recomputing
the histogram.

::

    [language=C++]
    size[0] = 255;   number of bins for the first  channel
    size[1] =   1;   number of bins for the second channel

    histogramFilter->SetHistogramSize( size );
    histogramFilter->Update();

We initialize to zero another variable in order to start accumulating
the entropy contributions from every bin.

::

    [language=C++]
    itr = histogram->Begin();
    end = histogram->End();

    double Entropy1 = 0.0;

    while( itr != end )
    {
    const double count = itr.GetFrequency();
    if( count > 0.0 )
    {
    const double probability = count / Sum;
    Entropy1 += - probability * vcl_log( probability ) / vcl_log( 2.0 );
    }
    ++itr;
    }

The same process is used for computing the entropy of the other
component. Simply by swapping the number of bins in the histogram.

::

    [language=C++]
    size[0] =   1;   number of bins for the first channel
    size[1] = 255;   number of bins for the second channel

    histogramFilter->SetHistogramSize( size );
    histogramFilter->Update();

The entropy is computed in a similar manner, just by visiting all the
bins on the histogram and accumulating their entropy contributions.

::

    [language=C++]
    itr = histogram->Begin();
    end = histogram->End();

    double Entropy2 = 0.0;

    while( itr != end )
    {
    const double count = itr.GetFrequency();
    if( count > 0.0 )
    {
    const double probability = count / Sum;
    Entropy2 += - probability * vcl_log( probability ) / vcl_log( 2.0 );
    }
    ++itr;
    }

At this point we can compute any of the popular measures of Mutual
Information. For example

::

    [language=C++]
    double MutualInformation = Entropy1 + Entropy2 - JointEntropy;

or Normalized Mutual Information, where the value of Mutual Information
gets divided by the mean entropy of the input images.

::

    [language=C++]
    double NormalizedMutualInformation1 =
    2.0 * MutualInformation / ( Entropy1 + Entropy2 );

A second form of Normalized Mutual Information has been defined as the
mean entropy of the two images divided by their joint entropy.

::

    [language=C++]
    double NormalizedMutualInformation2 = ( Entropy1 + Entropy2 ) / JointEntropy;

You probably will find very interesting how the value of Mutual
Information is strongly dependent on the number of bins over which the
histogram is defined.
