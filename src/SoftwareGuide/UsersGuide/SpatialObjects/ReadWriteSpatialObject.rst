Read/Write SpatialObjects
-------------------------

{sec:ReadWriteSpatialObjects}

The source code for this section can be found in the file
``ReadWriteSpatialObject.cxx``.

Reading and writing SpatialObjects is a fairly simple task. The classes
:itkdox:`itk::SpatialObjectReader` and :itkdox:`itk::SpatialObjectWriter` are
used to read and write these objects, respectively. (Note these classes make
use of the MetaIO auxiliary I/O routines and therefore have a ``.meta`` file
suffix.)

We begin this example by including the appropriate header files.

::

    #include "itkSpatialObjectReader.h"
    #include "itkSpatialObjectWriter.h"
    #include "itkEllipseSpatialObject.h"

Next, we create a SpatialObjectWriter that is templated over the
dimension of the object(s) we want to write.

::

    typedef itk::SpatialObjectWriter<3> WriterType;
    WriterType::Pointer writer = WriterType::New();

For this example, we create an :itkdox:`itk::EllipseSpatialObject`.

::

    typedef itk::EllipseSpatialObject<3> EllipseType;
    EllipseType::Pointer ellipse = EllipseType::New();
    ellipse->SetRadius(3);

Finally, we set to the writer the object to write using the ``SetInput()``
method and we set the name of the file with ``SetFileName()`` and call the
``Update()`` method to actually write the information.

::

    writer->SetInput(ellipse);
    writer->SetFileName("ellipse.meta");
    writer->Update();

Now we are ready to open the freshly created object. We first create a
SpatialObjectReader which is also templated over the dimension of the
object in the file. This means that the file should contain only objects
with the same dimension.

::

    typedef itk::SpatialObjectReader<3> ReaderType;
    ReaderType::Pointer reader = ReaderType::New();

Next we set the name of the file to read using ``SetFileName()`` and we
call the ``Update()`` method to read the file.

::

    reader->SetFileName("ellipse.meta");
    reader->Update();

To get the objects in the file you can call the ``GetScene()`` method or the
``GetGroup()`` method. ``GetScene()`` returns an pointer to a
:itkdox:`itk::SceneSpatialObject`.

::

    ReaderType::SceneType * scene = reader->GetScene();
    std::cout << "Number of objects in the scene: ";
    std::cout << scene->GetNumberOfObjects() << std::endl;
    ReaderType::GroupType * group = reader->GetGroup();
    std::cout << "Number of objects in the group: ";
    std::cout << group->GetNumberOfChildren() << std::endl;

