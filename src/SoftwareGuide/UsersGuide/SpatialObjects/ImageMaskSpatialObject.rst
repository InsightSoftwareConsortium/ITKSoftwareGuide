.. _sec-ImageMaskSpatialObject:

ImageMaskSpatialObject
~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``ImageMaskSpatialObject.cxx``.

An :itkdox:`itk::ImageMaskSpatialObject` is similar to the
:itkdox:`itk::ImageSpatialObject` and derived from it. However, the main
difference is that the ``IsInside()`` returns true if the pixel intensity in
the image is not zero.

The supported pixel types does not include :itkdox:`itk::RGBPixel`,
:itkdox:`itk::RGBAPixel`, etc... So far it only allows to manage images of
simple types like unsigned short, unsigned int, or :itkdox:`itk::Vector`. Let’s
begin by including the appropriate header file.

::

    #include "itkImageMaskSpatialObject.h"

The ImageMaskSpatialObject is templated over the dimensionality.

::

    typedef itk::ImageMaskSpatialObject<3> ImageMaskSpatialObject;

Next we create an :itkdox:`itk::Image` of size 50x50x50 filled with zeros
except a bright square in the middle which defines the mask.

::

    typedef ImageMaskSpatialObject::PixelType  PixelType;
    typedef ImageMaskSpatialObject::ImageType  ImageType;
    typedef itk::ImageRegionIterator<ImageType> Iterator;


    ImageType::Pointer image = ImageType::New();
    ImageType::SizeType size = {{ 50, 50, 50 }};
    ImageType::IndexType index = {{ 0, 0, 0 }};
    ImageType::RegionType region;

    region.SetSize(size);
    region.SetIndex(index);

    image->SetRegions( region );
    image->Allocate();

    PixelType p = itk::NumericTraits< PixelType >::Zero;

    image->FillBuffer( p );

    ImageType::RegionType insideRegion;
    ImageType::SizeType insideSize   = {{ 30, 30, 30 }};
    ImageType::IndexType insideIndex = {{ 10, 10, 10 }};
    insideRegion.SetSize( insideSize );
    insideRegion.SetIndex( insideIndex );

    Iterator it( image, insideRegion );
    it.GoToBegin();

    while( !it.IsAtEnd() )
      {
      it.Set( itk::NumericTraits< PixelType >::max() );
      ++it;
      }

Then, we create an ImageMaskSpatialObject.

::

    ImageMaskSpatialObject::Pointer maskSO = ImageMaskSpatialObject::New();

and we pass the corresponding pointer to the image.

::

    maskSO->SetImage(image);

We can then test if a physical :itkdox:`itk::Point` is inside or outside the
mask image. This is particularly useful during the registration process when
only a part of the image should be used to compute the metric.

::

    ImageMaskSpatialObject::PointType  inside;
    inside.Fill(20);
    std::cout << "Is my point " << inside << " inside my mask? "
    << maskSO->IsInside(inside) << std::endl;
    ImageMaskSpatialObject::PointType  outside;
    outside.Fill(45);
    std::cout << "Is my point " << outside << " outside my mask? "
    << !maskSO->IsInside(outside) << std::endl;

