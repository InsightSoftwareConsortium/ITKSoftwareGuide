.. _sec-MeshKComplex:

Topology and the K-Complex
~~~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``MeshKComplex.cxx``.

The :itkdox:`itk::Mesh` class supports the representation of formal topologies. In
particular the concept of *K-Complex* can be correctly represented in
the Mesh. An informal definition of K-Complex may be as follows: a
K-Complex is a topological structure in which for every cell of
dimension :math:`N`, its boundary faces which are cells of dimension
:math:`N-1` also belong to the structure.

This section illustrates how to instantiate a K-Complex structure using
the mesh. The example structure is composed of one tetrahedron, its four
triangle faces, its six line edges and its four vertices.

The header files of all the cell types involved should be loaded along
with the header file of the mesh class.

::

    #include "itkMesh.h"
    #include "itkLineCell.h"
    #include "itkTetrahedronCell.h"

Then the PixelType is defined and the mesh type is instantiated with it.
Note that the dimension of the space is three in this case.

::

    typedef float                             PixelType;
    typedef itk::Mesh< PixelType, 3 >         MeshType;

The cell type can now be instantiated using the traits taken from the
Mesh.

::

    typedef MeshType::CellType                CellType;
    typedef itk::VertexCell< CellType >       VertexType;
    typedef itk::LineCell< CellType >         LineType;
    typedef itk::TriangleCell< CellType >     TriangleType;
    typedef itk::TetrahedronCell< CellType >  TetrahedronType;

The mesh is created and the points associated with the vertices are
inserted. Note that there is an important distinction between the points
in the mesh and the ``VertexCell`` concept. A VertexCell is a cell of
dimension zero. Its main difference as compared to a point is that the
cell can be aware of neighborhood relationships with other cells. Points
are not aware of the existence of cells. In fact, from the pure
topological point of view, the coordinates of points in the mesh are
completely irrelevant. They may as well be absent from the mesh
structure altogether. VertexCells on the other hand are necessary to
represent the full set of neighborhood relationships on the K-Complex.

The geometrical coordinates of the nodes of a regular tetrahedron can be
obtained by taking every other node from a regular cube.

::

    MeshType::Pointer  mesh = MeshType::New();

    MeshType::PointType   point0;
    MeshType::PointType   point1;
    MeshType::PointType   point2;
    MeshType::PointType   point3;

    point0[0] = -1; point0[1] = -1; point0[2] = -1;
    point1[0] =  1; point1[1] =  1; point1[2] = -1;
    point2[0] =  1; point2[1] = -1; point2[2] =  1;
    point3[0] = -1; point3[1] =  1; point3[2] =  1;

    mesh->SetPoint( 0, point0 );
    mesh->SetPoint( 1, point1 );
    mesh->SetPoint( 2, point2 );
    mesh->SetPoint( 3, point3 );

We proceed now to create the cells, associate them with the points and
insert them on the mesh. Starting with the tetrahedron we write the
following code.

::

    CellType::CellAutoPointer cellpointer;

    cellpointer.TakeOwnership( new TetrahedronType );
    cellpointer->SetPointId( 0, 0 );
    cellpointer->SetPointId( 1, 1 );
    cellpointer->SetPointId( 2, 2 );
    cellpointer->SetPointId( 3, 3 );
    mesh->SetCell( 0, cellpointer );

Four triangular faces are created and associated with the mesh now. The
first triangle connects points {0,1,2}.

::

    cellpointer.TakeOwnership( new TriangleType );
    cellpointer->SetPointId( 0, 0 );
    cellpointer->SetPointId( 1, 1 );
    cellpointer->SetPointId( 2, 2 );
    mesh->SetCell( 1, cellpointer );

The second triangle connects points { 0, 2, 3 }

::

    cellpointer.TakeOwnership( new TriangleType );
    cellpointer->SetPointId( 0, 0 );
    cellpointer->SetPointId( 1, 2 );
    cellpointer->SetPointId( 2, 3 );
    mesh->SetCell( 2, cellpointer );

The third triangle connects points { 0, 3, 1 }

::

    cellpointer.TakeOwnership( new TriangleType );
    cellpointer->SetPointId( 0, 0 );
    cellpointer->SetPointId( 1, 3 );
    cellpointer->SetPointId( 2, 1 );
    mesh->SetCell( 3, cellpointer );

