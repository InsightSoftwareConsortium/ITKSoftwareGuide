/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    VectorGradientAnisotropicDiffusionFilter.cxx
  Language:  C++
  Date:      $Date$
  Version:   $Revision$

  Copyright (c) 2002 Insight Consortium. All rights reserved.
  See ITKCopyright.txt or https://www.itk.org/HTML/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notices for more information.

=========================================================================*/

#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkVectorGradientAnisotropicDiffusionImageFilter.h"
#include "itkCastImageFilter.h"
#include "itkRGBPixel.h"


int main( int argc, char * argv[] )
{

  if( argc < 5 )
    {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << "  inputImageFile  outputGradientImageFile ";
    std::cerr << "numberOfIterations  timeStep  " << std::endl;
    return 1;
    }

  using PixelComponentType = float;
  constexpr unsigned long Dimension  = 3;

  using PixelType = itk::RGBPixel< PixelComponentType >;
  using ImageType = itk::Image< PixelType, Dimension >;

  using OutputPixelType = itk::RGBPixel< unsigned char >;
  using OutputImageType = itk::Image< OutputPixelType, Dimension >;


  using ReaderType = itk::ImageFileReader< ImageType >;

  using WriterType = itk::ImageFileWriter< OutputImageType >;

  using CasterType = itk::CastImageFilter<
                               ImageType, OutputImageType >;

  using FilterType = itk::VectorGradientAnisotropicDiffusionImageFilter<
                       ImageType, ImageType >;


  auto reader = ReaderType::New();
  reader->SetFileName( argv[1] );

  auto filter = FilterType::New();

  filter->SetInput( reader->GetOutput() );

  const unsigned int numberOfIterations = atoi( argv[3] );
  const double       timeStep           = atof( argv[4] );

  filter->SetNumberOfIterations( numberOfIterations );
  filter->SetTimeStep( timeStep );
  filter->SetConductanceParameter( 3.0 );

  filter->Update();

  auto caster = CasterType::New();

  auto writer = WriterType::New();

  caster->SetInput( filter->GetOutput() );
  writer->SetInput( caster->GetOutput() );
  writer->SetFileName( argv[2] );
  writer->Update();

  return 0;

}

