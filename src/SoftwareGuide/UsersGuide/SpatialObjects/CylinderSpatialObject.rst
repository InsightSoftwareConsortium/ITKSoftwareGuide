.. _sec-CylinderSpatialObject:

CylinderSpatialObject
~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``CylinderSpatialObject.cxx``.

This example shows how to create a :itkdox:`itk::CylinderSpatialObject`. Let’s
begin by including the appropriate header file.

::

    #include "itkCylinderSpatialObject.h"

An :itkdox:`itk::CylinderSpatialObject` exists only in 3D, therefore, it is
not templated.

::

    typedef itk::CylinderSpatialObject   CylinderType;

We create a cylinder using the standard smart pointers.

::

    CylinderType::Pointer myCylinder = CylinderType::New();

The radius of the cylinder is set using the ``SetRadius()`` function. By
default the radius is set to 1.

::

    double radius = 3.0;
    myCylinder->SetRadius(radius);

The height of the cylinder is set using the ``SetHeight()`` function. By
default the cylinder is defined along the X axis (first dimension).

::

    double height = 12.0;
    myCylinder->SetHeight(height);

Like any other ``SpatialObject`` s, the ``IsInside()`` function can be used
to query if a point is inside or outside the cylinder.

::

    itk::Point<double,3> insidePoint;
    insidePoint[0]=1;
    insidePoint[1]=2;
    insidePoint[2]=0;
    std::cout << "Is my point "<< insidePoint << " inside the cylinder? : "
    << myCylinder->IsInside(insidePoint) << std::endl;

We can print the cylinder information using the ``Print()`` function.

::

    myCylinder->Print(std::cout);

