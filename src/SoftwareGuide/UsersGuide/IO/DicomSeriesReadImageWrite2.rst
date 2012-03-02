The source code for this section can be found in the file
``DicomSeriesReadImageWrite2.cxx``.

Probably the most common representation of datasets in clinical
applications is the one that uses sets of DICOM slices in order to
compose tridimensional images. This is the case for CT, MRI and PET
scanners. It is very common therefore for image analysts to have to
process volumetric images that are stored in the form of a set of DICOM
files belonging to a common DICOM series.

The following example illustrates how to use ITK functionalities in
order to read a DICOM series into a volume and then save this volume in
another file format.

The example begins by including the appropriate headers. In particular
we will need the {GDCMImageIO} object in order to have access to the
capabilities of the GDCM library for reading DICOM files, and the
{GDCMSeriesFileNames} object for generating the lists of filenames
identifying the slices of a common volumetric dataset.

::

    [language=C++]
    #include "itkImage.h"
    #include "itkGDCMImageIO.h"
    #include "itkGDCMSeriesFileNames.h"
    #include "itkImageSeriesReader.h"
    #include "itkImageFileWriter.h"

We define the pixel type and dimension of the image to be read. In this
particular case, the dimensionality of the image is 3, and we assume a
{signed short} pixel type that is commonly used for X-Rays CT scanners.

The image orientation information contained in the direction cosines of
the DICOM header are read in and passed correctly down the image
processing pipeline.

::

    [language=C++]
    typedef signed short    PixelType;
    const unsigned int      Dimension = 3;

    typedef itk::Image< PixelType, Dimension >         ImageType;

We use the image type for instantiating the type of the series reader
and for constructing one object of its type.

::

    [language=C++]
    typedef itk::ImageSeriesReader< ImageType >        ReaderType;
    ReaderType::Pointer reader = ReaderType::New();

A GDCMImageIO object is created and connected to the reader. This object
is the one that is aware of the internal intricacies of the DICOM
format.

::

    [language=C++]
    typedef itk::GDCMImageIO       ImageIOType;
    ImageIOType::Pointer dicomIO = ImageIOType::New();

    reader->SetImageIO( dicomIO );

Now we face one of the main challenges of the process of reading a DICOM
series. That is, to identify from a given directory the set of filenames
that belong together to the same volumetric image. Fortunately for us,
GDCM offers functionalities for solving this problem and we just need to
invoke those functionalities through an ITK class that encapsulates a
communication with GDCM classes. This ITK object is the
GDCMSeriesFileNames. Conveniently for us, we only need to pass to this
class the name of the directory where the DICOM slices are stored. This
is done with the {SetDirectory()} method. The GDCMSeriesFileNames object
will explore the directory and will generate a sequence of filenames for
DICOM files for one study/series. In this example, we also call the
{SetUseSeriesDetails(true)} function that tells the GDCMSereiesFileNames
object to use additional DICOM information to distinguish unique volumes
within the directory. This is useful, for example, if a DICOM device
assigns the same SeriesID to a scout scan and its 3D volume; by using
additional DICOM information the scout scan will not be included as part
of the 3D volume. Note that {SetUseSeriesDetails(true)} must be called
prior to calling {SetDirectory()}. By default
{SetUseSeriesDetails(true)} will use the following DICOM tags to
sub-refine a set of files into multiple series: \* 0020 0011 Series
Number \* 0018 0024 Sequence Name \* 0018 0050 Slice Thickness \* 0028
0010 Rows \* 0028 0011 Columns If this is not enough for your specific
case you can always add some more restrictions using the
{AddSeriesRestriction()} method. In this example we will use the DICOM
Tag: 0008 0021 DA 1 Series Date, to sub-refine each series. The format
for passing the argument is a string containing first the group then the
element of the DICOM tag, separed by a pipe (\|) sign.

::

    [language=C++]
    typedef itk::GDCMSeriesFileNames NamesGeneratorType;
    NamesGeneratorType::Pointer nameGenerator = NamesGeneratorType::New();

    nameGenerator->SetUseSeriesDetails( true );
    nameGenerator->AddSeriesRestriction("0008|0021" );

    nameGenerator->SetDirectory( argv[1] );

The GDCMSeriesFileNames object first identifies the list of DICOM series
that are present in the given directory. We receive that list in a
reference to a container of strings and then we can do things like
printing out all the series identifiers that the generator had found.
Since the process of finding the series identifiers can potentially
throw exceptions, it is wise to put this code inside a try/catch block.

::

    [language=C++]
    typedef std::vector< std::string >    SeriesIdContainer;

    const SeriesIdContainer & seriesUID = nameGenerator->GetSeriesUIDs();

    SeriesIdContainer::const_iterator seriesItr = seriesUID.begin();
    SeriesIdContainer::const_iterator seriesEnd = seriesUID.end();
    while( seriesItr != seriesEnd )
    {
    std::cout << seriesItr->c_str() << std::endl;
    ++seriesItr;
    }

Given that it is common to find multiple DICOM series in the same
directory, we must tell the GDCM classes what specific series do we want
to read. In this example we do this by checking first if the user has
provided a series identifier in the command line arguments. If no series
identifier has been passed, then we simply use the first series found
during the exploration of the directory.

::

    [language=C++]
    std::string seriesIdentifier;

    if( argc > 3 )  If no optional series identifier
    {
    seriesIdentifier = argv[3];
    }
    else
    {
    seriesIdentifier = seriesUID.begin()->c_str();
    }

We pass the series identifier to the name generator and ask for all the
filenames associated to that series. This list is returned in a
container of strings by the {GetFileNames()} method.

::

    [language=C++]
    typedef std::vector< std::string >   FileNamesContainer;
    FileNamesContainer fileNames;

    fileNames = nameGenerator->GetFileNames( seriesIdentifier );

The list of filenames can now be passed to the {ImageSeriesReader} using
the {SetFileNames()} method.

::

    [language=C++]
    reader->SetFileNames( fileNames );

Finally we can trigger the reading process by invoking the {Update()}
method in the reader. This call as usual is placed inside a {try/catch}
block.

::

    [language=C++]
    try
    {
    reader->Update();
    }
    catch (itk::ExceptionObject &ex)
    {
    std::cout << ex << std::endl;
    return EXIT_FAILURE;
    }

At this point, we have a volumetric image in memory that we can access
by invoking the {GetOutput()} method of the reader.

We proceed now to save the volumetric image in another file, as
specified by the user in the command line arguments of this program.
Thanks to the ImageIO factory mechanism, only the filename extension is
needed to identify the file format in this case.

::

    [language=C++]
    typedef itk::ImageFileWriter< ImageType > WriterType;
    WriterType::Pointer writer = WriterType::New();

    writer->SetFileName( argv[2] );

    writer->SetInput( reader->GetOutput() );

The process of writing the image is initiated by invoking the {Update()}
method of the writer.

::

    [language=C++]
    writer->Update();

Note that in addition to writing the volumetric image to a file we could
have used it as the input for any 3D processing pipeline. Keep in mind
that DICOM is simply a file format and a network protocol. Once the
image data has been loaded into memory, it behaves as any other
volumetric dataset that you could have loaded from any other file
format.
