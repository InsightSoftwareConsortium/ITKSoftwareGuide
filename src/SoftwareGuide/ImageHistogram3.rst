The source code for this section can be found in the file
``ImageHistogram3.cxx``.

By now, you are probably thinking that the statistics framework in ITK
is too complex for simply computing histograms from images. Here we
illustrate that the benefit for this complexity is the power that these
methods provide for dealing with more complex and realistic uses of
image statistics than the trivial 256-bin histogram of 8-bit images that
most software packages provide. One of such cases is the computation of
histograms from multi-component images such as Vector images and color
images.

This example shows how to compute the histogram of an RGB image by using
the helper class {ImageToHistogramFilter}. In this first example we
compute the histogram of each channel independently.

We start by including the header of the {Statistics}
{ImageToHistogramFilter}, as well as the headers for the image class and
the RGBPixel class.

::

    [language=C++]
    #include "itkImageToHistogramFilter.h"
    #include "itkImage.h"
    #include "itkRGBPixel.h"

The type of the RGB image is defined by first instantiating a RGBPixel
and then using the image dimension specification.

::

    [language=C++]
    typedef unsigned char                         PixelComponentType;

    typedef itk::RGBPixel< PixelComponentType >   RGBPixelType;

    const unsigned int                            Dimension = 2;

    typedef itk::Image< RGBPixelType, Dimension > RGBImageType;

Using the RGB image type we can instantiate the type of the
corresponding histogram filter and construct one filter by invoking its
{New()} method.

::

    [language=C++]
    typedef itk::Statistics::ImageToHistogramFilter<
    RGBImageType >   HistogramFilterType;

    HistogramFilterType::Pointer histogramFilter =
    HistogramFilterType::New();

The parameters of the histogram must be defined now. Probably the most
important one is the arrangement of histogram bins. This is provided to
the histogram through a size array. The type of the array can be taken
from the traits of the {HistogramFilterType} type. We create one
instance of the size object and fill in its content. In this particular
case, the three components of the size array will correspond to the
number of bins used for each one of the RGB components in the color
image. The following lines show how to define a histogram on the red
component of the image while disregarding the green and blue components.

::

    [language=C++]
    typedef HistogramFilterType::HistogramSizeType   SizeType;

    SizeType size( 3 );

    size[0] = 255;         number of bins for the Red   channel
    size[1] =   1;         number of bins for the Green channel
    size[2] =   1;         number of bins for the Blue  channel

    histogramFilter->SetHistogramSize( size );

The marginal scale must be defined in the filter. This will determine
the precision in the assignment of values to the histogram bins.

::

    [language=C++]
    histogramFilter->SetMarginalScale( 10.0 );

Finally, we must specify the upper and lower bounds for the histogram.
This can either be done manually using the {SetHistogramBinMinimum()}
and {SetHistogramBinMaximum()} methods or it can be done automatically
by calling {SetHistogramAutoMinimumMaximum( true )}. Here we use the
manual method.

::

    [language=C++]
    HistogramFilterType::HistogramMeasurementVectorType lowerBound( 3 );
    HistogramFilterType::HistogramMeasurementVectorType upperBound( 3 );

    lowerBound[0] = 0;
    lowerBound[1] = 0;
    lowerBound[2] = 0;
    upperBound[0] = 256;
    upperBound[1] = 256;
    upperBound[2] = 256;

    histogramFilter->SetHistogramBinMinimum( lowerBound );
    histogramFilter->SetHistogramBinMaximum( upperBound );

The input of the filter is taken from an image reader, and the
computation of the histogram is triggered by invoking the {Update()}
method of the filter.

::

    [language=C++]
    histogramFilter->SetInput(  reader->GetOutput()  );

    histogramFilter->Update();

We can now access the results of the histogram computation by declaring
a pointer to histogram and getting its value from the filter using the
{GetOutput()} method. Note that here we use a {const HistogramType}
pointer instead of a const smart pointer because we are sure that the
filter is not going to be destroyed while we access the values of the
histogram. Depending on what you are doing, it may be safer to assign
the histogram to a const smart pointer as shown in previous examples.

::

    [language=C++]
    typedef HistogramFilterType::HistogramType  HistogramType;

    const HistogramType * histogram = histogramFilter->GetOutput();

Just for the sake of exercising the experimental method , we verify that
the resulting histogram actually have the size that we requested when we
configured the filter. This can be done by invoking the {Size()} method
of the histogram and printing out the result.

::

    [language=C++]
    const unsigned int histogramSize = histogram->Size();

    std::cout << "Histogram size " << histogramSize << std::endl;

Strictly speaking, the histogram computed here is the joint histogram of
the three RGB components. However, given that we set the resolution of
the green and blue channels to be just one bin, the histogram is in
practice representing just the red channel. In the general case, we can
alway access the frequency of a particular channel in a joint histogram,
thanks to the fact that the histogram class offers a {GetFrequency()}
method that accepts a channel as argument. This is illustrated in the
following lines of code.

::

    [language=C++]
    unsigned int channel = 0;   red channel

    std::cout << "Histogram of the red component" << std::endl;

    for( unsigned int bin=0; bin < histogramSize; bin++ )
    {
    std::cout << "bin = " << bin << " frequency = ";
    std::cout << histogram->GetFrequency( bin, channel ) << std::endl;
    }

In order to reinforce the concepts presented above, we modify now the
setup of the histogram filter in order to compute the histogram of the
green channel instead of the red one. This is done by simply changing
the number of bins desired on each channel and invoking the computation
of the filter again by calling the {Update()} method.

::

    [language=C++]
    size[0] =   1;   number of bins for the Red   channel
    size[1] = 255;   number of bins for the Green channel
    size[2] =   1;   number of bins for the Blue  channel

    histogramFilter->SetHistogramSize( size );

    histogramFilter->Update();

The result can be verified now by setting the desired channel to green
and invoking the {GetFrequency()} method.

::

    [language=C++]
    channel = 1;   green channel

    std::cout << "Histogram of the green component" << std::endl;

    for( unsigned int bin=0; bin < histogramSize; bin++ )
    {
    std::cout << "bin = " << bin << " frequency = ";
    std::cout << histogram->GetFrequency( bin, channel ) << std::endl;
    }

To finalize the example, we do the same computation for the case of the
blue channel.

::

    [language=C++]
    size[0] =   1;   number of bins for the Red   channel
    size[1] =   1;   number of bins for the Green channel
    size[2] = 255;   number of bins for the Blue  channel

    histogramFilter->SetHistogramSize( size );

    histogramFilter->Update();

and verify the output.

::

    [language=C++]
    channel = 2;   blue channel

    std::cout << "Histogram of the blue component" << std::endl;

    for( unsigned int bin=0; bin < histogramSize; bin++ )
    {
    std::cout << "bin = " << bin << " frequency = ";
    std::cout << histogram->GetFrequency( bin, channel ) << std::endl;
    }

