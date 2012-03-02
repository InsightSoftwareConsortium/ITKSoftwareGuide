The source code for this section can be found in the file
``ImageHistogram4.cxx``.

The statistics framework in ITK has been designed for managing
multi-variate statistics in a natural way. The {Statistics} {Histogram}
class reflects this concept clearly since it is a N-variable joint
histogram. This nature of the Histogram class is exploited in the
following example in order to build the joint histogram of a color image
encoded in RGB values.

Note that the same treatment could be applied further to any vector
image thanks to the generic programming approach used in the
implementation of the statistical framework.

The most relevant class in this example is the {Statistics}
{ImageToHistogramFilter}. This class will take care of adapting the
{Image} to a list of samples and then to a histogram filter. The user is
only bound to provide the desired resolution on the histogram bins for
each one of the image components.

In this example we compute the joint histogram of the three channels of
an RGB image. Our output histogram will be equivalent to a 3D array of
bins. This histogram could be used further for feeding a segmentation
method based on statistical pattern recognition. Such method was
actually used during the generation of the image in the cover of the
Software Guide.

The first step is to include the header files for the histogram filter,
the RGB pixel type and the Image.

::

    [language=C++]
    #include "itkImageToHistogramFilter.h"
    #include "itkImage.h"
    #include "itkRGBPixel.h"

We declare now the type used for the components of the RGB pixel,
instantiate the type of the RGBPixel and instantiate the image type.

::

    [language=C++]
    typedef unsigned char                         PixelComponentType;

    typedef itk::RGBPixel< PixelComponentType >   RGBPixelType;

    const unsigned int                            Dimension = 2;

    typedef itk::Image< RGBPixelType, Dimension > RGBImageType;

Using the type of the color image, and in general of any vector image,
we can now instantiate the type of the histogram filter class. We then
use that type for constructing an instance of the filter by invoking its
{New()} method and assigning the result to a smart pointer.

::

    [language=C++]
    typedef itk::Statistics::ImageToHistogramFilter<
    RGBImageType >   HistogramFilterType;

    HistogramFilterType::Pointer histogramFilter =
    HistogramFilterType::New();

The resolution at which the statistics of each one of the color
component will be evaluated is defined by setting the number of bins
along every component in the joint histogram. For this purpose we take
the {HistogramSizeType} trait from the filter and use it to instantiate
a {size} variable. We set in this variable the number of bins to use for
each component of the color image.

::

    [language=C++]
    typedef HistogramFilterType::HistogramSizeType   SizeType;

    SizeType size(3);

    size[0] = 256;   number of bins for the Red   channel
    size[1] = 256;   number of bins for the Green channel
    size[2] = 256;   number of bins for the Blue  channel

    histogramFilter->SetHistogramSize( size );

Finally, we must specify the upper and lower bounds for the histogram
using the {SetHistogramBinMinimum()} and {SetHistogramBinMaximum()}
methods.

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

The input to the histogram filter is taken from the output of an image
reader. Of course, the output of any filter producing an RGB image could
have been used instead of a reader.

::

    [language=C++]
    histogramFilter->SetInput(  reader->GetOutput()  );

The marginal scale is defined in the histogram filter. This value will
define the precision in the assignment of values to the histogram bins.

::

    [language=C++]
    histogramFilter->SetMarginalScale( 10.0 );

Finally, the computation of the histogram is triggered by invoking the
{Update()} method of the filter.

::

    [language=C++]
    histogramFilter->Update();

At this point, we can recover the histogram by calling the {GetOutput()}
method of the filter. The result is assigned to a variable that is
instantiated using the {HistogramType} trait of the filter type.

::

    [language=C++]
    typedef HistogramFilterType::HistogramType  HistogramType;

    const HistogramType * histogram = histogramFilter->GetOutput();

We can verify that the computed histogram has the requested size by
invoking its {Size()} method.

::

    [language=C++]
    const unsigned int histogramSize = histogram->Size();

    std::cout << "Histogram size " << histogramSize << std::endl;

The values of the histogram can now be saved into a file by walking
through all of the histogram bins and pushing them into a std::ofstream.

::

    [language=C++]
    std::ofstream histogramFile;
    histogramFile.open( argv[2] );

    HistogramType::ConstIterator itr = histogram->Begin();
    HistogramType::ConstIterator end = histogram->End();

    typedef HistogramType::AbsoluteFrequencyType AbsoluteFrequencyType;

    while( itr != end )
    {
    const AbsoluteFrequencyType frequency = itr.GetFrequency();
    histogramFile.write( (const char *)(&frequency), sizeof(frequency) );

    if (frequency != 0)
    {
    HistogramType::IndexType index;
    index = histogram->GetIndex(itr.GetInstanceIdentifier());
    std::cout << "Index = " << index << ", Frequency = " << frequency << std::endl;
    }
    ++itr;
    }

    histogramFile.close();

Note that here the histogram is saved as a block of memory in a raw
file. At this point you can use visualization software in order to
explore the histogram in a display that would be equivalent to a scatter
plot of the RGB components of the input color image.
