.. _sec-TeeContainer:

TreeContainer
~~~~~~~~~~~~~

The source code for this section can be found in the file
``TreeContainer.cxx``.

This example shows how to use the :itkdox:`itk::TreeContainer` and the associated
TreeIterators. The :itkdox:`itk::TreeContainer` implements the notion of tree and is
templated over the type of node so it can virtually handle any objects.
Each node is supposed to have only one parent so no cycle is present in
the tree. No checking is done to ensure a cycle-free tree.

Let’s begin by including the appropriate header file.

::

    #include "itkTreeContainer.h"
    #include "itkTreeContainer.h"
    #include "itkChildTreeIterator.h"
    #include "itkLeafTreeIterator.h"
    #include "itkLevelOrderTreeIterator.h"
    #include "itkInOrderTreeIterator.h"
    #include "itkPostOrderTreeIterator.h"
    #include "itkRootTreeIterator.h"
    #include "itkTreeIteratorClone.h"

First, we create a tree of integers. The TreeContainer is templated over
the type of nodes.

::

    typedef int                          NodeType;
    typedef itk::TreeContainer<NodeType> TreeType;
    TreeType::Pointer tree = TreeType::New();

Next we set the value of the root node using ``SetRoot()``.

::

    tree->SetRoot(0);

Then we use the ``Add()`` function to add nodes to the tree The first
argument is the value of the new node and the second argument is the
value of the parent node. If two nodes have the same values then the
first one is picked. In this particular case it is better to use an
iterator to fill the tree.

::

    tree->Add(1,0);
    tree->Add(2,0);
    tree->Add(3,0);
    tree->Add(4,2);
    tree->Add(5,2);
    tree->Add(6,5);
    tree->Add(7,1);

We define an ``LevelOrderTreeIterator`` to parse the tree in level order.
This particular iterator takes three arguments. The first one is the
actual tree to be parsed, the second one is the maximum depth level and
the third one is the starting node. The ``GetNode()`` function return a
node given its value. Once again the first node that corresponds to the
value is returned.

::

    itk::LevelOrderTreeIterator<TreeType> levelIt(tree,10,tree->GetNode(2));
    levelIt.GoToBegin();
    while(!levelIt.IsAtEnd())
      {
      std::cout << levelIt.Get()
      << " ("<< levelIt.GetLevel()
      << ")" << std::endl;
      ++levelIt;
      }
    std::cout << std::endl;

The TreeIterators have useful functions to test the property of the
current pointed node. Among these functions: ``IsLeaf{}`` returns true if
the current node is a leaf, ``IsRoot{}`` returns true if the node is a
root, `HasParent()`` returns true if the node has a parent and
``CountChildren()`` returns the number of children for this particular
node.

::

    levelIt.IsLeaf();
    levelIt.IsRoot();
    levelIt.HasParent();
    levelIt.CountChildren();

The :itkdox:`itk::ChildTreeIterator` provides another way to iterate through a tree
by listing all the children of a node.

::

    itk::ChildTreeIterator<TreeType> childIt(tree);
    childIt.GoToBegin();
    while(!childIt.IsAtEnd())
      {
      std::cout << childIt.Get() << std::endl;
      ++childIt;
      }
    std::cout << std::endl;

The ``GetType()`` function returns the type of iterator used. The list of
enumerated types is as follow: PREORDER, INORDER, POSTORDER, LEVELORDER,
CHILD, ROOT and LEAF.

::

    if(childIt.GetType() != itk::TreeIteratorBase<TreeType>::CHILD)
      {
      std::cout << "[FAILURE]" << std::endl;
      return EXIT_FAILURE;
      }

Every TreeIterator has a ``Clone()`` function which returns a copy of the
current iterator. Note that the user should delete the created iterator
by hand.

::

    childIt.GoToParent();
    itk::TreeIteratorBase<TreeType>* childItClone = childIt.Clone();
    delete childItClone;

The :itkdox:`itk::LeafTreeIterator` iterates through the leaves of the tree.

::

    itk::LeafTreeIterator<TreeType> leafIt(tree);
    leafIt.GoToBegin();
    while(!leafIt.IsAtEnd())
      {
      std::cout << leafIt.Get() << std::endl;
      ++leafIt;
      }
    std::cout << std::endl;

The :itkdox:`itk::InOrderTreeIterator` iterates through the tree in the order from
left to right.

::

    itk::InOrderTreeIterator<TreeType> InOrderIt(tree);
    InOrderIt.GoToBegin();
    while(!InOrderIt.IsAtEnd())
      {
      std::cout << InOrderIt.Get() << std::endl;
      ++InOrderIt;
      }
    std::cout << std::endl;

The :itkdox:`itk::PreOrderTreeIterator` iterates through the tree from left to right
but do a depth first search.

::

    itk::PreOrderTreeIterator<TreeType> PreOrderIt(tree);
    PreOrderIt.GoToBegin();
    while(!PreOrderIt.IsAtEnd())
      {
      std::cout << PreOrderIt.Get() << std::endl;
      ++PreOrderIt;
      }
    std::cout << std::endl;

The :itkdox:`itk::PostOrderTreeIterator` iterates through the tree from left to right
but goes from the leaves to the root in the search.

::

    itk::PostOrderTreeIterator<TreeType> PostOrderIt(tree);
    PostOrderIt.GoToBegin();
    while(!PostOrderIt.IsAtEnd())
      {
      std::cout << PostOrderIt.Get() << std::endl;
      ++PostOrderIt;
      }
    std::cout << std::endl;

The :itkdox:`itk::RootTreeIterator` goes from one node to the root. The second
arguments is the starting node. Here we go from the leaf node (value =
6) up to the root.

::

    itk::RootTreeIterator<TreeType> RootIt(tree,tree->GetNode(6));
    RootIt.GoToBegin();
    while(!RootIt.IsAtEnd())
      {
      std::cout << RootIt.Get() << std::endl;
      ++RootIt;
      }
    std::cout << std::endl;

All the nodes of the tree can be removed by using the ``Clear()``
function.

::

    tree->Clear();

We show how to use a TreeIterator to form a tree by creating nodes. The
``Add()`` function is used to add a node and put a value on it. The
``GoToChild()`` is used to jump to a node.

::

    itk::PreOrderTreeIterator<TreeType> PreOrderIt2(tree);
    PreOrderIt2.Add(0);
    PreOrderIt2.Add(1);
    PreOrderIt2.Add(2);
    PreOrderIt2.Add(3);
    PreOrderIt2.GoToChild(2);
    PreOrderIt2.Add(4);
    PreOrderIt2.Add(5);

The :itkdox:`itk::TreeIteratorClone` can be used to have a generic copy of an
iterator.

::

    typedef itk::TreeIteratorBase<TreeType>      IteratorType;
    typedef itk::TreeIteratorClone<IteratorType> IteratorCloneType;
    itk::PreOrderTreeIterator<TreeType> anIterator(tree);
    IteratorCloneType aClone = anIterator;

