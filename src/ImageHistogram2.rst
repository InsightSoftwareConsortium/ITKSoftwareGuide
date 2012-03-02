The source code for this section can be found in the file
``ImageHistogram2.cxx``.

From the previous example you will have noticed that there is a
significant number of operations to perform to compute the simple
histogram of a scalar image. Given that this is a relatively common
operation, it is convenient to encapsulate many of these operations in a
single helper class.

The {Statistics} {ScalarImageToHistogramGenerator} is the result of such
encapsulation. This example illustrates how to compute the histogram of
a scalar image using this helper class.

We should first include the header of the histogram generator and the
image class.

::

    [language=C++]
    #include "itkScalarImageToHistogramGenerator.h"
    #include "itkImage.h"

The image type must be defined using the typical pair of pixel type and
dimension specification.

::

    [language=C++]
    typedef unsigned char       PixelType;
    const unsigned int          Dimension = 2;

    typedef itk::Image<PixelType, Dimension > ImageType;

We use now the image type in order to instantiate the type of the
corresponding histogram generator class, and invoke its {New()} method
in order to construct one.

::

    [language=C++]
    typedef itk::Statistics::ScalarImageToHistogramGenerator<
    ImageType >   HistogramGeneratorType;

    HistogramGeneratorType::Pointer histogramGenerator =
    HistogramGeneratorType::New();

The image to be passed as input to the histogram generator is taken in
this case from the output of an image reader.

::

    [language=C++]
    histogramGenerator->SetInput(  reader->GetOutput() );

We define also the typical parameters that specify the characteristics
of the histogram to be computed.

::

    [language=C++]
    histogramGenerator->SetNumberOfBins( 256 );
    histogramGenerator->SetMarginalScale( 10.0 );

    histogramGenerator->SetHistogramMin(  -0.5 );
    histogramGenerator->SetHistogramMax( 255.5 );

Finally we trigger the computation of the histogram by invoking the
{Compute()} method of the generator. Note again, that a generator is not
a pipeline object and therefore it is up to you to make sure that the
filters providing the input image have been updated.

::

    [language=C++]
    histogramGenerator->Compute();

The resulting histogram can be obtained from the generator by invoking
its {GetOutput()} method. It is also convenient to get the Histogram
type from the traits of the generator type itself as shown in the code
below.

::

    [language=C++]
    typedef HistogramGeneratorType::HistogramType  HistogramType;

    const HistogramType * histogram = histogramGenerator->GetOutput();

In this case we simply print out the frequency values of the histogram.
These values can be accessed by using iterators.

::

    [language=C++]
    HistogramType::ConstIterator itr = histogram->Begin();
    HistogramType::ConstIterator end = histogram->End();

    unsigned int binNumber = 0;
    while( itr != end )
    {
    std::cout << "bin = " << binNumber << " frequency = ";
    std::cout << itr.GetFrequency() << std::endl;
    ++itr;
    ++binNumber;
    }

