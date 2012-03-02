The source code for this section can be found in the file
``NeighborhoodIterators2.cxx``.

In this example, the Sobel edge-detection routine is rewritten using
convolution filtering. Convolution filtering is a standard image
processing technique that can be implemented numerically as the inner
product of all image neighborhoods with a convolution kernel . In ITK,
we use a class of objects called *neighborhood operators* as convolution
kernels and a special function object called {NeighborhoodInnerProduct}
to calculate inner products.

The basic ITK convolution filtering routine is to step through the image
with a neighborhood iterator and use NeighborhoodInnerProduct to find
the inner product of each neighborhood with the desired kernel. The
resulting values are written to an output image. This example uses a
neighborhood operator called the {SobelOperator}, but all neighborhood
operators can be convolved with images using this basic routine. Other
examples of neighborhood operators include derivative kernels, Gaussian
kernels, and morphological operators. {NeighborhoodOperatorImageFilter}
is a generalization of the code in this section to ND images and
arbitrary convolution kernels.

We start writing this example by including the header files for the
Sobel kernel and the inner product function.

::

    [language=C++]
    #include "itkSobelOperator.h"
    #include "itkNeighborhoodInnerProduct.h"

Refer to the previous example for a description of reading the input
image and setting up the output image and iterator.

The following code creates a Sobel operator. The Sobel operator requires
a direction for its partial derivatives. This direction is read from the
command line. Changing the direction of the derivatives changes the bias
of the edge detection, i.e. maximally vertical or maximally horizontal.

::

    [language=C++]
    itk::SobelOperator<PixelType, 2> sobelOperator;
    sobelOperator.SetDirection( ::atoi(argv[3]) );
    sobelOperator.CreateDirectional();

The neighborhood iterator is initialized as before, except that now it
takes its radius directly from the radius of the Sobel operator. The
inner product function object is templated over image type and requires
no initialization.

::

    [language=C++]
    NeighborhoodIteratorType::RadiusType radius = sobelOperator.GetRadius();
    NeighborhoodIteratorType it( radius, reader->GetOutput(),
    reader->GetOutput()->GetRequestedRegion() );

    itk::NeighborhoodInnerProduct<ImageType> innerProduct;

Using the Sobel operator, inner product, and neighborhood iterator
objects, we can now write a very simple {for} loop for performing
convolution filtering. As before, out-of-bounds pixel values are
supplied automatically by the iterator.

::

    [language=C++]
    for (it.GoToBegin(), out.GoToBegin(); !it.IsAtEnd(); ++it, ++out)
    {
    out.Set( innerProduct( it, sobelOperator ) );
    }

The output is rescaled and written as in the previous example. Applying
this example in the :math:`x` and :math:`y` directions produces the
images at the center and right of Figure {fig:NeighborhoodExamples1}.
Note that x-direction operator produces the same output image as in the
previous example.
