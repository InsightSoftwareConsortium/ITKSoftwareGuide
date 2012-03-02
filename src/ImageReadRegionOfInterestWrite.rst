The source code for this section can be found in the file
``ImageReadRegionOfInterestWrite.cxx``.

This example should arguably be placed in the previous filtering
chapter. However its usefulness for typical IO operations makes it
interesting to mention here. The purpose of this example is to read and
image, extract a subregion and write this subregion to a file. This is a
common task when we want to apply a computationally intensive method to
the region of interest of an image.

As usual with ITK IO, we begin by including the appropriate header
files.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

The {RegionOfInterestImageFilter} is the filter used to extract a region
from an image. Its header is included below.

::

    [language=C++]
    #include "itkRegionOfInterestImageFilter.h"

Image types are defined below.

::

    [language=C++]
    typedef signed short        InputPixelType;
    typedef signed short        OutputPixelType;
    const   unsigned int        Dimension = 2;

    typedef itk::Image< InputPixelType,  Dimension >    InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >    OutputImageType;

The types for the {ImageFileReader} and {ImageFileWriter} are
instantiated using the image types.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType  >  ReaderType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

The RegionOfInterestImageFilter type is instantiated using the input and
output image types. A filter object is created with the New() method and
assigned to a {SmartPointer}.

::

    [language=C++]
    typedef itk::RegionOfInterestImageFilter< InputImageType,
    OutputImageType > FilterType;

    FilterType::Pointer filter = FilterType::New();

The RegionOfInterestImageFilter requires a region to be defined by the
user. The region is specified by an {Index} indicating the pixel where
the region starts and an {Size} indicating how many pixels the region
has along each dimension. In this example, the specification of the
region is taken from the command line arguments (this example assumes
that a 2D image is being processed).

::

    [language=C++]
    OutputImageType::IndexType start;
    start[0] = atoi( argv[3] );
    start[1] = atoi( argv[4] );

::

    [language=C++]
    OutputImageType::SizeType size;
    size[0] = atoi( argv[5] );
    size[1] = atoi( argv[6] );

An {ImageRegion} object is created and initialized with start and size
obtained from the command line.

::

    [language=C++]
    OutputImageType::RegionType desiredRegion;
    desiredRegion.SetSize(  size  );
    desiredRegion.SetIndex( start );

Then the region is passed to the filter using the SetRegionOfInterest()
method.

::

    [language=C++]
    filter->SetRegionOfInterest( desiredRegion );

Below, we create the reader and writer using the New() method and
assigning the result to a SmartPointer.

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
    writer->SetInput( filter->GetOutput() );

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

