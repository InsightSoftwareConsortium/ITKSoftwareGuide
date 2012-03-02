The source code for this section can be found in the file
``DicomImageReadChangeHeaderWrite.cxx``.

This example illustrates how to read a single DICOM slice and write it
back with some changed header information as another DICOM slice. Header
Key/Value pairs can be specified on the command line. The keys are
defined in the file

{Insight/Utilities/gdcm/Dicts/dicomV3.dic}

Please note that modifying the content of a DICOM header is a very risky
operation. The Header contains fundamental information about the patient
and therefore its consistency must be protected from any data
corruption. Before attempting to modify the DICOM headers of your files,
you must make sure that you have a very good reason for doing so, and
that you can ensure that this information change will not result in a
lower quality of health care to be delivered to the patient.

We must start by including the relevant header files. Here we include
the image reader, image writer, the image, the Meta data dictionary and
its entries the Meta data objects and the GDCMImageIO. The Meta data
dictionary is the data container that stores all the entries from the
DICOM header once the DICOM image file is read into an ITK image.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkImage.h"
    #include "itkMetaDataObject.h"
    #include "itkGDCMImageIO.h"

We declare the image type by selecting a particular pixel type and image
dimension.

::

    [language=C++]
    typedef signed short InputPixelType;
    const unsigned int   Dimension = 2;
    typedef itk::Image< InputPixelType, Dimension > InputImageType;

We instantiate the reader type by using the image type as template
parameter. An instance of the reader is created and the file name to be
read is taken from the command line arguments.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType > ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );

The GDCMImageIO object is created in order to provide the services for
reading and writing DICOM files. The newly created image IO class is
connected to the reader.

::

    [language=C++]
    typedef itk::GDCMImageIO           ImageIOType;
    ImageIOType::Pointer gdcmImageIO = ImageIOType::New();
    reader->SetImageIO( gdcmImageIO );

The reading of the image is triggered by invoking {Update()} in the
reader.

::

    [language=C++]
    reader->Update();

We take the Meta data dictionary from the image that the reader had
loaded in memory.

::

    [language=C++]
    InputImageType::Pointer inputImage = reader->GetOutput();
    typedef itk::MetaDataDictionary   DictionaryType;
    DictionaryType & dictionary = inputImage->GetMetaDataDictionary();

Now we access the entries in the Meta data dictionary, and for
particular key values we assign a new content to the entry. This is done
here by taking {key,value} pairs from the command line arguments. The
relevant method is the EncapsulateMetaData that takes the dictionary and
for a given key provided by {entryId}, replaces the current value with
the content of the {value} variable. This is repeated for every
potential pair present in the command line arguments.

::

    [language=C++]
    for (int i = 3; i < argc; i+=2)
    {
    std::string entryId( argv[i] );
    std::string value( argv[i+1] );
    itk::EncapsulateMetaData<std::string>( dictionary, entryId, value );
    }

Now that the Dictionary has been updated, we proceed to save the image.
This output image will have the modified data associated to its DICOM
header.

Using the image type, we instantiate a writer type and construct a
writer. A short pipeline between the reader and the writer is connected.
The filename to write is taken from the command line arguments. The
image IO object is connected to the writer.

::

    [language=C++]
    typedef itk::ImageFileWriter< InputImageType >  Writer1Type;

    Writer1Type::Pointer writer1 = Writer1Type::New();

    writer1->SetInput( reader->GetOutput() );
    writer1->SetFileName( argv[2] );
    writer1->SetImageIO( gdcmImageIO );

Execution of the writer is triggered by invoking the {Update()} method.

::

    [language=C++]
    writer1->Update();

Remember again, that modifying the header entries of a DICOM file
involves very serious risks for patients and therefore must be done with
extreme caution.
