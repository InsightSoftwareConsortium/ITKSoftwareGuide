The source code for this section can be found in the file
``ConnectedThresholdImageFilter.cxx``.

The following example illustrates the use of the
\doxygen{ConnectedThresholdImageFilter}. This filter uses the flood fill
iterator. Most of the algorithmic complexity of a region growing method
comes from visiting neighboring pixels. The flood fill iterator assumes
this responsibility and greatly simplifies the implementation of the
region growing algorithm. Thus the algorithm is left to establish a
criterion to decide whether a particular pixel should be included in the
current region or not.

.. index:: 
   pair: FloodFillIterator; In Region Growing
   single: ConnectedThresholdImageFilter

The criterion used by the ConnectedThresholdImageFilter is based on an
interval of intensity values provided by the user. Values of lower and
upper threshold should be provided. The region growing algorithm
includes those pixels whose intensities are inside the interval.

:math:`I(\mathbf{X}) \in [ \mbox{lower}, \mbox{upper} ]
`

Let’s look at the minimal code required to use this algorithm. First,
the following header defining the ConnectedThresholdImageFilter class
must be included.

::

    [language=C++]
    #include "itkConnectedThresholdImageFilter.h"

Noise present in the image can reduce the capacity of this filter to
grow large regions. When faced with noisy images, it is usually
convenient to pre-process the image by using an edge-preserving
smoothing filter. Any of the filters discussed in
Section \ref{sec:EdgePreservingSmoothingFilters} could be used to this end.
In this particular example we use the \doxygen{CurvatureFlowImageFilter}, hence
we need to include its header file.

::

    [language=C++]
    #include "itkCurvatureFlowImageFilter.h"

We declare the image type based on a particular pixel type and
dimension. In this case the \code{float} type is used for the pixels due to
the requirements of the smoothing filter.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The smoothing filter is instantiated using the image type as a template
parameter.

::

    [language=C++]
    typedef itk::CurvatureFlowImageFilter< InternalImageType, InternalImageType >
    CurvatureFlowImageFilterType;

Then the filter is created by invoking the {New()} method and assigning
the result to a {SmartPointer}.

::

    [language=C++]
    CurvatureFlowImageFilterType::Pointer smoothing =
    CurvatureFlowImageFilterType::New();

We now declare the type of the region growing filter. In this case it is
the ConnectedThresholdImageFilter.

::

    [language=C++]
    typedef itk::ConnectedThresholdImageFilter< InternalImageType,
    InternalImageType > ConnectedFilterType;

Then we construct one filter of this class using the {New()} method.

::

    [language=C++]
    ConnectedFilterType::Pointer connectedThreshold = ConnectedFilterType::New();

Now it is time to connect a simple, linear pipeline. A file reader is
added at the beginning of the pipeline and a cast filter and writer are
added at the end. The cast filter is required to convert \code{float} pixel
types to integer types since only a few image file formats support
\code{float} types.

::

    [language=C++]
    smoothing->SetInput( reader->GetOutput() );
    connectedThreshold->SetInput( smoothing->GetOutput() );
    caster->SetInput( connectedThreshold->GetOutput() );
    writer->SetInput( caster->GetOutput() );

The CurvatureFlowImageFilter requires a couple of parameters to be
defined. The following are typical values for :math:`2D` images.
However they may have to be adjusted depending on the amount of noise
present in the input image.

.. index:: 
   pair: ConnectedThresholdImageFilter; SetUpper
   pair: ConnectedThresholdImageFilter; SetLower

::

    [language=C++]
    smoothing->SetNumberOfIterations( 5 );
    smoothing->SetTimeStep( 0.125 );

The ConnectedThresholdImageFilter has two main parameters to be defined.
They are the lower and upper thresholds of the interval in which
intensity values should fall in order to be included in the region.
Setting these two values too close will not allow enough flexibility for
the region to grow. Setting them too far apart will result in a region
that engulfs the image.

::

    [language=C++]
    connectedThreshold->SetLower(  lowerThreshold  );
    connectedThreshold->SetUpper(  upperThreshold  );

The output of this filter is a binary image with zero-value pixels
everywhere except on the extracted region. The intensity value set
inside the region is selected with the method \code{SetReplaceValue()}

::

    [language=C++]
    connectedThreshold->SetReplaceValue( 255 );

The initialization of the algorithm requires the user to provide a seed
point. It is convenient to select this point to be placed in a *typical*
region of the anatomical structure to be segmented. The seed is passed
in the form of a \doxygen{Index} to the \code{SetSeed()} method.

::

    [language=C++]
    connectedThreshold->SetSeed( index );

The invocation of the \code{Update()} method on the writer triggers the
execution of the pipeline. It is usually wise to put update calls in a
\code{try/catch} block in case errors occur and exceptions are thrown.

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

Let’s run this example using as input the image
\code{BrainProtonDensitySlice.png} provided in the directory \code{Examples/Data}.
We can easily segment the major anatomical structures by providing seeds
in the appropriate locations and defining values for the lower and upper
thresholds. Figure \ref{fig:ConnectedThresholdOutput} illustrates several
examples of segmentation. The parameters used are presented in
Table \ref{tab:ConnectedThresholdOutput}.

        +----------------+----------------------+---------+---------+-------------------------------------------------------------+
        | Structure      | Seed Index           | Lower   | Upper   | Output Image                                                |
        +================+======================+=========+=========+=============================================================+
        | White matter   | :math:`(60,116)`   | 150     | 180     | Second from left in Figure\ref{fig:ConnectedThresholdOutput}|
        +----------------+----------------------+---------+---------+-------------------------------------------------------------+
        | Ventricle      | :math:`(81,112)`   | 210     | 250     | Third from left in Figure\ref{fig:ConnectedThresholdOutput} |
        +----------------+----------------------+---------+---------+-------------------------------------------------------------+
        | Gray matter    | :math:`(107,69)`   | 180     | 210     | Fourth from left in Figure\ref{fig:ConnectedThresholdOutput}|
        +----------------+----------------------+---------+---------+-------------------------------------------------------------+

    [ConnectedThreshold example parameters] {Parameters used for
    segmenting some brain structures shown in
    Figure {fig:ConnectedThresholdOutput} with the filter
    {ConnectedThresholdImageFilter}.{tab:ConnectedThresholdOutput}}

    |image| |image1| |image2| |image3| [ConnectedThreshold segmentation
    results] {Segmentation results for the ConnectedThreshold filter for
    various seed points.} {fig:ConnectedThresholdOutput}

Notice that the gray matter is not being completely segmented. This
illustrates the vulnerability of the region growing methods when the
anatomical structures to be segmented do not have a homogeneous
statistical distribution over the image space. You may want to
experiment with different values of the lower and upper thresholds to
verify how the accepted region will extend.

Another option for segmenting regions is to take advantage of the
functionality provided by the ConnectedThresholdImageFilter for managing
multiple seeds. The seeds can be passed one by one to the filter using
the \code{AddSeed()} method. You could imagine a user interface in which an
operator clicks on multiple points of the object to be segmented and
each selected point is passed as a seed to this filter.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: ConnectedThresholdOutput1.eps
.. |image2| image:: ConnectedThresholdOutput2.eps
.. |image3| image:: ConnectedThresholdOutput3.eps
