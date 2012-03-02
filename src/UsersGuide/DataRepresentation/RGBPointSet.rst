.. _sec-PointSetWithRGBAsPixelType:

RGB as Pixel Type
~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``RGBPointSet.cxx``.

The following example illustrates how a point set can be parameterized
to manage a particular pixel type. In this case, pixels of RGB type are
used. The first step is then to include the header files of the
:itkdox:`itk::RGBPixel` and :itkdox:`itk::PointSet` classes.

::

    #include "itkRGBPixel.h"
    #include "itkPointSet.h"

Then, the pixel type can be defined by selecting the type to be used to
represent each one of the RGB components.

::

    typedef itk::RGBPixel< float >    PixelType;

The newly defined pixel type is now used to instantiate the PointSet
type and subsequently create a point set object.

::

    typedef itk::PointSet< PixelType, 3 > PointSetType;
    PointSetType::Pointer  pointSet = PointSetType::New();

The following code is generating a sphere and assigning RGB values to
the points. The components of the RGB values in this example are
computed to represent the position of the points.

::

    PointSetType::PixelType   pixel;
    PointSetType::PointType   point;
    unsigned int pointId =  0;
    const double radius = 3.0;

    for(unsigned int i=0; i<360; i++)
      {
      const double angle = i * vnl_math::pi / 180.0;
      point[0] = radius * vcl_sin( angle );
      point[1] = radius * vcl_cos( angle );
      point[2] = 1.0;
      pixel.SetRed(    point[0] * 2.0 );
      pixel.SetGreen(  point[1] * 2.0 );
      pixel.SetBlue(   point[2] * 2.0 );
      pointSet->SetPoint( pointId, point );
      pointSet->SetPointData( pointId, pixel );
      pointId++;
      }

All the points on the PointSet are visited using the following code.

::

    typedef  PointSetType::PointsContainer::ConstIterator     PointIterator;
    PointIterator pointIterator = pointSet->GetPoints()->Begin();
    PointIterator pointEnd      = pointSet->GetPoints()->End();
    while( pointIterator != pointEnd )
      {
      point = pointIterator.Value();
      std::cout << point << std::endl;
      ++pointIterator;
      }

Note that here the ``ConstIterator`` was used instead of the ``Iterator``
since the pixel values are not expected to be modified. ITK supports
const-correctness at the API level.

All the pixel values on the PointSet are visited using the following
code.

::

    typedef  PointSetType::PointDataContainer::ConstIterator     PointDataIterator;
    PointDataIterator pixelIterator = pointSet->GetPointData()->Begin();
    PointDataIterator pixelEnd      = pointSet->GetPointData()->End();
    while( pixelIterator != pixelEnd )
      {
      pixel = pixelIterator.Value();
      std::cout << pixel << std::endl;
      ++pixelIterator;
      }

Again, please note the use of the ``ConstIterator`` instead of the
``Iterator``.
