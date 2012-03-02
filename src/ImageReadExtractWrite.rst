The source code for this section can be found in the file
``ImageReadExtractWrite.cxx``.

This example illustrates the common task of extracting a 2D slice from a
3D volume. This is typically used for display purposes and for
expediting user feedback in interactive programs. Here we simply read a
3D volume, extract one of its slices and save it as a 2D image. Note
that caution should be used when working with 2D slices from a 3D
dataset, since for most image processing operations, the application of
a filter on a extracted slice is not equivalent to first applying the
filter in the volume and then extracting the slice.

In this example we start by including the appropriate header files.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

The filter used to extract a region from an image is the
{ExtractImageFilter}. Its header is included below. This filter is
capable of extracting :math:`(N-1)`-dimensional images from
:math:`N`-dimensional ones.

::

    [language=C++]
    #include "itkExtractImageFilter.h"

Image types are defined below. Note that the input image type is
:math:`3D` and the output image type is :math:`2D`.

::

    [language=C++]
    typedef signed short        InputPixelType;
    typedef signed short        OutputPixelType;

    typedef itk::Image< InputPixelType,  3 >    InputImageType;
    typedef itk::Image< OutputPixelType, 2 >    OutputImageType;

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
    typedef itk::ExtractImageFilter< InputImageType, OutputImageType > FilterType;
    FilterType::Pointer filter = FilterType::New();
    filter->InPlaceOn();
    filter->SetDirectionCollapseToSubmatrix();

The ExtractImageFilter requires a region to be defined by the user. The
region is specified by an {Index} indicating the pixel where the region
starts and an {Size} indication how many pixels the region has along
each dimension. In order to extract a :math:`2D` image from a
:math:`3D` data set, it is enough to set the size of the region to
:math:`0` in one dimension. This will indicate to ExtractImageFilter
that a dimensional reduction has been specified. Here we take the region
from the largest possible region of the input image. Note that
UpdateOutputInformation() is being called first on the reader, this
method updates the meta-data in the outputImage without actually reading
in the bulk-data.

::

    [language=C++]
    reader->UpdateOutputInformation();
    InputImageType::RegionType inputRegion =
    reader->GetOutput()->GetLargestPossibleRegion();

We take the size from the region and collapse the size in the
:math:`Z` component by setting its value to :math:`0`. This will
indicate to the ExtractImageFilter that the output image should have a
dimension less than the input image.

::

    [language=C++]
    InputImageType::SizeType size = inputRegion.GetSize();
    size[2] = 0;

Note that in this case we are extracting a :math:`Z` slice, and for
that reason, the dimension to be collapsed in the one with index
:math:`2`. You may keep in mind the association of index components
:math:`\{X=0,Y=1,Z=2\}`. If we were interested in extracting a slice
perpendicular to the :math:`Y` axis we would have set {size[1]=0;}.

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
    filter->SetExtractionRegion( desiredRegion );

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

