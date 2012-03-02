 .. _sec-ManagingCellDataInMesh:

Managing Data in Cells
~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file ``Mesh3.cxx``.

In the same way that custom data can be associated with points in the
mesh, it is also possible to associate custom data with cells. The type
of the data associated with the cells can be different from the data
type associated with points. By default, however, these two types are
the same. The following example illustrates how to access data
associated with cells. The approach is analogous to the one used to
access point data.

Consider the example of a mesh containing lines on which values are
associated with each line. The mesh and cell header files should be
included first.

::

    #include "itkMesh.h"
    #include "itkLineCell.h"

Then the PixelType is defined and the mesh type is instantiated with it.

::

    typedef float                             PixelType;
    typedef itk::Mesh< PixelType, 2 >         MeshType;

The {LineCell} type can now be instantiated using the traits taken from
the Mesh.

::

    typedef MeshType::CellType                CellType;
    typedef itk::LineCell< CellType >         LineType;

Let’s now create a Mesh and insert some points into it. Note that the
dimension of the points matches the dimension of the Mesh. Here we
insert a sequence of points that look like a plot of the
:math:`\log()` function. We add the ``vnl_math::eps`` value in oder to
avoid numerical errors when the point id is zero. The value of
``vnl_math::eps`` is the difference between 1.0 and the least value
greater than 1.0 that is representable in this computer.

::

    MeshType::Pointer  mesh = MeshType::New();

    typedef MeshType::PointType PointType;
    PointType point;

    const unsigned int numberOfPoints = 10;
    for(unsigned int id=0; id<numberOfPoints; id++)
      {
      point[0] = static_cast<PointType::ValueType>( id );  x
      point[1] = vcl_log( static_cast<double>( id ) + vnl_math::eps );     y
      mesh->SetPoint( id, point );
      }

A set of line cells is created and associated with the existing points
by using point identifiers. In this simple case, the point identifiers
can be deduced from cell identifiers since the line cells are ordered in
the same way.

::

    CellType::CellAutoPointer line;
    const unsigned int numberOfCells = numberOfPoints-1;
    for(unsigned int cellId=0; cellId<numberOfCells; cellId++)
      {
      line.TakeOwnership(  new LineType  );
      line->SetPointId( 0, cellId   );  first point
      line->SetPointId( 1, cellId+1 );  second point
      mesh->SetCell( cellId, line );    insert the cell
      }

Data associated with cells is inserted in the :itkdox:`itk::Mesh` by using the
``SetCellData()`` method. It requires the user to provide an identifier
and the value to be inserted. The identifier should match one of the
inserted cells. In this simple example, the square of the cell
identifier is used as cell data. Note the use of ``static_cast`` to
``PixelType`` in the assignment.

::

    for(unsigned int cellId=0; cellId<numberOfCells; cellId++)
      {
      mesh->SetCellData( cellId, static_cast<PixelType>( cellId * cellId ) );
      }

Cell data can be read from the Mesh with the ``GetCellData()`` method. It
requires the user to provide the identifier of the cell for which the
data is to be retrieved. The user should provide also a valid pointer to
a location where the data can be copied.

::

    for(unsigned int cellId=0; cellId<numberOfCells; cellId++)
      {
      PixelType value = static_cast<PixelType>(0.0);
      mesh->GetCellData( cellId, &value );
      std::cout << "Cell " << cellId << " = " << value << std::endl;
      }

Neither ``SetCellData()`` or ``GetCellData()`` are efficient ways to access
cell data. More efficient access to cell data can be achieved by using
the Iterators built into the ``CellDataContainer``.

::

    typedef MeshType::CellDataContainer::ConstIterator CellDataIterator;

Note that the ``ConstIterator`` is used here because the data is only
going to be read. This approach is exactly the same already illustrated
for getting access to point data. The iterator to the first cell data
item can be obtained with the ``Begin()`` method of the CellDataContainer.
The past-end iterator is returned by the ``End()`` method. The cell data
container itself can be obtained from the mesh with the method
``GetCellData()``.

::

    CellDataIterator cellDataIterator  = mesh->GetCellData()->Begin();
    CellDataIterator end               = mesh->GetCellData()->End();

Finally a standard loop is used to iterate over all the cell data
entries. Note the use of the ``Value()`` method used to get the actual
value of the data entry. ``PixelType`` elements are copied into the local
variable ``cellValue``.

::

    while( cellDataIterator != end )
      {
      PixelType cellValue = cellDataIterator.Value();
      std::cout << cellValue << std::endl;
      ++cellDataIterator;
      }

