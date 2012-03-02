TubeSpatialObject
^^^^^^^^^^^^^^^^^

:itkdox:`itk::TubeSpatialObject` represents a base class for the representation of
tubular structures using SpatialObjects. The classes
:itkdox:`itk::VesselTubeSpatialObject` and :itkdox:`itk::DTITubeSpatialObject` derive from this
base class. VesselTubeSpatialObject represents blood vessels extracted
for an image and DTITubeSpatialObject is used to represent fiber tracts
from diffusion tensor images.

:itkdox:`itk::TubeSpatialObject` defines an n-dimensional tube. A tube is defined as
a list of centerline points which have a position, a radius, some
normals and other properties. Let’s start by including the appropriate
header file.

::

    #include "itkTubeSpatialObject.h"

TubeSpatialObject is templated over the dimension of the space. A
TubeSpatialObject contains a list of TubeSpatialObjectPoints.

First we define some type definitions and we create the tube.

::

    typedef itk::TubeSpatialObject<3>            TubeType;
    typedef TubeType::Pointer                    TubePointer;
    typedef itk::TubeSpatialObjectPoint<3>       TubePointType;
    typedef TubePointType::CovariantVectorType   VectorType;

    TubePointer tube = TubeType::New();

We create a point list and we set:

- The position of each point in the local coordinate system using the
  ``SetPosition()`` method.

- The radius of the tube at this position using ``SetRadius()``.

- The two normals at the tube is set using ``SetNormal1()`` and
  ``SetNormal2()``.

#. The color of the point is set to red in our case.

::

    TubeType::PointListType list;
    for( i=0; i<5; i++)
      {
      TubePointType p;
      p.SetPosition(i,i+1,i+2);
      p.SetRadius(1);
      VectorType normal1;
      VectorType normal2;
      for(unsigned int j=0;j<3;j++)
        {
        normal1[j]=j;
        normal2[j]=j*2;
        }

      p.SetNormal1(normal1);
      p.SetNormal2(normal2);
      p.SetColor(1,0,0,1);

      list.push_back(p);
      }

Next, we create the tube and set its name using ``SetName()``. We also set
its identification number with ``SetId()`` and, at the end, we add the
list of points previously created.

::

    tube->GetProperty()->SetName("Tube1");
    tube->SetId(1);
    tube->SetPoints(list);

The ``GetPoints()`` method return a reference to the internal list of
points of the object.

::

    TubeType::PointListType pointList = tube->GetPoints();
    std::cout << "Number of points representing the tube: ";
    std::cout << pointList.size() << std::endl;

The ``ComputeTangentAndNormals()`` function computes the normals and the
tangent for each point using finite differences.

::

    tube->ComputeTangentAndNormals();

Then we can access the points using STL iterators. ``GetPosition()`` and
``GetColor()`` functions return respectively the position and the color of
the point. ``GetRadius()`` returns the radius at that point.
``GetNormal1()`` and ``GetNormal1()`` functions return a {:itkdox:`itk::CovariantVector`
and ``GetTangent()`` returns a :itkdox:`itk::Vector`.

::

    TubeType::PointListType::const_iterator it = tube->GetPoints().begin();
    i=0;
    while(it != tube->GetPoints().end())
      {
      std::cout << std::endl;
      std::cout << "Point #" << i << std::endl;
      std::cout << "Position: " << (*it).GetPosition() << std::endl;
      std::cout << "Radius: " << (*it).GetRadius() << std::endl;
      std::cout << "Tangent: " << (*it).GetTangent() << std::endl;
      std::cout << "First Normal: " << (*it).GetNormal1() << std::endl;
      std::cout << "Second Normal: " << (*it).GetNormal2() << std::endl;
      std::cout << "Color = " << (*it).GetColor() << std::endl;
      it++;
      i++;
      }

