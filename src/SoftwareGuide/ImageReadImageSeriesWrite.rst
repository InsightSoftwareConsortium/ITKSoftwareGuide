The source code for this section can be found in the file
``ImageReadImageSeriesWrite.cxx``.

This example illustrates how to save an image using the
{ImageSeriesWriter}. This class enables the saving of a 3D volume as a
set of files containing one 2D slice per file.

The type of the input image is declared here and it is used for
declaring the type of the reader. This will be a conventional 3D image
reader.

::

    [language=C++]
    typedef itk::Image< unsigned char, 3 >      ImageType;
    typedef itk::ImageFileReader< ImageType >   ReaderType;

The reader object is constructed using the {New()} operator and
assigning the result to a {SmartPointer}. The filename of the 3D volume
to be read is taken from the command line arguments and passed to the
reader using the {SetFileName()} method.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );

The type of the series writer must be instantiated taking into account
that the input file is a 3D volume and the output files are 2D images.
Additionally, the output of the reader is connected as input to the
writer.

::

    [language=C++]
    typedef itk::Image< unsigned char, 2 >     Image2DType;

    typedef itk::ImageSeriesWriter< ImageType, Image2DType > WriterType;

    WriterType::Pointer writer = WriterType::New();

    writer->SetInput( reader->GetOutput() );

The writer requires a list of filenames to be generated. This list can
be produced with the help of the {NumericSeriesFileNames} class.

::

    [language=C++]
    typedef itk::NumericSeriesFileNames    NameGeneratorType;

    NameGeneratorType::Pointer nameGenerator = NameGeneratorType::New();

The {NumericSeriesFileNames} class requires an input string in order to
have a template for generating the filenames of all the output slices.
Here we compose this string using a prefix taken from the command line
arguments and adding the extension for PNG files.

::

    [language=C++]
    std::string format = argv[2];
    format += "%03d.";
    format += argv[3];    filename extension

    nameGenerator->SetSeriesFormat( format.c_str() );

The input string is going to be used for generating filenames by setting
the values of the first and last slice. This can be done by collecting
information from the input image. Note that before attempting to take
any image information from the reader, its execution must be triggered
with the invocation of the {Update()} method, and since this invocation
can potentially throw exceptions, it must be put inside a {try/catch}
block.

::

    [language=C++]
    try
    {
    reader->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Exception thrown while reading the image" << std::endl;
    std::cerr << excp << std::endl;
    }

Now that the image has been read we can query its largest possible
region and recover information about the number of pixels along every
dimension.

::

    [language=C++]
    ImageType::ConstPointer inputImage = reader->GetOutput();
    ImageType::RegionType   region     = inputImage->GetLargestPossibleRegion();
    ImageType::IndexType    start      = region.GetIndex();
    ImageType::SizeType     size       = region.GetSize();

With this information we can find the number that will identify the
first and last slices of the 3D data set. This numerical values are then
passed to the filenames generator object that will compose the names of
the files where the slices are going to be stored.

::

    [language=C++]
    const unsigned int firstSlice = start[2];
    const unsigned int lastSlice  = start[2] + size[2] - 1;

    nameGenerator->SetStartIndex( firstSlice );
    nameGenerator->SetEndIndex( lastSlice );
    nameGenerator->SetIncrementIndex( 1 );

The list of filenames is taken from the names generator and it is passed
to the series writer.

::

    [language=C++]
    writer->SetFileNames( nameGenerator->GetFileNames() );

Finally we trigger the execution of the pipeline with the Update()
method on the writer. At this point the slices of the image will be
saved in individual files containing a single slice per file. The
filenames used for these slices are those produced by the filenames
generator.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Exception thrown while reading the image" << std::endl;
    std::cerr << excp << std::endl;
    }

Note that by saving data into isolated slices we are losing information
that may be significant for medical applications, such as the interslice
spacing in millimeters.
