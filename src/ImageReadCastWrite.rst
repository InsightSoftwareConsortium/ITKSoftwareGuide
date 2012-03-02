The source code for this section can be found in the file
``ImageReadCastWrite.cxx``.

Given that `ITK <http:www.itk.org>`_ is based on the Generic Programming
paradigm, most of the types are defined at compilation time. It is
sometimes important to anticipate conversion between different types of
images. The following example illustrates the common case of reading an
image of one pixel type and writing it on a different pixel type. This
process not only involves casting but also rescaling the image intensity
since the dynamic range of the input and output pixel types can be quite
different. The {RescaleIntensityImageFilter} is used here to linearly
rescale the image values.

The first step in this example is to include the appropriate headers.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkRescaleIntensityImageFilter.h"

Then, as usual, a decision should be made about the pixel type that
should be used to represent the images. Note that when reading an image,
this pixel type **is not necessarily** the pixel type of the image
stored in the file. Instead, it is the type that will be used to store
the image as soon as it is read into memory.

::

    [language=C++]
    typedef float               InputPixelType;
    typedef unsigned char       OutputPixelType;
    const   unsigned int        Dimension = 2;

    typedef itk::Image< InputPixelType,  Dimension >    InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >    OutputImageType;

Note that the dimension of the image in memory should match the one of
the image in file. There are a couple of special cases in which this
condition may be relaxed, but in general it is better to ensure that
both dimensions match.

We can now instantiate the types of the reader and writer. These two
classes are parameterized over the image type.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType  >  ReaderType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

Below we instantiate the RescaleIntensityImageFilter class that will
linearly scale the image intensities.

::

    [language=C++]
    typedef itk::RescaleIntensityImageFilter<
    InputImageType,
    OutputImageType >    FilterType;

A filter object is constructed and the minimum and maximum values of the
output are selected using the SetOutputMinimum() and SetOutputMaximum()
methods.

::

    [language=C++]
    FilterType::Pointer filter = FilterType::New();
    filter->SetOutputMinimum(   0 );
    filter->SetOutputMaximum( 255 );

Then, we create the reader and writer and connect the pipeline.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );

The name of the files to be read and written are passed with the
SetFileName() method.

::

    [language=C++]
    reader->SetFileName( inputFilename  );
    writer->SetFileName( outputFilename );

Finally we trigger the execution of the pipeline with the Update()
method on the writer. The output image will then be the scaled and cast
version of the input image.

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

