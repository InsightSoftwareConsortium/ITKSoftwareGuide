The source code for this section can be found in the file
``NeighborhoodIterators4.cxx``.

We now introduce a variation on convolution filtering that is useful
when a convolution kernel is separable. In this example, we create a
different neighborhood iterator for each axial direction of the image
and then take separate inner products with a 1D discrete Gaussian
kernel. The idea of using several neighborhood iterators at once has
applications beyond convolution filtering and may improve efficiency
when the size of the whole neighborhood relative to the portion of the
neighborhood used in calculations becomes large.

The only new class necessary for this example is the Gaussian operator.

::

    [language=C++]
    #include "itkGaussianOperator.h"

The Gaussian operator, like the Sobel operator, is instantiated with a
pixel type and a dimensionality. Additionally, we set the variance of
the Gaussian, which has been read from the command line as standard
deviation.

::

    [language=C++]
    itk::GaussianOperator< PixelType, 2 > gaussianOperator;
    gaussianOperator.SetVariance( ::atof(argv[3]) * ::atof(argv[3]) );

The only further changes from the previous example are in the main loop.
Once again we use the results from face calculator to construct a loop
that processes boundary and non-boundary image regions separately.
Separable convolution, however, requires an additional, outer loop over
all the image dimensions. The direction of the Gaussian operator is
reset at each iteration of the outer loop using the new dimension. The
iterators change direction to match because they are initialized with
the radius of the Gaussian operator.

Input and output buffers are swapped at each iteration so that the
output of the previous iteration becomes the input for the current
iteration. The swap is not performed on the last iteration.

::

    [language=C++]
    ImageType::Pointer input = reader->GetOutput();
    for (unsigned int i = 0; i < ImageType::ImageDimension; ++i)
    {
    gaussianOperator.SetDirection(i);
    gaussianOperator.CreateDirectional();

    faceList = faceCalculator(input, output->GetRequestedRegion(),
    gaussianOperator.GetRadius());

    for ( fit=faceList.begin(); fit != faceList.end(); ++fit )
    {
    it = NeighborhoodIteratorType( gaussianOperator.GetRadius(),
    input, *fit );

    out = IteratorType( output, *fit );

    for (it.GoToBegin(), out.GoToBegin(); ! it.IsAtEnd(); ++it, ++out)
    {
    out.Set( innerProduct(it, gaussianOperator) );
    }
    }

    Swap the input and output buffers
    if (i != ImageType::ImageDimension - 1)
    {
    ImageType::Pointer tmp = input;
    input = output;
    output = tmp;
    }
    }

The output is rescaled and written as in the previous examples.
Figure {fig:NeighborhoodExample4} shows the results of Gaussian blurring
the image {Examples/Data/BrainT1Slice.png} using increasing kernel
widths.

    |image| |image1| |image2| |image3| [Gaussian blurring by convolution
    filtering] {Results of convolution filtering with a Gaussian kernel
    of increasing standard deviation :math:`\sigma` (from left to
    right, :math:`\sigma = 0`, :math:`\sigma = 1`, :math:`\sigma
    = 2`, :math:`\sigma = 5`). Increased blurring reduces contrast
    and changes the average intensity value of the image, which causes
    the image to appear brighter when rescaled.}
    {fig:NeighborhoodExample4}

.. |image| image:: NeighborhoodIterators4a.eps
.. |image1| image:: NeighborhoodIterators4b.eps
.. |image2| image:: NeighborhoodIterators4c.eps
.. |image3| image:: NeighborhoodIterators4d.eps
