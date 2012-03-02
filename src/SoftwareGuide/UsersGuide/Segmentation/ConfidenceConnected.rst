The source code for this section can be found in the file
``ConfidenceConnected.cxx``.

.. index:: 
   pair: FloodFillIterator; In Region Growing
   single: ConfidenceConnectedImageFilter
   
The following example illustrates the use of the
\doxygen{ConfidenceConnectedImageFilter}. The criterion used by the
ConfidenceConnectedImageFilter is based on simple statistics of the
current region. First, the algorithm computes the mean and standard
deviation of intensity values for all the pixels currently included in
the region. A user-provided factor is used to multiply the standard
deviation and define a range around the mean. Neighbor pixels whose
intensity values fall inside the range are accepted and included in the
region. When no more neighbor pixels are found that satisfy the
criterion, the algorithm is considered to have finished its first
iteration. At that point, the mean and standard deviation of the
intensity levels are recomputed using all the pixels currently included
in the region. This mean and standard deviation defines a new intensity
range that is used to visit current region neighbors and evaluate
whether their intensity falls inside the range. This iterative process
is repeated until no more pixels are added or the maximum number of
iterations is reached. The following equation illustrates the inclusion
criterion used by this filter,

:math:`I(\mathbf{X}) \in [ m - f \sigma , m + f \sigma ]
`

where :math:`m` and :math:`\sigma` are the mean and standard
deviation of the region intensities, :math:`f` is a factor defined by
the user, :math:`I()` is the image and :math:`\mathbf{X}` is the
position of the particular neighbor pixel being considered for inclusion
in the region.

Let’s look at the minimal code required to use this algorithm. First,
the following header defining the \doxygen{ConfidenceConnectedImageFilter} class
must be included.

::

    [language=C++]
    #include "itkConfidenceConnectedImageFilter.h"

Noise present in the image can reduce the capacity of this filter to
grow large regions. When faced with noisy images, it is usually
convenient to pre-process the image by using an edge-preserving
smoothing filter. Any of the filters discussed in
Section \ref{sec:EdgePreservingSmoothingFilters} can be used to this end. In
this particular example we use the \doxygen{CurvatureFlowImageFilter}, hence we
need to include its header file.

::

    [language=C++]
    #include "itkCurvatureFlowImageFilter.h"

We now define the image type using a pixel type and a particular
dimension. In this case the \code{float} type is used for the pixels due to
the requirements of the smoothing filter.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The smoothing filter type is instantiated using the image type as a
template parameter.

::

    [language=C++]
    typedef itk::CurvatureFlowImageFilter< InternalImageType, InternalImageType >
    CurvatureFlowImageFilterType;

Next the filter is created by invoking the \code{New()} method and assigning
the result to a \code{SmartPointer}.

::

    [language=C++]
    CurvatureFlowImageFilterType::Pointer smoothing =
    CurvatureFlowImageFilterType::New();

We now declare the type of the region growing filter. In this case it is
the ConfidenceConnectedImageFilter.

::

    [language=C++]
    typedef itk::ConfidenceConnectedImageFilter<InternalImageType, InternalImageType>
    ConnectedFilterType;

Then, we construct one filter of this class using the {New()} method.

::

    [language=C++]
    ConnectedFilterType::Pointer confidenceConnected = ConnectedFilterType::New();

Now it is time to create a simple, linear pipeline. A file reader is
added at the beginning of the pipeline and a cast filter and writer are
added at the end. The cast filter is required here to convert \code{float}
pixel types to integer types since only a few image file formats support
\code{float} types.

::

    [language=C++]
    smoothing->SetInput( reader->GetOutput() );
    confidenceConnected->SetInput( smoothing->GetOutput() );
    caster->SetInput( confidenceConnected->GetOutput() );
    writer->SetInput( caster->GetOutput() );

The CurvatureFlowImageFilter requires defining two parameters. The
following are typical values for :math:`2D` images. However they may
have to be adjusted depending on the amount of noise present in the
input image.

::

    [language=C++]
    smoothing->SetNumberOfIterations( 5 );
    smoothing->SetTimeStep( 0.125 );

