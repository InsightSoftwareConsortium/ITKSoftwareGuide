.. _sec-SpatialObjectTreeContainer:

SpatialObject Tree Container
----------------------------

The source code for this section can be found in the file
``SpatialObjectTreeContainer.cxx``.

This example describes how to use the :itkdox:`itk::SpatialObjectTreeContainer` to
form a hierarchy of SpatialObjects. First we include the appropriate
header file.

::

    #include "itkSpatialObjectTreeContainer.h"

Next we define the type of node and the type of tree we plan to use.
Both are templated over the dimensionality of the space. Let’s create a
2-dimensional tree.

::

    typedef itk::GroupSpatialObject<2> NodeType;
    typedef itk::SpatialObjectTreeContainer<2> TreeType;

Then, we can create three nodes and set their corresponding
identification numbers (using ``SetId``).

::

    NodeType::Pointer object0 = NodeType::New();
    object0->SetId(0);
    NodeType::Pointer object1 = NodeType::New();
    object1->SetId(1);
    NodeType::Pointer object2 = NodeType::New();
    object2->SetId(2);

The hierarchy is formed using the ``AddSpatialObject()`` function.

::

    object0->AddSpatialObject(object1);
    object1->AddSpatialObject(object2);

After instantiation of the tree we set its root using the ``SetRoot()``
function.

::

    TreeType::Pointer tree = TreeType::New();
    tree->SetRoot(object0.GetPointer());

The tree iterators described in a previous section of this guide can be
used to parse the hierarchy. For example, via an
:itkdox:`itk::LevelOrderTreeIterator` templated over the type of tree, we can parse
the hierarchy of SpatialObjects. We set the maximum level to 10 which is
enough in this case since our hierarchy is only 2 deep.

::

    itk::LevelOrderTreeIterator<TreeType> levelIt(tree,10);
    levelIt.GoToBegin();
    while(!levelIt.IsAtEnd())
      {
      std::cout << levelIt.Get()->GetId() << " ("<< levelIt.GetLevel()
      << ")" << std::endl;;
      ++levelIt;
      }

Tree iterators can also be used to add spatial objects to the hierarchy.
Here we show how to use the :itkdox:`itk::PreOrderTreeIterator` to add a fourth
object to the tree.

::

    NodeType::Pointer object4 = NodeType::New();
    itk::PreOrderTreeIterator<TreeType> preIt( tree );
    preIt.Add(object4.GetPointer());