The fourth triangle connects points { 3, 2, 1 }

::

    cellpointer.TakeOwnership( new TriangleType );
    cellpointer->SetPointId( 0, 3 );
    cellpointer->SetPointId( 1, 2 );
    cellpointer->SetPointId( 2, 1 );
    mesh->SetCell( 4, cellpointer );

Note how the ``CellAutoPointer`` is reused every time. Reminder: the
``AutoPointer`` loses ownership of the cell when it is passed as an
argument of the ``SetCell()`` method. The AutoPointer is attached to a new
cell by using the ``TakeOwnership()`` method.

The construction of the K-Complex continues now with the creation of the
six lines on the tetrahedron edges.

::

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 0 );
    cellpointer->SetPointId( 1, 1 );
    mesh->SetCell( 5, cellpointer );

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 1 );
    cellpointer->SetPointId( 1, 2 );
    mesh->SetCell( 6, cellpointer );

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 2 );
    cellpointer->SetPointId( 1, 0 );
    mesh->SetCell( 7, cellpointer );

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 1 );
    cellpointer->SetPointId( 1, 3 );
    mesh->SetCell( 8, cellpointer );

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 3 );
    cellpointer->SetPointId( 1, 2 );
    mesh->SetCell( 9, cellpointer );

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 3 );
    cellpointer->SetPointId( 1, 0 );
    mesh->SetCell( 10, cellpointer );

Finally the zero dimensional cells represented by the ``VertexCell`` are
created and inserted in the mesh.

::

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 0 );
    mesh->SetCell( 11, cellpointer );

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 1 );
    mesh->SetCell( 12, cellpointer );

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 2 );
    mesh->SetCell( 13, cellpointer );

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 3 );
    mesh->SetCell( 14, cellpointer );

At this point the Mesh contains four points and fifteen cells enumerated
from 0 to 14. The points can be visited using PointContainer iterators

::

    typedef MeshType::PointsContainer::ConstIterator  PointIterator;
    PointIterator pointIterator = mesh->GetPoints()->Begin();
    PointIterator pointEnd      = mesh->GetPoints()->End();

    while( pointIterator != pointEnd )
      {
      std::cout << pointIterator.Value() << std::endl;
      ++pointIterator;
      }

The cells can be visited using CellsContainer iterators

::

    typedef MeshType::CellsContainer::ConstIterator  CellIterator;

    CellIterator cellIterator = mesh->GetCells()->Begin();
    CellIterator cellEnd      = mesh->GetCells()->End();

    while( cellIterator != cellEnd )
    {
    CellType * cell = cellIterator.Value();
    std::cout << cell->GetNumberOfPoints() << std::endl;
    ++cellIterator;
    }

Note that cells are stored as pointer to a generic cell type that is the
base class of all the specific cell classes. This means that at this
level we can only have access to the virtual methods defined in the
``CellType``.

The point identifiers to which the cells have been associated can be
visited using iterators defined in the ``CellType`` trait. The following
code illustrates the use of the PointIdIterators. The ``PointIdsBegin()``
method returns the iterator to the first point-identifier in the cell.
The ``PointIdsEnd()`` method returns the iterator to the past-end
point-identifier in the cell.

::

    typedef CellType::PointIdIterator     PointIdIterator;

    PointIdIterator pointIditer = cell->PointIdsBegin();
    PointIdIterator pointIdend  = cell->PointIdsEnd();

    while( pointIditer != pointIdend )
      {
      std::cout << *pointIditer << std::endl;
      ++pointIditer;
      }

Note that the point-identifier is obtained from the iterator using the
more traditional ``*iterator`` notation instead the ``Value()`` notation
used by cell-iterators.

Up to here, the topology of the K-Complex is not completely defined
since we have only introduced the cells. ITK allows the user to define
explicitly the neighborhood relationships between cells. It is clear
that a clever exploration of the point identifiers could have allowed a
user to figure out the neighborhood relationships. For example, two
triangle cells sharing the same two point identifiers will probably be
neighbor cells. Some of the drawbacks on this implicit discovery of
neighborhood relationships is that it takes computing time and that some
applications may not accept the same assumptions. A specific case is
surgery simulation. This application typically simulates bistoury cuts
in a mesh representing an organ. A small cut in the surface may be made
by specifying that two triangles are not considered to be neighbors any
more.

