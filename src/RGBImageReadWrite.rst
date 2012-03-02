The source code for this section can be found in the file
``RGBImageReadWrite.cxx``.

RGB images are commonly used for representing data acquired from
cryogenic sections, optical microscopy and endoscopy. This example
illustrates how to read and write RGB color images to and from a file.
This requires the following headers as shown.

::

    [language=C++]
    #include "itkRGBPixel.h"
    #include "itkImage.h"
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

The {RGBPixel} class is templated over the type used to represent each
one of the red, green and blue components. A typical instantiation of
the RGB image class might be as follows.

::

    [language=C++]
    typedef itk::RGBPixel< unsigned char >   PixelType;
    typedef itk::Image< PixelType, 2 >       ImageType;

The image type is used as a template parameter to instantiate the reader
and writer.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >  ReaderType;
    typedef itk::ImageFileWriter< ImageType >  WriterType;

    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

The filenames of the input and output files must be provided to the
reader and writer respectively.

::

    [language=C++]
    reader->SetFileName( inputFilename  );
    writer->SetFileName( outputFilename );

Finally, execution of the pipeline can be triggered by invoking the
Update() method in the writer.

::

    [language=C++]
    writer->Update();

You may have noticed that apart from the declaration of the {PixelType}
there is nothing in this code that is specific for RGB images. All the
actions required to support color images are implemented internally in
the {ImageIO} objects.
