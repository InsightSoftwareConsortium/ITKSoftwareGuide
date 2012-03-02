The source code for this section can be found in the file
``NeighborhoodIterators3.cxx``.

This example illustrates a technique for improving the efficiency of
neighborhood calculations by eliminating unnecessary bounds checking. As
described in Section {sec:NeighborhoodIterators}, the neighborhood
iterator automatically enables or disables bounds checking based on the
iteration region in which it is initialized. By splitting our image into
boundary and non-boundary regions, and then processing each region using
a different neighborhood iterator, the algorithm will only perform
bounds-checking on those pixels for which it is actually required. This
trick can provide a significant speedup for simple algorithms such as
our Sobel edge detection, where iteration speed is a critical.

Splitting the image into the necessary regions is an easy task when you
use the {ImageBoundaryFacesCalculator}. The face calculator is so named
because it returns a list of the “faces” of the ND dataset. Faces are
those regions whose pixels all lie within a distance :math:`d` from
the boundary, where :math:`d` is the radius of the neighborhood
stencil used for the numerical calculations. In other words, faces are
those regions where a neighborhood iterator of radius :math:`d` will
always overlap the boundary of the image. The face calculator also
returns the single *inner* region, in which out-of-bounds values are
never required and bounds checking is not necessary.

The face calculator object is defined in {itkNeighborhoodAlgorithm.h}.
We include this file in addition to those from the previous two
examples.

::

    [language=C++]
    #include "itkNeighborhoodAlgorithm.h"

First we load the input image and create the output image and inner
product function as in the previous examples. The image iterators will
be created in a later step. Next we create a face calculator object. An
empty list is created to hold the regions that will later on be returned
by the face calculator.

::

    [language=C++]
    typedef itk::NeighborhoodAlgorithm
    ::ImageBoundaryFacesCalculator< ImageType > FaceCalculatorType;

    FaceCalculatorType faceCalculator;
    FaceCalculatorType::FaceListType faceList;

The face calculator function is invoked by passing it an image pointer,
an image region, and a neighborhood radius. The image pointer is the
same image used to initialize the neighborhood iterator, and the image
region is the region that the algorithm is going to process. The radius
is the radius of the iterator.

Notice that in this case the image region is given as the region of the
*output* image and the image pointer is given as that of the *input*
image. This is important if the input and output images differ in size,
i.e. the input image is larger than the output image. ITK image filters,
for example, operate on data from the input image but only generate
results in the {RequestedRegion} of the output image, which may be
smaller than the full extent of the input.

::

    [language=C++]
    faceList = faceCalculator(reader->GetOutput(), output->GetRequestedRegion(),
    sobelOperator.GetRadius());

The face calculator has returned a list of :math:`2N+1` regions. The
first element in the list is always the inner region, which may or may
not be important depending on the application. For our purposes it does
not matter because all regions are processed the same way. We use an
iterator to traverse the list of faces.

::

    [language=C++]
    FaceCalculatorType::FaceListType::iterator fit;

We now rewrite the main loop of the previous example so that each region
in the list is processed by a separate iterator. The iterators {it} and
{out} are reinitialized over each region in turn. Bounds checking is
automatically enabled for those regions that require it, and disabled
for the region that does not.

::

    [language=C++]
    IteratorType out;
    NeighborhoodIteratorType it;

    for ( fit=faceList.begin(); fit != faceList.end(); ++fit)
    {
    it = NeighborhoodIteratorType( sobelOperator.GetRadius(),
    reader->GetOutput(), *fit );
    out = IteratorType( output, *fit );

    for (it.GoToBegin(), out.GoToBegin(); ! it.IsAtEnd(); ++it, ++out)
    {
    out.Set( innerProduct(it, sobelOperator) );
    }
    }

The output is written as before. Results for this example are the same
as the previous example. You may not notice the speedup except on larger
images. When moving to 3D and higher dimensions, the effects are greater
because the volume to surface area ratio is usually larger. In other
words, as the number of interior pixels increases relative to the number
of face pixels, there is a corresponding increase in efficiency from
disabling bounds checking on interior pixels.
