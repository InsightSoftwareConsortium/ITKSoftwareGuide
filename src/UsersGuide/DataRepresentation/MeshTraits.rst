Customizing the Mesh
~~~~~~~~~~~~~~~~~~~~

{sec:CustomizingTheMesh}

The source code for this section can be found in the file
``MeshTraits.cxx``.

This section illustrates the full power of `Generic
Programming <http:www.boost.org/more/generic_programming.html>`_. This
is sometimes perceived as *too much of a good thing*!

The toolkit has been designed to offer flexibility while keeping the
complexity of the code to a moderate level. This is achieved in the Mesh
by hiding most of its parameters and defining reasonable defaults for
them.

The generic concept of a mesh integrates many different elements. It is
possible in principle to use independent types for every one of such
elements. The mechanism used in generic programming for specifying the
many different types involved in a concept is called *traits*. They are
basically the list of all types that interact with the current class.

The {Mesh} is templated over three parameters. So far only two of them
have been discussed, namely the {PixelType} and the {Dimension}. The
third parameter is a class providing the set of traits required by the
mesh. When the third parameter is omitted a default class is used. This
default class is the {DefaultStaticMeshTraits}. If you want to customize
the types used by the mesh, the way to proceed is to modify the default
traits and provide them as the third parameter of the Mesh class
instantiation.

There are two ways of achieving this. The first is to use the existing
DefaultStaticMeshTraits class. This class is itself templated over six
parameters. Customizing those parameters could provide enough
flexibility to define a very specific kind of mesh. The second way is to
write a traits class from scratch, in which case the easiest way to
proceed is to copy the DefaultStaticMeshTraits into another file and
edit its content. Only the first approach is illustrated here. The
second is discouraged unless you are familiar with Generic Programming,
feel comfortable with C++ templates and have access to an abundant
supply of (Columbian) coffee.

The first step in customizing the mesh is to include the header file of
the Mesh and its static traits.

::

    [language=C++]
    #include "itkMesh.h"
    #include "itkDefaultStaticMeshTraits.h"

Then the MeshTraits class is instantiated by selecting the types of each
one of its six template arguments. They are in order

PixelType.
    The type associated with every point.

PointDimension.
    The dimension of the space in which the mesh is embedded.

MaxTopologicalDimension.
    The highest dimension of the mesh cells.

CoordRepType.
    The type used to represent space coordinates.

InterpolationWeightType.
    The type used to represent interpolation weights.

CellPixelType.
    The type associated with every cell.

Let’s define types and values for each one of those elements. For
example the following code will use points in 3D space as nodes of the
Mesh. The maximum dimension of the cells will be two which means that
this is a 2D manifold better know as a *surface*. The data type
associated with points is defined to be a four-dimensional vector. This
type could represent values of membership for a four-classes
segmentation method. The value selected for the cells are
:math:`4\times3` matrices which could have for example the derivative
of the membership values with respect to coordinates in space. Finally a
{double} type is selected for representing space coordinates on the mesh
points and also for the weight used for interpolating values.

::

    [language=C++]
    const unsigned int PointDimension = 3;
    const unsigned int MaxTopologicalDimension = 2;

    typedef itk::Vector<double,4>                  PixelType;
    typedef itk::Matrix<double,4,3>                CellDataType;

    typedef double CoordinateType;
    typedef double InterpolationWeightType;

    typedef itk::DefaultStaticMeshTraits<
    PixelType, PointDimension, MaxTopologicalDimension,
    CoordinateType, InterpolationWeightType, CellDataType > MeshTraits;

    typedef itk::Mesh< PixelType, PointDimension, MeshTraits > MeshType;

The {LineCell} type can now be instantiated using the traits taken from
the Mesh.

::

    [language=C++]
    typedef MeshType::CellType                CellType;
    typedef itk::LineCell< CellType >         LineType;

Let’s now create an Mesh and insert some points on it. Note that the
dimension of the points matches the dimension of the Mesh. Here we
insert a sequence of points that look like a plot of the :math:`log()`
function.

::

    [language=C++]
    MeshType::Pointer  mesh = MeshType::New();

    typedef MeshType::PointType PointType;
    PointType point;

    const unsigned int numberOfPoints = 10;
    for(unsigned int id=0; id<numberOfPoints; id++)
    {
    point[0] = 1.565;    Initialize points here
    point[1] = 3.647;    with arbitrary values
    point[2] = 4.129;
    mesh->SetPoint( id, point );
    }

A set of line cells is created and associated with the existing points
by using point identifiers. In this simple case, the point identifiers
can be deduced from cell identifiers since the line cells are ordered in
the same way. Note that in the code above, the values assigned to point
components are arbitrary. In a more realistic example, those values
would be computed from another source.

::

    [language=C++]
    CellType::CellAutoPointer line;
    const unsigned int numberOfCells = numberOfPoints-1;
    for(unsigned int cellId=0; cellId<numberOfCells; cellId++)
    {
    line.TakeOwnership(  new LineType  );
    line->SetPointId( 0, cellId   );  first point
    line->SetPointId( 1, cellId+1 );  second point
    mesh->SetCell( cellId, line );    insert the cell
    }

Data associated with cells is inserted in the Mesh by using the
{SetCellData()} method. It requires the user to provide an identifier
and the value to be inserted. The identifier should match one of the
inserted cells. In this example, we simply store a CellDataType dummy
variable named {value}.

::

    [language=C++]
    for(unsigned int cellId=0; cellId<numberOfCells; cellId++)
    {
    CellDataType value;
    mesh->SetCellData( cellId, value );
    }

Cell data can be read from the Mesh with the {GetCellData()} method. It
requires the user to provide the identifier of the cell for which the
data is to be retrieved. The user should provide also a valid pointer to
a location where the data can be copied.

::

    [language=C++]
    for(unsigned int cellId=0; cellId<numberOfCells; cellId++)
    {
    CellDataType value;
    mesh->GetCellData( cellId, &value );
    std::cout << "Cell " << cellId << " = " << value << std::endl;
    }

Neither {SetCellData()} or {GetCellData()} are efficient ways to access
cell data. Efficient access to cell data can be achieved by using the
Iterators built into the CellDataContainer.

::

    [language=C++]
    typedef MeshType::CellDataContainer::ConstIterator CellDataIterator;

Note that the {ConstIterator} is used here because the data is only
going to be read. This approach is exactly the same already illustrated
for getting access to point data. The iterator to the first cell data
item can be obtained with the {Begin()} method of the CellDataContainer.
The past-end iterator is returned by the {End()} method. The cell data
container itself can be obtained from the mesh with the method
{GetCellData()}.

::

    [language=C++]
    CellDataIterator cellDataIterator  = mesh->GetCellData()->Begin();
    CellDataIterator end               = mesh->GetCellData()->End();

Finally a standard loop is used to iterate over all the cell data
entries. Note the use of the {Value()} method used to get the actual
value of the data entry. {PixelType} elements are returned by copy.

::

    [language=C++]
    while( cellDataIterator != end )
    {
    CellDataType cellValue = cellDataIterator.Value();
    std::cout << cellValue << std::endl;
    ++cellDataIterator;
    }

