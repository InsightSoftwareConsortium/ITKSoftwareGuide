The source code for this section can be found in the file
``NeighborhoodIterators1.cxx``.

This example uses the {NeighborhoodIterator} to implement a simple Sobel
edge detection algorithm . The algorithm uses the neighborhood iterator
to iterate through an input image and calculate a series of finite
difference derivatives. Since the derivative results cannot be written
back to the input image without affecting later calculations, they are
written instead to a second, output image. Most neighborhood processing
algorithms follow this read-only model on their inputs.

We begin by including the proper header files. The {ImageRegionIterator}
will be used to write the results of computations to the output image. A
const version of the neighborhood iterator is used because the input
image is read-only.

::

    [language=C++]
    #include "itkConstNeighborhoodIterator.h"
    #include "itkImageRegionIterator.h"

The finite difference calculations in this algorithm require floating
point values. Hence, we define the image pixel type to be {float} and
the file reader will automatically cast fixed-point data to {float}.

We declare the iterator types using the image type as the template
parameter. The second template parameter of the neighborhood iterator,
which specifies the boundary condition, has been omitted because the
default condition is appropriate for this algorithm.

::

    [language=C++]
    typedef float                             PixelType;
    typedef itk::Image< PixelType, 2 >        ImageType;
    typedef itk::ImageFileReader< ImageType > ReaderType;

    typedef itk::ConstNeighborhoodIterator< ImageType > NeighborhoodIteratorType;
    typedef itk::ImageRegionIterator< ImageType>        IteratorType;

The following code creates and executes the ITK image reader. The
{Update} call on the reader object is surrounded by the standard
{try/catch} blocks to handle any exceptions that may be thrown by the
reader.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );
    try
    {
    reader->Update();
    }
    catch ( itk::ExceptionObject &err)
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return -1;
    }

We can now create a neighborhood iterator to range over the output of
the reader. For Sobel edge-detection in 2D, we need a square iterator
that extends one pixel away from the neighborhood center in every
dimension.

::

    [language=C++]
    NeighborhoodIteratorType::RadiusType radius;
    radius.Fill(1);
    NeighborhoodIteratorType it( radius, reader->GetOutput(),
    reader->GetOutput()->GetRequestedRegion() );

The following code creates an output image and iterator.

::

    [language=C++]
    ImageType::Pointer output = ImageType::New();
    output->SetRegions(reader->GetOutput()->GetRequestedRegion());
    output->Allocate();

    IteratorType out(output, reader->GetOutput()->GetRequestedRegion());

Sobel edge detection uses weighted finite difference calculations to
construct an edge magnitude image. Normally the edge magnitude is the
root sum of squares of partial derivatives in all directions, but for
simplicity this example only calculates the :math:`x` component. The
result is a derivative image biased toward maximally vertical edges.

The finite differences are computed from pixels at six locations in the
neighborhood. In this example, we use the iterator {GetPixel()} method
to query the values from their offsets in the neighborhood. The example
in Section {sec:NeighborhoodExample2} uses convolution with a Sobel
kernel instead.

Six positions in the neighborhood are necessary for the finite
difference calculations. These positions are recorded in {offset1}
through {offset6}.

::

    [language=C++]
    NeighborhoodIteratorType::OffsetType offset1 = {{-1,-1}};
    NeighborhoodIteratorType::OffsetType offset2 = {{1,-1}};
    NeighborhoodIteratorType::OffsetType offset3 = {{-1,0 }};
    NeighborhoodIteratorType::OffsetType offset4 = {{1,0}};
    NeighborhoodIteratorType::OffsetType offset5 = {{-1,1}};
    NeighborhoodIteratorType::OffsetType offset6 = {{1,1}};

It is equivalent to use the six corresponding integer array indices
instead. For example, the offsets {(-1,-1)} and {(1, -1)} are equivalent
to the integer indices {0} and {2}, respectively.

The calculations are done in a {for} loop that moves the input and
output iterators synchronously across their respective images. The {sum}
variable is used to sum the results of the finite differences.

::

    [language=C++]
    for (it.GoToBegin(), out.GoToBegin(); !it.IsAtEnd(); ++it, ++out)
    {
    float sum;
    sum = it.GetPixel(offset2) - it.GetPixel(offset1);
    sum += 2.0 * it.GetPixel(offset4) - 2.0 * it.GetPixel(offset3);
    sum += it.GetPixel(offset6) - it.GetPixel(offset5);
    out.Set(sum);
    }

The last step is to write the output buffer to an image file. Writing is
done inside a {try/catch} block to handle any exceptions. The output is
rescaled to intensity range :math:`[0, 255]` and cast to unsigned char
so that it can be saved and visualized as a PNG image.

::

    [language=C++]
    typedef unsigned char                          WritePixelType;
    typedef itk::Image< WritePixelType, 2 >        WriteImageType;
    typedef itk::ImageFileWriter< WriteImageType > WriterType;

    typedef itk::RescaleIntensityImageFilter<
    ImageType, WriteImageType > RescaleFilterType;

    RescaleFilterType::Pointer rescaler = RescaleFilterType::New();

    rescaler->SetOutputMinimum(   0 );
    rescaler->SetOutputMaximum( 255 );
    rescaler->SetInput(output);

    WriterType::Pointer writer = WriterType::New();
    writer->SetFileName( argv[2] );
    writer->SetInput(rescaler->GetOutput());
    try
    {
    writer->Update();
    }
    catch ( itk::ExceptionObject &err)
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return -1;
    }

The center image of Figure {fig:NeighborhoodExamples1} shows the output
of the Sobel algorithm applied to {Examples/Data/BrainT1Slice.png}.

    |image| |image1| |image2| [Sobel edge detection results] {Applying
    the Sobel operator in different orientations to an MRI image (left)
    produces :math:`x` (center) and :math:`y` (right) derivative
    images.} {fig:NeighborhoodExamples1}

.. |image| image:: BrainT1Slice.eps
.. |image1| image:: NeighborhoodIterators1a.eps
.. |image2| image:: NeighborhoodIterators1b.eps
