.. _sec-EllipseSpatialObject:

EllipseSpatialObject
~~~~~~~~~~~~~~~~~~~~


The source code for this section can be found in the file
``EllipseSpatialObject.cxx``.

:itkdox:`itk::EllipseSpatialObject` defines an n-Dimensional ellipse. Like other
spatial objects this class derives from :itkdox:`itk::SpatialObject`. Let’s start by
including the appropriate header file.

::

    #include "itkEllipseSpatialObject.h"

Like most of the SpatialObjects, the :itkdox:`itk::EllipseSpatialObject` is
templated over the dimension of the space. In this example we create a
3-dimensional ellipse.

::

    typedef itk::EllipseSpatialObject<3>   EllipseType;
    EllipseType::Pointer myEllipse = EllipseType::New();

Then we set a radius for each dimension. By default the radius is set to
1.

::

    EllipseType::ArrayType radius;
    for(unsigned int i = 0; i<3; i++)
      {
      radius[i] = i;
      }

    myEllipse->SetRadius(radius);

Or if we have the same radius in each dimension we can do

::

    myEllipse->SetRadius(2.0);

We can then display the current radius by using the ``GetRadius()``
function:

::

    EllipseType::ArrayType myCurrentRadius = myEllipse->GetRadius();
    std::cout << "Current radius is " << myCurrentRadius << std::endl;

Like other SpatialObjects, we can query the object if a point is inside the
object by using the ``IsInside(itk::Point)`` function. This function expects
the point to be in world coordinates.

::

    itk::Point<double,3> insidePoint;
    insidePoint.Fill(1.0);
    if(myEllipse->IsInside(insidePoint))
      {
      std::cout << "The point " << insidePoint;
      std::cout << " is really inside the ellipse" << std::endl;
      }

    itk::Point<double,3> outsidePoint;
    outsidePoint.Fill(3.0);
    if(!myEllipse->IsInside(outsidePoint))
      {
      std::cout << "The point " << outsidePoint;
      std::cout << " is really outside the ellipse" << std::endl;
      }

All spatial objects can be queried for a value at a point. The
``IsEvaluableAt()`` function returns a boolean to know if the object is
evaluable at a particular point.

::

    if(myEllipse->IsEvaluableAt(insidePoint))
      {
      std::cout << "The point " << insidePoint;
      std::cout << " is evaluable at the point " << insidePoint << std::endl;
      }

If the object is evaluable at that point, the ``ValueAt()`` function
returns the current value at that position. Most of the objects returns
a boolean value which is set to true when the point is inside the object
and false when it is outside. However, for some objects, it is more
interesting to return a value representing, for instance, the distance
from the center of the object or the distance from from the boundary.

::

    double value;
    myEllipse->ValueAt(insidePoint,value);
    std::cout << "The value inside the ellipse is: " << value << std::endl;

Like other spatial objects, we can also query the bounding box of the
object by using ``GetBoundingBox()``. The resulting bounding box is
expressed in the local frame.

::

    myEllipse->ComputeBoundingBox();
    EllipseType::BoundingBoxType * boundingBox = myEllipse->GetBoundingBox();
    std::cout << "Bounding Box: " << boundingBox->GetBounds() << std::endl;

