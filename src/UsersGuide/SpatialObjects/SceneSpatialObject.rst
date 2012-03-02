.. _sec-Scene:

SceneSpatialObject
------------------

The source code for this section can be found in the file
``SceneSpatialObject.cxx``.

This example describes how to use the :itkdox:`itk::SceneSpatialObject`. A
SceneSpatialObject contains a collection of SpatialObjects. This example
begins by including the appropriate header file.

::

    #include "itkSceneSpatialObject.h"

An SceneSpatialObject is templated over the dimension of the space which
requires all the objects referenced by the SceneSpatialObject to have
the same dimension.

First we define some type definitions and we create the
SceneSpatialObject.

::

    typedef itk::SceneSpatialObject<3> SceneSpatialObjectType;
    SceneSpatialObjectType::Pointer scene = SceneSpatialObjectType::New();

Then we create two :itkdox:`itk::EllipseSpatialObject`'s.

::

    typedef itk::EllipseSpatialObject<3> EllipseType;
    EllipseType::Pointer ellipse1 = EllipseType::New();
    ellipse1->SetRadius(1);
    ellipse1->SetId(1);
    EllipseType::Pointer ellipse2 = EllipseType::New();
    ellipse2->SetId(2);
    ellipse2->SetRadius(2);

Then we add the two ellipses into the SceneSpatialObject.

::

    scene->AddSpatialObject(ellipse1);
    scene->AddSpatialObject(ellipse2);

We can query the number of object in the SceneSpatialObject with the
``GetNumberOfObjects()`` function. This function takes two optional
arguments: the depth at which we should count the number of objects
(default is set to infinity) and the name of the object to count
(default is set to NULL). This allows the user to count, for example,
only ellipses.

::

    std::cout << "Number of objects in the SceneSpatialObject = ";
    std::cout << scene->GetNumberOfObjects() << std::endl;

The ``GetObjectById()`` returns the first object in the SceneSpatialObject
that has the specified identification number.

::

    std::cout << "Object in the SceneSpatialObject with an ID == 2: " << std::endl;
    scene->GetObjectById(2)->Print(std::cout);

Objects can also be removed from the SceneSpatialObject using the
``RemoveSpatialObject()`` function.

::

    scene->RemoveSpatialObject(ellipse1);

The list of current objects in the SceneSpatialObject can be retrieved
using the ``GetObjects()`` method. Like the ``GetNumberOfObjects()`` method,
``GetObjects()`` can take two arguments: a search depth and a matching
name.

::

    SceneSpatialObjectType::ObjectListType * myObjectList =  scene->GetObjects();
    std::cout << "Number of objects in the SceneSpatialObject = ";
    std::cout << myObjectList->size() << std::endl;

In some cases, it is useful to define the hierarchy by using
``ParentId()`` and the current identification number. This results in
having a flat list of SpatialObjects in the SceneSpatialObject.
Therefore, the SceneSpatialObject provides the ``FixHierarchy()`` method
which reorganizes the Parent-Child hierarchy based on identification
numbers.

::

    scene->FixHierarchy();

The scene can also be cleared by using the ``Clear()`` function.

::

    scene->Clear();

