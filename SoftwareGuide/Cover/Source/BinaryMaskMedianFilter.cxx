/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    BinaryMaskMedianFilter.cxx
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
#include "itkBinaryMedianImageFilter.h"
#include "itkImage.h"


int main( int argc, char ** argv )
{

  // Verify the number of parameters in the command line
  if( argc < 4 )
    {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << " inputImageFile  outputImageFile " << std::endl;
    std::cerr << " radius " << std::endl;
    return -1;
    }


  using PixelType = unsigned char;

  constexpr unsigned int Dimension = 3;

  using ImageType = itk::Image< PixelType,  Dimension >;



  using ReaderType = itk::ImageFileReader< ImageType >;
  using WriterType = itk::ImageFileWriter< ImageType >;


  using FilterType = itk::BinaryMedianImageFilter< ImageType, ImageType >;

  auto filter = FilterType::New();


  unsigned int radius = atoi( argv[3] );

  ImageType::SizeType size;

  size[0] = radius;
  size[1] = radius;
  size[2] = radius;


  filter->SetRadius( size );

  filter->SetBackgroundValue(  0  );
  filter->SetForegroundValue( 255 );


  auto reader = ReaderType::New();
  auto writer = WriterType::New();

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
  catch( const itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return -1;
    }



  return 0;


}



