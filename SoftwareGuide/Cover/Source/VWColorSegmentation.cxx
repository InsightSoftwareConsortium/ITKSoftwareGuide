
#include <fstream>
#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkRGBPixel.h"
#include "itkImageRegionIterator.h"
#include "itkVectorConfidenceConnectedImageFilter.h"



int main(int argc, char * argv[] )
{

  if( argc < 5 )
  {
    std::cerr << "VWSegmentation  inputFile outputFile seedsFile multiplier" << std::endl;
    return -1;
  }
  
  typedef unsigned char                         PixelComponentType;
  typedef itk::RGBPixel<PixelComponentType>     ImagePixelType;
  typedef itk::Image< ImagePixelType,     3 >   ImageType;


  typedef unsigned char                          OutputPixelType;
  typedef itk::Image< OutputPixelType,     3 >   OutputImageType;

  typedef itk::ImageFileReader< ImageType  >        ImageReaderType;
  typedef itk::ImageFileWriter< OutputImageType >   ImageWriterType;

  typedef itk::VectorConfidenceConnectedImageFilter< 
                                              ImageType,
                                              OutputImageType
                                              >  ConfidenceConnectedFilterType;

  ConfidenceConnectedFilterType::Pointer 
                          confidenceFilter = ConfidenceConnectedFilterType::New();

  confidenceFilter->ReleaseDataFlagOn();

  ImageReaderType::Pointer imageReader = ImageReaderType::New();
  imageReader->SetFileName( argv[1] );
  try
    {
    imageReader->Update();
    }
  catch( itk::ExceptionObject & excp )
    {
    std::cout << excp << std::endl;
    return -1;
    }

  confidenceFilter->SetInput( imageReader->GetOutput() );


  confidenceFilter->Update();
  confidenceFilter->SetReplaceValue( 255 );
  confidenceFilter->SetNumberOfIterations( 2 );
  confidenceFilter->SetMultiplier( atof( argv[4] ) );

  std::ifstream seedsFile;
  seedsFile.open( argv[3] );

  ImageType::IndexType index;

  seedsFile >> index[0] >> index[1] >> index[2];
  while( !seedsFile.eof() );
    {
    confidenceFilter->AddSeed( index );
    seedsFile >> index[0] >> index[1] >> index[2];
    }
  
  seedsFile.close();
  

  ImageWriterType::Pointer imageWriter = ImageWriterType::New();

  imageWriter->SetFileName( argv[2] );

  imageWriter->SetInput( confidenceFilter->GetOutput() );


  try
    {
    imageWriter->Update();
    }
  catch( itk::ExceptionObject & excp )
    {
    std::cout << excp << std::endl;
    return -1;
    }

  
  return 0;
}

