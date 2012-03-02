The source code for this section can be found in the file
``ImageToPointSet.cxx``.

This example illustrates how to convert an ITK Image into a PointSet.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"


    #include "itkImage.h"
    #include "itkPointSet.h"
    #include "itkImageRegionConstIterator.h"


    int main( int argc, char * argv[] )
    {
    Verify the number of parameters in the command line
    if( argc < 2 )
    {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << " inputImageFile  " << std::endl;
    return -1;
    }


    typedef unsigned char      PixelType;
    const   unsigned int       Dimension = 2;

    typedef itk::Image< PixelType, Dimension >    ImageType;
    typedef itk::PointSet< PixelType, Dimension > PointSetType;
    typedef itk::ImageFileReader< ImageType >     ReaderType;

    ReaderType::Pointer reader = ReaderType::New();

    const char * inputFilename  = argv[1];
    reader->SetFileName( inputFilename  );

    try
    {
    reader->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return -1;
    }

    PointSetType::Pointer  pointSet = PointSetType::New();


    typedef itk::ImageRegionConstIterator< ImageType > IteratorType;

    const ImageType * image = reader->GetOutput();

    IteratorType it( image, image->GetBufferedRegion() );

    it.GoToBegin();


    typedef PointSetType::PointType     PointType;
    PointType point;

    unsigned long pointId = 0;

    while( !it.IsAtEnd() )
    {

    Convert the pixel position into a Point
    image->TransformIndexToPhysicalPoint( it.GetIndex() , point );
    pointSet->SetPoint( pointId, point );

    Transfer the pixel data to the value associated with the point.
    pointSet->SetPointData( pointId, it.Get() );

    ++it;
    ++pointId;
    }


    std::cout << "Number Of Points = ";
    std::cout << pointSet->GetNumberOfPoints() << std::endl;

