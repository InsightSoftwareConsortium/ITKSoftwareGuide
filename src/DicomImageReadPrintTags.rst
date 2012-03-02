The source code for this section can be found in the file
``DicomImageReadPrintTags.cxx``.

It is often valuable to be able to query the entries from the header of
a DICOM file. This can be used for checking for consistency, or simply
for verifying that we have the correct dataset in our hands. This
example illustrates how to read a DICOM file and then print out most of
the DICOM header information. The binary fields of the DICOM header are
skipped.

The headers of the main classes involved in this example are specified
below. They include the image file reader, the GDCM image IO object, the
Meta data dictionary and its entry element the Meta data object.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkGDCMImageIO.h"
    #include "itkMetaDataObject.h"

We instantiate the type to be used for storing the image once it is read
into memory.

::

    [language=C++]
    typedef signed short       PixelType;
    const unsigned int         Dimension = 2;

    typedef itk::Image< PixelType, Dimension >      ImageType;

Using the image type as template parameter we instantiate the type of
the image file reader and construct one instance of it.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >     ReaderType;

    ReaderType::Pointer reader = ReaderType::New();

The GDCM image IO type is declared and used for constructing one image
IO object.

::

    [language=C++]
    typedef itk::GDCMImageIO       ImageIOType;
    ImageIOType::Pointer dicomIO = ImageIOType::New();

Here we override the gdcm default value of 0xfff with a value of 0xffff
to allow the loading of long binary stream in the DICOM file. This is
particularly useful when reading the private tag: 0029,1010 from Siemens
as it allows to completely specify the imaging parameters

We pass to the reader the filename of the image to be read and connect
the ImageIO object to it too.

::

    [language=C++]
    reader->SetFileName( argv[1] );
    reader->SetImageIO( dicomIO );

The reading process is triggered with a call to the {Update()} method.
This call should be placed inside a {try/catch} block because its
execution may result in exceptions being thrown.

::

    [language=C++]
    reader->Update();

Now that the image has been read, we obtain the Meta data dictionary
from the ImageIO object using the {GetMetaDataDictionary()} method.

::

    [language=C++]
    typedef itk::MetaDataDictionary   DictionaryType;

    const  DictionaryType & dictionary = dicomIO->GetMetaDataDictionary();

Since we are interested only in the DICOM tags that can be expressed in
strings, we declare a MetaDataObject suitable for managing strings.

::

    [language=C++]
    typedef itk::MetaDataObject< std::string > MetaDataStringType;

We instantiate the iterators that will make possible to walk through all
the entries of the MetaDataDictionary.

::

    [language=C++]
    DictionaryType::ConstIterator itr = dictionary.Begin();
    DictionaryType::ConstIterator end = dictionary.End();

For each one of the entries in the dictionary, we check first if its
element can be converted to a string, a {dynamic\_cast} is used for this
purpose.

::

    [language=C++]
    while( itr != end )
    {
    itk::MetaDataObjectBase::Pointer  entry = itr->second;

    MetaDataStringType::Pointer entryvalue =
    dynamic_cast<MetaDataStringType *>( entry.GetPointer() );

For those entries that can be converted, we take their DICOM tag and
pass it to the {GetLabelFromTag()} method of the GDCMImageIO class. This
method checks the DICOM dictionary and returns the string label
associated to the tag that we are providing in the {tagkey} variable. If
the label is found, it is returned in {labelId} variable. The method
itself return false if the tagkey is not found in the dictionary. For
example "0010\|0010" in {tagkey} becomes "Patient’s Name" in {labelId}.

::

    [language=C++]
    if( entryvalue )
    {
    std::string tagkey   = itr->first;
    std::string labelId;
    bool found =  itk::GDCMImageIO::GetLabelFromTag( tagkey, labelId );

The actual value of the dictionary entry is obtained as a string with
the {GetMetaDataObjectValue()} method.

::

    [language=C++]
    std::string tagvalue = entryvalue->GetMetaDataObjectValue();

At this point we can print out an entry by concatenating the DICOM Name
or label, the numeric tag and its actual value.

::

    [language=C++]
    if( found )
    {
    std::cout << "(" << tagkey << ") " << labelId;
    std::cout << " = " << tagvalue.c_str() << std::endl;
    }

Finally we just close the loop that will walk through all the Dictionary
entries.

::

    [language=C++]
    ++itr;
    }

It is also possible to read a specific tag. In that case the string of
the entry can be used for querying the MetaDataDictionary.

::

    [language=C++]
    std::string entryId = "0010|0010";
    DictionaryType::ConstIterator tagItr = dictionary.Find( entryId );

If the entry is actually found in the Dictionary, then we can attempt to
convert it to a string entry by using a {dynamic\_cast}.

::

    [language=C++]
    if( tagItr != end )
    {
    MetaDataStringType::ConstPointer entryvalue =
    dynamic_cast<const MetaDataStringType *>(
    tagItr->second.GetPointer() );

If the dynamic cast succeed, then we can print out the values of the
label, the tag and the actual value.

::

    [language=C++]
    if( entryvalue )
    {
    std::string tagvalue = entryvalue->GetMetaDataObjectValue();
    std::cout << "Patient's Name (" << entryId <<  ") ";
    std::cout << " is: " << tagvalue.c_str() << std::endl;
    }

Another way to read a specific tag is to use the encapsulation above
MetaDataDictionary Note that this is stricly equivalent to the above
code.

::

    [language=C++]
    std::string tagkey = "0008|1050";
    std::string labelId;
    if( itk::GDCMImageIO::GetLabelFromTag( tagkey, labelId ) )
    {
    std::string value;
    std::cout << labelId << " (" << tagkey << "): ";
    if( dicomIO->GetValueFromTag(tagkey, value) )
    {
    std::cout << value;
    }
    else
    {
    std::cout << "(No Value Found in File)";
    }
    std::cout << std::endl;
    }
    else
    {
    std::cerr << "Trying to access inexistant DICOM tag." << std::endl;
    }

For a full description of the DICOM dictionary please look at the file.

{Insight/Utilities/gdcm/Dicts/dicomV3.dic}

The following piece of code will print out the proper pixel type /
component for instanciating an itk::ImageFileReader that can properly
import the printed DICOM file.

::

    [language=C++]

    itk::ImageIOBase::IOPixelType pixelType;
    pixelType = reader->GetImageIO()->GetPixelType();

    itk::ImageIOBase::IOComponentType componentType;
    componentType = reader->GetImageIO()->GetComponentType();
    std::cout << "PixelType: " << reader->GetImageIO()->GetPixelTypeAsString(pixelType) << std::endl;
    std::cout << "Component Type: " <<
    reader->GetImageIO()->GetComponentTypeAsString(componentType) << std::endl;

