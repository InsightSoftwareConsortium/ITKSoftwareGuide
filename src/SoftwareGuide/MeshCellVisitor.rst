.. _sec-MeshCellVisitor:

Visiting Cells
~~~~~~~~~~~~~~

The source code for this section can be found in the file
``MeshCellVisitor.cxx``.

In order to facilitate access to particular cell types, a convenience
mechanism has been built-in on the :itkdox:`itk::Mesh`. This mechanism is based on
the *Visitor Pattern* presented in . The visitor pattern is designed to
facilitate the process of walking through an heterogeneous list of
objects sharing a common base class.

The first requirement for using the ``CellVisitor`` mechanism it to
include the :itkdox:`itk::CellInterfaceVisitor` header file.

::

    #include "itkCellInterfaceVisitor.h"

The typical mesh types are now declared

::

    typedef float                             PixelType;
    typedef itk::Mesh< PixelType, 3 >         MeshType;

    typedef MeshType::CellType                CellType;

    typedef itk::VertexCell< CellType >       VertexType;
    typedef itk::LineCell< CellType >         LineType;
    typedef itk::TriangleCell< CellType >     TriangleType;
    typedef itk::TetrahedronCell< CellType >  TetrahedronType;

Then, a custom CellVisitor class should be declared. In this particular
example, the visitor class is intended to act only on ``TriangleType``
cells. The only requirement on the declaration of the visitor class is
that it must provide a method named ``Visit()``. This method expects as
arguments a cell identifier and a pointer to the *specific* cell type
for which this visitor is intended. Nothing prevents a visitor class
from providing ``Visit()`` methods for several different cell types. The
multiple methods will be differentiated by the natural C++ mechanism of
function overload. The following code illustrates a minimal cell visitor
class.

::

    class CustomTriangleVisitor
      {
      public:
      typedef itk::TriangleCell<CellType>      TriangleType;
      void Visit(unsigned long cellId, TriangleType * t )
        {
        std::cout << "Cell # " << cellId << " is a TriangleType ";
        std::cout << t->GetNumberOfPoints() << std::endl;
        }
      CustomTriangleVisitor() {}
      virtual ~CustomTriangleVisitor() {}
      };

This newly defined class will now be used to instantiate a cell visitor.
In this particular example we create a class ``CustomTriangleVisitor``
which will be invoked each time a triangle cell is found while the mesh
iterates over the cells.

::

    typedef itk::CellInterfaceVisitorImplementation<
      PixelType,
      MeshType::CellTraits,
      TriangleType,
      CustomTriangleVisitor
      > TriangleVisitorInterfaceType;

Note that the actual ``CellInterfaceVisitorImplementation`` is templated
over the PixelType, the CellTraits, the CellType to be visited and the
Visitor class that defines with will be done with the cell.

A visitor implementation class can now be created using the normal
invocation to its ``New()`` method and assigning the result to a
``SmartPointer``.

::

    TriangleVisitorInterfaceType::Pointer  triangleVisitor =
    TriangleVisitorInterfaceType::New();

Many different visitors can be configured in this way. The set of all
visitors can be registered with the MultiVisitor class provided for the
mesh. An instance of the MultiVisitor class will walk through the cells
and delegate action to every registered visitor when the appropriate
cell type is encountered.

::

    typedef CellType::MultiVisitor CellMultiVisitorType;
    CellMultiVisitorType::Pointer multiVisitor = CellMultiVisitorType::New();

The visitor is registered with the Mesh using the ``AddVisitor()`` method.

::

    multiVisitor->AddVisitor( triangleVisitor );

Finally, the iteration over the cells is triggered by calling the method
``Accept()`` on the :itkdox:`itk::Mesh`.

::

    mesh->Accept( multiVisitor );

The ``Accept()`` method will iterate over all the cells and for each one
will invite the MultiVisitor to attempt an action on the cell. If no
visitor is interested on the current cell type the cell is just ignored
and skipped.

MultiVisitors make it possible to add behavior to the cells without
having to create new methods on the cell types or creating a complex
visitor class that knows about every CellType.
