The source code for this section can be found in the file
``SpatialObjectToImage2.cxx``.

This example illustrates the use of the {GaussianSpatialObjects} for
composing complex smoothed shapes by aggregating them in a group. This
process is equivalent to what is called ’’MetaBalls’’ in Computer
Graphics.

See http:en.wikipedia.org/wiki/Metaballs

We include the header file of the SpatialObjectToImageFilter since we
will use it to rasterize the group of spatial objects into an image.

::

    [language=C++]
    #include "itkSpatialObjectToImageFilter.h"

Then we include the header of the GaussianSpatialObject that we will use
as elementary shape.

::

    [language=C++]
    #include "itkGaussianSpatialObject.h"

Then we include the header of the {GroupSpatialObject} that will group
together these instances of SpatialObjects.

::

    [language=C++]
    #include "itkGroupSpatialObject.h"

We declare the pixel type and dimension of the image to be produced as
output.

::

    [language=C++]
    typedef signed short  PixelType;
    const unsigned int    Dimension = 3;

    typedef itk::Image< PixelType, Dimension >       ImageType;

Using the same dimension, we instantiate the types of the elementary
SpatialObjects that we plan to group, and we instantiate as well the
type of the SpatialObject that will hold the group together.

::

    [language=C++]
    typedef itk::GaussianSpatialObject< Dimension >  MetaBallType;
    typedef itk::GroupSpatialObject< Dimension >     GroupType;

We instantiate the SpatialObjectToImageFilter type by using as template
arguments the input SpatialObject and the output image types.

::

    [language=C++]
    typedef itk::SpatialObjectToImageFilter<
    GroupType, ImageType >   SpatialObjectToImageFilterType;

    SpatialObjectToImageFilterType::Pointer imageFilter =
    SpatialObjectToImageFilterType::New();

The SpatialObjectToImageFilter requires that the user defines the grid
parameters of the output image. This includes the number of pixels along
each dimension, the pixel spacing, image direction and

::

    [language=C++]
    ImageType::SizeType size;
    size[ 0 ] =  50;
    size[ 1 ] =  50;
    size[ 2 ] = 200;

    imageFilter->SetSize( size );

::

    [language=C++]
    ImageType::SpacingType spacing;
    spacing[0] =  100.0 / size[0];
    spacing[1] =  100.0 / size[1];
    spacing[2] =  400.0 / size[2];

    imageFilter->SetSpacing( spacing );

We create the elementary shapes that are going to be composed into the
group spatial objects.

::

    [language=C++]
    MetaBallType::Pointer metaBall1 = MetaBallType::New();
    MetaBallType::Pointer metaBall2 = MetaBallType::New();
    MetaBallType::Pointer metaBall3 = MetaBallType::New();

The Elementary shapes have internal parameters of their own. These
parameters define the geometrical characteristics of the basic shapes.
For example, a cylinder is defined by its radius and height.

::

    [language=C++]
    metaBall1->SetRadius(  size[0] * spacing[0] * 0.2 );
    metaBall2->SetRadius(  size[0] * spacing[0] * 0.2 );
    metaBall3->SetRadius(  size[0] * spacing[0] * 0.2 );

Each one of these components will be placed in a different position and
orientation. We define transforms in order to specify those relative
positions and orientations.

::

    [language=C++]
    typedef GroupType::TransformType                 TransformType;

    TransformType::Pointer transform1 = TransformType::New();
    TransformType::Pointer transform2 = TransformType::New();
    TransformType::Pointer transform3 = TransformType::New();

    transform1->SetIdentity();
    transform2->SetIdentity();
    transform3->SetIdentity();

Then we set the specific values of the transform parameters, and we
assign the transforms to the elementary shapes.

::

    [language=C++]
    TransformType::OutputVectorType  translation;
    TransformType::CenterType        center;

    translation[ 0 ] =  size[0] * spacing[0] / 2.0;
    translation[ 1 ] =  size[1] * spacing[1] / 4.0;
    translation[ 2 ] =  size[2] * spacing[2] / 2.0;
    transform1->Translate( translation, false );

    translation[ 1 ] =  size[1] * spacing[1] / 2.0;
    translation[ 2 ] =  size[2] * spacing[2] * 0.22;
    transform2->Rotate( 1, 2, vnl_math::pi / 2.0 );
    transform2->Translate( translation, false );

    translation[ 2 ] = size[2] * spacing[2] * 0.78;
    transform3->Rotate( 1, 2, vnl_math::pi / 2.0 );
    transform3->Translate( translation, false );

    metaBall1->SetObjectToParentTransform( transform1 );
    metaBall2->SetObjectToParentTransform( transform2 );
    metaBall3->SetObjectToParentTransform( transform3 );

The elementary shapes are aggregated in a parent group, that in turn is
passed as input to the filter.

::

    [language=C++]
    GroupType::Pointer group = GroupType::New();
    group->AddSpatialObject( metaBall1 );
    group->AddSpatialObject( metaBall2 );
    group->AddSpatialObject( metaBall3 );

    imageFilter->SetInput(  group  );

By default, the filter will rasterize the aggregation of elementary
shapes and will assign a pixel value to locations that fall inside of
any of the elementary shapes, and a different pixel value to locations
that fall outside of all of the elementary shapes. In this case, we
actually want the values of the Gaussians (MetaBalls) to be used in
order produce the equivalent of a smooth fusion effect among the shapes.

::

    [language=C++]
    const PixelType airHounsfieldUnits  = -1000;

    imageFilter->SetUseObjectValue( true );
    imageFilter->SetOutsideValue( airHounsfieldUnits );

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
