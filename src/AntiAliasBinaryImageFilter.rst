The source code for this section can be found in the file
``AntiAliasBinaryImageFilter.cxx``.

This example introduces the use of the \doxygen{AntiAliasBinaryImageFilter}.
This filter expect a binary mask as input, and using Level Sets it
smooths the image by keeping the edge of the structure within 1 pixel
distance from the original location. It is usually desirable to run this
filter before extracting isocontour with surface extraction methods.

.. index::
   single: AntiAliasBinaryImageFilter

The first step required for using this filter is to include its header
file

::

    [language=C++]
    #include "itkAntiAliasBinaryImageFilter.h"

This filter operates on image of pixel type float. It is then necessary
to cast the type of the input images that are usually of integer type.
The \doxygen{CastImageFilter} is used here for that purpose. Its image template
parameters are defined for casting from the input type to the float type
using for processing.

::

    [language=C++]
    typedef itk::CastImageFilter< CharImageType, RealImageType> CastToRealFilterType;

The \doxygen{AntiAliasBinaryImageFilter} is instantiated using the float image
type.

::

    [language=C++]
    AntiAliasFilterType::Pointer antiAliasFilter = AntiAliasFilterType::New();

    reader->SetFileName( inputFilename  );

    The output of an edge filter is 0 or 1
    rescale->SetOutputMinimum(   0 );
    rescale->SetOutputMaximum( 255 );

    toReal->SetInput( reader->GetOutput() );

    antiAliasFilter->SetInput( toReal->GetOutput() );
    antiAliasFilter->SetMaximumRMSError( maximumRMSError );
    antiAliasFilter->SetNumberOfIterations( numberOfIterations );
    antiAliasFilter->SetNumberOfLayers( 2 );

    RealWriterType::Pointer realWriter = RealWriterType::New();
    realWriter->SetInput( antiAliasFilter->GetOutput() );
    realWriter->SetFileName( outputFilename1 );

    try
    {
    realWriter->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return EXIT_FAILURE;
    }


    WriterType::Pointer rescaledWriter = WriterType::New();
    rescale->SetInput( antiAliasFilter->GetOutput() );
    rescaledWriter->SetInput( rescale->GetOutput() );
    rescaledWriter->SetFileName( outputFilename2 );
    try
    {
    rescaledWriter->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return EXIT_FAILURE;
    }

    std::cout << "Completed in " << antiAliasFilter->GetNumberOfIterations() << std::endl;

