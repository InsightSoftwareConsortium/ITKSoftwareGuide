The source code for this section can be found in the file
``DigitallyReconstructedRadiograph1.cxx``.

This example illustrates the use of the
{RayCastInterpolateImageFunction} class to generate digitally
reconstructed radiographs (DRRs) from a 3D image volume such as CT or
MR.

The {RayCastInterpolateImageFunction} class definition for this example
is contained in the following header file.

::

    [language=C++]
    #include "itkRayCastInterpolateImageFunction.h"

Although we generate a 2D projection of the 3D volume for the purposes
of the interpolator both images must be three dimensional.

::

    [language=C++]
    const     unsigned int   Dimension = 3;
    typedef   short         InputPixelType;
    typedef   unsigned char OutputPixelType;

    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;

    InputImageType::Pointer image;

For the purposes of this example we assume the input volume has been
loaded into an {itk::Image image}.

Creation of a {ResampleImageFilter} enables coordinates for each of the
pixels in the DRR image to be generated. These coordinates are used by
the {RayCastInterpolateImageFunction} to determine the equation of each
corresponding ray which is cast through the input volume.

::

    [language=C++]
    typedef itk::ResampleImageFilter<InputImageType, InputImageType > FilterType;

    FilterType::Pointer filter = FilterType::New();

    filter->SetInput( image );
    filter->SetDefaultPixelValue( 0 );

An Euler transformation is defined to position the input volume. The
{ResampleImageFilter} uses this transform to position the output DRR
image for the desired view.

::

    [language=C++]
    typedef itk::CenteredEuler3DTransform< double >  TransformType;

    TransformType::Pointer transform = TransformType::New();

    transform->SetComputeZYX(true);

    TransformType::OutputVectorType translation;

    translation[0] = tx;
    translation[1] = ty;
    translation[2] = tz;

    constant for converting degrees into radians
    const double dtr = ( vcl_atan(1.0) * 4.0 ) / 180.0;

    transform->SetTranslation( translation );
    transform->SetRotation( dtr*rx, dtr*ry, dtr*rz );

    InputImageType::PointType   imOrigin = image->GetOrigin();
    InputImageType::SpacingType imRes    = image->GetSpacing();

    typedef InputImageType::RegionType     InputImageRegionType;
    typedef InputImageRegionType::SizeType InputImageSizeType;

    InputImageRegionType imRegion = image->GetBufferedRegion();
    InputImageSizeType   imSize   = imRegion.GetSize();

    imOrigin[0] += imRes[0] * static_cast<double>( imSize[0] ) / 2.0;
    imOrigin[1] += imRes[1] * static_cast<double>( imSize[1] ) / 2.0;
    imOrigin[2] += imRes[2] * static_cast<double>( imSize[2] ) / 2.0;

    TransformType::InputPointType center;
    center[0] = cx + imOrigin[0];
    center[1] = cy + imOrigin[1];
    center[2] = cz + imOrigin[2];

    transform->SetCenter(center);

    if (verbose)
    {
    std::cout << "Image size: "
    << imSize[0] << ", " << imSize[1] << ", " << imSize[2] << std::endl
    << "   resolution: "
    << imRes[0] << ", " << imRes[1] << ", " << imRes[2] << std::endl
    << "   origin: "
    << imOrigin[0] << ", " << imOrigin[1] << ", " << imOrigin[2] << std::endl
    << "   center: "
    << center[0] << ", " << center[1] << ", " << center[2] << std::endl
    << "Transform: " << transform << std::endl;
    }

The {RayCastInterpolateImageFunction} is instantiated and passed the
transform object. The {RayCastInterpolateImageFunction} uses this
transform to reposition the x-ray source such that the DRR image and
x-ray source move as one around the input volume. This coupling mimics
the rigid geometry of the x-ray gantry.

::

    [language=C++]
    typedef itk::RayCastInterpolateImageFunction<InputImageType,double> InterpolatorType;

    InterpolatorType::Pointer interpolator = InterpolatorType::New();

    interpolator->SetTransform(transform);

We can then specify a threshold above which the volume’s intensities
will be integrated.

::

    [language=C++]
    interpolator->SetThreshold(threshold);

The ray-cast interpolator needs to know the initial position of the ray
source or focal point. In this example we place the input volume at the
origin and halfway between the ray source and the screen. The distance
between the ray source and the screen is the "source to image distance"
{sid} and is specified by the user.

::

    [language=C++]
    InterpolatorType::InputPointType focalpoint;

    focalpoint[0]= imOrigin[0];
    focalpoint[1]= imOrigin[1];
    focalpoint[2]= imOrigin[2] - sid/2.;

    interpolator->SetFocalPoint(focalpoint);

Having initialised the interpolator we pass the object to the resample
filter.

::

    [language=C++]
    interpolator->Print (std::cout);

    filter->SetInterpolator( interpolator );
    filter->SetTransform( transform );

The size and resolution of the output DRR image is specified via the
resample filter.

::

    [language=C++]

    setup the scene
    InputImageType::SizeType   size;

    size[0] = dx;   number of pixels along X of the 2D DRR image
    size[1] = dy;   number of pixels along Y of the 2D DRR image
    size[2] = 1;    only one slice

    filter->SetSize( size );

    InputImageType::SpacingType spacing;

    spacing[0] = sx;   pixel spacing along X of the 2D DRR image [mm]
    spacing[1] = sy;   pixel spacing along Y of the 2D DRR image [mm]
    spacing[2] = 1.0;  slice thickness of the 2D DRR image [mm]

    filter->SetOutputSpacing( spacing );

In addition the position of the DRR is specified. The default position
of the input volume, prior to its transformation is half-way between the
ray source and screen and unless specified otherwise the normal from the
"screen" to the ray source passes directly through the centre of the
DRR.

::

    [language=C++]

    double origin[ Dimension ];

    origin[0] = imOrigin[0] + o2Dx - sx*((double) dx - 1.)/2.;
    origin[1] = imOrigin[1] + o2Dy - sy*((double) dy - 1.)/2.;
    origin[2] = imOrigin[2] + sid/2.;

    filter->SetOutputOrigin( origin );

The output of the resample filter can then be passed to a writer to save
the DRR image to a file.

::

    [language=C++]
    typedef itk::RescaleIntensityImageFilter<
    InputImageType, OutputImageType > RescaleFilterType;
    RescaleFilterType::Pointer rescaler = RescaleFilterType::New();
    rescaler->SetOutputMinimum(   0 );
    rescaler->SetOutputMaximum( 255 );
    rescaler->SetInput( filter->GetOutput() );

    typedef itk::ImageFileWriter< OutputImageType >  WriterType;
    WriterType::Pointer writer = WriterType::New();

    writer->SetFileName( output_name );
    writer->SetInput( rescaler->GetOutput() );

    try
    {
    std::cout << "Writing image: " << output_name << std::endl;
    writer->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ERROR: ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    }

