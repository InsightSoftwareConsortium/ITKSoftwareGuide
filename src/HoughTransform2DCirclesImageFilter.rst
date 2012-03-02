The source code for this section can be found in the file
``HoughTransform2DCirclesImageFilter.cxx``.

This example illustrates the use of the
{HoughTransform2DCirclesImageFilter} to find circles in a 2-dimensional
image.

First, we include the header files of the filter.

::

    [language=C++]
    #include "itkHoughTransform2DCirclesImageFilter.h"

Next, we declare the pixel type and image dimension and specify the
image type to be used as input. We also specify the image type of the
accumulator used in the Hough transform filter.

::

    [language=C++]
    typedef   unsigned char   PixelType;
    typedef   float           AccumulatorPixelType;
    const     unsigned int    Dimension = 2;
    typedef itk::Image< PixelType, Dimension >  ImageType;
    ImageType::IndexType localIndex;
    typedef itk::Image< AccumulatorPixelType, Dimension > AccumulatorImageType;

We setup a reader to load the input image.

::

    [language=C++]
    typedef  itk::ImageFileReader< ImageType > ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );
    try
    {
    reader->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr << excep << std::endl;
    }
    ImageType::Pointer localImage = reader->GetOutput();

We create the HoughTransform2DCirclesImageFilter based on the pixel type
of the input image (the resulting image from the ThresholdImageFilter).

::

    [language=C++]
    std::cout << "Computing Hough Map" << std::endl;

    typedef itk::HoughTransform2DCirclesImageFilter<PixelType,
    AccumulatorPixelType> HoughTransformFilterType;
    HoughTransformFilterType::Pointer houghFilter = HoughTransformFilterType::New();

We set the input of the filter to be the output of the ImageFileReader.
We set also the number of circles we are looking for. Basically, the
filter computes the Hough map, blurs it using a certain variance and
finds maxima in the Hough map. After a maximum is found, the local
neighborhood, a circle, is removed from the Hough map.
SetDiscRadiusRatio() defines the radius of this disc proportional to the
radius of the disc found. The Hough map is computed by looking at the
points above a certain threshold in the input image. Then, for each
point, a Gaussian derivative function is computed to find the direction
of the normal at that point. The standard deviation of the derivative
function can be adjusted by SetSigmaGradient(). The accumulator is
filled by drawing a line along the normal and the length of this line is
defined by the minimum radius (SetMinimumRadius()) and the maximum
radius (SetMaximumRadius()). Moreover, a sweep angle can be defined by
SetSweepAngle() (default 0.0) to increase the accuracy of detection.

The output of the filter is the accumulator.

::

    [language=C++]
    houghFilter->SetInput( reader->GetOutput() );

    houghFilter->SetNumberOfCircles( atoi(argv[3]) );
    houghFilter->SetMinimumRadius(   atof(argv[4]) );
    houghFilter->SetMaximumRadius(   atof(argv[5]) );

    if( argc > 6 )
    {
    houghFilter->SetSweepAngle( atof(argv[6]) );
    }
    if( argc > 7 )
    {
    houghFilter->SetSigmaGradient( atoi(argv[7]) );
    }
    if( argc > 8 )
    {
    houghFilter->SetVariance( atof(argv[8]) );
    }
    if( argc > 9 )
    {
    houghFilter->SetDiscRadiusRatio( atof(argv[9]) );
    }

    houghFilter->Update();
    AccumulatorImageType::Pointer localAccumulator = houghFilter->GetOutput();

We can also get the circles as {EllipseSpatialObject}. The
{GetCircles()} function return a list of those.

::

    [language=C++]
    HoughTransformFilterType::CirclesListType circles;
    circles = houghFilter->GetCircles( atoi(argv[3]) );
    std::cout << "Found " << circles.size() << " circle(s)." << std::endl;

We can then allocate an image to draw the resulting circles as binary
objects.

::

    [language=C++]
    typedef  unsigned char                            OutputPixelType;
    typedef  itk::Image< OutputPixelType, Dimension > OutputImageType;

    OutputImageType::Pointer  localOutputImage = OutputImageType::New();

    OutputImageType::RegionType region;
    region.SetSize(localImage->GetLargestPossibleRegion().GetSize());
    region.SetIndex(localImage->GetLargestPossibleRegion().GetIndex());
    localOutputImage->SetRegions( region );
    localOutputImage->SetOrigin(localImage->GetOrigin());
    localOutputImage->SetSpacing(localImage->GetSpacing());
    localOutputImage->Allocate();
    localOutputImage->FillBuffer(0);

We iterate through the list of circles and we draw them.

::

    [language=C++]
    typedef HoughTransformFilterType::CirclesListType CirclesListType;
    CirclesListType::const_iterator itCircles = circles.begin();

    while( itCircles != circles.end() )
    {
    std::cout << "Center: ";
    std::cout << (*itCircles)->GetObjectToParentTransform()->GetOffset()
    << std::endl;
    std::cout << "Radius: " << (*itCircles)->GetRadius()[0] << std::endl;

We draw white pixels in the output image to represent each circle.

::

    [language=C++]
    for(double angle = 0;angle <= 2*vnl_math::pi; angle += vnl_math::pi/60.0 )
    {
    localIndex[0] =
    (long int)((*itCircles)->GetObjectToParentTransform()->GetOffset()[0]
    + (*itCircles)->GetRadius()[0]*vcl_cos(angle));
    localIndex[1] =
    (long int)((*itCircles)->GetObjectToParentTransform()->GetOffset()[1]
    + (*itCircles)->GetRadius()[0]*vcl_sin(angle));
    OutputImageType::RegionType outputRegion =
    localOutputImage->GetLargestPossibleRegion();

    if( outputRegion.IsInside( localIndex ) )
    {
    localOutputImage->SetPixel( localIndex, 255 );
    }
    }
    itCircles++;
    }

We setup a writer to write out the binary image created.

::

    [language=C++]
    typedef  itk::ImageFileWriter< ImageType  > WriterType;
    WriterType::Pointer writer = WriterType::New();

    writer->SetFileName( argv[2] );
    writer->SetInput(localOutputImage );

    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

