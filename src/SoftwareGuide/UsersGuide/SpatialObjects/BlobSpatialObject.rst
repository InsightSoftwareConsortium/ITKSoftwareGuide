.. _sec-BlobSpatialObject:

BlobSpatialObject
~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``BlobSpatialObject.cxx``.

:itkdox:`BlobSpatialObject` defines an N-dimensional blob. Like other
SpatialObjects this class derives from :itkdox:`SpatialObject`. A blob is
defined as a list of points which compose the object.

Let’s start by including the appropriate header file.

::

    #include "itkBlobSpatialObject.h"

BlobSpatialObject is templated over the dimension of the space. A
BlobSpatialObject contains a list of SpatialObjectPoints. Basically, a
SpatialObjectPoint has a position and a color.

.. index:
   single: BlobSpatialObject

::

    #include "itkSpatialObjectPoint.h"

First we declare some type definitions.

::

    typedef itk::BlobSpatialObject<3>    BlobType;
    typedef BlobType::Pointer            BlobPointer;
    typedef itk::SpatialObjectPoint<3>   BlobPointType;

Then, we create a list of points and we set the position of each point
in the local coordinate system using the ``SetPosition()`` method. We also
set the color of each point to be red.

::

    BlobType::PointListType list;

    for( unsigned int i=0; i<4; i++)
      {
      BlobPointType p;
      p.SetPosition(i,i+1,i+2);
      p.SetRed(1);
      p.SetGreen(0);
      p.SetBlue(0);
      p.SetAlpha(1.0);
      list.push_back(p);
      }

Next, we create the blob and set its name using the ``SetName()``
function. We also set its Identification number with ``SetId()`` and we
add the list of points previously created.

::

    BlobPointer blob = BlobType::New();
    blob->GetProperty()->SetName("My Blob");
    blob->SetId(1);
    blob->SetPoints(list);

The ``GetPoints()`` method returns a reference to the internal list of
points of the object.

::

    BlobType::PointListType pointList = blob->GetPoints();
    std::cout << "The blob contains " << pointList.size();
    std::cout << " points" << std::endl;

Then we can access the points using standard STL iterators and
``GetPosition()`` and ``GetColor()`` functions return respectively the
position and the color of the point.

::

    BlobType::PointListType::const_iterator it = blob->GetPoints().begin();
    while(it != blob->GetPoints().end())
    {
    std::cout << "Position = " << (*it).GetPosition() << std::endl;
    std::cout << "Color = " << (*it).GetColor() << std::endl;
    it++;
    }

