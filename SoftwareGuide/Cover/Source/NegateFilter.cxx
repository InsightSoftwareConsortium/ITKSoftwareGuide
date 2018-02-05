/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    NegateFilter.cxx
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
#include "itkUnaryFunctorImageFilter.h"
#include "itkImage.h"

namespace itk
{

class Negate
{
public:
  Negate() {}
  ~Negate() {}
  inline unsigned char operator()( const unsigned char & A )
  {
    return (A==0)?255:0;
  }
};


template <class TImage >
class ITK_EXPORT NegateImageFilter :
    public
UnaryFunctorImageFilter<TImage,TImage, Negate   >
{
public:
  /** Standard class type aliases. */
  using Self = NegateImageFilter;
  using Superclass = UnaryFunctorImageFilter<TImage,TImage, Negate >;
  using Pointer = SmartPointer<Self>;
  using ConstPointer = SmartPointer<const Self>;

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

protected:
  NegateImageFilter() {}
  virtual ~NegateImageFilter() {}

private:
  NegateImageFilter(const Self&); //purposely not implemented
  void operator=(const Self&); //purposely not implemented

};


} // end namespace itk

int main( int argc, char ** argv )
{

  // Verify the number of parameters in the command line
  if( argc < 3 )
    {
    std::cerr << "Usage: " << std::endl;
    std::cerr << argv[0] << " inputImageFile  outputImageFile " << std::endl;
    return -1;
    }


  using PixelType = unsigned char;

  constexpr unsigned int Dimension = 3;

  using ImageType = itk::Image< PixelType,  Dimension >;

  using ReaderType = itk::ImageFileReader< ImageType >;
  using WriterType = itk::ImageFileWriter< ImageType >;

  using FilterType = itk::NegateImageFilter< ImageType >;

  FilterType::Pointer filter = FilterType::New();


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



