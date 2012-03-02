The source code for this section can be found in the file
``ShapedNeighborhoodIterators1.cxx``.

This example uses {ShapedNeighborhoodIterator} to implement a binary
erosion algorithm. If we think of an image :math:`I` as a set of pixel
indices, then erosion of :math:`I` by a smaller set :math:`E`,
called the *structuring element*, is the set of all indices at locations
:math:`x` in :math:`I` such that when :math:`E` is positioned at
:math:`x`, every element in :math:`E` is also contained in
:math:`I`.

This type of algorithm is easy to implement with shaped neighborhood
iterators because we can use the iterator itself as the structuring
element :math:`E` and move it sequentially through all positions
:math:`x`. The result at :math:`x` is obtained by checking values in
a simple iteration loop through the neighborhood stencil.

We need two iterators, a shaped iterator for the input image and a
regular image iterator for writing results to the output image.

::

    [language=C++]
    #include "itkConstShapedNeighborhoodIterator.h"
    #include "itkImageRegionIterator.h"

Since we are working with binary images in this example, an {unsigned
char} pixel type will do. The image and iterator types are defined using
the pixel type.

::

    [language=C++]
    typedef unsigned char               PixelType;
    typedef itk::Image< PixelType, 2 >  ImageType;

    typedef itk::ConstShapedNeighborhoodIterator<
    ImageType
    > ShapedNeighborhoodIteratorType;

    typedef itk::ImageRegionIterator< ImageType> IteratorType;

Refer to the examples in Section {sec:itkNeighborhoodIterator} or the
source code of this example for a description of how to read the input
image and allocate a matching output image.

The size of the structuring element is read from the command line and
used to define a radius for the shaped neighborhood iterator. Using the
method developed in section {sec:itkNeighborhoodIterator} to minimize
bounds checking, the iterator itself is not initialized until entering
the main processing loop.

::

    [language=C++]
    unsigned int element_radius = ::atoi( argv[3] );
    ShapedNeighborhoodIteratorType::RadiusType radius;
    radius.Fill(element_radius);

The face calculator object introduced in
Section {sec:NeighborhoodExample3} is created and used as before.

::

    [language=C++]
    typedef itk::NeighborhoodAlgorithm::ImageBoundaryFacesCalculator<
    ImageType > FaceCalculatorType;

    FaceCalculatorType faceCalculator;
    FaceCalculatorType::FaceListType faceList;
    FaceCalculatorType::FaceListType::iterator fit;

    faceList = faceCalculator( reader->GetOutput(),
    output->GetRequestedRegion(),
    radius );

Now we initialize some variables and constants.

::

    [language=C++]
    IteratorType out;

    const PixelType background_value = 0;
    const PixelType foreground_value = 255;
    const float rad = static_cast<float>(element_radius);

The outer loop of the algorithm is structured as in previous
neighborhood iterator examples. Each region in the face list is
processed in turn. As each new region is processed, the input and output
iterators are initialized on that region.

The shaped iterator that ranges over the input is our structuring
element and its active stencil must be created accordingly. For this
example, the structuring element is shaped like a circle of radius
{element\_radius}. Each of the appropriate neighborhood offsets is
activated in the double {for} loop.

::

    [language=C++]
    for ( fit=faceList.begin(); fit != faceList.end(); ++fit)
    {
    ShapedNeighborhoodIteratorType it( radius, reader->GetOutput(), *fit );
    out = IteratorType( output, *fit );

    Creates a circular structuring element by activating all the pixels less
    than radius distance from the center of the neighborhood.

    for (float y = -rad; y <= rad; y++)
    {
    for (float x = -rad; x <= rad; x++)
    {
    ShapedNeighborhoodIteratorType::OffsetType off;

    float dis = vcl_sqrt( x*x + y*y );
    if (dis <= rad)
    {
    off[0] = static_cast<int>(x);
    off[1] = static_cast<int>(y);
    it.ActivateOffset(off);
    }
    }
    }

The inner loop, which implements the erosion algorithm, is fairly
simple. The {for} loop steps the input and output iterators through
their respective images. At each step, the active stencil of the shaped
iterator is traversed to determine whether all pixels underneath the
stencil contain the foreground value, i.e. are contained within the set
:math:`I`. Note the use of the stencil iterator, {ci}, in performing
this check.

::

    [language=C++]

    Implements erosion
    for (it.GoToBegin(), out.GoToBegin(); !it.IsAtEnd(); ++it, ++out)
    {
    ShapedNeighborhoodIteratorType::ConstIterator ci;

    bool flag = true;
    for (ci = it.Begin(); ci != it.End(); ci++)
    {
    if (ci.Get() == background_value)
    {
    flag = false;
    break;
    }
    }
    if (flag == true)
    {
    out.Set(foreground_value);
    }
    else
    {
    out.Set(background_value);
    }
    }
    }

