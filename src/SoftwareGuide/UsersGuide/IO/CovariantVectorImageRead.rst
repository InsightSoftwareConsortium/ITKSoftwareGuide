The source code for this section can be found in the file
``CovariantVectorImageRead.cxx``.

This example illustrates how to read an image whose pixel type is
\doxygen{CovariantVector}. For practical purposes this example is applicable to
images of pixel type {Vector}, {Point} and {FixedArray}. These pixel
types are similar in that they are all arrays of fixed size in which the
components have the same representation type.

In this example we are reading an gradient image from a file (written in
the previous example) and computing its magnitude using the
{GradientToMagnitudeImageFilter}. Note that this filter is different
from the {GradientMagnitudeImageFilter} which actually takes a scalar
image as input and compute the magnitude of its gradient. The
GradientToMagnitudeImageFilter class takes an image of vector pixel type
as input and computes pixel-wise the magnitude of each vector.

Let’s start by including the relevant header files.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkGradientToMagnitudeImageFilter.h"
    #include "itkRescaleIntensityImageFilter.h"

We read an image of {CovariantVector} pixels and compute pixel magnitude
to produce an image where each pixel is of type {unsigned short}. The
components of the CovariantVector are selected to be {float} here.
Notice that a renormalization is required in order to map the dynamic
range of the magnitude values into the range of the output pixel type.
The {RescaleIntensityImageFilter} is used to achieve this.

::

    [language=C++]
    typedef float                 ComponentType;
    const   unsigned int          Dimension = 2;

    typedef itk::CovariantVector< ComponentType,
    Dimension  >      InputPixelType;

    typedef float                                       MagnitudePixelType;
    typedef unsigned short                              OutputPixelType;

    typedef itk::Image< InputPixelType,      Dimension >    InputImageType;
    typedef itk::Image< MagnitudePixelType,  Dimension >    MagnitudeImageType;
    typedef itk::Image< OutputPixelType,     Dimension >    OutputImageType;

The {ImageFileReader} and {ImageFileWriter} are instantiated using the
image types.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType  >  ReaderType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

The GradientToMagnitudeImageFilter is instantiated using the input and
output image types. A filter object is created with the New() method and
assigned to a {SmartPointer}.

::

    [language=C++]
    typedef itk::GradientToMagnitudeImageFilter<
    InputImageType,
    MagnitudeImageType    > FilterType;

    FilterType::Pointer filter = FilterType::New();

The RescaleIntensityImageFilter class is instantiated next.

::

    [language=C++]
    typedef itk::RescaleIntensityImageFilter<
    MagnitudeImageType,
    OutputImageType >      RescaleFilterType;

    RescaleFilterType::Pointer  rescaler = RescaleFilterType::New();

In the following the minimum and maximum values for the output image are
specified. Note the use of the {NumericTraits} class which allows to
define a number of type-related constant in a generic way. The use of
traits is a fundamental characteristic of generic programming .

::

    [language=C++]
    rescaler->SetOutputMinimum( itk::NumericTraits< OutputPixelType >::min() );
    rescaler->SetOutputMaximum( itk::NumericTraits< OutputPixelType >::max() );

Below, we create the reader and writer using the New() method and assign
the result to a SmartPointer.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

The name of the file to be read or written is passed with the
SetFileName() method.

::

    [language=C++]
    reader->SetFileName( inputFilename  );
    writer->SetFileName( outputFilename );

Below we connect the reader, filter and writer to form the data
processing pipeline.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    rescaler->SetInput( filter->GetOutput() );
    writer->SetInput( rescaler->GetOutput() );

Finally we execute the pipeline by invoking Update() on the writer. The
call is placed in a {try/catch} block in case exceptions are thrown.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

