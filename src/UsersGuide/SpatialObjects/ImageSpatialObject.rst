.. _sec-ImageSpatialObject:

ImageSpatialObject
~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``ImageSpatialObject.cxx``.

An :itkdox:`itk::ImageSpatialObject` contains an :itkdox:`itk::Image` but adds
the notion of spatial transformations and parent-child hierarchy. Let’s begin
the next example by including the appropriate header file.

::

    #include "itkImageSpatialObject.h"

We first create a simple 2D image of size 10 by 10 pixels.

::

    typedef itk::Image<short,2> Image;
    Image::Pointer image = Image::New();
    Image::SizeType size = {{ 10, 10 }};
    Image::RegionType region;
    region.SetSize(size);
    image->SetRegions(region);
    image->Allocate();

Next we fill the image with increasing values.

::

    typedef itk::ImageRegionIterator<Image> Iterator;
    Iterator it(image,region);
    short pixelValue =0;
    it.GoToBegin();
    for(; !it.IsAtEnd(); ++it, ++pixelValue)
      {
      it.Set(pixelValue);
      }

We can now define the :itkdox:`itk::ImageSpatialObject` which is templated over
the dimension and the pixel type of the image.

::

    typedef itk::ImageSpatialObject<2,short> ImageSpatialObject;
    ImageSpatialObject::Pointer imageSO = ImageSpatialObject::New();

Then we set the itkImage to the :itkdox:`itk::ImageSpatialObject` by using the
``SetImage()`` function.

::

    imageSO->SetImage(image);

At this point we can use ``IsInside()``, ``ValueAt()`` and ``DerivativeAt()``
functions inherent in SpatialObjects. The ``IsInside()`` value can be useful
when dealing with registration.

::

    typedef itk::Point<double,2> Point;
    Point insidePoint;
    insidePoint.Fill(9);

    if( imageSO->IsInside(insidePoint) )
      {
      std::cout << insidePoint << " is inside the image." << std::endl;
      }

The ``ValueAt()`` returns the value of the closest pixel, i.e no
interpolation, to a given physical point.

::

    double returnedValue;
    imageSO->ValueAt(insidePoint,returnedValue);

    std::cout << "ValueAt(" << insidePoint << ") = " << returnedValue << std::endl;

The derivative at a specified position in space can be computed using the
``DerivativeAt()`` function. The first argument is the point in physical
coordinates where we are evaluating the derivatives. The second argument is the
order of the derivation, and the third argument is the result expressed as a
:itkdox:`itk::Vector`. Derivatives are computed iteratively using finite
differences and, like the ``ValueAt()``, no interpolator is used.

::

    ImageSpatialObject::OutputVectorType returnedDerivative;
    imageSO->DerivativeAt(insidePoint,1,returnedDerivative);
    std::cout << "First derivative at " << insidePoint;
    std::cout << " = " << returnedDerivative << std::endl;

