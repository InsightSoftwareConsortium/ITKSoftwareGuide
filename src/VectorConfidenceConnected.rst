The source code for this section can be found in the file
``VectorConfidenceConnected.cxx``.

This example illustrates the use of the confidence connected concept
applied to images with vector pixel types. The confidence connected
algorithm is implemented for vector images in the class
{VectorConfidenceConnected}. The basic difference between the scalar and
vector version is that the vector version uses the covariance matrix
instead of a variance, and a vector mean instead of a scalar mean. The
membership of a vector pixel value to the region is measured using the
Mahalanobis distance as implemented in the class {Statistics}
{MahalanobisDistanceThresholdImageFunction}.

::

    [language=C++]
    #include "itkVectorConfidenceConnectedImageFilter.h"

We now define the image type using a particular pixel type and
dimension. In this case the {float} type is used for the pixels due to
the requirements of the smoothing filter.

::

    [language=C++]
    typedef   unsigned char                         PixelComponentType;
    typedef   itk::RGBPixel< PixelComponentType >   InputPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< InputPixelType, Dimension >  InputImageType;

We now declare the type of the region growing filter. In this case it is
the {VectorConfidenceConnectedImageFilter}.

::

    [language=C++]
    typedef  itk::VectorConfidenceConnectedImageFilter< InputImageType,
    OutputImageType > ConnectedFilterType;

Then, we construct one filter of this class using the {New()} method.

::

    [language=C++]
    ConnectedFilterType::Pointer confidenceConnected = ConnectedFilterType::New();

Next we create a simple, linear data processing pipeline.

::

    [language=C++]
    confidenceConnected->SetInput( reader->GetOutput() );
    writer->SetInput( confidenceConnected->GetOutput() );

The VectorConfidenceConnectedImageFilter requires specifying two
parameters. First, the multiplier factor :math:`f` defines how large
the range of intensities will be. Small values of the multiplier will
restrict the inclusion of pixels to those having similar intensities to
those already in the current region. Larger values of the multiplier
relax the accepting condition and result in more generous growth of the
region. Values that are too large will cause the region to grow into
neighboring regions that may actually belong to separate anatomical
structures.

::

    [language=C++]
    confidenceConnected->SetMultiplier( multiplier );

The number of iterations is typically determined based on the
homogeneity of the image intensity representing the anatomical structure
to be segmented. Highly homogeneous regions may only require a couple of
iterations. Regions with ramp effects, like MRI images with
inhomogeneous fields, may require more iterations. In practice, it seems
to be more relevant to carefully select the multiplier factor than the
number of iterations. However, keep in mind that there is no reason to
assume that this algorithm should converge to a stable region. It is
possible that by letting the algorithm run for more iterations the
region will end up engulfing the entire image.

::

    [language=C++]
    confidenceConnected->SetNumberOfIterations( iterations );

The output of this filter is a binary image with zero-value pixels
everywhere except on the extracted region. The intensity value to be put
inside the region is selected with the method {SetReplaceValue()}

::

    [language=C++]
    confidenceConnected->SetReplaceValue( 255 );

The initialization of the algorithm requires the user to provide a seed
point. This point should be placed in a *typical* region of the
anatomical structure to be segmented. A small neighborhood around the
seed point will be used to compute the initial mean and standard
deviation for the inclusion criterion. The seed is passed in the form of
a {Index} to the {SetSeed()} method.

::

    [language=C++]
    confidenceConnected->SetSeed( index );

The size of the initial neighborhood around the seed is defined with the
method {SetInitialNeighborhoodRadius()}. The neighborhood will be
defined as an :math:`N`-Dimensional rectangular region with
:math:`2r+1` pixels on the side, where :math:`r` is the value passed
as initial neighborhood radius.

::

    [language=C++]
    confidenceConnected->SetInitialNeighborhoodRadius( 3 );

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

Now let’s run this example using as input the image
{VisibleWomanEyeSlice.png} provided in the directory {Examples/Data}. We
can easily segment the major anatomical structures by providing seeds in
the appropriate locations. For example,

    +-------------+----------------------+--------------+--------------+--------------------------------------------------------------------+
    | Structure   | Seed Index           | Multiplier   | Iterations   | Output Image                                                       |
    +=============+======================+==============+==============+====================================================================+
    | Rectum      | :math:`(70,120)`   | 7            | 1            | Second from left in Figure {fig:VectorConfidenceConnectedOutput}   |
    +-------------+----------------------+--------------+--------------+--------------------------------------------------------------------+
    | Rectum      | :math:`(23, 93)`   | 7            | 1            | Third from left in Figure {fig:VectorConfidenceConnectedOutput}    |
    +-------------+----------------------+--------------+--------------+--------------------------------------------------------------------+
    | Vitreo      | :math:`(66, 66)`   | 3            | 1            | Fourth from left in Figure {fig:VectorConfidenceConnectedOutput}   |
    +-------------+----------------------+--------------+--------------+--------------------------------------------------------------------+

    |image| |image1| |image2| |image3| [VectorConfidenceConnected
    segmentation results] {Segmentation results of the
    VectorConfidenceConnected filter for various seed points.}
    {fig:VectorConfidenceConnectedOutput}

The coloration of muscular tissue makes it easy to distinguish them from
the surrounding anatomical structures. The optic vitrea on the other
hand has a coloration that is not very homogeneous inside the eyeball
and does not allow to generate a full segmentation based only on color.

The values of the final mean vector and covariance matrix used for the
last iteration can be queried using the methods {GetMean()} and
{GetCovariance()}.

::

    [language=C++]
    typedef ConnectedFilterType::MeanVectorType   MeanVectorType;

    const MeanVectorType & mean = confidenceConnected->GetMean();

    std::cout << "Mean vector = " << std::endl;
    std::cout << mean << std::endl;

    typedef ConnectedFilterType::CovarianceMatrixType   CovarianceMatrixType;

    const CovarianceMatrixType & covariance = confidenceConnected->GetCovariance();

    std::cout << "Covariance matrix = " << std::endl;
    std::cout << covariance << std::endl;

.. |image| image:: VisibleWomanEyeSlice.eps
.. |image1| image:: VectorConfidenceConnectedOutput1.eps
.. |image2| image:: VectorConfidenceConnectedOutput2.eps
.. |image3| image:: VectorConfidenceConnectedOutput3.eps
