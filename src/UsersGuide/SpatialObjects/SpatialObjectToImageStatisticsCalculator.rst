.. _sec-SpatialObjectToImageStatisticsCalculator:

Statistics Computation via SpatialObjects
-----------------------------------------

The source code for this section can be found in the file
``SpatialObjectToImageStatisticsCalculator.cxx``.

This example describes how to use the
:itkdox:`itk::SpatialObjectToImageStatisticsCalculator` to compute statistics of an
:itkdox:`itk::Image` only in a region defined inside a given :itkdox:`itk::SpatialObject`.

::

    #include "itkSpatialObjectToImageStatisticsCalculator.h"

We first create a test image using the :itkdox:`itk::RandomImageSource`

::

    typedef itk::Image<unsigned char,2> ImageType;
    typedef itk::RandomImageSource<ImageType> RandomImageSourceType;
    RandomImageSourceType::Pointer randomImageSource = RandomImageSourceType::New();
    ImageType::SizeValueType size[2];
    size[0] = 10;
    size[1] = 10;
    randomImageSource->SetSize(size);
    randomImageSource->Update();
    ImageType::Pointer image = randomImageSource->GetOutput();

Next we create an :itkdox:`itk::EllipseSpatialObject` with a radius of 2. We also
move the ellipse to the center of the image by increasing the offset of
the IndexToObjectTransform.

::

    typedef itk::EllipseSpatialObject<2> EllipseType;
    EllipseType::Pointer ellipse = EllipseType::New();
    ellipse->SetRadius(2);
    EllipseType::VectorType offset;
    offset.Fill(5);
    ellipse->GetIndexToObjectTransform()->SetOffset(offset);
    ellipse->ComputeObjectToParentTransform();

Then we can create the :itkdox:`itk::SpatialObjectToImageStatisticsCalculator`

::

    typedef itk::SpatialObjectToImageStatisticsCalculator<
    ImageType, EllipseType > CalculatorType;
    CalculatorType::Pointer calculator = CalculatorType::New();

We pass a pointer to the image to the calculator.

::

    calculator->SetImage(image);

And we also pass the SpatialObject. The statistics will be computed
inside the SpatialObject (Internally the calculator is using the
``IsInside()`` function).

::

    calculator->SetSpatialObject(ellipse);

At the end we trigger the computation via the ``Update()`` function and we
can retrieve the mean and the covariance matrix using ``GetMean()`` and
``GetCovarianceMatrix()`` respectively.

::

    calculator->Update();
    std::cout << "Sample mean = " << calculator->GetMean() << std::endl ;
    std::cout << "Sample covariance = " << calculator->GetCovarianceMatrix();


