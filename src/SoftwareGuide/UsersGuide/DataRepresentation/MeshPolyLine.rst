.. _sec-MeshPolyLine:

Representing a PolyLine
~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``MeshPolyLine.cxx``.

This section illustrates how to represent a classical *PolyLine*
structure using the :itkdox:`itk::Mesh`

A PolyLine only involves zero and one dimensional cells, which are
represented by the :itkdox:`itk::VertexCell` and the :itkdox:`itk::LineCell`.

::

    #include "itkMesh.h"
    #include "itkLineCell.h"

Then the PixelType is defined and the mesh type is instantiated with it.
Note that the dimension of the space is two in this case.

::

    typedef float                             PixelType;
    typedef itk::Mesh< PixelType, 2 >         MeshType;

The cell type can now be instantiated using the traits taken from the
Mesh.

::

    typedef MeshType::CellType                CellType;
    typedef itk::VertexCell< CellType >       VertexType;
    typedef itk::LineCell< CellType >         LineType;

The mesh is created and the points associated with the vertices are
inserted. Note that there is an important distinction between the points
in the mesh and the :itkdox:`itk::VertexCell` concept. A VertexCell is a cell of
dimension zero. Its main difference as compared to a point is that the
cell can be aware of neighborhood relationships with other cells. Points
are not aware of the existence of cells. In fact, from the pure
topological point of view, the coordinates of points in the mesh are
completely irrelevant. They may as well be absent from the mesh
structure altogether. VertexCells on the other hand are necessary to
represent the full set of neighborhood relationships on the Polyline.

In this example we create a polyline connecting the four vertices of a
square by using three of the square sides.

::

    MeshType::Pointer  mesh = MeshType::New();

    MeshType::PointType   point0;
    MeshType::PointType   point1;
    MeshType::PointType   point2;
    MeshType::PointType   point3;

    point0[0] = -1; point0[1] = -1;
    point1[0] =  1; point1[1] = -1;
    point2[0] =  1; point2[1] =  1;
    point3[0] = -1; point3[1] =  1;

    mesh->SetPoint( 0, point0 );
    mesh->SetPoint( 1, point1 );
    mesh->SetPoint( 2, point2 );
    mesh->SetPoint( 3, point3 );

We proceed now to create the cells, associate them with the points and
insert them on the mesh.

::

    CellType::CellAutoPointer cellpointer;

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 0 );
    cellpointer->SetPointId( 1, 1 );
    mesh->SetCell( 0, cellpointer );

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 1 );
    cellpointer->SetPointId( 1, 2 );
    mesh->SetCell( 1, cellpointer );

    cellpointer.TakeOwnership( new LineType );
    cellpointer->SetPointId( 0, 2 );
    cellpointer->SetPointId( 1, 0 );
    mesh->SetCell( 2, cellpointer );

Finally the zero dimensional cells represented by the :itkdox:`itk::VertexCell` are
created and inserted in the mesh.

::

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 0 );
    mesh->SetCell( 3, cellpointer );

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 1 );
    mesh->SetCell( 4, cellpointer );

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 2 );
    mesh->SetCell( 5, cellpointer );

    cellpointer.TakeOwnership( new VertexType );
    cellpointer->SetPointId( 0, 3 );
    mesh->SetCell( 6, cellpointer );

At this point the Mesh contains four points and three cells. The points
can be visited using PointContainer iterators

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
{CellType}.

The point identifiers to which the cells have been associated can be
visited using iterators defined in the ``CellType`` trait. The following
code illustrates the use of the PointIdIterator. The ``PointIdsBegin()``
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
