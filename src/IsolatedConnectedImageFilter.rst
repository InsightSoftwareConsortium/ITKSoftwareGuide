The source code for this section can be found in the file
``IsolatedConnectedImageFilter.cxx``.

The following example illustrates the use of the
{IsolatedConnectedImageFilter}. This filter is a close variant of the
{ConnectedThresholdImageFilter}. In this filter two seeds and a lower
threshold are provided by the user. The filter will grow a region
connected to the first seed and **not connected** to the second one. In
order to do this, the filter finds an intensity value that could be used
as upper threshold for the first seed. A binary search is used to find
the value that separates both seeds.

This example closely follows the previous ones. Only the relevant pieces
of code are highlighted here.

The header of the IsolatedConnectedImageFilter is included below.

::

    [language=C++]
    #include "itkIsolatedConnectedImageFilter.h"

We define the image type using a pixel type and a particular dimension.

::

    [language=C++]
    typedef   float           InternalPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InternalPixelType, Dimension >  InternalImageType;

The IsolatedConnectedImageFilter is instantiated in the lines below.

::

    [language=C++]
    typedef itk::IsolatedConnectedImageFilter<InternalImageType, InternalImageType>
    ConnectedFilterType;

One filter of this class is constructed using the {New()} method.

::

    [language=C++]
    ConnectedFilterType::Pointer isolatedConnected = ConnectedFilterType::New();

Now it is time to connect the pipeline.

::

    [language=C++]
    smoothing->SetInput( reader->GetOutput() );
    isolatedConnected->SetInput( smoothing->GetOutput() );
    caster->SetInput( isolatedConnected->GetOutput() );
    writer->SetInput( caster->GetOutput() );

The IsolatedConnectedImageFilter expects the user to specify a threshold
and two seeds. In this example, we take all of them from the command
line arguments.

::

    [language=C++]
    isolatedConnected->SetLower(  lowerThreshold  );
    isolatedConnected->SetSeed1( indexSeed1 );
    isolatedConnected->SetSeed2( indexSeed2 );

As in the {ConnectedThresholdImageFilter} we must now specify the
intensity value to be set on the output pixels and at least one seed
point to define the initial region.

::

    [language=C++]
    isolatedConnected->SetReplaceValue( 255 );

The invocation of the {Update()} method on the writer triggers the
execution of the pipeline.

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

The intensity value allowing us to separate both regions can be
recovered with the method {GetIsolatedValue()}

::

    [language=C++]
    std::cout << "Isolated Value Found = ";
    std::cout << isolatedConnected->GetIsolatedValue()  << std::endl;

Let’s now run this example using the image {BrainProtonDensitySlice.png}
provided in the directory {Examples/Data}. We can easily segment the
major anatomical structures by providing seed pairs in the appropriate
locations and defining values for the lower threshold. It is important
to keep in mind in this and the previous examples that the segmentation
is being performed in the smoothed version of the image. The selection
of threshold values should therefore be performed in the smoothed image
since the distribution of intensities could be quite different from that
of the input image. As a reminder of this fact, Figure
{fig:IsolatedConnectedImageFilterOutput} presents, from left to right,
the input image and the result of smoothing with the
{CurvatureFlowImageFilter} followed by segmentation results.

This filter is intended to be used in cases where adjacent anatomical
structures are difficult to separate. Selecting one seed in one
structure and the other seed in the adjacent structure creates the
appropriate setup for computing the threshold that will separate both
structures. Table {tab:IsolatedConnectedImageFilterOutput} presents the
parameters used to obtain the images shown in
Figure {fig:IsolatedConnectedImageFilterOutput}.

        +-------------------------------+----------------------+---------------------+-----------------+------------------------+
        | Adjacent Structures           | Seed1                | Seed2               | Lower           | Isolated value found   |
        +===============================+======================+=====================+=================+========================+
        | Gray matter vs White matter   | :math:`(61,140)`   | :math:`(63,43)`   | :math:`150`   | :math:`183.31`       |
        +-------------------------------+----------------------+---------------------+-----------------+------------------------+

    [IsolatedConnectedImageFilter example parameters] {Parameters used
    for separating white matter from gray matter in
    Figure {fig:IsolatedConnectedImageFilterOutput} using the
    IsolatedConnectedImageFilter.{tab:IsolatedConnectedImageFilterOutput}}

    |image| |image1| |image2| [IsolatedConnected segmentation results]
    {Segmentation results of the IsolatedConnectedImageFilter.}
    {fig:IsolatedConnectedImageFilterOutput}

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: IsolatedConnectedImageFilterOutput0.eps
.. |image2| image:: IsolatedConnectedImageFilterOutput1.eps
