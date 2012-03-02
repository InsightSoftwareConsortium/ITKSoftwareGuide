.. _sec-ArrowSpatialObject:

ArrowSpatialObject
~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``ArrowSpatialObject.cxx``.

.. index::
   single: ArrowSpatialObject

This example shows how to create a :itkdox:`itk::ArrowSpatialObject`. Let’s
begin by including the appropriate header file.

::

    #include "itkArrowSpatialObject.h"

The :itkdox:`itk::ArrowSpatialObject`, like many SpatialObjects, is templated
over the dimensionality of the object.

::

    typedef itk::ArrowSpatialObject<3>   ArrowType;
    ArrowType::Pointer myArrow = ArrowType::New();

The length of the arrow in the local coordinate frame is done using the
SetLength() function. By default the length is set to 1.

::

    myArrow->SetLength(2);

The direction of the arrow can be set using the SetDirection() function.
The SetDirection() function modifies the ObjectToParentTransform (not
the IndexToObjectTransform). By default the direction is set along the X
axis (first direction).

::

    ArrowType::VectorType direction;
    direction.Fill(0);
    direction[1] = 1.0;
    myArrow->SetDirection(direction);

