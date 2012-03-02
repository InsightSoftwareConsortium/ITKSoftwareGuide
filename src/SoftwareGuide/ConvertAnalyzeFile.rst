The source code for this section can be found in the file
``ConvertAnalyzeFile.cxx``.

This example illustrates how to use the deprecated {AnalyzeImageIO} to
convert Analyze files written with ITK prior to version 4. It exists as
a utility to convert any Analyze files that are not readable using
\code{NiftiImageIO}.

Let’s start by including the relevant header files.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkAnalyzeImageIO.h"
    #include "itkRGBPixel.h"
    #include "itkImage.h"

Use a function templated over the desired image pixel type. You still
have to decide which version of ReadAnalyzeWriteNIfTI to call at
runtime, but at least the read/write code only happens once in the
source code.

::

    [language=C++]
    template <typename TImage>
    int
    ReadAnalyzeWriteNIfTI(const char *inputName, const char *outputName)
    {
    typedef itk::ImageFileReader<TImage> ReaderType;
    typedef itk::ImageFileWriter<TImage> WriterType;

    typename ReaderType::Pointer reader = ReaderType::New();
    typename WriterType::Pointer writer = WriterType::New();
    To force the use of a particular ImageIO class, you
    create an instance of that class, and use ImageIO::SetImageIO
    to force the image file reader to exclusively use that
    ImageIO.
    typename itk::AnalyzeImageIO::Pointer analyzeIO = itk::AnalyzeImageIO::New();

    reader->SetImageIO(analyzeIO);
    reader->SetFileName(inputName);
    writer->SetFileName(outputName);
    writer->SetInput(reader->GetOutput());
    try
    {
    writer->Update();
    }
    catch( itk::ImageFileReaderException& readErr )
    {
    std::cerr << "Failed to read file " << inputName
    << " " << readErr.what()
    << std::endl;
    return EXIT_FAILURE;
    }
    catch( itk::ImageFileWriterException& writeErr )
    {
    std::cerr << "Failed to write file " << outputName
    << writeErr.what()
    << std::endl;
    return EXIT_FAILURE;
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << " Failure reading " << inputName
    << " or writing " << outputName
    << " " << err.what()
    << std::endl;
    return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
    }

Create an instance of AnalyzeImageIO, this will be used to read in the
Analyze file. Then choose between which template function to call based
on a command line parameter. This kind of runtime template selection is
rather brute force and ugly, but sometimes it’s unavoidable.

::

    [language=C++]
    itk::AnalyzeImageIO::Pointer analyzeIO = itk::AnalyzeImageIO::New();
    if(!analyzeIO->CanReadFile(argv[1]))
    {
    std::cerr << argv[0] << ": AnalyzeImageIO cannot read "
    << argv[1] << std::endl;
    return EXIT_FAILURE;
    }
    analyzeIO->ReadImageInformation();

    unsigned int dim = analyzeIO->GetNumberOfDimensions();
    itk::ImageIOBase::IOComponentType componentType = analyzeIO->GetComponentType();
    itk::ImageIOBase::IOPixelType pixelType = analyzeIO->GetPixelType();

    if(pixelType != itk::ImageIOBase::SCALAR && pixelType == itk::ImageIOBase::RGB)
    {
    std::cerr << argv[0] << "No support for Image Pixel TYPE "
    << analyzeIO->GetPixelTypeAsString(pixelType) << std::endl;
    return EXIT_FAILURE;
    }

    base reading/writing type on command line parameter
    switch(componentType)
    {
    case itk::ImageIOBase::CHAR:
    if(pixelType == itk::ImageIOBase::SCALAR)
    {
    if(dim == 2)
    {
    return ReadAnalyzeWriteNIfTI<itk::Image<char,2> >(argv[1],argv[2]);
    }
    else
    {
    return ReadAnalyzeWriteNIfTI<itk::Image<char,3> >(argv[1],argv[2]);
    }
    }
    else if(pixelType == itk::ImageIOBase::RGB)
    {
    if(dim == 2)
    {
    return ReadAnalyzeWriteNIfTI<itk::Image<itk::RGBPixel<unsigned char>,2> >(argv[1],argv[2]);
    }
    else
    {
    return ReadAnalyzeWriteNIfTI<itk::Image<itk::RGBPixel<unsigned char>,3> >(argv[1],argv[2]);
    }
    }
    break;
    case itk::ImageIOBase::UCHAR:
    if(dim == 2)
    {
    return ReadAnalyzeWriteNIfTI<itk::Image<unsigned char,2> >( argv[1],argv[2]);
    }
    else
    {
    return ReadAnalyzeWriteNIfTI<itk::Image<unsigned char,3> >( argv[1],argv[2]);
    }
    break;

