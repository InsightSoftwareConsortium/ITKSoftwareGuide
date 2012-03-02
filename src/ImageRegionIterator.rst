The source code for this section can be found in the file
``ImageRegionIterator.cxx``.

The {ImageRegionIterator} is optimized for iteration speed and is the
first choice for iterative, pixel-wise operations when location in the
image is not important. ImageRegionIterator is the least specialized of
the ITK image iterator classes. It implements all of the methods
described in the preceding section.

The following example illustrates the use of {ImageRegionConstIterator}
and ImageRegionIterator. Most of the code constructs introduced apply to
other ITK iterators as well. This simple application crops a subregion
from an image by copying its pixel values into to a second, smaller
image.

We begin by including the appropriate header files.

::

    [language=C++]
    #include "itkImageRegionIterator.h"

Next we define a pixel type and corresponding image type. ITK iterator
classes expect the image type as their template parameter.

::

    [language=C++]
    const unsigned int Dimension = 2;

    typedef unsigned char                      PixelType;
    typedef itk::Image< PixelType, Dimension > ImageType;

    typedef itk::ImageRegionConstIterator< ImageType > ConstIteratorType;
    typedef itk::ImageRegionIterator< ImageType>       IteratorType;

Information about the subregion to copy is read from the command line.
The subregion is defined by an {ImageRegion} object, with a starting
grid index and a size (Section {sec:ImageSection}).

::

    [language=C++]
    ImageType::RegionType inputRegion;

    ImageType::RegionType::IndexType inputStart;
    ImageType::RegionType::SizeType  size;

    inputStart[0] = ::atoi( argv[3] );
    inputStart[1] = ::atoi( argv[4] );

    size[0]  = ::atoi( argv[5] );
    size[1]  = ::atoi( argv[6] );

    inputRegion.SetSize( size );
    inputRegion.SetIndex( inputStart );

The destination region in the output image is defined using the input
region size, but a different start index. The starting index for the
destination region is the corner of the newly generated image.

::

    [language=C++]
    ImageType::RegionType outputRegion;

    ImageType::RegionType::IndexType outputStart;

    outputStart[0] = 0;
    outputStart[1] = 0;

    outputRegion.SetSize( size );
    outputRegion.SetIndex( outputStart );

After reading the input image and checking that the desired subregion
is, in fact, contained in the input, we allocate an output image. It is
fundamental to set valid values to some of the basic image information
during the copying process. In particular, the starting index of the
output region is now filled up with zero values and the coordinates of
the physical origin are computed as a shift from the origin of the input
image. This is quite important since it will allow us to later register
the extracted region against the original image.

::

    [language=C++]
    ImageType::Pointer outputImage = ImageType::New();
    outputImage->SetRegions( outputRegion );
    const ImageType::SpacingType& spacing = reader->GetOutput()->GetSpacing();
    const ImageType::PointType& inputOrigin = reader->GetOutput()->GetOrigin();
    double   outputOrigin[ Dimension ];

    for(unsigned int i=0; i< Dimension; i++)
    {
    outputOrigin[i] = inputOrigin[i] + spacing[i] * inputStart[i];
    }

    outputImage->SetSpacing( spacing );
    outputImage->SetOrigin(  outputOrigin );
    outputImage->Allocate();

The necessary images and region definitions are now in place. All that
is left to do is to create the iterators and perform the copy. Note that
image iterators are not accessed via smart pointers so they are
light-weight objects that are instantiated on the stack. Also notice how
the input and output iterators are defined over the *same corresponding
region*. Though the images are different sizes, they both contain the
same target subregion.

::

    [language=C++]
    ConstIteratorType inputIt(   reader->GetOutput(), inputRegion  );
    IteratorType      outputIt(  outputImage,         outputRegion );

    inputIt.GoToBegin();
    outputIt.GoToBegin();

    while( !inputIt.IsAtEnd() )
    {
    outputIt.Set(  inputIt.Get()  );
    ++inputIt;
    ++outputIt;
    }

The {while} loop above is a common construct in ITK. The beauty of these
four lines of code is that they are equally valid for one, two, three,
or even ten dimensional data, and no knowledge of the size of the image
is necessary. Consider the ugly alternative of ten nested {for} loops
for traversing an image.

Let’s run this example on the image {FatMRISlice.png} found in
{Examples/Data}. The command line arguments specify the input and output
file names, then the :math:`x`, :math:`y` origin and the
:math:`x`, :math:`y` size of the cropped subregion.

::

    ImageRegionIterator FatMRISlice.png ImageRegionIteratorOutput.png 20 70 210 140

The output is the cropped subregion shown in
Figure {fig:ImageRegionIteratorOutput}.

    |image| |image1| [Copying an image subregion using
    ImageRegionIterator] {Cropping a region from an image. The original
    image is shown at left. The image on the right is the result of
    applying the ImageRegionIterator example code.}
    {fig:ImageRegionIteratorOutput}

.. |image| image:: FatMRISlice.eps
.. |image1| image:: ImageRegionIteratorOutput.eps
