.. _sec-ThresholdingImageFilter:

General Thresholding
~~~~~~~~~~~~~~~~~~~~


The source code for this section can be found in the file
``ThresholdImageFilter.cxx``.

    |image| |image1| [ThresholdImageFilter using the threshold-below
    mode.] {ThresholdImageFilter using the threshold-below mode.}
    {fig:ThresholdTransferFunctionBelow}

    |image2| |image3| [ThresholdImageFilter using the threshold-above
    mode] {ThresholdImageFilter using the threshold-above mode.}
    {fig:ThresholdTransferFunctionAbove}

    |image4| |image5| [ThresholdImageFilter using the threshold-outside
    mode] {ThresholdImageFilter using the threshold-outside mode.}
    {fig:ThresholdTransferFunctionOutside}

This example illustrates the use of the {ThresholdImageFilter}. This
filter can be used to transform the intensity levels of an image in
three different ways.

-  First, the user can define a single threshold. Any pixels with values
   below this threshold will be replaced by a user defined value, called
   here the {OutsideValue}. Pixels with values above the threshold
   remain unchanged. This type of thresholding is illustrated in
   Figure {fig:ThresholdTransferFunctionBelow}.

-  Second, the user can define a particular threshold such that all the
   pixels with values above the threshold will be replaced by the
   {OutsideValue}. Pixels with values below the threshold remain
   unchanged. This is illustrated in
   Figure {fig:ThresholdTransferFunctionAbove}.

-  Third, the user can provide two thresholds. All the pixels with
   intensity values inside the range defined by the two thresholds will
   remain unchanged. Pixels with values outside this range will be
   assigned to the {OutsideValue}. This is illustrated in
   Figure {fig:ThresholdTransferFunctionOutside}.

The following methods choose among the three operating modes of the
filter.

-  ``ThresholdBelow()``

-  ``ThresholdAbove()``

-  ``ThresholdOutside()``

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkThresholdImageFilter.h"

Then we must decide what pixel type to use for the image. This filter is
templated over a single image type because the algorithm only modifies
pixel values outside the specified range, passing the rest through
unchanged.

::

    [language=C++]
    typedef  unsigned char  PixelType;

The image is defined using the pixel type and the dimension.

::

    [language=C++]
    typedef itk::Image< PixelType,  2 >   ImageType;

The filter can be instantiated using the image type defined above.

::

    [language=C++]
    typedef itk::ThresholdImageFilter< ImageType >  FilterType;

An {ImageFileReader} class is also instantiated in order to read image
data from a file.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >  ReaderType;

An {ImageFileWriter} is instantiated in order to write the output image
to a file.

::

    [language=C++]
    typedef itk::ImageFileWriter< ImageType >  WriterType;

Both the filter and the reader are created by invoking their {New()}
methods and assigning the result to SmartPointers.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    FilterType::Pointer filter = FilterType::New();

The image obtained with the reader is passed as input to the
{ThresholdImageFilter}.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The method {SetOutsideValue()} defines the intensity value to be
assigned to those pixels whose intensities are outside the range defined
by the lower and upper thresholds.

::

    [language=C++]
    filter->SetOutsideValue( 0 );

The method {ThresholdBelow()} defines the intensity value below which
pixels of the input image will be changed to the {OutsideValue}.

::

    [language=C++]
    filter->ThresholdBelow( 180 );

The filter is executed by invoking the {Update()} method. If the filter
is part of a larger image processing pipeline, calling {Update()} on a
downstream filter will also trigger update of this filter.

::

    [language=C++]
    filter->Update();

The output of this example is shown in
Figure {fig:ThresholdTransferFunctionBelow}. The second operating mode
of the filter is now enabled by calling the method {ThresholdAbove()}.

::

    [language=C++]
    filter->ThresholdAbove( 180 );
    filter->Update();

Updating the filter with this new setting produces the output shown in
Figure {fig:ThresholdTransferFunctionAbove}. The third operating mode of
the filter is enabled by calling {ThresholdOutside()}.

::

    [language=C++]
    filter->ThresholdOutside( 170,190 );
    filter->Update();

The output of this third, “band-pass” thresholding mode is shown in
Figure {fig:ThresholdTransferFunctionOutside}.

The examples in this section also illustrate the limitations of the
thresholding filter for performing segmentation by itself. These
limitations are particularly noticeable in noisy images and in images
lacking spatial uniformity, as is the case with MRI due to field bias.

-  {BinaryThresholdImageFilter}

.. |image| image:: ThresholdTransferFunctionBelow.eps
.. |image1| image:: ThresholdImageFilterOutputBelow.eps
.. |image2| image:: ThresholdTransferFunctionAbove.eps
.. |image3| image:: ThresholdImageFilterOutputAbove.eps
.. |image4| image:: ThresholdTransferFunctionOutside.eps
.. |image5| image:: ThresholdImageFilterOutputOutside.eps
