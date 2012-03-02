The source code for this section can be found in the file
``SpatialObjectToImage3.cxx``.

This example illustrates the use of the {PolygonSpatialObject} for
generating a binary image through the {SpatialObjectToImageFilter}.

We start by including the header of the PolygonSpatialObject that we
will use as elementary shape, and the header for the
SpatialObjectToImageFilter that we will use to rasterize the
SpatialObject.

::

    [language=C++]
    #include "itkPolygonSpatialObject.h"
    #include "itkSpatialObjectToImageFilter.h"

We declare the pixel type and dimension of the image to be produced as
output.

::

    [language=C++]
    typedef unsigned char PixelType;
    const unsigned int    Dimension = 3;

    typedef itk::Image< PixelType, Dimension >       ImageType;

Using the same dimension, we instantiate the types of the elementary
SpatialObjects that we plan to rasterize.

::

    [language=C++]
    typedef itk::PolygonSpatialObject< Dimension >  PolygonType;

We instantiate the SpatialObjectToImageFilter type by using as template
arguments the input SpatialObject and the output image types.

::

    [language=C++]
    typedef itk::SpatialObjectToImageFilter<
    PolygonType, ImageType >   SpatialObjectToImageFilterType;

    SpatialObjectToImageFilterType::Pointer imageFilter =
    SpatialObjectToImageFilterType::New();

The SpatialObjectToImageFilter requires that the user defines the grid
parameters of the output image. This includes the number of pixels along
each dimension, the pixel spacing, image direction and

::

    [language=C++]
    ImageType::SizeType size;
    size[ 0 ] =  100;
    size[ 1 ] =  100;
    size[ 2 ] =    1;

    imageFilter->SetSize( size );

::

    [language=C++]
    ImageType::SpacingType spacing;
    spacing[0] =  100.0 / size[0];
    spacing[1] =  100.0 / size[1];
    spacing[2] =    1.0;

    imageFilter->SetSpacing( spacing );

We create the polygon object.

::

    [language=C++]
    PolygonType::Pointer polygon = PolygonType::New();

We populate the points of the polygon by computing the edges of a
hexagon centered in the image.

::

    [language=C++]
    const unsigned int numberOfPoints = 6;
    PolygonType::PointType point;
    PolygonType::PointType::VectorType radial;
    radial[0] = 0.0;
    radial[1] = 0.0;
    radial[2] = 0.0;

    PolygonType::PointType center;
    center[0] = 50.0;
    center[1] = 50.0;
    center[2] =  0.0;

    const double radius = 40.0;

    for( unsigned int i=0; i < numberOfPoints; i++ )
    {
    const double angle = 2.0 * vnl_math::pi * i / numberOfPoints;
    radial[0] = radius * vcl_cos( angle );
    radial[1] = radius * vcl_sin( angle );
    point = center + radial;
    polygon->AddPoint( point );
    }

We connect the polygon as the input to the SpatialObjectToImageFilter.

::

    [language=C++]
    imageFilter->SetInput(  polygon  );

Finally we are ready to run the filter. We use the typical invocation of
the {Update} method, and we instantiate an {ImageFileWriter} in order to
save the generated image into a file.

::

    [language=C++]
    typedef itk::ImageFileWriter< ImageType >     WriterType;
    WriterType::Pointer writer = WriterType::New();

    writer->SetFileName( argv[1] );
    writer->SetInput( imageFilter->GetOutput() );

    try
    {
    imageFilter->Update();
    writer->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

