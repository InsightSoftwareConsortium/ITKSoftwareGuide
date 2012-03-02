.. _sec-SurfaceSpatialObject:

SurfaceSpatialObject
~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``SurfaceSpatialObject.cxx``.

:itkdox:`itk::SurfaceSpatialObject` defines a surface in n-dimensional space. A
SurfaceSpatialObject is defined by a list of points which lie on the surface.
Each point has a position and a unique normal. The example begins by including
the appropriate header file.

::

    #include "itkSurfaceSpatialObject.h"

SurfaceSpatialObject is templated over the dimension of the space. A
SurfaceSpatialObject contains a list of SurfaceSpatialObjectPoints. A
SurfaceSpatialObjectPoint has a position, a normal and a color.

First we define some type definitions

::

    typedef itk::SurfaceSpatialObject<3>        SurfaceType;
    typedef SurfaceType::Pointer                SurfacePointer;
    typedef itk::SurfaceSpatialObjectPoint<3>   SurfacePointType;
    typedef itk::CovariantVector<double,3>      VectorType;

    SurfacePointer Surface = SurfaceType::New();

We create a point list and we set the position of each point in the local
coordinate system using the ``SetPosition()`` method. We also set the color of
each point to red.

::

    SurfaceType::PointListType list;

    for( unsigned int i=0; i<3; i++)
      {
      SurfacePointType p;
      p.SetPosition(i,i+1,i+2);
      p.SetColor(1,0,0,1);
      VectorType normal;
      for(unsigned int j=0;j<3;j++)
        {
        normal[j]=j;
        }
      p.SetNormal(normal);
      list.push_back(p);
      }

Next, we create the surface and set his name using ``SetName()``. We also set
its Identification number with ``SetId()`` and we add the list of points
previously created.

::

    Surface->GetProperty()->SetName("Surface1");
    Surface->SetId(1);
    Surface->SetPoints(list);

The ``GetPoints()`` method returns a reference to the internal list of
points of the object.

::

    SurfaceType::PointListType pointList = Surface->GetPoints();
    std::cout << "Number of points representing the surface: ";
    std::cout << pointList.size() << std::endl;

Then we can access the points using standard STL iterators.
``GetPosition()`` and ``GetColor()`` functions return respectively the
position and the color of the point. ``GetNormal()`` returns the normal as
a :itkdox:`itk::CovariantVector`.

::

    SurfaceType::PointListType::const_iterator it = Surface->GetPoints().begin();
    while(it != Surface->GetPoints().end())
      {
      std::cout << "Position = " << (*it).GetPosition() << std::endl;
      std::cout << "Normal = " << (*it).GetNormal() << std::endl;
      std::cout << "Color = " << (*it).GetColor() << std::endl;
      std::cout << std::endl;
      it++;
      }

