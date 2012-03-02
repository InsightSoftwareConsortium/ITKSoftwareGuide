.. _sec-CreatingAPolyLineParametricPath:

Creating a PolyLineParametricPath
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``PolyLineParametricPath1.cxx``.

This example illustrates how to use the :itkdox:`itk::PolyLineParametricPath`. This
class will typically be used for representing in a concise way the
output of an image segmentation algorithm in 2D. The
:itkdox:`itk::PolyLineParametricPath` however could also be used for representing any
open or close curve in N-Dimensions as a linear piece-wise
approximation.

First, the header file of the :itkdox:`itk::PolyLineParametricPath` class must be
included.

::

    #include "itkPolyLineParametricPath.h"

The path is instantiated over the dimension of the image. In this case
2D.

::

    const unsigned int Dimension = 2;

    typedef itk::Image< unsigned char, Dimension > ImageType;

    typedef itk::PolyLineParametricPath< Dimension > PathType;

::


    ImageType::ConstPointer image = reader->GetOutput();


    PathType::Pointer path = PathType::New();


    path->Initialize();


    typedef PathType::ContinuousIndexType    ContinuousIndexType;

    ContinuousIndexType cindex;

    typedef ImageType::PointType             ImagePointType;

    ImagePointType origin = image->GetOrigin();


    ImageType::SpacingType spacing = image->GetSpacing();
    ImageType::SizeType    size    = image->GetBufferedRegion().GetSize();

    ImagePointType point;

    point[0] = origin[0] + spacing[0] * size[0];
    point[1] = origin[1] + spacing[1] * size[1];

    image->TransformPhysicalPointToContinuousIndex( origin, cindex );

    path->AddVertex( cindex );

    image->TransformPhysicalPointToContinuousIndex( point, cindex );

    path->AddVertex( cindex );

