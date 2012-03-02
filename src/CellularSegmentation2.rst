The source code for this section can be found in the file
``CellularSegmentation2.cxx``.

The following example illustrates the use of Cellular Algorithms for
performing image segmentation. Cellular algorithms are implemented by
combining the following classes

\subdoxygen{bio}{CellularAggregate}
\subdoxygen{bio}{Cell}

::

    [language=C++]
    #include "itkBioCellularAggregate.h"

We now define the image type using a pixel type and a particular
dimension. In this case the \code{float} type is used for the pixels due to
the requirements of the smoothing filter.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 3;
    typedef itk::Image< InternalPixelType, Dimension >  ImageType;

The \subdoxygen{bio}{CellularAggregate} class must be instantiated using the
dimension of the image to be segmented.

::

    [language=C++]
    typedef itk::bio::CellularAggregate< Dimension >  CellularAggregateType;
    typedef CellularAggregateType::BioCellType        CellType;

Then an object of this class can be constructed by invoking the {New}
operator and receiving the result in a \code{SmartPointer},

::

    [language=C++]
    CellularAggregateType::Pointer cellularAggregate = CellularAggregateType::New();

The CellularAggregate considers the image as a chemical substrate in
which the Cells are going to develop. The intensity values of the image
will influence the behavior of the Cells, in particular they will
intervine to regulate the Cell Cycle. A Cellular Aggregate could be
gathering information from several images simultaneously, in this
context each image can bee seen as a map of concentration of a
particular chemical compound. The set of images will describe the
chemical composition of the extra cellular matrix.

::

    [language=C++]
    cellularAggregate->AddSubstrate( reader->GetOutput() );

The initialization of the algorithm requires the user to provide a seed
point. It is convenient to select this point to be placed in a *typical*
region of the anatomical structure to be segmented. A small neighborhood
around the seed point will be used to compute the initial mean and
standard deviation for the inclusion criterion. The seed is passed in
the form of a \doxygen{Index} to the \code{SetSeed()} method.

Individual Cell do not derive from the \doxygen{Object} class in order to avoid
the penalties of Mutex operations when passing pointers to them. The
Creation of a new cell is done by invoking the normal \code{new} operator.

::

    [language=C++]
    CellType * egg = CellType::CreateEgg();

In this particular example, the Cell cycle is going to be controled
mostly by the intensity values of the image. These values are asimilated
to concentrations of a particular chemical compound. Cell will feel
compfortable at when the concentration of this chemical is inside a
particular range. In this circumstances cells will be able to
proliferate. When the chemical concentration is out of the range, cell
will not enter their division stage and will anchor to the cellular
matrix. The values defining this range can be set by invoking the
methods \code{SetChemoAttractantHighThreshold} and
\code{SetChemoAttractantLowThreshold). These to methods are static and set
the values to be used by all the cells.

.. index::
   pair: Cell; SetChemoAttractantLowThreshold
   pair: Cell; SetChemoAttractantHighThreshold

::

    [language=C++]
    CellType::SetChemoAttractantLowThreshold(  atof( argv[5] ) );
    CellType::SetChemoAttractantHighThreshold( atof( argv[6] ) );

The newly created Cell is passed to the \code{CellularAggregate} object that
will take care of controling the development of the cells.

.. index::
   pair: CellularAggregate;SetEgg

::

    [language=C++]
    cellularAggregate->SetEgg( egg, position );

The CellularAggregate will update the life cycle of all the cells in an
iterative way. The User must select how many iterations to run.
CellularAlgorithms can in principle run forever. It is up to the User to
define an stopping criterion. One of the simplest options is to set a
limit to the number of iterations, by invoking the AdvanceTimeStep()
method inside a for loop.

.. index::
   pair: CellularAggregate; SetEgg

::

    [language=C++]
    unsigned int numberOfIterations = atoi( argv[7] );

    std::cout << "numberOfIterations " << numberOfIterations << std::endl;

    for(unsigned int i=0; i<numberOfIterations; i++)
    {
    cellularAggregate->AdvanceTimeStep();
    }

