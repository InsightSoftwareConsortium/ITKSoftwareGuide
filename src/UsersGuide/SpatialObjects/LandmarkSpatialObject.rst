.. _sec-LandmarkSpatialObject:

LandmarkSpatialObject
~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``LandmarkSpatialObject.cxx``.

:itkdox:`itk::LandmarkSpatialObject` contains a list of
:itkdox:`itk::SpatialObjectPoint` s which have a position and a color. Let’s
begin this example by including the appropriate header file.

::

    #include "itkLandmarkSpatialObject.h"

LandmarkSpatialObject is templated over the dimension of the space.

Here we create a 3-dimensional landmark.

::

    typedef itk::LandmarkSpatialObject<3>  LandmarkType;
    typedef LandmarkType::Pointer          LandmarkPointer;
    typedef itk::SpatialObjectPoint<3>     LandmarkPointType;

    LandmarkPointer landmark = LandmarkType::New();

Next, we set some properties of the object like its name and its
identification number.

::

    landmark->GetProperty()->SetName("Landmark1");
    landmark->SetId(1);

We are now ready to add points into the landmark. We first create a list
of SpatialObjectPoint and for each point we set the position and the
color.

::

    LandmarkType::PointListType list;

    for( unsigned int i=0; i<5; i++)
      {
      LandmarkPointType p;
      p.SetPosition(i,i+1,i+2);
      p.SetColor(1,0,0,1);
      list.push_back(p);
      }

Then we add the list to the object using the ``SetPoints()`` method.

::

    landmark->SetPoints(list);

The current point list can be accessed using the ``GetPoints()``  method.  The
method returns a reference to the (STL) list.

::

    unsigned int nPoints = landmark->GetPoints().size();
    std::cout << "Number of Points in the landmark: " << nPoints << std::endl;

    LandmarkType::PointListType::const_iterator it = landmark->GetPoints().begin();
    while(it != landmark->GetPoints().end())
      {
      std::cout << "Position: " << (*it).GetPosition() << std::endl;
      std::cout << "Color: " << (*it).GetColor() << std::endl;
      it++;
      }

