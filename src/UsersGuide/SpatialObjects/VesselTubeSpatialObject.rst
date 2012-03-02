.. _sec-VesselTubeSpatialObject:

VesselTubeSpatialObject
^^^^^^^^^^^^^^^^^^^^^^^

The source code for this section can be found in the file
``VesselTubeSpatialObject.cxx``.

:itkdox:`itk::VesselTubeSpatialObject` derives from
:itkdox:`itk::TubeSpatialObject`. It represents a blood vessel segmented from
an image. A :itkdox:`itk::VesselTubeSpatialObject` is described as a list of centerline points
which have a position, a radius, normals,

Let’s start by including the appropriate header file.

::

    #include "itkVesselTubeSpatialObject.h"

VesselTubeSpatialObject is templated over the dimension of the space. A
VesselTubeSpatialObject contains a list of
VesselTubeSpatialObjectPoints.

First we define some type definitions and we create the tube.

::

    typedef itk::VesselTubeSpatialObject<3>            VesselTubeType;
    typedef itk::VesselTubeSpatialObjectPoint<3>       VesselTubePointType;

    VesselTubeType::Pointer VesselTube = VesselTubeType::New();

We create a point list and we set:

- The position of each point in the local coordinate system using the
  ``SetPosition()`` method.

- The radius of the tube at this position using ``SetRadius()``.

- The medialness value describing how the point lies in the middle of
   the vessel using ``SetMedialness()``.

- The ridgeness value describing how the point lies on the ridge using
   ``SetRidgeness()``.

- The branchness value describing if the point is a branch point using
   ``SetBranchness()``.

- The three alpha values corresponding to the eigenvalues of the
   Hessian using ``SetAlpha1()``,``SetAlpha2()`` and ``SetAlpha3()``.

- The mark value using ``SetMark()``.

- The color of the point is set to red in this example with an opacity
   of 1.

::

    VesselTubeType::PointListType list;
    for( i=0; i<5; i++)
      {
      VesselTubePointType p;
      p.SetPosition(i,i+1,i+2);
      p.SetRadius(1);
      p.SetAlpha1(i);
      p.SetAlpha2(i+1);
      p.SetAlpha3(i+2);
      p.SetMedialness(i);
      p.SetRidgeness(i);
      p.SetBranchness(i);
      p.SetMark(true);
      p.SetColor(1,0,0,1);
      list.push_back(p);
      }

Next, we create the tube and set its name using ``SetName()``. We also set
its identification number with ``SetId()`` and, at the end, we add the
list of points previously created.

::

    VesselTube->GetProperty()->SetName("VesselTube");
    VesselTube->SetId(1);
    VesselTube->SetPoints(list);

The ``GetPoints()`` method return a reference to the internal list of
points of the object.

::

    VesselTubeType::PointListType pointList = VesselTube->GetPoints();
    std::cout << "Number of points representing the blood vessel: ";
    std::cout << pointList.size() << std::endl;

Then we can access the points using STL iterators. ``GetPosition()`` and
``GetColor()`` functions return respectively the position and the color of
the point.

::

    VesselTubeType::PointListType::const_iterator
    it = VesselTube->GetPoints().begin();
    i=0;
    while(it != VesselTube->GetPoints().end())
      {
      std::cout << std::endl;
      std::cout << "Point #" << i << std::endl;
      std::cout << "Position: " << (*it).GetPosition() << std::endl;
      std::cout << "Radius: " << (*it).GetRadius() << std::endl;
      std::cout << "Medialness: " << (*it).GetMedialness() << std::endl;
      std::cout << "Ridgeness: " << (*it).GetRidgeness() << std::endl;
      std::cout << "Branchness: " << (*it).GetBranchness() << std::endl;
      std::cout << "Mark: " << (*it).GetMark() << std::endl;
      std::cout << "Alpha1: " << (*it).GetAlpha1() << std::endl;
      std::cout << "Alpha2: " << (*it).GetAlpha2() << std::endl;
      std::cout << "Alpha3: " << (*it).GetAlpha3() << std::endl;
      std::cout << "Color = " << (*it).GetColor() << std::endl;
      it++;
      i++;
      }

