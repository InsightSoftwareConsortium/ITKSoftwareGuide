.. _sec:MeshCellsIteration:

Iterating Through Cells
~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``MeshCellsIteration.cxx``.

Cells are stored in the :itkdox:`itk::Mesh` as pointers to a generic cell
:itkdox:`itk::CellInterface`. This implies that only the virtual methods defined on
this base cell class can be invoked. In order to use methods that are
specific to each cell type it is necessary to down-cast the pointer to
the actual type of the cell. This can be done safely by taking advantage
of the ``GetType()`` method that allows to identify the actual type of a
cell.

Let’s start by assuming a mesh defined with one tetrahedron and all its
boundary faces. That is, four triangles, six edges and four vertices.

The cells can be visited using CellsContainer iterators . The iterator
``Value()`` corresponds to a raw pointer to the ``CellType`` base class.

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

In order to perform down-casting in a safe manner, the cell type can be
queried first using the ``GetType()`` method. Codes for the cell types
have been defined with an ``enum`` type on the ``itkCellInterface.h`` header
file. These codes are :

-  VERTEX_CELL
-  LINE_CELL
-  TRIANGLE_CELL
-  QUADRILATERAL_CELL
-  POLYGON_CELL
-  TETRAHEDRON_CELL
-  HEXAHEDRON_CELL
-  QUADRATIC_EDGE_CELL
-  QUADRATIC_TRIANGLE_CELL

The method ``GetType()`` returns one of these codes. It is then possible
to test the type of the cell before down-casting its pointer to the
actual type. For example, the following code visits all the cells in the
mesh and tests which ones are actually of type ``LINE_CELL``. Only those
cells are down-casted to ``LineType`` cells and a method specific for the
``LineType`` is invoked.

::

    cellIterator = mesh->GetCells()->Begin();
    cellEnd      = mesh->GetCells()->End();

    while( cellIterator != cellEnd )
      {
      CellType * cell = cellIterator.Value();
      if( cell->GetType() == CellType::LINE_CELL )
        {
        LineType * line = static_cast<LineType *>( cell );
        std::cout << "dimension = " << line->GetDimension();
        std::cout << " # points = " << line->GetNumberOfPoints();
        std::cout << std::endl;
        }
      ++cellIterator;
      }

In order to perform different actions on different cell types a ``switch``
statement can be used with cases for every cell type. The following code
illustrates an iteration over the cells and the invocation of different
methods on each cell type.

::

    cellIterator = mesh->GetCells()->Begin();
    cellEnd      = mesh->GetCells()->End();

    while( cellIterator != cellEnd )
      {
      CellType * cell = cellIterator.Value();
      switch( cell->GetType() )
        {
        case CellType::VERTEX_CELL:
          {
          std::cout << "VertexCell : " << std::endl;
          VertexType * line = dynamic_cast<VertexType *>( cell );
          std::cout << "dimension = " << line->GetDimension()      << std::endl;
          std::cout << "# points  = " << line->GetNumberOfPoints() << std::endl;
          break;
          }
        case CellType::LINE_CELL:
          {
          std::cout << "LineCell : " << std::endl;
          LineType * line = dynamic_cast<LineType *>( cell );
          std::cout << "dimension = " << line->GetDimension()      << std::endl;
          std::cout << "# points  = " << line->GetNumberOfPoints() << std::endl;
          break;
          }
        case CellType::TRIANGLE_CELL:
          {
          std::cout << "TriangleCell : " << std::endl;
          TriangleType * line = dynamic_cast<TriangleType *>( cell );
          std::cout << "dimension = " << line->GetDimension()      << std::endl;
          std::cout << "# points  = " << line->GetNumberOfPoints() << std::endl;
          break;
          }
        default:
          {
          std::cout << "Cell with more than three points" << std::endl;
          std::cout << "dimension = " << cell->GetDimension()      << std::endl;
          std::cout << "# points  = " << cell->GetNumberOfPoints() << std::endl;
          break;
          }
        }
      ++cellIterator;
      }

