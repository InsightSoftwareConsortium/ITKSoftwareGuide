The source code for this section can be found in the file
``DicomImageReadWrite.cxx``.

This example illustrates how to read a single DICOM slice and write it
back as another DICOM slice. In the process an intensity rescaling is
also applied.

In order to read and write the slice we use here the {GDCMImageIO} class
that encapsulates a connection to the underlying GDCM library. In this
way we gain access from ITK to the DICOM functionalities offered by
GDCM. The GDCMImageIO object is connected as the ImageIO object to be
used by the {ImageFileWriter}.

We should first include the following header files.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkRescaleIntensityImageFilter.h"
    #include "itkGDCMImageIO.h"

Then we declare the pixel type and image dimension, and use them for
instantiating the image type to be read.

::

    [language=C++]
    typedef signed short InputPixelType;
    const unsigned int   InputDimension = 2;

    typedef itk::Image< InputPixelType, InputDimension > InputImageType;

With the image type we can instantiate the type of the reader, create
one, and set the filename of the image to be read.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType > ReaderType;

    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );

GDCMImageIO is an ImageIO class for reading and writing DICOM v3 and
ACR/NEMA images. The GDCMImageIO object is constructed here and
connected to the ImageFileReader.

::

    [language=C++]
    typedef itk::GDCMImageIO           ImageIOType;

    ImageIOType::Pointer gdcmImageIO = ImageIOType::New();

    reader->SetImageIO( gdcmImageIO );

At this point we can trigger the reading process by invoking the
Update() method. Since this reading process may eventually throw an
exception, we place the invocation inside a try/catch block.

::

    [language=C++]
    try
    {
    reader->Update();
    }
    catch (itk::ExceptionObject & e)
    {
    std::cerr << "exception in file reader " << std::endl;
    std::cerr << e << std::endl;
    return EXIT_FAILURE;
    }

We have now the image in memory and can get access to it by using the
GetOutput() method of the reader. In the remaining of this current
example, we focus on showing how we can save this image again in DICOM
format in a new file.

First, we must instantiate an ImageFileWriter type. Then, we construct
one, set the filename to be used for writing and connect the input image
to be written. Given that in this example we write the image in
different ways, and in each case we use a different writer, we
enumerated here the variable names of the writer objects as well as
their types.

::

    [language=C++]
    typedef itk::ImageFileWriter< InputImageType >  Writer1Type;

    Writer1Type::Pointer writer1 = Writer1Type::New();

    writer1->SetFileName( argv[2] );
    writer1->SetInput( reader->GetOutput() );

We need to explicitly set the proper image IO (GDCMImageIO) to the
writer filter since the input DICOM dictionary is being passed along the
writing process. The dictionary contains all necessary information that
a valid DICOM file should contain, like Patient Name, Patient ID,
Institution Name, etc.

::

    [language=C++]
    writer1->SetImageIO( gdcmImageIO );

The writing process is triggered by invoking the Update() method. Since
this execution may result in exceptions being thrown we place the
Update() call inside a try/catch block.

::

    [language=C++]
    try
    {
    writer1->Update();
    }
    catch (itk::ExceptionObject & e)
    {
    std::cerr << "exception in file writer " << std::endl;
    std::cerr << e << std::endl;
    return EXIT_FAILURE;
    }

We will now rescale the image into a rescaled image one using the
rescale intensity image filter. For this purpose we use a better suited
pixel type: {unsigned char} instead of {signed short}. The minimum and
maximum values of the output image are explicitly defined in the
rescaling filter.

::

    [language=C++]
    typedef unsigned char WritePixelType;

    typedef itk::Image< WritePixelType, 2 > WriteImageType;

    typedef itk::RescaleIntensityImageFilter<
    InputImageType, WriteImageType > RescaleFilterType;

    RescaleFilterType::Pointer rescaler = RescaleFilterType::New();

    rescaler->SetOutputMinimum(   0 );
    rescaler->SetOutputMaximum( 255 );

We create a second writer object that will save the rescaled image into
a file. This time not in DICOM format. This is done only for the sake of
verifying the image against the one that will be saved in DICOM format
later on this example.

::

    [language=C++]
    typedef itk::ImageFileWriter< WriteImageType >  Writer2Type;

    Writer2Type::Pointer writer2 = Writer2Type::New();

    writer2->SetFileName( argv[3] );

    rescaler->SetInput( reader->GetOutput() );
    writer2->SetInput( rescaler->GetOutput() );

The writer can be executed by invoking the Update() method from inside a
try/catch block.

We proceed now to save the same rescaled image into a file in DICOM
format. For this purpose we just need to set up a {ImageFileWriter} and
pass to it the rescaled image as input.

::

    [language=C++]
    typedef itk::ImageFileWriter< WriteImageType >  Writer3Type;

    Writer3Type::Pointer writer3 = Writer3Type::New();

    writer3->SetFileName( argv[4] );
    writer3->SetInput( rescaler->GetOutput() );

We now need to explicitly set the proper image IO (GDCMImageIO), but
also we must tell the ImageFileWriter to not use the MetaDataDictionary
from the input but from the GDCMImageIO since this is the one that
contains the DICOM specific information

The GDCMImageIO object will automatically detect the pixel type, in this
case {unsigned char} and it will update the DICOM header information
accordingly.

::

    [language=C++]
    writer3->UseInputMetaDataDictionaryOff ();
    writer3->SetImageIO( gdcmImageIO );

Finally we trigger the execution of the DICOM writer by invoking the
Update() method from inside a try/catch block.

::

    [language=C++]
    try
    {
    writer3->Update();
    }
    catch (itk::ExceptionObject & e)
    {
    std::cerr << "Exception in file writer " << std::endl;
    std::cerr << e << std::endl;
    return EXIT_FAILURE;
    }

