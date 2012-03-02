.. _sec-MeshCellVisitorMultipleType:

More on Visiting Cells
~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``MeshCellVisitor2.cxx``.

The following section illustrates a realistic example of the use of Cell
visitors on the :itkdox:`itk::Mesh`. A set of different visitors is defined here,
each visitor associated with a particular type of cell. All the visitors
are registered with a MultiVisitor class which is passed to the mesh.

The first step is to include the :itkdox:`itk::CellInterfaceVisitor` header file.

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

Then, custom CellVisitor classes should be declared. The only
requirement on the declaration of each visitor class is to provide a
method named ``Visit()``. This method expects as arguments a cell
identifier and a pointer to the *specific* cell type for which this
visitor is intended.

The following Vertex visitor simply prints out the identifier of the
point with which the cell is associated. Note that the cell uses the
method ``GetPointId()`` without any arguments. This method is only defined
on the VertexCell.

::

    class CustomVertexVisitor
      {
      public:
      void Visit(unsigned long cellId, VertexType * t )
        {
        std::cout << "cell " << cellId << " is a Vertex " << std::endl;
        std::cout << "    associated with point id = ";
        std::cout << t->GetPointId() << std::endl;
        }
      virtual ~CustomVertexVisitor() {}
      };

The following Line visitor computes the length of the line. Note that
this visitor is slightly more complicated since it needs to get access
to the actual mesh in order to get point coordinates from the point
identifiers returned by the line cell. This is done by holding a pointer
to the mesh and querying the mesh each time point coordinates are
required. The mesh pointer is set up in this case with the ``SetMesh()``
method.

::

    class CustomLineVisitor
      {
      public:
      CustomLineVisitor():m_Mesh( 0 ) {}
      virtual ~CustomLineVisitor() {}

      void SetMesh( MeshType * mesh ) { m_Mesh = mesh; }

      void Visit(unsigned long cellId, LineType * t )
        {
        std::cout << "cell " << cellId << " is a Line " << std::endl;
        LineType::PointIdIterator pit = t->PointIdsBegin();
        MeshType::PointType p0;
        MeshType::PointType p1;
        m_Mesh->GetPoint( *pit++, &p0 );
        m_Mesh->GetPoint( *pit++, &p1 );
        const double length = p0.EuclideanDistanceTo( p1 );
        std::cout << " length = " << length << std::endl;
        }

      private:
      MeshType::Pointer m_Mesh;
      };

The Triangle visitor below prints out the identifiers of its points.
Note the use of the ``PointIdIterator`` and the ``PointIdsBegin()`` and
``PointIdsEnd()`` methods.

::

    class CustomTriangleVisitor
      {
      public:
      void Visit(unsigned long cellId, TriangleType * t )
        {
        std::cout << "cell " << cellId << " is a Triangle " << std::endl;
        LineType::PointIdIterator pit = t->PointIdsBegin();
        LineType::PointIdIterator end = t->PointIdsEnd();
        while( pit != end )
          {
          std::cout << "  point id = " << *pit << std::endl;
          ++pit;
          }
        }
      virtual ~CustomTriangleVisitor() {}
      };

The TetrahedronVisitor below simply returns the number of faces on this
figure. Note that {GetNumberOfFaces()} is a method exclusive of 3D
cells.

::

    class CustomTetrahedronVisitor
      {
      public:
      void Visit(unsigned long cellId, TetrahedronType * t )
        {
        std::cout << "cell " << cellId << " is a Tetrahedron " << std::endl;
        std::cout << "  number of faces = ";
        std::cout << t->GetNumberOfFaces() << std::endl;
        }
      virtual ~CustomTetrahedronVisitor() {}
      };

With the cell visitors we proceed now to instantiate CellVisitor
implementations. The visitor classes defined above are used as template
arguments of the cell visitor implementation.

::

    typedef itk::CellInterfaceVisitorImplementation<
      PixelType, MeshType::CellTraits, VertexType, CustomVertexVisitor
      > VertexVisitorInterfaceType;

    typedef itk::CellInterfaceVisitorImplementation<
      PixelType, MeshType::CellTraits, LineType, CustomLineVisitor
      > LineVisitorInterfaceType;

    typedef itk::CellInterfaceVisitorImplementation<
      PixelType, MeshType::CellTraits, TriangleType, CustomTriangleVisitor
      > TriangleVisitorInterfaceType;

    typedef itk::CellInterfaceVisitorImplementation<
      PixelType, MeshType::CellTraits, TetrahedronType, CustomTetrahedronVisitor
      > TetrahedronVisitorInterfaceType;

Note that the actual ``CellInterfaceVisitorImplementation`` is templated
over the PixelType, the CellTraits, the CellType to be visited and the
Visitor class defining what to do with the cell.

A visitor implementation class can now be created using the normal
invocation to its ``New()`` method and assigning the result to a
``SmartPointer``.

::

    VertexVisitorInterfaceType::Pointer  vertexVisitor =
      VertexVisitorInterfaceType::New();

    LineVisitorInterfaceType::Pointer  lineVisitor =
      LineVisitorInterfaceType::New();

    TriangleVisitorInterfaceType::Pointer  triangleVisitor =
      TriangleVisitorInterfaceType::New();

    TetrahedronVisitorInterfaceType::Pointer  tetrahedronVisitor =
      TetrahedronVisitorInterfaceType::New();

Remember that the LineVisitor requires the pointer to the mesh object
since it needs to get access to actual point coordinates. This is done
by invoking the ``SetMesh()`` method defined above.

::

    lineVisitor->SetMesh( mesh );

Looking carefully you will notice that the ``SetMesh()`` method is
declared in ``MeshCustomLineVisitor`` but we are invoking it on
``LineVisitorInterfaceType``. This is possible thanks to the way in which
the VisitorInterfaceImplementation is defined. This class derives from
the visitor type provided by the user as the fourth template parameter.
``LineVisitorInterfaceType`` is then a derived class of
``CustomLineVisitor``.

The set of visitors should now be registered with the MultiVisitor class
that will walk through the cells and delegate action to every registered
visitor when the appropriate cell type is encountered. The following
lines create a MultiVisitor object.

::

    typedef CellType::MultiVisitor CellMultiVisitorType;
    CellMultiVisitorType::Pointer multiVisitor = CellMultiVisitorType::New();

Every visitor implementation is registered with the Mesh using the
``AddVisitor()`` method.

::

    multiVisitor->AddVisitor( vertexVisitor      );
    multiVisitor->AddVisitor( lineVisitor        );
    multiVisitor->AddVisitor( triangleVisitor    );
    multiVisitor->AddVisitor( tetrahedronVisitor );

Finally, the iteration over the cells is triggered by calling the method
``Accept()`` on the Mesh class.

::

    mesh->Accept( multiVisitor );

The ``Accept()`` method will iterate over all the cells and for each one
will invite the MultiVisitor to attempt an action on the cell. If no
visitor is interested on the current cell type, the cell is just ignored
and skipped.
