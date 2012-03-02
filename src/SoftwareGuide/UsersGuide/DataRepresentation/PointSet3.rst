.. _sec-GettingAccessToDataInThePointSet:

Getting Access to Data in Points
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``PointSet3.cxx``.

The :itkdox:`itk::PointSet` class was designed to interact with the Image class. For
this reason it was found convenient to allow the points in the set to
hold values that could be computed from images. The value associated
with the point is referred as ``PixelType`` in order to make it consistent
with image terminology. Users can define the type as they please thanks
to the flexibility offered by the Generic Programming approach used in
the toolkit. The ``PixelType`` is the first template parameter of the
PointSet.

The following code defines a particular type for a pixel type and
instantiates a PointSet class with it.

::

    typedef unsigned short                PixelType;
    typedef itk::PointSet< PixelType, 3 > PointSetType;

Data can be inserted into the PointSet using the ``SetPointData()``
method. This method requires the user to provide an identifier. The data
in question will be associated to the point holding the same identifier.
It is the user’s responsibility to verify the appropriate matching
between inserted data and inserted points. The following line
illustrates the use of the ``SetPointData()`` method.

::

    unsigned int dataId =  0;
    PixelType value     = 79;
    pointSet->SetPointData( dataId++, value );

Data associated with points can be read from the PointSet using the
``GetPointData()`` method. This method requires the user to provide the
identifier to the point and a valid pointer to a location where the
pixel data can be safely written. In case the identifier does not match
any existing identifier on the PointSet the method will return ``false``
and the pixel value returned will be invalid. It is the user’s
responsibility to check the returned boolean value before attempting to
use it.

::


    const bool found = pointSet->GetPointData( dataId, & value );
    if( found )
      {
      std::cout << "Pixel value = " << value << std::endl;
      }

The ``SetPointData()`` and ``GetPointData()`` methods are not the most
efficient way to get access to point data. It is far more efficient to
use the Iterators provided by the ``PointDataContainer``.

Data associated with points is internally stored in
``PointDataContainer`` s. In the same way as with points, the actual
container type used depend on whether the style of the PointSet is
static or dynamic. Static point sets will use an ``VectorContainer`` while
dynamic point sets will use an ``MapContainer``. The type of the data
container is defined as one of the traits in the PointSet. The following
declaration illustrates how the type can be taken from the traits and
used to conveniently declare a similar type on the global namespace.

::

    typedef PointSetType::PointDataContainer      PointDataContainer;

Using the type it is now possible to create an instance of the data
container. This is a standard reference counted object, henceforth it
uses the ``New()`` method for creation and assigns the newly created
object to a SmartPointer.

::

    PointDataContainer::Pointer pointData = PointDataContainer::New();

Pixel data can be inserted in the container with the method
``InsertElement()``. This method requires an identified to be provided for
each point data.

::

    unsigned int pointId = 0;

    PixelType value0 = 34;
    PixelType value1 = 67;

    pointData->InsertElement( pointId++ , value0 );
    pointData->InsertElement( pointId++ , value1 );

Finally the PointDataContainer can be assigned to the PointSet. This
will substitute any previously existing PointDataContainer on the
PointSet. The assignment is done using the ``SetPointData()`` method.

::

    pointSet->SetPointData( pointData );

The PointDataContainer can be obtained from the PointSet using the
``GetPointData()`` method. This method returns a pointer (assigned to a
SmartPointer) to the actual container owned by the PointSet.

::

    PointDataContainer::Pointer  pointData2 = pointSet->GetPointData();

The most efficient way to sequentially visit the data associated with
points is to use the iterators provided by ``PointDataContainer``. The
``Iterator`` type belongs to the traits of the PointsContainer classes.
The iterator is not a reference counted class, so it is just created
directly from the traits without using SmartPointers.

::

    typedef PointDataContainer::Iterator     PointDataIterator;

The subsequent use of the iterator follows what you may expect from a
STL iterator. The iterator to the first point is obtained from the
container with the ``Begin()`` method and assigned to another iterator.

::

    PointDataIterator  pointDataIterator = pointData2->Begin();

The ``++`` operator on the iterator can be used to advance from one data
point to the next. The actual value of the PixelType to which the
iterator is pointing can be obtained with the ``Value()`` method. The loop
for walking through all the point data can be controlled by comparing
the current iterator with the iterator returned by the ``End()`` method of
the PointsContainer. The following lines illustrate the typical loop for
walking through the point data.

::

    PointDataIterator end = pointData2->End();
    while( pointDataIterator != end )
      {
      PixelType p = pointDataIterator.Value();   access the pixel data
      std::cout << p << std::endl;               print the pixel data
      ++pointDataIterator;                       advance to next pixel/point
      }

Note that as in STL, the iterator returned by the ``End()`` method is not
a valid iterator. This is called a *past-end* iterator in order to
indicate that it is the value resulting from advancing one step after
visiting the last element in the container.
