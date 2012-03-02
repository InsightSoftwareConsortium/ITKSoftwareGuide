The source code for this section can be found in the file
``DicomSeriesReadSeriesWrite.cxx``.

This example illustrates how to read a DICOM series into a volume and
then save this volume into another DICOM series using the exact same
header information. It makes use of the GDCM library.

The main purpose of this example is to show how to properly propagate
the DICOM specific information along the pipeline to be able to
correctly write back the image using the information from the input
DICOM files.

Please note that writing DICOM files is quite a delicate operation since
we are dealing with a significant amount of patient specific data. It is
your responsibility to verify that the DICOM headers generated from this
code are not introducing risks in the diagnosis or treatment of
patients. It is as well your responsibility to make sure that the
privacy of the patient is respected when you process data sets that
contain personal information. Privacy issues are regulated in the United
States by the HIPAA norms [1]_. You would probably find similar
legislation in every country.

When saving datasets in DICOM format it must be made clear whether this
datasets have been processed in any way, and if so, you should inform
the recipients of the data about the purpose and potential consequences
of the processing. This is fundamental if the datasets are intended to
be used for diagnosis, treatment or follow-up of patients. For example,
the simple reduction of a dataset form a 16-bits/pixel to a 8-bits/pixel
representation may make impossible to detect certain pathologies and as
a result will expose the patient to the risk or remaining untreated for
a long period of time while her/his pathology progresses.

You are strongly encouraged to get familiar with the report on medical
errors “To Err is Human”, produced by the U.S. Institute of Medicine .
Raising awareness about the high frequency of medical errors is a first
step in reducing their occurrence.

After all these warnings, let us now go back to the code and get
familiar with the use of ITK and GDCM for writing DICOM Series. The
first step that we must take is to include the header files of the
relevant classes. We include the GDCM image IO class, the GDCM filenames
generator, the series reader and writer.

::

    [language=C++]
    #include "itkGDCMImageIO.h"
    #include "itkGDCMSeriesFileNames.h"
    #include "itkImageSeriesReader.h"
    #include "itkImageSeriesWriter.h"

As a second step, we define the image type to be used in this example.
This is done by explicitly selecting a pixel type and a dimension. Using
the image type we can define the type of the series reader.

::

    [language=C++]
    typedef signed short    PixelType;
    const unsigned int      Dimension = 3;

    typedef itk::Image< PixelType, Dimension >      ImageType;
    typedef itk::ImageSeriesReader< ImageType >     ReaderType;

We also declare types for the {GDCMImageIO} object that will actually
read and write the DICOM images, and the {GDCMSeriesFileNames} object
that will generate and order all the filenames for the slices composing
the volume dataset. Once we have the types, we proceed to create
instances of both objects.

::

    [language=C++]
    typedef itk::GDCMImageIO                        ImageIOType;
    typedef itk::GDCMSeriesFileNames                NamesGeneratorType;

    ImageIOType::Pointer gdcmIO = ImageIOType::New();
    NamesGeneratorType::Pointer namesGenerator = NamesGeneratorType::New();

Just as the previous example, we get the DICOM filenames from the
directory. Note however, that in this case we use the
{SetInputDirectory()} method instead of the {SetDirectory()}. This is
done because in the present case we will use the filenames generator for
producing both the filenames for reading and the filenames for writing.
Then, we invoke the {GetInputFileNames()} method in order to get the
list of filenames to read.

::

    [language=C++]
    namesGenerator->SetInputDirectory( argv[1] );

    const ReaderType::FileNamesContainer & filenames =
    namesGenerator->GetInputFileNames();

We construct one instance of the series reader object. Set the DICOM
image IO object to be use with it, and set the list of filenames to
read.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();

    reader->SetImageIO( gdcmIO );
    reader->SetFileNames( filenames );

We can trigger the reading process by calling the {Update()} method on
the series reader. It is wise to put this invocation inside a
{try/catch} block since the process may eventually throw exceptions.

::

    [language=C++]
    reader->Update();

At this point we would have the volumetric data loaded in memory and we
can get access to it by invoking the {GetOutput()} method in the reader.

Now we can prepare the process for writing the dataset. First, we take
the name of the output directory from the command line arguments.

::

    [language=C++]
    const char * outputDirectory = argv[2];

Second, we make sure the output directory exist, using the cross
platform tools: itksys::SystemTools. In this case we select to create
the directory if it does not exist yet.

::

    [language=C++]
    itksys::SystemTools::MakeDirectory( outputDirectory );

We instantiate explicitly the image type to be used for writing, and use
the image type for instantiating the type of the series writer.

::

    [language=C++]
    typedef signed short    OutputPixelType;
    const unsigned int      OutputDimension = 2;

    typedef itk::Image< OutputPixelType, OutputDimension >    Image2DType;

    typedef itk::ImageSeriesWriter<
    ImageType, Image2DType >  SeriesWriterType;

We construct a series writer and connect to its input the output from
the reader. Then we pass the GDCM image IO object in order to be able to
write the images in DICOM format.

::

    [language=C++]
    SeriesWriterType::Pointer seriesWriter = SeriesWriterType::New();

    seriesWriter->SetInput( reader->GetOutput() );
    seriesWriter->SetImageIO( gdcmIO );

It is time now to setup the GDCMSeriesFileNames to generate new
filenames using another output directory. Then simply pass those newly
generated files to the series writer.

::

    [language=C++]
    namesGenerator->SetOutputDirectory( outputDirectory );

    seriesWriter->SetFileNames( namesGenerator->GetOutputFileNames() );

The following line of code is extremely important for this process to
work correctly. The line is taking the MetaDataDictionary from the input
reader and passing it to the output writer. The reason why this step is
so important is that the MetaDataDictionary contains all the entries of
the input DICOM header.

::

    [language=C++]
    seriesWriter->SetMetaDataDictionaryArray(
    reader->GetMetaDataDictionaryArray() );

Finally we trigger the writing process by invoking the {Update()} method
in the series writer. We place this call inside a try/catch block, in
case any exception is thrown during the writing process.

::

    [language=C++]
    try
    {
    seriesWriter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Exception thrown while writing the series " << std::endl;
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

Please keep in mind that you should avoid to generate DICOM files that
have the appearance of being produced by a scanner. It should be clear
from the directory or filenames that this data was the result of the
execution of some sort of algorithm. This will help to prevent your
dataset from being used as scanner data by accident.

.. [1]
   The Health Insurance Portability and Accountability Act of 1996.
   http:www.cms.hhs.gov/hipaa/
