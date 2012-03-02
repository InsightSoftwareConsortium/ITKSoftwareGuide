The source code for this section can be found in the file
``KdTree.cxx``.

The {Statistics} {KdTree} implements a data structure that separates
samples in a :math:`k`-dimension space. The {std::vector} class is
used here as the container for the measurement vectors from a sample.

::

    [language=C++]
    #include "itkVector.h"
    #include "itkListSample.h"
    #include "itkWeightedCentroidKdTreeGenerator.h"
    #include "itkEuclideanDistanceMetric.h"

We define the measurement vector type and instantiate a {Statistics}
{ListSample} object, and then put 1000 measurement vectors in the
object.

::

    [language=C++]
    typedef itk::Vector< float, 2 > MeasurementVectorType;

    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    sample->SetMeasurementVectorSize( 2 );

    MeasurementVectorType mv;
    for (unsigned int i = 0 ; i < 1000 ; ++i )
    {
    mv[0] = (float) i;
    mv[1] = (float) ((1000 - i) / 2 );
    sample->PushBack( mv );
    }

The following code snippet shows how to create two KdTree objects. The
first object {Statistics} {KdTreeGenerator} has a minimal set of
information (partition dimension, partition value, and pointers to the
left and right child nodes). The second tree from the {Statistics}
{WeightedCentroidKdTreeGenerator} has additional information such as the
number of children under each node, and the vector sum of the
measurement vectors belonging to children of a particular node.
WeightedCentroidKdTreeGenerator and the resulting k-d tree structure
were implemented based on the description given in the paper by Kanungo
et al .

The instantiation and input variables are exactly the same for both tree
generators. Using the {SetSample()} method we plug-in the source sample.
The bucket size input specifies the limit on the maximum number of
measurement vectors that can be stored in a terminal (leaf) node. A
bigger bucket size results in a smaller number of nodes in a tree. It
also affects the efficiency of search. With many small leaf nodes, we
might experience slower search performance because of excessive boundary
comparisons.

::

    [language=C++]
    typedef itk::Statistics::KdTreeGenerator< SampleType > TreeGeneratorType;
    TreeGeneratorType::Pointer treeGenerator = TreeGeneratorType::New();

    treeGenerator->SetSample( sample );
    treeGenerator->SetBucketSize( 16 );
    treeGenerator->Update();

    typedef itk::Statistics::WeightedCentroidKdTreeGenerator< SampleType >
    CentroidTreeGeneratorType;

    CentroidTreeGeneratorType::Pointer centroidTreeGenerator =
    CentroidTreeGeneratorType::New();

    centroidTreeGenerator->SetSample( sample );
    centroidTreeGenerator->SetBucketSize( 16 );
    centroidTreeGenerator->Update();

After the generation step, we can get the pointer to the kd-tree from
the generator by calling the {GetOutput()} method. To traverse a
kd-tree, we have to use the {GetRoot()} method. The method will return
the root node of the tree. Every node in a tree can have its left and/or
right child node. To get the child node, we call the {Left()} or the
{Right()} method of a node (these methods do not belong to the kd-tree
but to the nodes).

We can get other information about a node by calling the methods
described below in addition to the child node pointers.

::

    [language=C++]
    typedef TreeGeneratorType::KdTreeType TreeType;
    typedef TreeType::NearestNeighbors NeighborsType;
    typedef TreeType::KdTreeNodeType NodeType;

    TreeType::Pointer tree = treeGenerator->GetOutput();
    TreeType::Pointer centroidTree = centroidTreeGenerator->GetOutput();

    NodeType* root = tree->GetRoot();

    if ( root->IsTerminal() )
    {
    std::cout << "Root node is a terminal node." << std::endl;
    }
    else
    {
    std::cout << "Root node is not a terminal node." << std::endl;
    }

    unsigned int partitionDimension;
    float partitionValue;
    root->GetParameters( partitionDimension, partitionValue);
    std::cout << "Dimension chosen to split the space = "
    << partitionDimension << std::endl;
    std::cout << "Split point on the partition dimension = "
    << partitionValue << std::endl;

    std::cout << "Address of the left chile of the root node = "
    << root->Left() << std::endl;

    std::cout << "Address of the right chile of the root node = "
    << root->Right() << std::endl;

    root = centroidTree->GetRoot();
    std::cout << "Number of the measurement vectors under the root node"
    << " in the tree hierarchy = " << root->Size() << std::endl;

    NodeType::CentroidType centroid;
    root->GetWeightedCentroid( centroid );
    std::cout << "Sum of the measurement vectors under the root node = "
    << centroid << std::endl;

    std::cout << "Number of the measurement vectors under the left child"
    << " of the root node = " << root->Left()->Size() << std::endl;

