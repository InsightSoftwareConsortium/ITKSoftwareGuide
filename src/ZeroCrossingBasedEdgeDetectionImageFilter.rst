The source code for this section can be found in the file
``ZeroCrossingBasedEdgeDetectionImageFilter.cxx``.

The {ZeroCrossingBasedEdgeDetectionImageFilter} performs edge detection
by combining a sequence of Gaussian smoothing, Laplacian filter, and
Zero cross detections on the Laplacian.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkZeroCrossingBasedEdgeDetectionImageFilter.h"

::

    [language=C++]
    typedef   double  InputPixelType;
    typedef   double  OutputPixelType;
    typedef unsigned char    CharPixelType;

    const unsigned int Dimension = 2;

    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;
    typedef itk::Image< CharPixelType, Dimension >     CharImageType;

The filter requires two parameters. First the value of the variance to
be used by the Gaussian smoothing stage. This value is provided in the
method {SetVariance} and it is given in pixel units. Second the filter
expects the acceptable error for computing the approximation to the
Gaussian kernel. This error is expected to be in the range between 0 and
1. Values outside that range will result in Exceptions being thrown.

::

    [language=C++]
    filter->SetVariance( atof( argv[3] ) );
    filter->SetMaximumError( atof( argv[4] ) );

As with most filters, we connect the input and output of this filter in
order to create a pipeline. In this particular case the input is taken
from a reader and the output is sent to a writer. Given that the zero
crossing filter is producing a float image as output, we use a
{RescaleIntensityImageFilter} to convert this image to an eight bits
image before sending it to the writer.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );

