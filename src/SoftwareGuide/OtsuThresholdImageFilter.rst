The source code for this section can be found in the file
``OtsuThresholdImageFilter.cxx``.

This example illustrates how to use the {OtsuThresholdImageFilter}.

::

    [language=C++]
    #include "itkOtsuThresholdImageFilter.h"

The next step is to decide which pixel types to use for the input and
output images.

::

    [language=C++]
    typedef  unsigned char  InputPixelType;
    typedef  unsigned char  OutputPixelType;

The input and output image types are now defined using their respective
pixel types and dimensions.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The filter type can be instantiated using the input and output image
types defined above.

::

    [language=C++]
    typedef itk::OtsuThresholdImageFilter<
    InputImageType, OutputImageType >  FilterType;

An {ImageFileReader} class is also instantiated in order to read image
data from a file. (See Section {sec:IO} on page {sec:IO} for more
information about reading and writing data.)

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType >  ReaderType;

An {ImageFileWriter} is instantiated in order to write the output image
to a file.

::

    [language=C++]
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

Both the filter and the reader are created by invoking their {New()}
methods and assigning the result to {SmartPointer}s.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    FilterType::Pointer filter = FilterType::New();

The image obtained with the reader is passed as input to the
OtsuThresholdImageFilter.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The method {SetOutsideValue()} defines the intensity value to be
assigned to those pixels whose intensities are outside the range defined
by the lower and upper thresholds. The method {SetInsideValue()} defines
the intensity value to be assigned to pixels with intensities falling
inside the threshold range.

::

    [language=C++]
    filter->SetOutsideValue( outsideValue );
    filter->SetInsideValue(  insideValue  );

The execution of the filter is triggered by invoking the {Update()}
method. If the filter’s output has been passed as input to subsequent
filters, the {Update()} call on any posterior filters in the pipeline
will indirectly trigger the update of this filter.

::

    [language=C++]
    filter->Update();

We print out here the Threshold value that was computed internally by
the filter. For this we invoke the {GetThreshold} method.

::

    [language=C++]
    int threshold = filter->GetThreshold();
    std::cout << "Threshold = " << threshold << std::endl;

    |image| |image1| [OtsuThresholdImageFilter output] {Effect of the
    OtsuThresholdImageFilter on a slice from a MRI proton density image
    of the brain.} {fig:OtsuThresholdImageFilterInputOutput}

Figure {fig:OtsuThresholdImageFilterInputOutput} illustrates the effect
of this filter on a MRI proton density image of the brain. This figure
shows the limitations of this filter for performing segmentation by
itself. These limitations are particularly noticeable in noisy images
and in images lacking spatial uniformity as is the case with MRI due to
field bias.

-  {ThresholdImageFilter}

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: OtsuThresholdImageFilterOutput.eps
