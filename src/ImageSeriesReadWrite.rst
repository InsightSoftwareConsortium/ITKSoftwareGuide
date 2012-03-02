The source code for this section can be found in the file
``ImageSeriesReadWrite.cxx``.

This example illustrates how to read a series of 2D slices from
independent files in order to compose a volume. The class
{ImageSeriesReader} is used for this purpose. This class works in
combination with a generator of filenames that will provide a list of
files to be read. In this particular example we use the
{NumericSeriesFileNames} class as filename generator. This generator
uses a {printf} style of string format with a “{%d}” field that will be
successively replaced by a number specified by the user. Here we will
use a format like “{file%03d.png}” for reading PNG files named
file001.png, file002.png, file003.png... and so on.

This requires the following headers as shown.

::

    [language=C++]
    #include "itkImage.h"
    #include "itkImageSeriesReader.h"
    #include "itkImageFileWriter.h"
    #include "itkNumericSeriesFileNames.h"
    #include "itkPNGImageIO.h"

We start by defining the {PixelType} and {ImageType}.

::

    [language=C++]
    typedef unsigned char                       PixelType;
    const unsigned int Dimension = 3;

    typedef itk::Image< PixelType, Dimension >  ImageType;

The image type is used as a template parameter to instantiate the reader
and writer.

::

    [language=C++]
    typedef itk::ImageSeriesReader< ImageType >  ReaderType;
    typedef itk::ImageFileWriter<   ImageType >  WriterType;

    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

Then, we declare the filenames generator type and create one instance of
it.

::

    [language=C++]
    typedef itk::NumericSeriesFileNames    NameGeneratorType;

    NameGeneratorType::Pointer nameGenerator = NameGeneratorType::New();

The filenames generator requires us to provide a pattern of text for the
filenames, and numbers for the initial value, last value and increment
to be used for generating the names of the files.

::

    [language=C++]
    nameGenerator->SetSeriesFormat( "vwe%03d.png" );

    nameGenerator->SetStartIndex( first );
    nameGenerator->SetEndIndex( last );
    nameGenerator->SetIncrementIndex( 1 );

The ImageIO object that actually performs the read process is now
connected to the ImageSeriesReader. This is the safest way of making
sure that we use an ImageIO object that is appropriate for the type of
files that we want to read.

::

    [language=C++]
    reader->SetImageIO( itk::PNGImageIO::New() );

The filenames of the input files must be provided to the reader. While
the writer is instructed to write the same volume dataset in a single
file.

::

    [language=C++]
    reader->SetFileNames( nameGenerator->GetFileNames()  );

    writer->SetFileName( outputFilename );

We connect the output of the reader to the input of the writer.

::

    [language=C++]
    writer->SetInput( reader->GetOutput() );

Finally, execution of the pipeline can be triggered by invoking the
Update() method in the writer. This call must be placed in a try/catch
block since exceptions be potentially be thrown in the process of
reading or writing the images.

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

