/*=========================================================================

  Program:   Insight Segmentation & Registration Toolkit
  Module:    ModelBasedSegmentation.cxx
  Language:  C++
  Date:      $Date$
  Version:   $Revision$

  Copyright (c) 2002 Insight Consortium. All rights reserved.
  See ITKCopyright.txt or https://www.itk.org/HTML/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notices for more information.

=========================================================================*/


#include "itkEllipseSpatialObject.h"
#include "itkImageToSpatialObjectRegistrationMethod.h"
#include "itkImageToSpatialObjectMetric.h"
#include "itkLinearInterpolateImageFunction.h"
#include "itkTranslationTransform.h"
#include "itkOnePlusOneEvolutionaryOptimizer.h"
#include "itkDiscreteGaussianImageFilter.h"
#include "itkNormalVariateGenerator.h"
#include "itkImageFileReader.h"
#include "itkImageFileWriter.h"
#include "itkCommand.h"


template <class TOptimizer>
class IterationCallback : public itk::Command
{

public:
  using Self = IterationCallback;
  using Superclass = itk::Command;
  using Pointer = itk::SmartPointer<Self>;
  using ConstPointer = itk::SmartPointer<const Self>;

  itkTypeMacro(IterationCallback, Superclass);
  itkNewMacro(Self);

  /** Type defining the optimizer */
  using OptimizerType = TOptimizer;

  /** Set Optimizer */
  void
  SetOptimizer(OptimizerType * optimizer)
  {
    m_Optimizer = optimizer;
    m_Optimizer->AddObserver(itk::IterationEvent(), this);
  }


  /** Execute method will print data at each iteration */
  void
  Execute(itk::Object * caller, const itk::EventObject & event)
  {
    Execute((const itk::Object *)caller, event);
  }

  void
  Execute(const itk::Object *, const itk::EventObject & event)
  {
    if (typeid(event) == typeid(itk::StartEvent))
    {
      std::cout << std::endl << "Position              Value";
      std::cout << std::endl << std::endl;
    }
    else if (typeid(event) == typeid(itk::IterationEvent))
    {
      std::cout << m_Optimizer->GetCurrentIteration() << "   ";
      std::cout << m_Optimizer->GetValue() << "   ";
      std::cout << m_Optimizer->GetCurrentPosition() << std::endl;
    }
    else if (typeid(event) == typeid(itk::EndEvent))
    {
      std::cout << std::endl << std::endl;
      std::cout << "After " << m_Optimizer->GetCurrentIteration();
      std::cout << "  iterations " << std::endl;
      std::cout << "Solution is    = " << m_Optimizer->GetCurrentPosition();
      std::cout << std::endl;
    }
  }


protected:
  IterationCallback(){};
  itk::WeakPointer<OptimizerType> m_Optimizer;
};


template <typename TFixedImage, typename TMovingSpatialObject>
class SimpleImageToSpatialObjectMetric : public itk::ImageToSpatialObjectMetric<TFixedImage, TMovingSpatialObject>
{
public:
  /** Standard class type aliases. */
  using Self = SimpleImageToSpatialObjectMetric;
  using Superclass = itk::ImageToSpatialObjectMetric<TFixedImage, TMovingSpatialObject>;
  using Pointer = itk::SmartPointer<Self>;
  using ConstPointer = itk::SmartPointer<const Self>;

  /** Image dimension. */
  itkStaticConstMacro(ImageDimension, unsigned int, TFixedImage::ImageDimension);

  using PointType = itk::Point<double, ImageDimension>;
  using PointListType = std::list<PointType>;
  using MovingSpatialObjectType = TMovingSpatialObject;
  using ParametersType = typename Superclass::ParametersType;
  using DerivativeType = typename Superclass::DerivativeType;
  using MeasureType = typename Superclass::MeasureType;
  using IndexType = typename TFixedImage::IndexType;
  using RegionType = typename TFixedImage::RegionType;

  /** Method for creation through the object factory. */
  itkNewMacro(Self);

  /** Run-time type information (and related methods). */
  itkTypeMacro(SimpleImageToSpatialObjectMetric, ImageToSpatialObjectMetric);

  enum
  {
    SpaceDimension = 3
  };

  /** Connect the MovingSpatialObject */
  void
  SetMovingSpatialObject(const MovingSpatialObjectType * object)
  {
    if (!this->GetFixedImage())
    {
      std::cout << "Please set the image before the moving spatial object" << std::endl;
      return;
    }
    this->m_MovingSpatialObject = object;
    this->m_PointList.clear();
    using myIteratorType = itk::ImageRegionConstIteratorWithIndex<TFixedImage>;

    RegionType region;
    if (m_FixedImageRegionSetByUser)
    {
      region = m_FixedImageRegion;
    }
    else
    {
      region = this->m_FixedImage->GetBufferedRegion();
    }

    myIteratorType it(this->m_FixedImage, region);

    PointType point;

    while (!it.IsAtEnd())
    {
      this->m_FixedImage->TransformIndexToPhysicalPoint(it.GetIndex(), point);
      if (this->m_MovingSpatialObject->IsInside(point))
      {
        this->m_PointList.push_back(point);
      }
      ++it;
    }

    std::cout << "Number of points in the metric = " << static_cast<unsigned long>(m_PointList.size()) << std::endl;
  }

  unsigned int
  GetNumberOfParameters() const
  {
    return SpaceDimension;
  };

  /** Get the Derivatives of the Match Measure */
  void
  GetDerivative(const ParametersType &, DerivativeType &) const
  {
    return;
  }


  void
  SetFixedImageRegion(const RegionType & region)
  {
    m_FixedImageRegionSetByUser = true;
    m_FixedImageRegion = region;
  }

  /** Get the Value for SingleValue Optimizers */

