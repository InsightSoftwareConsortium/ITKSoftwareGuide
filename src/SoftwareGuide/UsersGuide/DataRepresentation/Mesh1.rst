.. _sec-CreatingAMesh:

Creating a Mesh
~~~~~~~~~~~~~~~

The source code for this section can be found in the file ``Mesh1.cxx``.

The :itkdox:`itk::Mesh` class is intended to represent shapes in space. It derives
from the :itkdox:`itk::PointSet` class and hence inherits all the functionality
related to points and access to the pixel-data associated with the
points. The mesh class is also n-dimensional which allows a great
flexibility in its use.

In practice a Mesh class can be seen as a PointSet to which cells (also
known as elements) of many different dimensions and shapes have been
added. Cells in the mesh are defined in terms of the existing points
using their point-identifiers.

In the same way as for the :itkdox:`itk::PointSet`, two basic styles of Meshes are
available in ITK. They are referred to as *static* and *dynamic*. The
first one is used when the number of points in the set can be known in
advance and it is not expected to change as a consequence of the
manipulations performed on the set. The dynamic style, on the other
hand, is intended to support insertion and removal of points in an
efficient manner. The reason for making the distinction between the two
styles is to facilitate fine tuning its behavior with the aim of
optimizing performance and memory management. In the case of the Mesh,
the dynamic/static aspect is extended to the management of cells.

In order to use the Mesh class, its header file should be included.

::

    #include "itkMesh.h"

Then, the type associated with the points must be selected and used for
instantiating the Mesh type.

::

    typedef   float   PixelType;

The Mesh type extensively uses the capabilities provided by `Generic
Programming <http:www.boost.org/more/generic_programming.html>`_. In
particular the Mesh class is parameterized over the PixelType and the
dimension of the space. PixelType is the type of the value associated
with every point just as is done with the PointSet. The following line
illustrates a typical instantiation of the Mesh.

::

    const unsigned int Dimension = 3;
    typedef itk::Mesh< PixelType, Dimension >   MeshType;

Meshes are expected to take large amounts of memory. For this reason
they are reference counted objects and are managed using SmartPointers.
The following line illustrates how a mesh is created by invoking the
``New()`` method of the MeshType and the resulting object is assigned to a
``SmartPointer``.

::

    MeshType::Pointer  mesh = MeshType::New();

The management of points in the Mesh is exactly the same as in the
PointSet. The type point associated with the mesh can be obtained
through the ``PointType`` trait. The following code shows the creation of
points compatible with the mesh type defined above and the assignment of
values to its coordinates.

::

    MeshType::PointType p0;
    MeshType::PointType p1;
    MeshType::PointType p2;
    MeshType::PointType p3;

    p0[0]= -1.0; p0[1]= -1.0; p0[2]= 0.0;  first  point ( -1, -1, 0 )
    p1[0]=  1.0; p1[1]= -1.0; p1[2]= 0.0;  second point (  1, -1, 0 )
    p2[0]=  1.0; p2[1]=  1.0; p2[2]= 0.0;  third  point (  1,  1, 0 )
    p3[0]= -1.0; p3[1]=  1.0; p3[2]= 0.0;  fourth point ( -1,  1, 0 )

The points can now be inserted in the Mesh using the ``SetPoint()``
method. Note that points are copied into the mesh structure. This means
that the local instances of the points can now be modified without
affecting the Mesh content.

::

    mesh->SetPoint( 0, p0 );
    mesh->SetPoint( 1, p1 );
    mesh->SetPoint( 2, p2 );
    mesh->SetPoint( 3, p3 );

The current number of points in the Mesh can be queried with the
``GetNumberOfPoints()`` method.

::

    std::cout << "Points = " << mesh->GetNumberOfPoints() << std::endl;

The points can now be efficiently accessed using the Iterator to the
PointsContainer as it was done in the previous section for the PointSet.
First, the point iterator type is extracted through the mesh traits.

::

    typedef MeshType::PointsContainer::Iterator     PointsIterator;

A point iterator is initialized to the first point with the ``Begin()``
method of the PointsContainer.

::

    PointsIterator  pointIterator = mesh->GetPoints()->Begin();

The ``++`` operator on the iterator is now used to advance from one point
to the next. The actual value of the Point to which the iterator is
pointing can be obtained with the ``Value()`` method. The loop for walking
through all the points is controlled by comparing the current iterator
with the iterator returned by the ``End()`` method of the PointsContainer.
The following lines illustrate the typical loop for walking through the
points.

::

    PointsIterator end = mesh->GetPoints()->End();
    while( pointIterator != end )
      {
      MeshType::PointType p = pointIterator.Value();   access the point
      std::cout << p << std::endl;                     print the point
      ++pointIterator;                                 advance to next point
      }

