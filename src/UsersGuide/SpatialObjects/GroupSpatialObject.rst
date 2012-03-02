.. _sec-GroupSpatialObject:

GroupSpatialObject
~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``GroupSpatialObject.cxx``.

A :itkdox:`itk::GroupSpatialObject` does not have any data associated with it. It can
be used to group objects or to add transforms to a current object. In
this example we show how to use a GroupSpatialObject.

Let’s begin by including the appropriate header file.

::

    #include "itkGroupSpatialObject.h"

The :itkdox:`itk::GroupSpatialObject` is templated over the dimensionality of the
object.

::

    typedef itk::GroupSpatialObject<3>   GroupType;
    GroupType::Pointer myGroup = GroupType::New();

Next, we create an :itkdox:`itk::EllipseSpatialObject` and add it to the group.

::

    typedef itk::EllipseSpatialObject<3>   EllipseType;
    EllipseType::Pointer myEllipse = EllipseType::New();
    myEllipse->SetRadius(2);

    myGroup->AddSpatialObject(myEllipse);

We then translate the group by 10mm in each direction. Therefore the
ellipse is translated in physical space at the same time.

::

    GroupType::VectorType offset;
    offset.Fill(10);
    myGroup->GetObjectToParentTransform()->SetOffset(offset);
    myGroup->ComputeObjectToWorldTransform();

We can then query if a point is inside the group using the ``IsInside()``
function. We need to specify in this case that we want to consider all
the hierarchy, therefore we set the depth to 2.

::

    GroupType::PointType point;
    point.Fill(10);
    std::cout << "Is my point " << point << " inside?: "
    <<  myGroup->IsInside(point,2) << std::endl;

Like any other SpatialObjects we can remove the ellipse from the group
using the ``RemoveSpatialObject()`` method.

::

    myGroup->RemoveSpatialObject(myEllipse);

