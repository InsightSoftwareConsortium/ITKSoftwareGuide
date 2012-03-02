The source code for this section can be found in the file
``HoughTransform2DLinesImageFilter.cxx``.

This example illustrates the use of the
{HoughTransform2DLinesImageFilter} to find straight lines in a
2-dimensional image.

First, we include the header files of the filter.

::

    [language=C++]
    #include "itkHoughTransform2DLinesImageFilter.h"

Next, we declare the pixel type and image dimension and specify the
image type to be used as input. We also specify the image type of the
accumulator used in the Hough transform filter.

::

    [language=C++]
    typedef   unsigned char   PixelType;
    typedef   float           AccumulatorPixelType;
    const     unsigned int    Dimension = 2;

    typedef itk::Image< PixelType, Dimension >            ImageType;
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

Once the image is loaded, we apply a {GradientMagnitudeImageFilter} to
segment edges. This casts the input image using a {CastImageFilter}.

::

    [language=C++]
    typedef itk::CastImageFilter< ImageType, AccumulatorImageType >
    CastingFilterType;
    CastingFilterType::Pointer caster = CastingFilterType::New();

    std::cout << "Applying gradient magnitude filter" << std::endl;

    typedef itk::GradientMagnitudeImageFilter<AccumulatorImageType,
    AccumulatorImageType > GradientFilterType;
    GradientFilterType::Pointer gradFilter =  GradientFilterType::New();

    caster->SetInput(localImage);
    gradFilter->SetInput(caster->GetOutput());
    gradFilter->Update();

The next step is to apply a threshold filter on the gradient magnitude
image to keep only bright values. Only pixels with a high value will be
used by the Hough transform filter.

::

    [language=C++]
    std::cout << "Thresholding" << std::endl;
    typedef itk::ThresholdImageFilter<AccumulatorImageType> ThresholdFilterType;
    ThresholdFilterType::Pointer threshFilter = ThresholdFilterType::New();

    threshFilter->SetInput( gradFilter->GetOutput());
    threshFilter->SetOutsideValue(0);
    unsigned char threshBelow = 0;
    unsigned char threshAbove = 255;
    threshFilter->ThresholdOutside(threshBelow,threshAbove);
    threshFilter->Update();

We create the HoughTransform2DLinesImageFilter based on the pixel type
of the input image (the resulting image from the ThresholdImageFilter).

::

    [language=C++]
    std::cout << "Computing Hough Map" << std::endl;
    typedef itk::HoughTransform2DLinesImageFilter<AccumulatorPixelType,
    AccumulatorPixelType>  HoughTransformFilterType;

    HoughTransformFilterType::Pointer houghFilter = HoughTransformFilterType::New();

We set the input to the filter to be the output of the
ThresholdImageFilter. We set also the number of lines we are looking
for. Basically, the filter computes the Hough map, blurs it using a
certain variance and finds maxima in the Hough map. After a maximum is
found, the local neighborhood, a circle, is removed from the Hough map.
SetDiscRadius() defines the radius of this disc.

The output of the filter is the accumulator.

::

    [language=C++]
    houghFilter->SetInput(threshFilter->GetOutput());
    houghFilter->SetNumberOfLines(atoi(argv[3]));

    if(argc > 4 )
    {
    houghFilter->SetVariance(atof(argv[4]));
    }

    if(argc > 5 )
    {
    houghFilter->SetDiscRadius(atof(argv[5]));
    }
    houghFilter->Update();
    AccumulatorImageType::Pointer localAccumulator = houghFilter->GetOutput();

We can also get the lines as {LineSpatialObject}. The {GetLines()}
function return a list of those.

::

    [language=C++]
    HoughTransformFilterType::LinesListType lines;
    lines = houghFilter->GetLines(atoi(argv[3]));
    std::cout << "Found " << lines.size() << " line(s)." << std::endl;

We can then allocate an image to draw the resulting lines as binary
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

We iterate through the list of lines and we draw them.

::

    [language=C++]
    typedef HoughTransformFilterType::LinesListType::const_iterator LineIterator;
    LineIterator itLines = lines.begin();
    while( itLines != lines.end() )
    {

We get the list of points which consists of two points to represent a
straight line. Then, from these two points, we compute a fixed point
:math:`u` and a unit vector :math:`\vec{v}` to parameterize the
line.

::

    [language=C++]
    typedef HoughTransformFilterType::LineType::PointListType  PointListType;

    PointListType                   pointsList = (*itLines)->GetPoints();
    PointListType::const_iterator   itPoints = pointsList.begin();

    double u[2];
    u[0] = (*itPoints).GetPosition()[0];
    u[1] = (*itPoints).GetPosition()[1];
    itPoints++;
    double v[2];
    v[0] = u[0]-(*itPoints).GetPosition()[0];
    v[1] = u[1]-(*itPoints).GetPosition()[1];

    double norm = vcl_sqrt(v[0]*v[0]+v[1]*v[1]);
    v[0] /= norm;
    v[1] /= norm;

We draw a white pixels in the output image to represent the line.

::

    [language=C++]
    ImageType::IndexType localIndex;
    itk::Size<2> size = localOutputImage->GetLargestPossibleRegion().GetSize();
    float diag = vcl_sqrt((float)( size[0]*size[0] + size[1]*size[1] ));

    for(int i=static_cast<int>(-diag); i<static_cast<int>(diag); i++)
    {
    localIndex[0]=(long int)(u[0]+i*v[0]);
    localIndex[1]=(long int)(u[1]+i*v[1]);

    OutputImageType::RegionType outputRegion =
    localOutputImage->GetLargestPossibleRegion();

    if( outputRegion.IsInside( localIndex ) )
    {
    localOutputImage->SetPixel( localIndex, 255 );
    }
    }
    itLines++;
    }

We setup a writer to write out the binary image created.

::

    [language=C++]
    typedef  itk::ImageFileWriter<  OutputImageType  > WriterType;
    WriterType::Pointer writer = WriterType::New();
    writer->SetFileName( argv[2] );
    writer->SetInput( localOutputImage );

    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

