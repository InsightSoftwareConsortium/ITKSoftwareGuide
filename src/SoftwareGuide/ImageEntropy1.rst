The source code for this section can be found in the file
``ImageEntropy1.cxx``.

This example shows how to compute the entropy of an image. More formally
this should be said : The reduction in uncertainty gained when we
measure the intensity of *one* randomly selected pixel in this image,
given that we already know the statistical distribution of the image
intensity values.

In practice it is almost never possible to know the real statistical
distribution of intensities and we are force to estimate it from the
evaluation of the histogram from one or several images of similar
nature. We can use the counts in histogram bins in order to compute
frequencies and then consider those frequencies to be estimations of the
probablility of a new value to belong to the intensity range of that
bin.

Since the first stage in estimating the entropy of an image is to
compute its histogram, we must start by including the headers of the
classes that will perform such computation. In this case, we are going
to use a scalar image as input, therefore we need the {Statistics}
{ScalarImageToHistogramGenerator} class, as well as the image class.

::

    [language=C++]
    #include "itkScalarImageToHistogramGenerator.h"
    #include "itkImage.h"

The pixel type and dimension of the image are explicitly declared and
then used for instantiating the image type.

::

    [language=C++]
    typedef unsigned char       PixelType;
    const   unsigned int        Dimension = 3;

    typedef itk::Image< PixelType, Dimension > ImageType;

The image type is used as template parameter for instantiating the
histogram generator.

::

    [language=C++]
    typedef itk::Statistics::ScalarImageToHistogramGenerator<
    ImageType >   HistogramGeneratorType;

    HistogramGeneratorType::Pointer histogramGenerator =
    HistogramGeneratorType::New();

The parameters of the desired histogram are defined. In particular, the
number of bins and the marginal scale. For convenience in this example,
we read the number of bins from the command line arguments. In this way
we can easily experiment with different values for the number of bins
and see how that choice affects the computation of the entropy.

::

    [language=C++]
    const unsigned int numberOfHistogramBins = atoi( argv[2] );

    histogramGenerator->SetNumberOfBins( numberOfHistogramBins );
    histogramGenerator->SetMarginalScale( 10.0 );

We can then connect as input the output image from a reader and trigger
the histogram computation by invoking the {Compute()} method in the
generator.

::

    [language=C++]
    histogramGenerator->SetInput(  reader->GetOutput() );

    histogramGenerator->Compute();

The resulting histogram can be recovered from the generator by using the
{GetOutput()} method. A histogram class can be declared using the
{HistogramType} trait from the generator.

::

    [language=C++]
    typedef HistogramGeneratorType::HistogramType  HistogramType;

    const HistogramType * histogram = histogramGenerator->GetOutput();

We proceed now to compute the *estimation* of entropy given the
histogram. The first conceptual jump to be done here is that we assume
that the histogram, which is the simple count of frequency of occurrence
for the gray scale values of the image pixels, can be normalized in
order to estimate the probability density function **PDF** of the actual
statistical distribution of pixel values.

First we declare an iterator that will visit all the bins in the
histogram. Then we obtain the total number of counts using the
{GetTotalFrequency()} method, and we initialize the entropy variable to
zero.

::

    [language=C++]
    HistogramType::ConstIterator itr = histogram->Begin();
    HistogramType::ConstIterator end = histogram->End();

    double Sum = histogram->GetTotalFrequency();

    double Entropy = 0.0;

We start now visiting every bin and estimating the probability of a
pixel to have a value in the range of that bin. The base 2 logarithm of
that probability is computed, and then weighted by the probability in
order to compute the expected amount of information for any given pixel.
Note that a minimum value is imposed for the probability in order to
avoid computing logarithms of zeros.

Note that the :math:`\log{(2)}` factor is used to convert the natural
logarithm in to a logarithm of base 2, and make possible to report the
entropy in its natural unit: the bit.

::

    [language=C++]
    while( itr != end )
    {
    const double probability = itr.GetFrequency() / Sum;

    if( probability > 0.99 / Sum )
    {
    Entropy += - probability * vcl_log( probability ) / vcl_log( 2.0 );
    }
    ++itr;
    }

The result of this sum is considered to be our estimation of the image
entropy. Note that the Entrpy value will change depending on the number
of histogram bins that we use for computing the histogram. This is
particularly important when dealing with images whose pixel values have
dynamic ranges so large that our number of bins will always
underestimate the variability of the data.

::

    [language=C++]
    std::cout << "Image entropy = " << Entropy << " bits " << std::endl;

As an illustration, the application of this program to the image

-  {Examples/Data/BrainProtonDensitySlice.png}

results in the following values of entropy for different values of
number of histogram bins.

        Number of Histogram Bins & 16 & 32 & 64 & 128 & 255 Estimated
        Entropy (bits) & 3.02 & 3.98 & 4.92 & 5.89 & 6.88

This table highlights the importance of carefully considering the
characteristics of the histograms used for estimating Information Theory
measures such as the entropy.
