/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    RescaleIntensityFilter.cxx
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
#include "itkRescaleIntensityImageFilter.h"
#include "itkImage.h"


int main( int argc, char ** argv )
{

  // Verify the number of parameters in the command line
  if( argc < 3 )
    {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << " inputImageFile  outputImageFile " << std::endl;
    return -1;
    }


  using InputPixelType = float;
  using OutputPixelType = unsigned char;

  const   unsigned int        Dimension = 3;

  using InputImageType = itk::Image< InputPixelType,   Dimension >;
  using OutputImageType = itk::Image< OutputPixelType,  Dimension >;



  using ReaderType = itk::ImageFileReader< InputImageType >;
  using WriterType = itk::ImageFileWriter< OutputImageType >;


  using FilterType = itk::RescaleIntensityImageFilter<
                                    InputImageType,
                                    OutputImageType >;

  FilterType::Pointer filter = FilterType::New();


  ReaderType::Pointer reader = ReaderType::New();
  WriterType::Pointer writer = WriterType::New();

  const char * inputFilename  = argv[1];
  const char * outputFilename = argv[2];

  reader->SetFileName( inputFilename  );
  writer->SetFileName( outputFilename );


  filter->SetInput( reader->GetOutput() );

  writer->SetInput( filter->GetOutput() );

  filter->SetOutputMinimum(   0 );
  filter->SetOutputMaximum( 255 );

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