  MeasureType
  GetValue(const ParametersType & parameters) const
  {
    double value;
    this->m_Transform->SetParameters(parameters);

    typename PointListType::const_iterator it = m_PointList.begin();

    typename TFixedImage::RegionType region = this->m_FixedImage->GetBufferedRegion();

    IndexType index;

    value = 0;
    while (it != m_PointList.end())
    {
      PointType transformedPoint = this->m_Transform->TransformPoint(*it);
      this->m_FixedImage->TransformPhysicalPointToIndex(transformedPoint, index);
      if (region.IsInside(index))
      {
        value += this->m_FixedImage->GetPixel(index);
      }
      it++;
    }
    //    std::cout << "GetValue( " << parameters << " )  = " << value << std::endl;
    return value;
  }

  /** Get Value and Derivatives for MultipleValuedOptimizers */
  void
  GetValueAndDerivative(const ParametersType & parameters, MeasureType & Value, DerivativeType & Derivative) const
  {
    Value = this->GetValue(parameters);
    this->GetDerivative(parameters, Derivative);
  }

protected:
  SimpleImageToSpatialObjectMetric() { m_FixedImageRegionSetByUser = false; }
  ~SimpleImageToSpatialObjectMetric() {}

private:
  PointListType m_PointList;

  RegionType m_FixedImageRegion;
  bool       m_FixedImageRegionSetByUser;
};


int
main(int argc, char * argv[])
{
  if (argc != 2)
  {
    std::cerr << "Usage: " << argv[0] << "InputImageFilename" << std::endl;
  }


  constexpr unsigned int Dimension = 3;

  using EllipseType = itk::EllipseSpatialObject<Dimension>;


  using ImageType = itk::Image<float, Dimension>;

  auto ellipse = EllipseType::New();


  EllipseType::ArrayType axis;
  axis[0] = 6;
  axis[1] = 3;
  axis[2] = 6;


  ellipse->SetRadius(axis);


  using RegistrationType = itk::ImageToSpatialObjectRegistrationMethod<ImageType, EllipseType>;

  auto registration = RegistrationType::New();


  using MetricType = SimpleImageToSpatialObjectMetric<ImageType, EllipseType>;

  auto metric = MetricType::New();


  using InterpolatorType = itk::LinearInterpolateImageFunction<ImageType, double>;

  auto interpolator = InterpolatorType::New();


  using OptimizerType = itk::OnePlusOneEvolutionaryOptimizer;

  OptimizerType::Pointer optimizer = OptimizerType::New();


  using TransformType = itk::TranslationTransform<double, Dimension>;
  auto transform = TransformType::New();


  itk::Statistics::NormalVariateGenerator::Pointer generator = itk::Statistics::NormalVariateGenerator::New();


  generator->Initialize(12345);

  optimizer->SetNormalVariateGenerator(generator);
  optimizer->Initialize(5);
  optimizer->SetMaximumIteration(1000);


  TransformType::ParametersType parametersScale(Dimension);

  parametersScale.Fill(2.0);

  optimizer->SetScales(parametersScale);


  using IterationCallbackType = IterationCallback<OptimizerType>;

  auto callback = IterationCallbackType::New();

  callback->SetOptimizer(optimizer);

  using ReaderType = itk::ImageFileReader<ImageType>;
  ReaderType::Pointer reader = ReaderType::New();
  reader->SetFileName(argv[1]);
  reader->Update();


  // Place the ellipse close to the optimal position
  using IndexType = ImageType::IndexType;
  IndexType initialIndexPosition;

  initialIndexPosition[0] = 26;
  initialIndexPosition[1] = 18;
  initialIndexPosition[2] = 30;

  TransformType::InputPointType initialPhysicalPosition;

  reader->GetOutput()->TransformIndexToPhysicalPoint(initialIndexPosition, initialPhysicalPosition);

  EllipseType::TransformType::OffsetType offset;
  for (unsigned int i = 0; i < Dimension; i++)
  {
    offset[i] = initialPhysicalPosition[i];
  }

  ellipse->GetObjectToParentTransform()->SetOffset(offset);
  ellipse->ComputeObjectToWorldTransform();


  using RegionType = ImageType::RegionType;
  using IndexType = ImageType::IndexType;
  using SizeType = ImageType::SizeType;

  RegionType fixedRegion;

  IndexType fixedRegionStart;
  SizeType  fixedRegionSize;

  fixedRegionStart[0] = 20;
  fixedRegionStart[1] = 15;
  fixedRegionStart[2] = 20;

  fixedRegionSize[0] = 20;
  fixedRegionSize[1] = 10;
  fixedRegionSize[2] = 25;

  fixedRegion.SetSize(fixedRegionSize);
  fixedRegion.SetIndex(fixedRegionStart);

  metric->SetFixedImageRegion(fixedRegion);

  registration->SetFixedImage(reader->GetOutput());
  registration->SetMovingSpatialObject(ellipse);
  registration->SetTransform(transform);
  registration->SetInterpolator(interpolator);
  registration->SetOptimizer(optimizer);
  registration->SetMetric(metric);

  TransformType::ParametersType initialParameters = transform->GetParameters();

  initialParameters.Fill(0.0);


  registration->SetInitialTransformParameters(initialParameters);

  std::cout << "Initial Parameters  : " << initialParameters << std::endl;

  optimizer->MaximizeOn();


  try
  {
    registration->Update();
  }
  catch (const itk::ExceptionObject & exp)
  {
    std::cerr << "Exception caught ! " << std::endl;
    std::cerr << exp << std::endl;
  }


  RegistrationType::ParametersType finalParameters = registration->GetLastTransformParameters();

  std::cout << "Final Solution is : " << finalParameters << std::endl;

  return 0;
}
