#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkRGBPixel.h"
#include "itkImageRegionConstIterator.h"


int main(int argc, char * argv[] )
{

  if( argc < 3 )
  {
    std::cerr << "VWSegmentation  inputFile histogramRGBFile" << std::endl;
    return -1;
  }

  using PixelComponentType =  unsigned char;
  using InputPixelType =  itk::RGBPixel<PixelComponentType>;
  using OutputPixelType =  unsigned short;

  using InputImageType =  itk::Image< InputPixelType, 3 >;
  using OutputImageType =  itk::Image< OutputPixelType, 3 >;

  using ReaderType =  itk::ImageFileReader< InputImageType >;
  using WriterType =  itk::ImageFileWriter< OutputImageType >;

  using RegionType =  OutputImageType::RegionType;
  using SizeType =  OutputImageType::SizeType;
  using IndexType =  OutputImageType::IndexType;

  InputImageType::Pointer inputImage;

  { // local scope for destroying the reader

    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );
    try
      {
      reader->Update();
      }
    catch( const itk::ExceptionObject & excp )
      {
      std::cout << excp << std::endl;
      return -1;
      }
    inputImage = reader->GetOutput();
  }

  RegionType region;
  SizeType   size;
  IndexType  start;

  start.Fill( 0 );

  size[0] = 256;
  size[1] = 256;
  size[2] = 256;

  region.SetSize( size );
  region.SetIndex( start );

  OutputImageType::Pointer histogramImage = OutputImageType::New();
  histogramImage->SetRegions( region );
  histogramImage->Allocate();
  histogramImage->FillBuffer( 0 );


  using IteratorType =  itk::ImageRegionConstIterator< InputImageType >;

  IteratorType it( inputImage, inputImage->GetBufferedRegion() );
  it.GoToBegin();

  IndexType index;

  while( !it.IsAtEnd() )
    {
    InputPixelType pixel = it.Get();
    PixelComponentType red   = pixel.GetRed();
    PixelComponentType green = pixel.GetGreen();
    PixelComponentType blue  = pixel.GetBlue();
    index[0] = red;
    index[1] = green;
    index[2] = blue;

    OutputPixelType count = histogramImage->GetPixel( index );
    count++;
    histogramImage->SetPixel( index, count );
    ++it;
    }


  WriterType::Pointer writer = WriterType::New();

  writer->SetFileName( argv[2] );
  writer->SetInput( histogramImage );


  try
    {
    writer->Update();
    }
  catch( const itk::ExceptionObject & excp )
    {
    std::cout << excp << std::endl;
    return -1;
    }


  return 0;
}

