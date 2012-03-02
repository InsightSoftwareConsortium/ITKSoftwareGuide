The source code for this section can be found in the file
``ComplexImageReadWrite.cxx``.

This example illustrates how to read and write an image of pixel type
\code{std::complex}. The complex type is defined as an integral part of the
C++ language. The characteristics of the type are specified in the C++
standard document in Chapter 26 "Numerics Library", page 565, in
particular in section 26.2 \cite{CPPStandard1998}.

We start by including the headers of the complex class, the image, and
the reader and writer classes.

.. index::
   pair: ImageFileReader; Complex Images
   pair: ImageFileWrite; Complex Images
   pair: Complex images; Instantiation
   pair: Complex images; Reading
   pair: Complex images;Writing

::

    [language=C++]
    #include <complex>
    #include "itkImage.h"
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

The image dimension and pixel type must be declared. In this case we use
the \code{std::complex<>} as the pixel type. Using the dimension and pixel
type we proceed to instantiate the image type.

::

    [language=C++]
    const unsigned int Dimension = 2;

    typedef std::complex< float >              PixelType;
    typedef itk::Image< PixelType, Dimension > ImageType;

The image file reader and writer types are instantiated using the image
type. We can then create objects for both of them.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType > ReaderType;
    typedef itk::ImageFileWriter< ImageType > WriterType;

    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

Filenames should be provided for both the reader and the writer. In this
particular example we take those filenames from the command line
arguments.

::

    [language=C++]
    reader->SetFileName( argv[1] );
    writer->SetFileName( argv[2] );

Here we simply connect the output of the reader as input to the writer.
This simple program could be used for converting complex images from one
fileformat to another.

::

    [language=C++]
    writer->SetInput( reader->GetOutput() );

The execution of this short pipeline is triggered by invoking the
\code{Update()} method of the writer. This invocation must be placed inside a
try/catch block since its execution may result in exceptions being
thrown.

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

For a more interesting use of this code, you may want to add a filter in
between the reader and the writer and perform any complex image to
complex image operation. A practical application of this code is
presented in section \ref{sec:FrequencyDomain} in the context of Fourier
analysis.
