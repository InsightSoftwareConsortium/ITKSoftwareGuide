.. _sec-LineSpatialObject:

LineSpatialObject
~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``LineSpatialObject.cxx``.

:itkdox:`itk::LineSpatialObject` defines a line in an n-dimensional space. A
line is defined as a list of points which compose the line, i.e a polyline. We
begin the example by including the appropriate header files.

::

    #include "itkLineSpatialObject.h"

LineSpatialObject is templated over the dimension of the space. A
LineSpatialObject contains a list of LineSpatialObjectPoints. A
LineSpatialObjectPoint has a position, :math:`n-1` normals and a color. Each
normal is expressed as a :itkdox:`itk::CovariantVector` of size N.

First, we define some type definitions and we create our line.

::

    typedef itk::LineSpatialObject<3>        LineType;
    typedef LineType::Pointer                LinePointer;
    typedef itk::LineSpatialObjectPoint<3>   LinePointType;
    typedef itk::CovariantVector<double,3>   VectorType;

    LinePointer Line = LineType::New();

We create a point list and we set the position of each point in the
local coordinate system using the ``SetPosition()`` method. We also set
the color of each point to red.

The two normals are set using the ``SetNormal()`` function; the first
argument is the normal itself and the second argument is the index of
the normal.

::

    LineType::PointListType list;

    for(unsigned int i=0; i<3; i++)
      {
      LinePointType p;
      p.SetPosition(i,i+1,i+2);
      p.SetColor(1,0,0,1);

      VectorType normal1;
      VectorType normal2;
      for(unsigned int j=0;j<3;j++)
        {
        normal1[j]=j;
        normal2[j]=j*2;
        }

      p.SetNormal(normal1,0);
      p.SetNormal(normal2,1);
      list.push_back(p);
      }

Next, we set the name of the object using ``SetName()``. We also set its
identification number with ``SetId()`` and we set the list of points
previously created.

::

    Line->GetProperty()->SetName("Line1");
    Line->SetId(1);
    Line->SetPoints(list);

The ``GetPoints()`` method returns a reference to the internal list of
points of the object.

::

    LineType::PointListType pointList = Line->GetPoints();
    std::cout << "Number of points representing the line: ";
    std::cout << pointList.size() << std::endl;

Then we can access the points using standard STL iterators. The
``GetPosition()`` and ``GetColor()`` functions return respectively the
position and the color of the point. Using the GetNormal(unsigned int)
function we can access each normal.

::

    LineType::PointListType::const_iterator it = Line->GetPoints().begin();
    while(it != Line->GetPoints().end())
      {
      std::cout << "Position = " << (*it).GetPosition() << std::endl;
      std::cout << "Color = " << (*it).GetColor() << std::endl;
      std::cout << "First normal = " << (*it).GetNormal(0) << std::endl;
      std::cout << "Second normal = " << (*it).GetNormal(1) << std::endl;
      std::cout << std::endl;
      it++;
      }

