The source code for this section can be found in the file
``NeighborhoodConnectedImageFilter.cxx``.

The following example illustrates the use of the
{NeighborhoodConnectedImageFilter}. This filter is a close variant of
the {ConnectedThresholdImageFilter}. On one hand, the
ConnectedThresholdImageFilter accepts a pixel in the region if its
intensity is in the interval defined by two user-provided threshold
values. The NeighborhoodConnectedImageFilter, on the other hand, will
only accept a pixel if **all** its neighbors have intensities that fit
in the interval. The size of the neighborhood to be considered around
each pixel is defined by a user-provided integer radius.

The reason for considering the neighborhood intensities instead of only
the current pixel intensity is that small structures are less likely to
be accepted in the region. The operation of this filter is equivalent to
applying the ConnectedThresholdImageFilter followed by mathematical
morphology erosion using a structuring element of the same shape as the
neighborhood provided to the NeighborhoodConnectedImageFilter.

::

    [language=C++]
    #include "itkNeighborhoodConnectedImageFilter.h"

The {CurvatureFlowImageFilter} is used here to smooth the image while
preserving edges.

::

    [language=C++]
    #include "itkCurvatureFlowImageFilter.h"

We now define the image type using a particular pixel type and image
dimension. In this case the {float} type is used for the pixels due to
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
    typedef   itk::CurvatureFlowImageFilter<InternalImageType, InternalImageType>
    CurvatureFlowImageFilterType;

Then, the filter is created by invoking the {New()} method and assigning
the result to a {SmartPointer}.

::

    [language=C++]
    CurvatureFlowImageFilterType::Pointer smoothing =
    CurvatureFlowImageFilterType::New();

We now declare the type of the region growing filter. In this case it is
the NeighborhoodConnectedImageFilter.

::

    [language=C++]
    typedef itk::NeighborhoodConnectedImageFilter<InternalImageType,
    InternalImageType > ConnectedFilterType;

One filter of this class is constructed using the {New()} method.

::

    [language=C++]
    ConnectedFilterType::Pointer neighborhoodConnected = ConnectedFilterType::New();

Now it is time to create a simple, linear data processing pipeline. A
file reader is added at the beginning of the pipeline and a cast filter
and writer are added at the end. The cast filter is required to convert
{float} pixel types to integer types since only a few image file formats
support {float} types.

::

    [language=C++]
    smoothing->SetInput( reader->GetOutput() );
    neighborhoodConnected->SetInput( smoothing->GetOutput() );
    caster->SetInput( neighborhoodConnected->GetOutput() );
    writer->SetInput( caster->GetOutput() );

The CurvatureFlowImageFilter requires a couple of parameters to be
defined. The following are typical values for :math:`2D` images.
However they may have to be adjusted depending on the amount of noise
present in the input image.

::

    [language=C++]
    smoothing->SetNumberOfIterations( 5 );
    smoothing->SetTimeStep( 0.125 );

The NeighborhoodConnectedImageFilter requires that two main parameters
are specified. They are the lower and upper thresholds of the interval
in which intensity values must fall to be included in the region.
Setting these two values too close will not allow enough flexibility for
the region to grow. Setting them too far apart will result in a region
that engulfs the image.

::

    [language=C++]
    neighborhoodConnected->SetLower(  lowerThreshold  );
    neighborhoodConnected->SetUpper(  upperThreshold  );

Here, we add the crucial parameter that defines the neighborhood size
used to determine whether a pixel lies in the region. The larger the
neighborhood, the more stable this filter will be against noise in the
input image, but also the longer the computing time will be. Here we
select a filter of radius :math:`2` along each dimension. This results
in a neighborhood of :math:`5 \times 5` pixels.

::

    [language=C++]
    InternalImageType::SizeType   radius;

    radius[0] = 2;    two pixels along X
    radius[1] = 2;    two pixels along Y

    neighborhoodConnected->SetRadius( radius );

As in the ConnectedThresholdImageFilter we must now provide the
intensity value to be used for the output pixels accepted in the region
and at least one seed point to define the initial region.

::

    [language=C++]
    neighborhoodConnected->SetSeed( index );
    neighborhoodConnected->SetReplaceValue( 255 );

The invocation of the {Update()} method on the writer triggers the
execution of the pipeline. It is usually wise to put update calls in a
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

Now we’ll run this example using the image {BrainProtonDensitySlice.png}
as input available from the directory {Examples/Data}. We can easily
segment the major anatomical structures by providing seeds in the
appropriate locations and defining values for the lower and upper
thresholds. For example

    +----------------+----------------------+---------+---------+---------------------------------------------------------------------------+
    | Structure      | Seed Index           | Lower   | Upper   | Output Image                                                              |
    +================+======================+=========+=========+===========================================================================+
    | White matter   | :math:`(60,116)`   | 150     | 180     | Second from left in Figure {fig:NeighborhoodConnectedImageFilterOutput}   |
    +----------------+----------------------+---------+---------+---------------------------------------------------------------------------+
    | Ventricle      | :math:`(81,112)`   | 210     | 250     | Third from left in Figure {fig:NeighborhoodConnectedImageFilterOutput}    |
    +----------------+----------------------+---------+---------+---------------------------------------------------------------------------+
    | Gray matter    | :math:`(107,69)`   | 180     | 210     | Fourth from left in Figure {fig:NeighborhoodConnectedImageFilterOutput}   |
    +----------------+----------------------+---------+---------+---------------------------------------------------------------------------+

    |image| |image1| |image2| |image3| [NeighborhoodConnected
    segmentation results ] {Segmentation results of the
    NeighborhoodConnectedImageFilter for various seed points.}
    {fig:NeighborhoodConnectedImageFilterOutput}

As with the ConnectedThresholdImageFilter, several seeds could be
provided to the filter by using the {AddSeed()} method. Compare the
output of Figure {fig:NeighborhoodConnectedImageFilterOutput} with those
of Figure {fig:ConnectedThresholdOutput} produced by the
ConnectedThresholdImageFilter. You may want to play with the value of
the neighborhood radius and see how it affect the smoothness of the
segmented object borders, the size of the segmented region and how much
that costs in computing time.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: NeighborhoodConnectedImageFilterOutput1.eps
.. |image2| image:: NeighborhoodConnectedImageFilterOutput2.eps
.. |image3| image:: NeighborhoodConnectedImageFilterOutput3.eps
