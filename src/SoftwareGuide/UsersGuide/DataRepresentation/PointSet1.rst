.. _sec-CreatingAPointSet:

Creating a PointSet
~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``PointSet1.cxx``.

The :itkdox:`itk::PointSet` is a basic class intended to represent geometry in
the form of a set of points in n-dimensional space. It is the base class
for the :itkdox:`itk::Mesh` providing the methods necessary to manipulate sets
of point. Points can have values associated with them. The type of such
values is defined by a template parameter of the :itkdox:`itk::PointSet` class
(i.e., ``TPixelType``. Two basic interaction styles of PointSets are
available in ITK. These styles are referred to as *static* and
*dynamic*. The first style is used when the number of points in the set
is known in advance and is not expected to change as a consequence of
the manipulations performed on the set. The dynamic style, on the other
hand, is intended to support insertion and removal of points in an
efficient manner. Distinguishing between the two styles is meant to
facilitate the fine tuning of a :itkdox:`itk::PointSet`'s behavior while optimizing
performance and memory management.

In order to use the :itkdox:`itk::PointSet` class, its header file should be included.

::

    #include "itkPointSet.h"

Then we must decide what type of value to associate with the points.
This is generally called the ``PixelType`` in order to make the
terminology consistent with the :itkdox:`itk::Image`. The :itkdox:`itk::PointSet` is also
templated over the dimension of the space in which the points are
represented. The following declaration illustrates a typical
instantiation of the PointSet class.

::

    typedef itk::PointSet< unsigned short, 3 > PointSetType;

A :itkdox:`itk::PointSet` object is created by invoking the ``New()`` method on its
type. The resulting object must be assigned to a ``SmartPointer``. The
PointSet is then reference-counted and can be shared by multiple
objects. The memory allocated for the PointSet will be released when the
number of references to the object is reduced to zero. This simply means
that the user does not need to be concerned with invoking the ``Delete()``
method on this class. In fact, the ``Delete()`` method should **never** be
called directly within any of the reference-counted ITK classes.

::

    PointSetType::Pointer  pointsSet = PointSetType::New();

Following the principles of Generic Programming, the :itkdox:`itk::PointSet` class
has a set of associated defined types to ensure that interacting objects
can be declared with compatible types. This set of type definitions is
commonly known as a set of *traits*. Among them we can find the
``PointType`` type, for example. This is the type used by the point set to
represent points in space. The following declaration takes the point
type as defined in the :itkdox:`itk::PointSet` traits and renames it to be
conveniently used in the global namespace.

::

    typedef PointSetType::PointType     PointType;

The ``PointType`` can now be used to declare point objects to be inserted
in the :itkdox:`itk::PointSet`. Points are fairly small objects, so it is
inconvenient to manage them with reference counting and smart pointers.
They are simply instantiated as typical C++ classes. The Point class
inherits the ``[]`` operator from the :itkdox:`itk::Array` class. This makes it
possible to access its components using index notation. For efficiency’s
sake no bounds checking is performed during index access. It is the
user’s responsibility to ensure that the index used is in the range
:math:`\{0,Dimension-1\}`. Each of the components in the point is
associated with space coordinates. The following code illustrates how to
instantiate a point and initialize its components.

::

    PointType p0;
    p0[0] = -1.0;       x coordinate
    p0[1] = -1.0;       y coordinate
    p0[2] =  0.0;       z coordinate

Points are inserted in the PointSet by using the ``SetPoint()`` method.
This method requires the user to provide a unique identifier for the
point. The identifier is typically an unsigned integer that will
enumerate the points as they are being inserted. The following code
shows how three points are inserted into the PointSet.

::

    pointsSet->SetPoint( 0, p0 );
    pointsSet->SetPoint( 1, p1 );
    pointsSet->SetPoint( 2, p2 );

It is possible to query the PointSet in order to determine how many
points have been inserted into it. This is done with the
``GetNumberOfPoints()`` method as illustrated below.

::

    const unsigned int numberOfPoints = pointsSet->GetNumberOfPoints();
    std::cout << numberOfPoints << std::endl;

Points can be read from the PointSet by using the ``GetPoint()`` method
and the integer identifier. The point is stored in a pointer provided by
the user. If the identifier provided does not match an existing point,
the method will return ``false`` and the contents of the point will be
invalid. The following code illustrates point access using defensive
programming.

::

    PointType pp;
    bool pointExists =  pointsSet->GetPoint( 1, & pp );

    if( pointExists )
      {
      std::cout << "Point is = " << pp << std::endl;
      }

``GetPoint()`` and ``SetPoint()`` are not the most efficient methods to
access points in the PointSet. It is preferable to get direct access to
the internal point container defined by the *traits* and use iterators
to walk sequentially over the list of points (as shown in the following
example).
