The source code for this section can be found in the file
``VectorImageReadWrite.cxx``.

This example illustrates how to read and write an image of pixel type
{Vector}.

We should include the header files for the Image, the ImageFileReader
and the ImageFileWriter.

::

    [language=C++]
    #include "itkImage.h"
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

Then we define the specific type of vector to be used as pixel type.

::

    [language=C++]
    const unsigned int VectorDimension = 3;

    typedef itk::Vector< float, VectorDimension >    PixelType;

We define the image dimension, and along with the pixel type we use it
for fully instantiating the image type.

::

    [language=C++]
    const unsigned int ImageDimension = 2;

    typedef itk::Image< PixelType, ImageDimension > ImageType;

Having the image type at hand, we can instantiate the reader and writer
types, and use them for creating one object of each type.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType > ReaderType;
    typedef itk::ImageFileWriter< ImageType > WriterType;

    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

Filename must be provided to both the reader and the writer. In this
particular case we take those filenames from the command line arguments.

::

    [language=C++]
    reader->SetFileName( argv[1] );
    writer->SetFileName( argv[2] );

Being this a minimal example, we create a short pipeline where we simply
connect the output of the reader to the input of the writer.

::

    [language=C++]
    writer->SetInput( reader->GetOutput() );

The execution of this short pipeline is triggered by invoking the
writer’s Update() method. This invocation must be placed inside a
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

Of course, you could envision the addition of filters in between the
reader and the writer. Those filters could perform operations on the
vector image.
