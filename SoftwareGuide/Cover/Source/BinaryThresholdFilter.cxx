
#include <fstream>
#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkBinaryThresholdImageFilter.h"


int
main(int argc, char * argv[])
{

  if (argc < 5)
  {
    std::cerr << "BinaryThresholdFilter  inputFile outputFile lowerThreshold upperThreshold" << std::endl;
    return -1;
  }

  using InputPixelType = signed short;
  using InputImageType = itk::Image<InputPixelType, 3>;


  using OutputPixelType = unsigned char;
  using OutputImageType = itk::Image<OutputPixelType, 3>;

  using ImageReaderType = itk::ImageFileReader<InputImageType>;
  using ImageWriterType = itk::ImageFileWriter<OutputImageType>;

  using FilterType = itk::BinaryThresholdImageFilter<InputImageType, OutputImageType>;

  auto filter = FilterType::New();

  filter->ReleaseDataFlagOn();

  auto imageReader = ImageReaderType::New();
  imageReader->SetFileName(argv[1]);


  try
  {
    imageReader->Update();
  }
  catch (const itk::ExceptionObject & excp)
  {
    std::cerr << excp << std::endl;
    return -1;
  }

  filter->SetInput(imageReader->GetOutput());


  filter->SetInsideValue(255);
  filter->SetOutsideValue(0);

  const InputPixelType lowerThreshold = atoi(argv[3]);
  const InputPixelType upperThreshold = atoi(argv[4]);

  filter->SetLowerThreshold(lowerThreshold);
  filter->SetUpperThreshold(upperThreshold);


  try
  {
    filter->Update();
  }
  catch (const itk::ExceptionObject & excp)
  {
    std::cerr << excp << std::endl;
    return -1;
  }

  auto imageWriter = ImageWriterType::New();

  imageWriter->SetFileName(argv[2]);

  imageWriter->SetInput(filter->GetOutput());


  try
  {
    imageWriter->Update();
  }
  catch (const itk::ExceptionObject & excp)
  {
    std::cerr << excp << std::endl;
    return -1;
  }


  return 0;
}
