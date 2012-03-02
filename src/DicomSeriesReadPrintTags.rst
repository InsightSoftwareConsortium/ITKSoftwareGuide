The source code for this section can be found in the file
``DicomSeriesReadPrintTags.cxx``.

This example illustrates how to read a DICOM series into a volume and
then print most of the DICOM header information. The binary fields are
skipped.

The header files for the series reader and the GDCM classes for image IO
and name generation should be included first.

::

    [language=C++]
    #include "itkImageSeriesReader.h"
    #include "itkGDCMImageIO.h"
    #include "itkGDCMSeriesFileNames.h"

We instantiate then the type to be used for storing the image once it is
read into memory.

::

    [language=C++]
    typedef signed short       PixelType;
    const unsigned int         Dimension = 3;

    typedef itk::Image< PixelType, Dimension >      ImageType;

We use the image type for instantiating the series reader type and then
we construct one object of this class.

::

    [language=C++]
    typedef itk::ImageSeriesReader< ImageType >     ReaderType;

    ReaderType::Pointer reader = ReaderType::New();

A GDCMImageIO object is created and assigned to the reader.

::

    [language=C++]
    typedef itk::GDCMImageIO       ImageIOType;

    ImageIOType::Pointer dicomIO = ImageIOType::New();

    reader->SetImageIO( dicomIO );

A GDCMSeriesFileNames is declared in order to generate the names of
DICOM slices. We specify the directory with the {SetInputDirectory()}
method and, in this case, take the directory name from the command line
arguments. You could have obtained the directory name from a file dialog
in a GUI.

::

    [language=C++]
    typedef itk::GDCMSeriesFileNames     NamesGeneratorType;

    NamesGeneratorType::Pointer nameGenerator = NamesGeneratorType::New();

    nameGenerator->SetInputDirectory( argv[1] );

The list of files to read is obtained from the name generator by
invoking the {GetInputFileNames()} method and receiving the results in a
container of strings. The list of filenames is passed to the reader
using the {SetFileNames()} method.

::

    [language=C++]
    typedef std::vector<std::string>    FileNamesContainer;
    FileNamesContainer fileNames = nameGenerator->GetInputFileNames();

    reader->SetFileNames( fileNames );

We trigger the reader by invoking the {Update()} method. This invocation
should normally be done inside a {try/catch} block given that it may
eventually throw exceptions.

::

    [language=C++]
    reader->Update();

ITK internally queries GDCM and obtain all the DICOM tags from the file
headers. The tag values are stored in the {MetaDataDictionary} that is a
general purpose container for {key,value} pairs. The Meta data
dictionary can be recovered from any ImageIO class by invoking the
{GetMetaDataDictionary()} method.

::

    [language=C++]
    typedef itk::MetaDataDictionary   DictionaryType;

    const  DictionaryType & dictionary = dicomIO->GetMetaDataDictionary();

In this example, we are only interested in the DICOM tags that can be
represented as strings. We declare therefore a {MetaDataObject} of
string type in order to receive those particular values.

::

    [language=C++]
    typedef itk::MetaDataObject< std::string > MetaDataStringType;

The Meta data dictionary is organized as a container with its
corresponding iterators. We can therefore visit all its entries by first
getting access to its {Begin()} and {End()} methods.

::

    [language=C++]
    DictionaryType::ConstIterator itr = dictionary.Begin();
    DictionaryType::ConstIterator end = dictionary.End();

We are now ready for walking through the list of DICOM tags. For this
purpose we use the iterators that we just declared. At every entry we
attempt to convert it in to a string entry by using the {dynamic\_cast}
based on RTTI information [1]_. The dictionary is organized like a
{std::map} structure, we should use therefore the {first} and {second}
members of every entry in order to get access to the {key,value} pairs.

::

    [language=C++]
    while( itr != end )
    {
    itk::MetaDataObjectBase::Pointer  entry = itr->second;

    MetaDataStringType::Pointer entryvalue =
    dynamic_cast<MetaDataStringType *>( entry.GetPointer() );

    if( entryvalue )
    {
    std::string tagkey   = itr->first;
    std::string tagvalue = entryvalue->GetMetaDataObjectValue();
    std::cout << tagkey <<  " = " << tagvalue << std::endl;
    }

    ++itr;
    }

It is also possible to query for specific entries instead of reading all
of them as we did above. In this case, the user must provide the tag
identifier using the standard DICOM encoding. The identifier is stored
in a string and used as key on the dictionary.

::

    [language=C++]
    std::string entryId = "0010|0010";

    DictionaryType::ConstIterator tagItr = dictionary.Find( entryId );

    if( tagItr == end )
    {
    std::cerr << "Tag " << entryId;
    std::cerr << " not found in the DICOM header" << std::endl;
    return EXIT_FAILURE;
    }

Since the entry may or may not be of string type we must again use a
{dynamic\_cast} in order to attempt to convert it to a string dictionary
entry. If the conversion is successful, then we can print out its
content.

::

    [language=C++]
    MetaDataStringType::ConstPointer entryvalue =
    dynamic_cast<const MetaDataStringType *>( tagItr->second.GetPointer() );

    if( entryvalue )
    {
    std::string tagvalue = entryvalue->GetMetaDataObjectValue();
    std::cout << "Patient's Name (" << entryId <<  ") ";
    std::cout << " is: " << tagvalue << std::endl;
    }
    else
    {
    std::cerr << "Entry was not of string type" << std::endl;
    return EXIT_FAILURE;
    }

This type of functionality will probably be more useful when provided
through a graphical user interface. For a full description of the DICOM
dictionary please look at the file

{Insight/Utilities/gdcm/Dicts/dicomV3.dic}

.. [1]
   Run Time Type Information
