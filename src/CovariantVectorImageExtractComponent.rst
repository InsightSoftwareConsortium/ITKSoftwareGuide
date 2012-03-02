The source code for this section can be found in the file
``CovariantVectorImageExtractComponent.cxx``.

This example illustrates how to read an image whose pixel type is
\code{CovariantVector}, extract one of its components to form a scalar image
and finally save this image into a file.

The \doxygen{VectorIndexSelectionCastImageFilter} is used to extract a scalar
from the vector image. It is also possible to cast the component type
when using this filter. It is the user’s responsibility to make sure
that the cast will not result in any information loss.

Let’s start by including the relevant header files.

.. index::
   pair: ImageFileRead; Vector images
   single: VectorIndexSelectionCastImageFilter

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkVectorIndexSelectionCastImageFilter.h"
    #include "itkRescaleIntensityImageFilter.h"

We read an image of \doxygen{CovariantVector} pixels and extract on of its
components to generate a scalar image of a consistent pixel type. Then,
we rescale the intensities of this scalar image and write it as a image
of \code{unsigned short} pixels.

::

    [language=C++]
    typedef float                 ComponentType;
    const   unsigned int          Dimension = 2;

    typedef itk::CovariantVector< ComponentType,
    Dimension  >      InputPixelType;

    typedef unsigned short                              OutputPixelType;

    typedef itk::Image< InputPixelType,      Dimension >    InputImageType;
    typedef itk::Image< ComponentType,       Dimension >    ComponentImageType;
    typedef itk::Image< OutputPixelType,     Dimension >    OutputImageType;

The \doxygen{ImageFileReader} and \doxygen{ImageFileWriter} are instantiated using the
image types.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType  >  ReaderType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

The VectorIndexSelectionCastImageFilter is instantiated using the input
and output image types. A filter object is created with the New() method
and assigned to a {SmartPointer}.

::

    [language=C++]
    typedef itk::VectorIndexSelectionCastImageFilter<
    InputImageType,
    ComponentImageType    > FilterType;

    FilterType::Pointer componentExtractor = FilterType::New();

The VectorIndexSelectionCastImageFilter class require us to specify
which of the vector components is to be extracted from the vector image.
This is done with the SetIndex() method. In this example we obtain this
value from the command line arguments.

::

    [language=C++]
    componentExtractor->SetIndex( indexOfComponentToExtract );

The \doxygen{RescaleIntensityImageFilter} filter is instantiated here.

::

    [language=C++]
    typedef itk::RescaleIntensityImageFilter<
    ComponentImageType,
    OutputImageType >      RescaleFilterType;

    RescaleFilterType::Pointer  rescaler = RescaleFilterType::New();

The minimum and maximum values for the output image are specified in the
following. Note the use of the \doxygen{NumericTraits} class which allows to
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
    componentExtractor->SetInput( reader->GetOutput() );
    rescaler->SetInput( componentExtractor->GetOutput() );
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

