.. _sec-InsertingCellsInMesh:

Inserting Cells
~~~~~~~~~~~~~~~

The source code for this section can be found in the file ``Mesh2.cxx``.

A :itkdox:`itk::Mesh` can contain a variety of cell types. Typical cells are the
:itkdox:`itk::LineCell`, :itkdox:`itk::TriangleCell`, :itkdox:`itk::QuadrilateralCell` and :itkdox:`itk::TetrahedronCell`.
Additional flexibility is provided for managing cells at the price of a
bit more of complexity than in the case of point management.

The following code creates a polygonal line in order to illustrate the
simplest case of cell management in a Mesh. The only cell type used here
is the LineCell. The header file of this class has to be included.

::

    #include "itkLineCell.h"

In order to be consistent with the Mesh, cell types have to be
configured with a number of custom types taken from the mesh traits. The
set of traits relevant to cells are packaged by the Mesh class into the
``CellType`` trait. This trait needs to be passed to the actual cell types
at the moment of their instantiation. The following line shows how to
extract the Cell traits from the Mesh type.

::

    typedef MeshType::CellType                CellType;

The LineCell type can now be instantiated using the traits taken from
the Mesh.

::

    typedef itk::LineCell< CellType >         LineType;

The main difference in the way cells and points are managed by the Mesh
is that points are stored by copy on the PointsContainer while cells are
stored in the CellsContainer using pointers. The reason for using
pointers is that cells use C++ polymorphism on the mesh. This means that
the mesh is only aware of having pointers to a generic cell which is the
base class of all the specific cell types. This architecture makes it
possible to combine different cell types in the same mesh. Points, on
the other hand, are of a single type and have a small memory footprint,
which makes it efficient to copy them directly into the container.

Managing cells by pointers add another level of complexity to the Mesh
since it is now necessary to establish a protocol to make clear who is
responsible for allocating and releasing the cells’ memory. This
protocol is implemented in the form of a specific type of pointer called
the ``CellAutoPointer``. This pointer, based on the ``AutoPointer``, differs
in many respects from the SmartPointer. The CellAutoPointer has an
internal pointer to the actual object and a boolean flag that indicates
if the CellAutoPointer is responsible for releasing the cell memory
whenever the time comes for its own destruction. It is said that a
``CellAutoPointer`` *owns* the cell when it is responsible for its
destruction. Many CellAutoPointer can point to the same cell but at any
given time, only **one** CellAutoPointer can own the cell.

The ``CellAutoPointer`` trait is defined in the MeshType and can be
extracted as illustrated in the following line.

::

    typedef CellType::CellAutoPointer         CellAutoPointer;

Note that the CellAutoPointer is pointing to a generic cell type. It is
not aware of the actual type of the cell, which can be for example
LineCell, TriangleCell or TetrahedronCell. This fact will influence the
way in which we access cells later on.

At this point we can actually create a mesh and insert some points on
it.

::

    MeshType::Pointer  mesh = MeshType::New();

    MeshType::PointType p0;
    MeshType::PointType p1;
    MeshType::PointType p2;

    p0[0] = -1.0; p0[1] = 0.0; p0[2] = 0.0;
    p1[0] =  1.0; p1[1] = 0.0; p1[2] = 0.0;
    p2[0] =  1.0; p2[1] = 1.0; p2[2] = 0.0;

    mesh->SetPoint( 0, p0 );
    mesh->SetPoint( 1, p1 );
    mesh->SetPoint( 2, p2 );

The following code creates two CellAutoPointers and initializes them
with newly created cell objects. The actual cell type created in this
case is LineCell. Note that cells are created with the normal ``new`` C++
operator. The CellAutoPointer takes ownership of the received pointer by
using the method ``TakeOwnership()``. Even though this may seem verbose,
it is necessary in order to make it explicit from the code that the
responsibility of memory release is assumed by the AutoPointer.

::

    CellAutoPointer line0;
    CellAutoPointer line1;

    line0.TakeOwnership(  new LineType  );
    line1.TakeOwnership(  new LineType  );

The LineCells should now be associated with points in the mesh. This is
done using the identifiers assigned to points when they were inserted in
the mesh. Every cell type has a specific number of points that must be
associated with it. [1]_ For example a LineCell requires two points, a
TriangleCell requires three and a TetrahedronCell requires four. Cells
use an internal numbering system for points. It is simply an index in
the range :math:`\{0,NumberOfPoints-1\}`. The association of points
and cells is done by the ``SetPointId()`` method which requires the user
to provide the internal index of the point in the cell and the
corresponding PointIdentifier in the Mesh. The internal cell index is
the first parameter of ``SetPointId()`` while the mesh point-identifier is
the second.

::

    line0->SetPointId( 0, 0 );  line between points 0 and 1
    line0->SetPointId( 1, 1 );

    line1->SetPointId( 0, 1 );  line between points 1 and 2
    line1->SetPointId( 1, 2 );

Cells are inserted in the mesh using the ``SetCell()`` method. It requires
an identifier and the AutoPointer to the cell. The Mesh will take
ownership of the cell to which the AutoPointer is pointing. This is done
internally by the ``SetCell()`` method. In this way, the destruction of
the CellAutoPointer will not induce the destruction of the associated
cell.

::

    mesh->SetCell( 0, line0 );
    mesh->SetCell( 1, line1 );

After serving as an argument of the ``SetCell()`` method, a
CellAutoPointer no longer holds ownership of the cell. It is important
not to use this same CellAutoPointer again as argument to ``SetCell()``
without first securing ownership of another cell.

The number of Cells currently inserted in the mesh can be queried with
the ``GetNumberOfCells()`` method.

::

    std::cout << "Cells  = " << mesh->GetNumberOfCells()  << std::endl;

In a way analogous to points, cells can be accessed using Iterators to
the CellsContainer in the mesh. The trait for the cell iterator can be
extracted from the mesh and used to define a local type.

::

    typedef MeshType::CellsContainer::Iterator  CellIterator;

Then the iterators to the first and past-end cell in the mesh can be
obtained respectively with the ``Begin()`` and ``End()`` methods of the
CellsContainer. The CellsContainer of the mesh is returned by the
``GetCells()`` method.

::

    CellIterator  cellIterator = mesh->GetCells()->Begin();
    CellIterator  end          = mesh->GetCells()->End();

Finally a standard loop is used to iterate over all the cells. Note the
use of the ``Value()`` method used to get the actual pointer to the cell
from the CellIterator. Note also that the values returned are pointers
to the generic CellType. These pointers have to be down-casted in order
to be used as actual LineCell types. Safe down-casting is performed with
the ``dynamic_cast`` operator which will throw an exception if the
conversion cannot be safely performed.

::

    while( cellIterator != end )
      {
      MeshType::CellType * cellptr = cellIterator.Value();
      LineType * line = dynamic_cast<LineType *>( cellptr );
      std::cout << line->GetNumberOfPoints() << std::endl;
      ++cellIterator;
      }

.. [1]
   Some cell types like polygons have a variable number of points
   associated with them.
