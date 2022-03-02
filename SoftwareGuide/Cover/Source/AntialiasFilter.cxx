/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    AntialiasFilter.cxx
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
#include "itkAntiAliasBinaryImageFilter.h"
#include "itkImage.h"


int
main(int argc, char ** argv)
{

  // Verify the number of parameters in the command line
  if (argc < 5)
  {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << " inputImageFile  outputImageFile " << std::endl;
    std::cerr << " maximumRMSError maximumIterations " << std::endl;
    return -1;
  }


  using InputPixelType = unsigned char;
  using OutputPixelType = float;

  constexpr unsigned int Dimension = 3;

  using InputImageType = itk::Image<InputPixelType, Dimension>;
  using OutputImageType = itk::Image<OutputPixelType, Dimension>;

  using ReaderType = itk::ImageFileReader<InputImageType>;
  using WriterType = itk::ImageFileWriter<OutputImageType>;

  using FilterType = itk::AntiAliasBinaryImageFilter<InputImageType, OutputImageType>;

  auto filter = FilterType::New();


  const double            maximumRMSError = atof(argv[3]);
  const unsigned int long numberOfIterations = atol(argv[4]);

  filter->SetMaximumRMSError(maximumRMSError);
  filter->SetMaximumIterations(numberOfIterations);

  auto reader = ReaderType::New();
  auto writer = WriterType::New();

  const char * inputFilename = argv[1];
  const char * outputFilename = argv[2];

  reader->SetFileName(inputFilename);
  writer->SetFileName(outputFilename);


  filter->SetInput(reader->GetOutput());

  writer->SetInput(filter->GetOutput());


  try
  {
    writer->Update();
  }
  catch (const itk::ExceptionObject & err)
  {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return -1;
  }


  return 0;
}
