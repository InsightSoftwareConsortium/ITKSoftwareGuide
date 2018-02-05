/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    ImageReadExtractWriteRGB.cxx
  Language:  C++
  Date:      $Date$
  Version:   $Revision$

  Copyright (c) 2002 Insight Consortium. All rights reserved.
  See ITKCopyright.txt or https://www.itk.org/HTML/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notices for more information.

=========================================================================*/



#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkRegionOfInterestImageFilter.h"
#include "itkImage.h"
#include "itkRGBPixel.h"


int main( int argc, char ** argv )
{

  // Verify the number of parameters in the command line
  if( argc < 9 )
    {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << " inputImageFile  outputImageFile " << std::endl;
    std::cerr << " startX startY startZ sizeX sizeY sizeZ" << std::endl;
    return -1;
    }


  using PixelComponentType = unsigned char;

  using PixelType = itk::RGBPixel< PixelComponentType >;

  constexpr unsigned int Dimension = 3;

  using ImageType = itk::Image< PixelType, Dimension >;



  using ReaderType = itk::ImageFileReader< ImageType >;
  using WriterType = itk::ImageFileWriter< ImageType >;




  using FilterType = itk::RegionOfInterestImageFilter< ImageType, ImageType >;

  FilterType::Pointer filter = FilterType::New();



  ImageType::IndexType start;

  start[0] = atoi( argv[3] );
  start[1] = atoi( argv[4] );
  start[2] = atoi( argv[5] );


  ImageType::SizeType size;

  size[0] = atoi( argv[6] );
  size[1] = atoi( argv[7] );
  size[2] = atoi( argv[8] );


  ImageType::RegionType wantedRegion;

  wantedRegion.SetSize(  size  );
  wantedRegion.SetIndex( start );




  filter->SetRegionOfInterest( wantedRegion );



  ReaderType::Pointer reader = ReaderType::New();
  WriterType::Pointer writer = WriterType::New();




  //
  // Here we recover the file names from the command line arguments
  //
  const char * inputFilename  = argv[1];
  const char * outputFilename = argv[2];





  reader->SetFileName( inputFilename  );
  writer->SetFileName( outputFilename );



  filter->SetInput( reader->GetOutput() );

  writer->SetInput( filter->GetOutput() );




  try
    {
    writer->Update();
    }
  catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return -1;
    }



  return 0;


}



