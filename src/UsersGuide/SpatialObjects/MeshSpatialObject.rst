MeshSpatialObject
~~~~~~~~~~~~~~~~~

{sec:MeshSpatialObject}

The source code for this section can be found in the file
``MeshSpatialObject.cxx``.

A {MeshSpatialObject} contains a pointer to an {Mesh} but adds the
notion of spatial transformations and parent-child hierarchy. This
example shows how to create an {MeshSpatialObject}, use it to form a
binary image and how to write the mesh on disk.

Let’s begin by including the appropriate header file.

::

    [language=C++]
    #include "itkSpatialObjectToImageFilter.h"
    #include "itkMeshSpatialObject.h"
    #include "itkSpatialObjectReader.h"
    #include "itkSpatialObjectWriter.h"

The MeshSpatialObject wraps an {Mesh}, therefore we first create a mesh.

::

    [language=C++]
    typedef itk::DefaultDynamicMeshTraits< float , 3, 3 > MeshTrait;
    typedef itk::Mesh<float,3,MeshTrait>                  MeshType;
    typedef MeshType::CellTraits                          CellTraits;
    typedef itk::CellInterface< float, CellTraits >       CellInterfaceType;
    typedef itk::TetrahedronCell<CellInterfaceType>       TetraCellType;
    typedef MeshType::PointType                           PointType;
    typedef MeshType::CellType                            CellType;
    typedef CellType::CellAutoPointer                     CellAutoPointer;

::

    [language=C++]
    MeshType::Pointer myMesh = MeshType::New();

    MeshType::CoordRepType testPointCoords[4][3]
    = { {0,0,0}, {9,0,0}, {9,9,0}, {0,0,9} };

    MeshType::PointIdentifier tetraPoints[4] = {0,1,2,4};

    int i;
    for(i=0; i < 4 ; ++i)
    {
    myMesh->SetPoint(i, PointType(testPointCoords[i]));
    }

    myMesh->SetCellsAllocationMethod(
    MeshType::CellsAllocatedDynamicallyCellByCell );
    CellAutoPointer testCell1;
    testCell1.TakeOwnership(  new TetraCellType );
    testCell1->SetPointIds(tetraPoints);

::

    [language=C++]
    myMesh->SetCell(0, testCell1 );

We then create a MeshSpatialObject which is templated over the type of
mesh previously defined...

::

    [language=C++]
    typedef itk::MeshSpatialObject<MeshType>     MeshSpatialObjectType;
    MeshSpatialObjectType::Pointer myMeshSpatialObject =
    MeshSpatialObjectType::New();

... and pass the Mesh pointer to the MeshSpatialObject

::

    [language=C++]
    myMeshSpatialObject->SetMesh(myMesh);

The actual pointer to the passed mesh can be retrieved using the
{GetMesh()} function.

::

    [language=C++]
    myMeshSpatialObject->GetMesh();

Like any other SpatialObjects. The {GetBoundingBox()}, {ValueAt()},
{IsInside()} functions can be used to access important information.

::

    [language=C++]
    std::cout << "Mesh bounds : " <<
    myMeshSpatialObject->GetBoundingBox()->GetBounds() << std::endl;
    MeshSpatialObjectType::PointType myPhysicalPoint;
    myPhysicalPoint.Fill(1);
    std::cout << "Is my physical point inside? : " <<
    myMeshSpatialObject->IsInside(myPhysicalPoint) << std::endl;

Now that we have defined the MeshSpatialObject, we can save the actual
mesh using the {SpatialObjectWriter}. To be able to do so, we need to
specify the type of Mesh we are writing.

::

    [language=C++]
    typedef itk::SpatialObjectWriter<3,float,MeshTrait> WriterType;
    WriterType::Pointer writer = WriterType::New();

Then we set the mesh spatial object and the name of the file and call
the the {Update()} function.

::

    [language=C++]
    writer->SetInput(myMeshSpatialObject);
    writer->SetFileName("myMesh.meta");
    writer->Update();

Reading the saved mesh is done using the {SpatialObjectReader}. Once
again we need to specify the type of mesh we intend to read.

::

    [language=C++]
    typedef itk::SpatialObjectReader<3,float,MeshTrait> ReaderType;
    ReaderType::Pointer reader = ReaderType::New();

We set the name of the file we want to read and call update

::

    [language=C++]
    reader->SetFileName("myMesh.meta");
    reader->Update();

Next, we show how to create a binary image of a MeshSpatialObject using
the {SpatialObjectToImageFilter}. The resulting image will have ones
inside and zeros outside the mesh. First we define and instantiate the
SpatialObjectToImageFilter.

::

    [language=C++]
    typedef itk::Image<unsigned char,3> ImageType;
    typedef itk::GroupSpatialObject<3> GroupType;
    typedef itk::SpatialObjectToImageFilter< GroupType, ImageType >
    SpatialObjectToImageFilterType;
    SpatialObjectToImageFilterType::Pointer imageFilter =
    SpatialObjectToImageFilterType::New();

Then we pass the output of the reader, i.e the MeshSpatialObject, to the
filter.

::

    [language=C++]
    imageFilter->SetInput(  reader->GetGroup()  );

Finally we trigger the execution of the filter by calling the {Update()}
method. Note that depending on the size of the mesh, the computation
time can increase significantly.

::

    [language=C++]
    imageFilter->Update();

Then we can get the resulting binary image using the {GetOutput()}
function.

::

    [language=C++]
    ImageType::Pointer myBinaryMeshImage = imageFilter->GetOutput();

