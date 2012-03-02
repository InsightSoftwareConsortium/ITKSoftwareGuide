.. _sec-IntensityLinearMapping:

Linear Mappings
~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``CastingImageFilters.cxx``.

Due to the use of `Generic
Programming <http:www.boost.org/more/generic_programming.html>`_ in the
toolkit, most types are resolved at compile-time. Few decisions
regarding type conversion are left to run-time. It is up to the user to
anticipate the pixel type-conversions required in the data pipeline. In
medical imaging applications it is usually not desirable to use a
general pixel type since this may result in the loss of valuable
information.

This section introduces the mechanisms for explicit casting of images
that flow through the pipeline. The following four filters are treated
in this section: \doxygen{CastImageFilter}, \doxygen{RescaleIntensityImageFilter},
\doxygen{ShiftScaleImageFilter} and \doxygen{NormalizeImageFilter}. These filters are
not directly related to each other except that they all modify pixel
values. They are presented together here with the purpose of comparing
their individual features.

The CastImageFilter is a very simple filter that acts pixel-wise on an
input image, casting every pixel to the type of the output image. Note
that this filter does not perform any arithmetic operation on the
intensities. Applying CastImageFilter is equivalent to performing a
\code{C-Style} cast on every pixel.

\code{ outputPixel = static\_cast<OutputPixelType>( inputPixel ) }

The RescaleIntensityImageFilter linearly scales the pixel values in such
a way that the minimum and maximum values of the input are mapped to
minimum and maximum values provided by the user. This is a typical
process for forcing the dynamic range of the image to fit within a
particular scale and is common for image display. The linear
transformation applied by this filter can be expressed as

:math:`outputPixel = ( inputPixel - inpMin) \times
\frac{(outMax - outMin )}{(inpMax-inpMin)} + outMin `

The ShiftScaleImageFilter also applies a linear transformation to the
intensities of the input image, but the transformation is specified by
the user in the form of a multiplying factor and a value to be added.
This can be expressed as

:math:`outputPixel = \left( inputPixel  + Shift \right) \times Scale`.

The parameters of the linear transformation applied by the
NormalizeImageFilter are computed internally such that the statistical
distribution of gray levels in the output image have zero mean and a
variance of one. This intensity correction is particularly useful in
registration applications as a preprocessing step to the evaluation of
mutual information metrics. The linear transformation of
NormalizeImageFilter is given as

:math:`outputPixel = \frac{( inputPixel - mean )}{ \sqrt{ variance } } `

.. index::
   single: 'Casting Images'
   single: CastImageFilter
   single: RescaleIntensityImageFilter
   single: ShiftScaleImageFilter
   single: NormalizeImageFilter

As usual, the first step required to use these filters is to include
their header files.

::

    [language=C++]
    #include "itkCastImageFilter.h"
    #include "itkRescaleIntensityImageFilter.h"
    #include "itkNormalizeImageFilter.h"

Let’s define pixel types for the input and output images.

::

    [language=C++]
    typedef   unsigned char    InputPixelType;
    typedef   float            OutputPixelType;

Then, the input and output image types are defined.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  3 >   InputImageType;
    typedef itk::Image< OutputPixelType, 3 >   OutputImageType;

The filters are instantiated using the defined image types.

::

    [language=C++]
    typedef itk::CastImageFilter<
    InputImageType, OutputImageType >  CastFilterType;

    typedef itk::RescaleIntensityImageFilter<
    InputImageType, OutputImageType >  RescaleFilterType;

    typedef itk::ShiftScaleImageFilter<
    InputImageType, OutputImageType >  ShiftScaleFilterType;

    typedef itk::NormalizeImageFilter<
    InputImageType, OutputImageType >  NormalizeFilterType;

Object filters are created by invoking the {New()} operator and
assigning the result to {SmartPointer}s.

::

    [language=C++]
    CastFilterType::Pointer       castFilter       = CastFilterType::New();
    RescaleFilterType::Pointer    rescaleFilter    = RescaleFilterType::New();
    ShiftScaleFilterType::Pointer shiftFilter      = ShiftScaleFilterType::New();
    NormalizeFilterType::Pointer  normalizeFilter = NormalizeFilterType::New();

The output of a reader filter (whose creation is not shown here) is now
connected as input to the various casting filters.

::

    [language=C++]
    castFilter->SetInput(       reader->GetOutput() );
    shiftFilter->SetInput(      reader->GetOutput() );
    rescaleFilter->SetInput(    reader->GetOutput() );
    normalizeFilter->SetInput( reader->GetOutput() );

Next we proceed to setup the parameters required by each filter. The
CastImageFilter and the NormalizeImageFilter do not require any
parameters. The RescaleIntensityImageFilter, on the other hand, requires
the user to provide the desired minimum and maximum pixel values of the
output image. This is done by using the \code{SetOutputMinimum()} and
\code{SetOutputMaximum()} methods as illustrated below.

::

    [language=C++]
    rescaleFilter->SetOutputMinimum(  10 );
    rescaleFilter->SetOutputMaximum( 250 );

The ShiftScaleImageFilter requires a multiplication factor (scale) and a
post-scaling additive value (shift). The methods \code{SetScale()} and
\code{SetShift()} are used, respectively, to set these values.

::

    [language=C++]
    shiftFilter->SetScale( 1.2 );
    shiftFilter->SetShift( 25 );

Finally, the filters are executed by invoking the \code{Update()} method.

.. index
   pair: ShiftScaleImageFilter; Update
   pair: RescaleIntensityImageFilter; Update
   pair: NormalizeImageFilter; Update
   pair: CastImageFilter; Update

::

    [language=C++]
    castFilter->Update();
    shiftFilter->Update();
    rescaleFilter->Update();
    normalizeFilter->Update();

