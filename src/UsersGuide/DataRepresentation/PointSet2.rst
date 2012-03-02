.. _sec-GettingAccessToPointsInThePointSet:

Getting Access to Points
~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``PointSet2.cxx``.

The :itkdox:`itk::PointSet` class uses an internal container to manage the storage of
:itkdox:`itk::Point`s. It is more efficient, in general, to manage points by using
the access methods provided directly on the points container. The
following example illustrates how to interact with the point container
and how to use point iterators.

The type is defined by the *traits* of the :itkdox:`itk::PointSet` class. The following
line conveniently takes the ``PointsContainer`` type from the :itkdox:`itk::PointSet`
traits and declare it in the global namespace.

::

    typedef PointSetType::PointsContainer      PointsContainer;

The actual type of the ``PointsContainer`` depends on what style of PointSet
is being used. The dynamic :itkdox:`itk::PointSet` use the :itkdox:`itk::MapContainer` while the
static PointSet uses the :itkdox:`itk::VectorContainer`. The vector and map
containers are basically ITK wrappers around the
`STL <http:www.sgi.com/tech/stl/>`_ classes
`std::map <http:www.sgi.com/tech/stl/Map.html>`_ and
`std::vector <http:www.sgi.com/tech/stl/Vector.html>`_. By default,
the :itkdox:`itk::PointSet` uses a static style, hence the default type of point
container is an VectorContainer. Both the map and vector container are
templated over the type of the elements they contain. In this case they
are templated over PointType. Containers are reference counted object.
They are then created with the ``New()`` method and assigned to a
``SmartPointer`` after creation. The following line creates a point
container compatible with the type of the PointSet from which the trait
has been taken.

::

    PointsContainer::Pointer points = PointsContainer::New();

Points can now be defined using the ``PointType`` trait from the PointSet.

::

    typedef PointSetType::PointType   PointType;
    PointType p0;
    PointType p1;
    p0[0] = -1.0; p0[1] = 0.0; p0[2] = 0.0;  Point 0 = {-1,0,0 }
    p1[0] =  1.0; p1[1] = 0.0; p1[2] = 0.0;  Point 1 = { 1,0,0 }

The created points can be inserted in the PointsContainer using the
generic method ``InsertElement()`` which requires an identifier to be
provided for each point.

::

    unsigned int pointId = 0;
    points->InsertElement( pointId++ , p0 );
    points->InsertElement( pointId++ , p1 );

Finally the PointsContainer can be assigned to the PointSet. This will
substitute any previously existing PointsContainer on the PointSet. The
assignment is done using the ``SetPoints()`` method.

::

    pointSet->SetPoints( points );

The PointsContainer object can be obtained from the PointSet using the
``GetPoints()`` method. This method returns a pointer to the actual
container owned by the PointSet which is then assigned to a
SmartPointer.

::

    PointsContainer::Pointer  points2 = pointSet->GetPoints();

The most efficient way to sequentially visit the points is to use the
iterators provided by PointsContainer. The ``Iterator`` type belongs to
the traits of the PointsContainer classes. It behaves pretty much like
the STL iterators. [1]_ The Points iterator is not a reference counted
class, so it is created directly from the traits without using
SmartPointers.

::

    typedef PointsContainer::Iterator     PointsIterator;

The subsequent use of the iterator follows what you may expect from a
STL iterator. The iterator to the first point is obtained from the
container with the ``Begin()`` method and assigned to another iterator.

::

    PointsIterator  pointIterator = points->Begin();

The ``++`` operator on the iterator can be used to advance from one point
to the next. The actual value of the Point to which the iterator is
pointing can be obtained with the ``Value()`` method. The loop for walking
through all the points can be controlled by comparing the current
iterator with the iterator returned by the ``End()`` method of the
PointsContainer. The following lines illustrate the typical loop for
walking through the points.

::

    PointsIterator end = points->End();
    while( pointIterator != end )
      {
      PointType p = pointIterator.Value();    access the point
      std::cout << p << std::endl;            print the point
      ++pointIterator;                        advance to next point
      }

Note that as in STL, the iterator returned by the ``End()`` method is not
a valid iterator. This is called a past-end iterator in order to
indicate that it is the value resulting from advancing one step after
visiting the last element in the container.

The number of elements stored in a container can be queried with the
``Size()`` method. In the case of the PointSet, the following two lines of
code are equivalent, both of them returning the number of points in the
PointSet.

::

    std::cout << pointSet->GetNumberOfPoints() << std::endl;
    std::cout << pointSet->GetPoints()->Size() << std::endl;

.. [1]
   If you dig deep enough into the code, you will discover that these
   iterators are actually ITK wrappers around STL iterators.
