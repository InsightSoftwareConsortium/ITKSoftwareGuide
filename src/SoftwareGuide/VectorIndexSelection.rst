The source code for this section can be found in the file
``VectorIndexSelection.cxx``.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkVectorIndexSelectionCastImageFilter.h"
    #include "itkRGBPixel.h"

::

    [language=C++]
    typedef itk::RGBPixel<unsigned char>  InputPixelType;
    typedef unsigned char                 OutputPixelType;
    const   unsigned int                  Dimension = 2;

    typedef itk::Image< InputPixelType,  Dimension >    InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >    OutputImageType;

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType  >  ReaderType;
    typedef itk::VectorIndexSelectionCastImageFilter< InputImageType, OutputImageType  >  FilterType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

::

    [language=C++]
    FilterType::Pointer filter = FilterType::New();
    filter->SetIndex(atoi(argv[3]));

Then, we create the reader and writer and connect the pipeline.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );

::

    [language=C++]
    reader->SetFileName( inputFilename  );
    writer->SetFileName( outputFilename );

Finally we trigger the execution of the pipeline with the Update()
method on the writer. The output image will then be the scaled and cast
version of the input image.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return EXIT_FAILURE;
    }

