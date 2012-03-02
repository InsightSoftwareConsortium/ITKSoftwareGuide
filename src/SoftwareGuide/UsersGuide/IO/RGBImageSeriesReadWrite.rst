The source code for this section can be found in the file
``RGBImageSeriesReadWrite.cxx``.

RGB images are commonly used for representing data acquired from
cryogenic sections, optical microscopy and endoscopy. This example
illustrates how to read RGB color images from a set of files containing
individual 2D slices in order to compose a 3D color dataset. Then save
it into a single 3D file, and finally save it again as a set of 2D
slices with other names.

This requires the following headers as shown.

::

    [language=C++]
    #include "itkRGBPixel.h"
    #include "itkImage.h"
    #include "itkImageSeriesReader.h"
    #include "itkImageSeriesWriter.h"
    #include "itkNumericSeriesFileNames.h"
    #include "itkPNGImageIO.h"

The {RGBPixel} class is templated over the type used to represent each
one of the Red, Green and Blue components. A typical instantiation of
the RGB image class might be as follows.

::

    [language=C++]
    typedef itk::RGBPixel< unsigned char >        PixelType;
    const unsigned int Dimension = 3;

    typedef itk::Image< PixelType, Dimension >    ImageType;

The image type is used as a template parameter to instantiate the series
reader and the volumetric writer.

::

    [language=C++]
    typedef itk::ImageSeriesReader< ImageType >  SeriesReaderType;
    typedef itk::ImageFileWriter<   ImageType >  WriterType;

    SeriesReaderType::Pointer seriesReader = SeriesReaderType::New();
    WriterType::Pointer       writer       = WriterType::New();

We use a NumericSeriesFileNames class in order to generate the filenames
of the slices to be read. Later on in this example we will reuse this
object in order to generate the filenames of the slices to be written.

::

    [language=C++]
    typedef itk::NumericSeriesFileNames    NameGeneratorType;

    NameGeneratorType::Pointer nameGenerator = NameGeneratorType::New();

    nameGenerator->SetStartIndex( first );
    nameGenerator->SetEndIndex( last );
    nameGenerator->SetIncrementIndex( 1 );

    nameGenerator->SetSeriesFormat( "vwe%03d.png" );

The ImageIO object that actually performs the read process is now
connected to the ImageSeriesReader.

::

    [language=C++]
    seriesReader->SetImageIO( itk::PNGImageIO::New() );

The filenames of the input slices are taken from the names generator and
passed to the series reader.

::

    [language=C++]
    seriesReader->SetFileNames( nameGenerator->GetFileNames()  );

The name of the volumetric output image is passed to the image writer,
and we connect the output of the series reader to the input of the
volumetric writer.

::

    [language=C++]
    writer->SetFileName( outputFilename );

    writer->SetInput( seriesReader->GetOutput() );

Finally, execution of the pipeline can be triggered by invoking the
Update() method in the volumetric writer. This, of course, is done from
inside a try/catch block.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Error reading the series " << std::endl;
    std::cerr << excp << std::endl;
    }

We now proceed to save the same volumetric dataset as a set of slices.
This is done only to illustrate the process for saving a volume as a
series of 2D individual datasets. The type of the series writer must be
instantiated taking into account that the input file is a 3D volume and
the output files are 2D images. Additionally, the output of the series
reader is connected as input to the series writer.

::

    [language=C++]
    typedef itk::Image< PixelType, 2 >     Image2DType;

    typedef itk::ImageSeriesWriter< ImageType, Image2DType > SeriesWriterType;

    SeriesWriterType::Pointer seriesWriter = SeriesWriterType::New();

    seriesWriter->SetInput( seriesReader->GetOutput() );

We now reuse the filenames generator in order to produce the list of
filenames for the output series. In this case we just need to modify the
format of the filenames generator. Then, we pass the list of output
filenames to the series writer.

::

    [language=C++]
    nameGenerator->SetSeriesFormat( "output%03d.png" );

    seriesWriter->SetFileNames( nameGenerator->GetFileNames() );

Finally we trigger the execution of the series writer from inside a
try/catch block.

::

    [language=C++]
    try
    {
    seriesWriter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Error reading the series " << std::endl;
    std::cerr << excp << std::endl;
    }

You may have noticed that apart from the declaration of the {PixelType}
there is nothing in this code that is specific for RGB images. All the
actions required to support color images are implemented internally in
the {ImageIO} objects.
