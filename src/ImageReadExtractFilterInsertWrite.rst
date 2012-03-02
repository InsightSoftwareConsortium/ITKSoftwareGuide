The source code for this section can be found in the file
``ImageReadExtractFilterInsertWrite.cxx``.

This example illustrates the common task of extracting a 2D slice from a
3D volume. Perform some processing on that slice and then paste it on an
output volume of the same size as the volume from the input.

In this example we start by including the appropriate header files.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

The filter used to extract a region from an image is the
{ExtractImageFilter}. Its header is included below. This filter is
capable of extracting a slice from the input image.

::

    [language=C++]
    #include "itkExtractImageFilter.h"

The filter used to place the processed image in a region of the output
image is the {PasteImageFilter}. Its header is included below. This
filter is capable of inserting the processed image into the destination
image.

::

    [language=C++]
    #include "itkPasteImageFilter.h"

::

    [language=C++]
    #include "itkMedianImageFilter.h"

Image types are defined below. Note that the input image type is
:math:`3D` and the output image type is a :math:`3D` image as well.

::

    [language=C++]
    typedef unsigned char                       InputPixelType;
    typedef unsigned char                       MiddlePixelType;
    typedef unsigned char                       OutputPixelType;
    typedef itk::Image< InputPixelType,  3 >    InputImageType;
    typedef itk::Image< MiddlePixelType, 3 >    MiddleImageType;
    typedef itk::Image< OutputPixelType, 3 >    OutputImageType;

The types for the {ImageFileReader} and {ImageFileWriter} are
instantiated using the image types.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType  >  ReaderType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

Below, we create the reader and writer using the New() method and
assigning the result to a {SmartPointer}.

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

The ExtractImageFilter type is instantiated using the input and output
image types. A filter object is created with the New() method and
assigned to a SmartPointer.

::

    [language=C++]
    typedef itk::ExtractImageFilter< InputImageType, MiddleImageType > ExtractFilterType;
    ExtractFilterType::Pointer extractFilter = ExtractFilterType::New();
    extractFilter->SetDirectionCollapseToSubmatrix();

The ExtractImageFilter requires a region to be defined by the user. The
region is specified by an {Index} indicating the pixel where the region
starts and an {Size} indication how many pixels the region has along
each dimension. In order to extract a :math:`2D` image from a
:math:`3D` data set, it is enough to set the size of the region to
:math:`1` in one dimension. Note that, strictly speaking, we are
extracting here a :math:`3D` image of a single slice. Here we take the
region from the buffered region of the input image. Note that Update()
is being called first on the reader, since otherwise the output would
have invalid data.

::

    [language=C++]
    reader->Update();
    const InputImageType * inputImage = reader->GetOutput();
    InputImageType::RegionType inputRegion = inputImage->GetBufferedRegion();

We take the size from the region and collapse the size in the
:math:`Z` component by setting its value to :math:`1`.

::

    [language=C++]
    InputImageType::SizeType size = inputRegion.GetSize();
    size[2] = 1;

Note that in this case we are extracting a :math:`Z` slice, and for
that reason, the dimension to be collapsed in the one with index
:math:`2`. You may keep in mind the association of index components
:math:`\{X=0,Y=1,Z=2\}`. If we were interested in extracting a slice
perpendicular to the :math:`Y` axis we would have set {size[1]=1;}.

Then, we take the index from the region and set its :math:`Z` value to
the slice number we want to extract. In this example we obtain the slice
number from the command line arguments.

::

    [language=C++]
    InputImageType::IndexType start = inputRegion.GetIndex();
    const unsigned int sliceNumber = atoi( argv[3] );
    start[2] = sliceNumber;

Finally, an {ImageRegion} object is created and initialized with the
start and size we just prepared using the slice information.

::

    [language=C++]
    InputImageType::RegionType desiredRegion;
    desiredRegion.SetSize(  size  );
    desiredRegion.SetIndex( start );

Then the region is passed to the filter using the SetExtractionRegion()
method.

::

    [language=C++]
    extractFilter->SetExtractionRegion( desiredRegion );

::

    [language=C++]
    typedef itk::PasteImageFilter< MiddleImageType, OutputImageType > PasteFilterType;
    PasteFilterType::Pointer pasteFilter = PasteFilterType::New();

::

    [language=C++]
    typedef itk::MedianImageFilter< MiddleImageType, MiddleImageType > MedianFilterType;
    MedianFilterType::Pointer medianFilter = MedianFilterType::New();

Below we connect the reader, filter and writer to form the data
processing pipeline.

::

    [language=C++]
    extractFilter->SetInput( inputImage );
    medianFilter->SetInput( extractFilter->GetOutput() );
    pasteFilter->SetSourceImage( medianFilter->GetOutput() );
    pasteFilter->SetDestinationImage( inputImage );
    pasteFilter->SetDestinationIndex( start );
    MiddleImageType::SizeType indexRadius;
    indexRadius[0] = 1;  radius along x
    indexRadius[1] = 1;  radius along y
    indexRadius[2] = 0;  radius along z
    medianFilter->SetRadius( indexRadius );
    medianFilter->UpdateLargestPossibleRegion();
    const MiddleImageType * medianImage = medianFilter->GetOutput();
    pasteFilter->SetSourceRegion( medianImage->GetBufferedRegion() );
    writer->SetInput( pasteFilter->GetOutput() );

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