Neighborhood relationships are represented in the mesh by the notion of
*BoundaryFeature*. Every cell has an internal list of cell-identifiers
pointing to other cells that are considered to be its neighbors.
Boundary features are classified by dimension. For example, a line will
have two boundary features of dimension zero corresponding to its two
vertices. A tetrahedron will have boundary features of dimension zero,
one and two, corresponding to its four vertices, six edges and four
triangular faces. It is up to the user to specify the connections
between the cells.

Let’s take in our current example the tetrahedron cell that was
associated with the cell-identifier {0} and assign to it the four
vertices as boundaries of dimension zero. This is done by invoking the
``SetBoundaryAssignment()`` method on the Mesh class.

::

    MeshType::CellIdentifier cellId = 0;   the tetrahedron

    int dimension = 0;                     vertices

    MeshType::CellFeatureIdentifier featureId = 0;

    mesh->SetBoundaryAssignment( dimension, cellId, featureId++, 11 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++, 12 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++, 13 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++, 14 );

The ``featureId`` is simply a number associated with the sequence of the
boundary cells of the same dimension in a specific cell. For example,
the zero-dimensional features of a tetrahedron are its four vertices.
Then the zero-dimensional feature-Ids for this cell will range from zero
to three. The one-dimensional features of the tetrahedron are its six
edges, hence its one-dimensional feature-Ids will range from zero to
five. The two-dimensional features of the tetrahedron are its four
triangular faces. The two-dimensional feature ids will then range from
zero to three. The following table summarizes the use on indices for
boundary assignments.

        Dimension & CellType & FeatureId range & Cell Ids
         0 & VertexCell & [0:3] & {11,12,13,14}
         1 & LineCell & [0:5] & {5,6,7,8,9,10}
         2 & TriangleCell & [0:3] & {1,2,3,4}

In the code example above, the values of featureId range from zero to
three. The cell identifiers of the triangle cells in this example are
the numbers {1,2,3,4}, while the cell identifiers of the vertex cells
are the numbers {11,12,13,14}.

Let’s now assign one-dimensional boundary features of the tetrahedron.
Those are the line cells with identifiers {5,6,7,8,9,10}. Note that the
feature identifier is reinitialized to zero since the count is
independent for each dimension.

::

    cellId    = 0;   still the tetrahedron
    dimension = 1;   one-dimensional features = edges
    featureId = 0;   reinitialize the count

    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  5 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  6 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  7 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  8 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  9 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++, 10 );

Finally we assign the two-dimensional boundary features of the
tetrahedron. These are the four triangular cells with identifiers
{1,2,3,4}. The featureId is reset to zero since feature-Ids are
independent on each dimension.

::

    cellId    = 0;   still the tetrahedron
    dimension = 2;   two-dimensional features = triangles
    featureId = 0;   reinitialize the count

    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  1 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  2 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  3 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  4 );

At this point we can query the tetrahedron cell for information about
its boundary features. For example, the number of boundary features of
each dimension can be obtained with the method
``GetNumberOfBoundaryFeatures()``.

::

    cellId = 0;  still the tetrahedron

    MeshType::CellFeatureCount n0;   number of zero-dimensional features
    MeshType::CellFeatureCount n1;   number of  one-dimensional features
    MeshType::CellFeatureCount n2;   number of  two-dimensional features

    n0 = mesh->GetNumberOfCellBoundaryFeatures( 0, cellId );
    n1 = mesh->GetNumberOfCellBoundaryFeatures( 1, cellId );
    n2 = mesh->GetNumberOfCellBoundaryFeatures( 2, cellId );

The boundary assignments can be recovered with the method
``GetBoundaryAssigment()``. For example, the zero-dimensional features of
the tetrahedron can be obtained with the following code.

::

    dimension = 0;
    for(unsigned int b0=0; b0 < n0; b0++)
    {
    MeshType::CellIdentifier id;
    bool found = mesh->GetBoundaryAssignment( dimension, cellId, b0, &id );
    if( found ) std::cout << id << std::endl;
    }

The following code illustrates how to set the edge boundaries for one of
the triangular faces.

::

    cellId     =  2;     one of the triangles
    dimension  =  1;     boundary edges
    featureId  =  0;     start the count of features

    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  7 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++,  9 );
    mesh->SetBoundaryAssignment( dimension, cellId, featureId++, 10 );