The ConfidenceConnectedImageFilter requires defining two parameters.
First, the factor :math:`f` that the defines how large the range of
intensities will be. Small values of the multiplier will restrict the
inclusion of pixels to those having very similar intensities to those in
the current region. Larger values of the multiplier will relax the
accepting condition and will result in more generous growth of the
region. Values that are too large will cause the region to grow into
neighboring regions that may actually belong to separate anatomical
structures.

.. index::
   pair: ConfidenceConnectedImageFilter; SetMultiplier

::

    [language=C++]
    confidenceConnected->SetMultiplier( 2.5 );

The number of iterations is specified based on the homogeneity of the
intensities of the anatomical structure to be segmented. Highly
homogeneous regions may only require a couple of iterations. Regions
with ramp effects, like MRI images with inhomogeneous fields, may
require more iterations. In practice, it seems to be more important to
carefully select the multiplier factor than the number of iterations.
However, keep in mind that there is no reason to assume that this
algorithm should converge to a stable region. It is possible that by
letting the algorithm run for more iterations the region will end up
engulfing the entire image.

.. index::
   pair: ConfidenceConnectedImageFilter; SetNumberOfIterations

::

    [language=C++]
    confidenceConnected->SetNumberOfIterations( 5 );

The output of this filter is a binary image with zero-value pixels
everywhere except on the extracted region. The intensity value to be set
inside the region is selected with the method \code{SetReplaceValue()}

.. index::
   pair: ConfidenceConnectedImageFilter; SetReplaceValue

::

    [language=C++]
    confidenceConnected->SetReplaceValue( 255 );

The initialization of the algorithm requires the user to provide a seed
point. It is convenient to select this point to be placed in a *typical*
region of the anatomical structure to be segmented. A small neighborhood
around the seed point will be used to compute the initial mean and
standard deviation for the inclusion criterion. The seed is passed in
the form of a \doxygen{Index} to the \code{SetSeed()} method.

.. index::
   pair: ConfidenceConnectedImageFilter; SetSeed
   pair: ConfidenceConnectedImageFilter; SetInitialNeighborhoodRadius

::

    [language=C++]
    confidenceConnected->SetSeed( index );

The size of the initial neighborhood around the seed is defined with the
method \code{SetInitialNeighborhoodRadius()}. The neighborhood will be
defined as an :math:`N`-dimensional rectangular region with
:math:`2r+1` pixels on the side, where :math:`r` is the value passed
as initial neighborhood radius.

::

    [language=C++]
    confidenceConnected->SetInitialNeighborhoodRadius( 2 );

The invocation of the \code{Update()} method on the writer triggers the
execution of the pipeline. It is recommended to place update calls in a
{try/catch} block in case errors occur and exceptions are thrown.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

Let’s now run this example using as input the image
\ref{BrainProtonDensitySlice.png} provided in the directory {Examples/Data}.
We can easily segment the major anatomical structures by providing seeds
in the appropriate locations. For example

    +----------------+----------------------+---------------------------------------------------------------+
    | Structure      | Seed Index           | Output Image                                                  |
    +================+======================+===============================================================+
    | White matter   | :math:`(60,116)`   | Second from left in Figure \ref{fig:ConfidenceConnectedOutput}|
    +----------------+----------------------+---------------------------------------------------------------+
    | Ventricle      | :math:`(81,112)`   | Third from left in Figure \ref{fig:ConfidenceConnectedOutput} |
    +----------------+----------------------+---------------------------------------------------------------+
    | Gray matter    | :math:`(107,69)`   | Fourth from left in Figure \ref{fig:ConfidenceConnectedOutput}|
    +----------------+----------------------+---------------------------------------------------------------+

    |image| |image1| |image2| |image3| [ConfidenceConnected segmentation
    results] {Segmentation results for the ConfidenceConnected filter
    for various seed points.} {fig:ConfidenceConnectedOutput}

Note that the gray matter is not being completely segmented. This
illustrates the vulnerability of the region growing methods when the
anatomical structures to be segmented do not have a homogeneous
statistical distribution over the image space. You may want to
experiment with different numbers of iterations to verify how the
accepted region will extend.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: ConfidenceConnectedOutput1.eps
.. |image2| image:: ConfidenceConnectedOutput2.eps
.. |image3| image:: ConfidenceConnectedOutput3.eps
