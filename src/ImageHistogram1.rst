The source code for this section can be found in the file
``ImageHistogram1.cxx``.

This example shows how to compute the histogram of a scalar image. Since
the statistics framework classes operate on Samples and ListOfSamples,
we need to introduce a class that will make the image look like a list
of samples. This class is the {Statistics} {ImageToListSampleAdaptor}.
Once we have connected this adaptor to an image, we can proceed to use
the {Statistics} {SampleToHistogramFilter} in order to compute the
histogram of the image.

First, we need to include the headers for the {Statistics}
{ImageToListSampleAdaptor} and the {Image} classes.

::

    [language=C++]
    #include "itkImageToListSampleAdaptor.h"
    #include "itkImage.h"

Now we include the headers for the {Histogram}, the
{SampleToHistogramFilter}, and the reader that we will use for reading
the image from a file.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkHistogram.h"
    #include "itkSampleToHistogramFilter.h"

The image type must be defined using the typical pair of pixel type and
dimension specification.

::

    [language=C++]
    typedef unsigned char       PixelType;
    const unsigned int          Dimension = 2;

    typedef itk::Image<PixelType, Dimension > ImageType;

Using the same image type we instantiate the type of the image reader
that will provide the image source for our example.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType > ReaderType;

    ReaderType::Pointer reader = ReaderType::New();

    reader->SetFileName( argv[1] );

Now we introduce the central piece of this example, which is the use of
the adaptor that will present the {Image} as if it was a list of
samples. We instantiate the type of the adaptor by using the actual
image type. Then construct the adaptor by invoking its {New()} method
and assigning the result to the corresponding smart pointer. Finally we
connect the output of the image reader to the input of the adaptor.

::

    [language=C++]
    typedef itk::Statistics::ImageToListSampleAdaptor< ImageType >   AdaptorType;

    AdaptorType::Pointer adaptor = AdaptorType::New();

    adaptor->SetImage(  reader->GetOutput() );

You must keep in mind that adaptors are not pipeline objects. This means
that they do not propagate update calls. It is therefore your
responsibility to make sure that you invoke the {Update()} method of the
reader before you attempt to use the output of the adaptor. As usual,
this must be done inside a try/catch block because the read operation
can potentially throw exceptions.

::

    [language=C++]
    try
    {
    reader->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Problem reading image file : " << argv[1] << std::endl;
    std::cerr << excp << std::endl;
    return -1;
    }

At this point, we are ready for instantiating the type of the histogram
filter. We must first declare the type of histogram we wish to use. The
adaptor type is also used as template parameter of the filter. Having
instantiated this type, we proceed to create one filter by invoking its
{New()} method.

::

    [language=C++]
    typedef PixelType HistogramMeasurementType;
    typedef itk::Statistics::Histogram< HistogramMeasurementType >
    HistogramType;
    typedef itk::Statistics::SampleToHistogramFilter<
    AdaptorType,
    HistogramType>
    FilterType;

    FilterType::Pointer filter = FilterType::New();

We define now the characteristics of the Histogram that we want to
compute. This typically includes the size of each one of the component,
but given that in this simple example we are dealing with a scalar
image, then our histogram will have a single component. For the sake of
generality, however, we use the {HistogramType} as defined inside of the
Generator type. We define also the marginal scale factor that will
control the precision used when assigning values to histogram bins.
Finally we invoke the {Update()} method in the filter.

::

    [language=C++]
    const unsigned int numberOfComponents = 1;
    HistogramType::SizeType size( numberOfComponents );
    size.Fill( 255 );

    filter->SetInput( adaptor );
    filter->SetHistogramSize( size );
    filter->SetMarginalScale( 10 );

    HistogramType::MeasurementVectorType min( numberOfComponents );
    HistogramType::MeasurementVectorType max( numberOfComponents );

    min.Fill( 0 );
    max.Fill( 255 );

    filter->SetHistogramBinMinimum( min );
    filter->SetHistogramBinMaximum( max );

    filter->Update();

Now we are ready for using the image histogram for any further
processing. The histogram is obtained from the filter by invoking the
{GetOutput()} method.

::

    [language=C++]
    HistogramType::ConstPointer histogram = filter->GetOutput();

In this current example we simply print out the frequency values of all
the bins in the image histogram.

::

    [language=C++]
    const unsigned int histogramSize = histogram->Size();

    std::cout << "Histogram size " << histogramSize << std::endl;

    for( unsigned int bin=0; bin < histogramSize; bin++ )
    {
    std::cout << "bin = " << bin << " frequency = ";
    std::cout << histogram->GetFrequency( bin, 0 ) <<std::endl;
    }