In the following code snippet, we query the three nearest neighbors of
the {queryPoint} on the two tree. The results and procedures are exactly
the same for both. First we define the point from which distances will
be measured.

::

    [language=C++]
    MeasurementVectorType queryPoint;
    queryPoint[0] = 10.0;
    queryPoint[1] = 7.0;

Then we instantiate the type of a distance metric, create an object of
this type and set the origin of coordinates for measuring distances. The
{GetMeasurementVectorSize()} method returns the length of each
measurement vector stored in the sample.

::

    [language=C++]
    typedef itk::Statistics::EuclideanDistanceMetric< MeasurementVectorType >
    DistanceMetricType;
    DistanceMetricType::Pointer distanceMetric = DistanceMetricType::New();

    DistanceMetricType::OriginType origin( 2 );
    for ( unsigned int i = 0 ; i < sample->GetMeasurementVectorSize() ; ++i )
    {
    origin[i] = queryPoint[i];
    }
    distanceMetric->SetOrigin( origin );

We can now set the number of neighbors to be located and the point
coordinates to be used as a reference system.

::

    [language=C++]
    unsigned int numberOfNeighbors = 3;
    TreeType::InstanceIdentifierVectorType neighbors;
    tree->Search( queryPoint, numberOfNeighbors, neighbors ) ;

    std::cout << "kd-tree knn search result:" << std::endl
    << "query point = [" << queryPoint << "]" << std::endl
    << "k = " << numberOfNeighbors << std::endl;
    std::cout << "measurement vector : distance" << std::endl;
    for ( unsigned int i = 0 ; i < numberOfNeighbors ; ++i )
    {
    std::cout << "[" << tree->GetMeasurementVector( neighbors[i] )
    << "] : "
    << distanceMetric->Evaluate(
    tree->GetMeasurementVector( neighbors[i] ))
    << std::endl;
    }

As previously indicated, the interface for finding nearest neighbors in
the centroid tree is very similar.

::

    [language=C++]
    centroidTree->Search( queryPoint, numberOfNeighbors, neighbors ) ;
    std::cout << "weighted centroid kd-tree knn search result:" << std::endl
    << "query point = [" << queryPoint << "]" << std::endl
    << "k = " << numberOfNeighbors << std::endl;
    std::cout << "measurement vector : distance" << std::endl;
    for ( unsigned int i = 0 ; i < numberOfNeighbors ; ++i )
    {
    std::cout << "[" << centroidTree->GetMeasurementVector( neighbors[i] )
    << "] : "
    << distanceMetric->Evaluate(
    centroidTree->GetMeasurementVector( neighbors[i]))
    << std::endl;
    }

KdTree also supports searching points within a hyper-spherical kernel.
We specify the radius and call the {Search()} method. In the case of the
KdTree, this is done with the following lines of code.

::

    [language=C++]
    double radius = 437.0;

    tree->Search( queryPoint, radius, neighbors ) ;

    std::cout << "kd-tree radius search result:" << std::endl
    << "query point = [" << queryPoint << "]" << std::endl
    << "search radius = " << radius << std::endl;
    std::cout << "measurement vector : distance" << std::endl;
    for ( unsigned int i = 0 ; i < neighbors.size() ; ++i )
    {
    std::cout << "[" << tree->GetMeasurementVector( neighbors[i] )
    << "] : "
    << distanceMetric->Evaluate(
    tree->GetMeasurementVector( neighbors[i]))
    << std::endl;
    }

In the case of the centroid KdTree, the {Search()} method is used as
illustrated by the following code.

::

    [language=C++]
    centroidTree->Search( queryPoint, radius, neighbors ) ;
    std::cout << "weighted centroid kd-tree radius search result:" << std::endl
    << "query point = [" << queryPoint << "]" << std::endl
    << "search radius = " << radius << std::endl;
    std::cout << "measurement vector : distance" << std::endl;
    for ( unsigned int i = 0 ; i < neighbors.size() ; ++i )
    {
    std::cout << "[" << centroidTree->GetMeasurementVector( neighbors[i] )
    << "] : "
    << distanceMetric->Evaluate(
    centroidTree->GetMeasurementVector( neighbors[i]))
    << std::endl;
    }

