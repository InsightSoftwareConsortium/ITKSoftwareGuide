The source code for this section can be found in the file
``ImageSliceIteratorWithIndex.cxx``.

The {ImageSliceIteratorWithIndex} class is an extension of
{ImageLinearIteratorWithIndex} from iteration along lines to iteration
along both lines *and planes* in an image. A *slice* is a 2D plane
spanned by two vectors pointing along orthogonal coordinate axes. The
slice orientation of the slice iterator is defined by specifying its two
spanning axes.

    **{SetFirstDirection()**} Specifies the first coordinate axis
    direction of the slice plane.

    **{SetSecondDirection()**} Specifies the second coordinate axis
    direction of the slice plane.

Several new methods control movement from slice to slice.

    **{NextSlice()**} Moves the iterator to the beginning pixel location
    of the next slice in the image. The origin of the next slice is
    calculated by incrementing the current origin index along the
    fastest increasing dimension of the image subspace which excludes
    the first and second dimensions of the iterator.

    **{PreviousSlice()**} Moves the iterator to the *last valid pixel
    location* in the previous slice. The origin of the previous slice is
    calculated by decrementing the current origin index along the
    fastest increasing dimension of the image subspace which excludes
    the first and second dimensions of the iterator.

    **{IsAtReverseEndOfSlice()**} Returns true if the iterator points to
    *one position before* the beginning pixel of the current slice.

    **{IsAtEndOfSlice()**} Returns true if the iterator points to *one
    position past* the last valid pixel of the current slice.

The slice iterator moves line by line using {NextLine()} and
{PreviousLine()}. The line direction is parallel to the *second*
coordinate axis direction of the slice plane (see also
Section {sec:itkImageLinearIteratorWithIndex}).

The next code example calculates the maximum intensity projection along
one of the coordinate axes of an image volume. The algorithm is
straightforward using ImageSliceIteratorWithIndex because we can
coordinate movement through a slice of the 3D input image with movement
through the 2D planar output.

Here is how the algorithm works. For each 2D slice of the input, iterate
through all the pixels line by line. Copy a pixel value to the
corresponding position in the 2D output image if it is larger than the
value already contained there. When all slices have been processed, the
output image is the desired maximum intensity projection.

We include a header for the const version of the slice iterator. For
writing values to the 2D projection image, we use the linear iterator
from the previous section. The linear iterator is chosen because it can
be set to follow the same path in its underlying 2D image that the slice
iterator follows over each slice of the 3D image.

::

    [language=C++]
    #include "itkImageSliceConstIteratorWithIndex.h"
    #include "itkImageLinearIteratorWithIndex.h"

The pixel type is defined as {unsigned short}. For this application, we
need two image types, a 3D image for the input, and a 2D image for the
intensity projection.

::

    [language=C++]
    typedef unsigned short              PixelType;
    typedef itk::Image< PixelType, 2 >  ImageType2D;
    typedef itk::Image< PixelType, 3 >  ImageType3D;

A slice iterator type is defined to walk the input image.

::

    [language=C++]
    typedef itk::ImageLinearIteratorWithIndex< ImageType2D > LinearIteratorType;
    typedef itk::ImageSliceConstIteratorWithIndex< ImageType3D >  SliceIteratorType;

The projection direction is read from the command line. The projection
image will be the size of the 2D plane orthogonal to the projection
direction. Its spanning vectors are the two remaining coordinate axes in
the volume. These axes are recorded in the {direction} array.

::

    [language=C++]
    unsigned int projectionDirection =
    static_cast<unsigned int>( ::atoi( argv[3] ) );

    unsigned int i, j;
    unsigned int direction[2];
    for (i = 0, j = 0; i < 3; ++i )
    {
    if (i != projectionDirection)
    {
    direction[j] = i;
    j++;
    }
    }

The {direction} array is now used to define the projection image size
based on the input image size. The output image is created so that its
common dimension(s) with the input image are the same size. For example,
if we project along the :math:`x` axis of the input, the size and
origin of the :math:`y` axes of the input and output will match. This
makes the code slightly more complicated, but prevents a
counter-intuitive rotation of the output.

::

    [language=C++]
    ImageType2D::RegionType region;
    ImageType2D::RegionType::SizeType size;
    ImageType2D::RegionType::IndexType index;

    ImageType3D::RegionType requestedRegion = inputImage->GetRequestedRegion();

    index[ direction[0] ]    = requestedRegion.GetIndex()[ direction[0] ];
    index[ 1- direction[0] ] = requestedRegion.GetIndex()[ direction[1] ];
    size[ direction[0] ]     = requestedRegion.GetSize()[  direction[0] ];
    size[ 1- direction[0] ]  = requestedRegion.GetSize()[  direction[1] ];

    region.SetSize( size );
    region.SetIndex( index );

    ImageType2D::Pointer outputImage = ImageType2D::New();

    outputImage->SetRegions( region );
    outputImage->Allocate();

Next we create the necessary iterators. The const slice iterator walks
the 3D input image, and the non-const linear iterator walks the 2D
output image. The iterators are initialized to walk the same linear path
through a slice. Remember that the *second* direction of the slice
iterator defines the direction that linear iteration walks within a
slice.

::

    [language=C++]
    SliceIteratorType  inputIt(  inputImage,  inputImage->GetRequestedRegion() );
    LinearIteratorType outputIt( outputImage, outputImage->GetRequestedRegion() );

    inputIt.SetFirstDirection(  direction[1] );
    inputIt.SetSecondDirection( direction[0] );

    outputIt.SetDirection( 1 - direction[0] );

Now we are ready to compute the projection. The first step is to
initialize all of the projection values to their nonpositive minimum
value. The projection values are then updated row by row from the first
slice of the input. At the end of the first slice, the input iterator
steps to the first row in the next slice, while the output iterator,
whose underlying image consists of only one slice, rewinds to its first
row. The process repeats until the last slice of the input is processed.

::

    [language=C++]
    outputIt.GoToBegin();
    while ( ! outputIt.IsAtEnd() )
    {
    while ( ! outputIt.IsAtEndOfLine() )
    {
    outputIt.Set( itk::NumericTraits<unsigned short>::NonpositiveMin() );
    ++outputIt;
    }
    outputIt.NextLine();
    }

    inputIt.GoToBegin();
    outputIt.GoToBegin();

    while( !inputIt.IsAtEnd() )
    {
    while ( !inputIt.IsAtEndOfSlice() )
    {
    while ( !inputIt.IsAtEndOfLine() )
    {
    outputIt.Set( vnl_math_max( outputIt.Get(), inputIt.Get() ));
    ++inputIt;
    ++outputIt;
    }
    outputIt.NextLine();
    inputIt.NextLine();

    }
    outputIt.GoToBegin();
    inputIt.NextSlice();
    }

Running this example code on the 3D image
{Examples/Data/BrainProtonDensity3Slices.mha} using the :math:`z`-axis
as the axis of projection gives the image shown in
Figure {fig:ImageSliceIteratorWithIndexOutput}.

    |image| [Maximum intensity projection using
    ImageSliceIteratorWithIndex] {The maximum intensity projection
    through three slices of a volume.}
    {fig:ImageSliceIteratorWithIndexOutput}

.. |image| image:: ImageSliceIteratorWithIndexOutput.eps
