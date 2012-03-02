The source code for this section can be found in the file
``BinaryThresholdImageFilter.cxx``.

    |image| [BinaryThresholdImageFilter transfer function] {Transfer
    function of the BinaryThresholdImageFilter.
    {fig:BinaryThresholdTransferFunction}}

This example illustrates the use of the binary threshold image filter.
This filter is used to transform an image into a binary image by
changing the pixel values according to the rule illustrated in
Figure \ref{fig:BinaryThresholdTransferFunction}. The user defines two
thresholds—Upper and Lower—and two intensity values—Inside and Outside.
For each pixel in the input image, the value of the pixel is compared
with the lower and upper thresholds. If the pixel value is inside the
range defined by :math:`[Lower,Upper]` the output pixel is assigned
the InsideValue. Otherwise the output pixels are assigned to the
OutsideValue. Thresholding is commonly applied as the last operation of
a segmentation pipeline.

.. index::
   single: BinaryThresholdImageFilter

The first step required to use the \doxygen{BinaryThresholdImageFilter} is to
include its header file.

::

    [language=C++]
    #include "itkBinaryThresholdImageFilter.h"

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
    typedef itk::BinaryThresholdImageFilter<
    InputImageType, OutputImageType >  FilterType;

An \doxygen{ImageFileReader} class is also instantiated in order to read image
data from a file. (See Section \ref{sec:IO} on page \ref{sec:IO} for more
information about reading and writing data.)

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType >  ReaderType;

An \doxygen{ImageFileWriter} is instantiated in order to write the output image
to a file.

::

    [language=C++]
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

Both the filter and the reader are created by invoking their \code{New()}
methods and assigning the result to \code{SmartPointer}s.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    FilterType::Pointer filter = FilterType::New();

The image obtained with the reader is passed as input to the
BinaryThresholdImageFilter.

.. index::
   pair: BinaryThresholdImageFilter; SetInput
   pair: ImageFileReader; GetOutput

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The method \code{SetOutsideValue()} defines the intensity value to be
assigned to those pixels whose intensities are outside the range defined
by the lower and upper thresholds. The method \code{SetInsideValue()} defines
the intensity value to be assigned to pixels with intensities falling
inside the threshold range.

::

    [language=C++]
    filter->SetOutsideValue( outsideValue );
    filter->SetInsideValue(  insideValue  );

The methods \code{SetLowerThreshold()} and \code{SetUpperThreshold()} define the
range of the input image intensities that will be transformed into the
\code{InsideValue}. Note that the lower and upper thresholds are values of
the type of the input image pixels, while the inside and outside values
are of the type of the output image pixels.

::

    [language=C++]
    filter->SetLowerThreshold( lowerThreshold );
    filter->SetUpperThreshold( upperThreshold );

The execution of the filter is triggered by invoking the \code{Update()}
method. If the filter’s output has been passed as input to subsequent
filters, the \code{Update()} call on any posterior filters in the pipeline
will indirectly trigger the update of this filter.

::

    [language=C++]
    filter->Update();

    |image1| |image2| [BinaryThresholdImageFilter output] {Effect of the
    BinaryThresholdImageFilter on a slice from a MRI proton density
    image of the brain.} {fig:BinaryThresholdImageFilterInputOutput}

Figure \ref{fig:BinaryThresholdImageFilterInputOutput} illustrates the
effect of this filter on a MRI proton density image of the brain. This
figure shows the limitations of this filter for performing segmentation
by itself. These limitations are particularly noticeable in noisy images
and in images lacking spatial uniformity as is the case with MRI due to
field bias.

\relatedClasses
- \doxygen{ThresholdImageFilter}

.. |image| image:: BinaryThresholdTransferFunction.eps
.. |image1| image:: BrainProtonDensitySlice.eps
.. |image2| image:: BinaryThresholdImageFilterOutput.eps
