#include "itkImage.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkRGBPixel.h"
#include "itkImageRegionIterator.h"


int
main(int argc, char * argv[])
{

  if (argc < 3)
  {
    std::cerr << "VWBlueRemoval  inputFile outputFile" << std::endl;
    return -1;
  }

  using PixelComponentType = unsigned char;
  using ImagePixelType = itk::RGBPixel<PixelComponentType>;

  using ImageType = itk::Image<ImagePixelType, 3>;

  using ImageReaderType = itk::ImageFileReader<ImageType>;
  using ImageWriterType = itk::ImageFileWriter<ImageType>;


  ImageType::Pointer image;

  { // Local scoope for destroying the reader
    auto imageReader = ImageReaderType::New();
    imageReader->SetFileName(argv[1]);
    try
    {
      imageReader->Update();
    }
    catch (const itk::ExceptionObject & excp)
    {
      std::cout << excp << std::endl;
      return -1;
    }

    image = imageReader->GetOutput();
  }

  using IteratorType = itk::ImageRegionIterator<ImageType>;

  IteratorType it(image, image->GetBufferedRegion());
  it.GoToBegin();


  //
  // Separatrix Plane Coefficients
  //
  const double     A = -48.0;
  constexpr double B = 0.0;
  constexpr double C = 59.0;
  constexpr double D = 106.0;


  //
  // RGB color to replace blue
  //
  ImagePixelType replaceValue;
  replaceValue[0] = 0;
  replaceValue[1] = 0;
  replaceValue[2] = 0;


  //
  //  In place replacement
  //
  while (!it.IsAtEnd())
  {
    ImagePixelType           pixel = it.Get();
    const PixelComponentType red = pixel.GetRed();
    const PixelComponentType green = pixel.GetGreen();
    const PixelComponentType blue = pixel.GetBlue();

    const double distanceToPlane = A * red + B * green + C * blue + D;

    const bool pixelIsOnBlueSide = (distanceToPlane > 0);

    if (pixelIsOnBlueSide)
    {
      it.Set(replaceValue);
    }
    ++it;
  }


  auto imageWriter = ImageWriterType::New();

  imageWriter->SetFileName(argv[2]);
  imageWriter->SetInput(image);


  try
  {
    imageWriter->Update();
  }
  catch (const itk::ExceptionObject & excp)
  {
    std::cout << excp << std::endl;
    return -1;
  }


  return 0;
}
