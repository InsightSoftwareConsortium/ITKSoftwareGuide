.. _sec-SpatialObjectHierarchy:

Hierarchy
---------

Spatial objects can be combined to form a hierarchy as a tree. By
design, a SpatialObject can have one parent and only one. Moreover, each
transform is stored within each object, therefore the hierarchy cannot
be described as a Directed Acyclic Graph (DAG) but effectively as a
tree. The user is responsible for maintaining the tree structure, no
checking is done to ensure a cycle-free tree.
The source code for this section can be found in the file
``SpatialObjectHierarchy.cxx``.

This example describes how :itkdox:`itk::SpatialObject` can form a hierarchy. This
first example also shows how to create and manipulate spatial objects.

::

    #include "itkSpatialObject.h"

First, we create two spatial objects and give them the names ``First
Objectxi`` and ``Second Object``, respectively.

::

    typedef itk::SpatialObject<3> SpatialObjectType;

    SpatialObjectType::Pointer object1 = SpatialObjectType ::New();
    object1->GetProperty()->SetName("First Object");

    SpatialObjectType::Pointer object2 = SpatialObjectType ::New();
    object2->GetProperty()->SetName("Second Object");

We then add the second object to the first one by using the
``AddSpatialObject()`` method. As a result ``object2`` becomes a child of
object1.

::

    object1->AddSpatialObject(object2);

We can query if an object has a parent by using the ``HasParent()`` method.
If it has one, the ``GetParent()`` method returns a constant pointer to
the parent. In our case, if we ask the parent’s name of the object2 we
should obtain: ``First Object``.

::

    if(object2->HasParent())
      {
      std::cout << "Name of the parent of the object2: ";
      std::cout << object2->GetParent()->GetProperty()->GetName() << std::endl;
      }

To access the list of children of the object, the ``GetChildren()`` method
returns a pointer to the (STL) list of children.

::

    SpatialObjectType::ChildrenListType * childrenList = object1->GetChildren();
    std::cout << "object1 has " << childrenList->size() << " child" << std::endl;

    SpatialObjectType::ChildrenListType::const_iterator it = childrenList->begin();
    while(it != childrenList->end())
     {
      std::cout << "Name of the child of the object 1: ";
      std::cout << (*it)->GetProperty()->GetName() << std::endl;
      it++;
      }

Do NOT forget to delete the list of children since the ``GetChildren()``
function creates an internal list.

::

    delete childrenList;

An object can also be removed by using the ``RemoveSpatialObject()``
method.

::

    object1->RemoveSpatialObject(object2);

We can query the number of children an object has with the
``GetNumberOfChildren()`` method.

::

    std::cout << "Number of children for object1: ";
    std::cout << object1->GetNumberOfChildren() << std::endl;

The ``Clear()`` method erases all the information regarding the object as
well as the data. This method is usually overloaded by derived classes.

::

    object1->Clear();

The output of this first example looks like the following:

::

    Name of the parent of the object2: First Object
    object1 has 1 child
    Name of the child of the object 1: Second Object
    Number of children for object1: 0
