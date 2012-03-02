The source code for this section can be found in the file
``SpatialObjectToImage1.cxx``.

This example illustrates the use of the {SpatialObjectToImageFilter}.
This filter expect a {SpatialObject} as input, and rasterize it in order
to generate an output image. This is particularly useful for generating
synthetic images, in particular binary images containing a mask.

The first step required for using this filter is to include its header
file

::

    [language=C++]
    #include "itkSpatialObjectToImageFilter.h"

This filter takes as input a SpatialObject. However, SpatialObject can
be grouped together in a hierarchical structure in order to produce more
complex shapes. In this case, we illustrate how to aggregate multiple
basic shapes. We should, therefore, include the headers of the
individual elementary SpatialObjects.

::

    [language=C++]
    #include "itkEllipseSpatialObject.h"
    #include "itkCylinderSpatialObject.h"

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
    typedef itk::EllipseSpatialObject< Dimension >   EllipseType;
    typedef itk::CylinderSpatialObject               CylinderType;
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
    size[ 2 ] = 150;

    imageFilter->SetSize( size );

::

    [language=C++]
    ImageType::SpacingType spacing;
    spacing[0] =  100.0 / size[0];
    spacing[1] =  100.0 / size[1];
    spacing[2] =  300.0 / size[2];

    imageFilter->SetSpacing( spacing );

We create the elementary shapes that are going to be composed into the
group spatial objects.

::

    [language=C++]
    EllipseType::Pointer ellipse    = EllipseType::New();
    CylinderType::Pointer cylinder1 = CylinderType::New();
    CylinderType::Pointer cylinder2 = CylinderType::New();

The Elementary shapes have internal parameters of their own. These
parameters define the geometrical characteristics of the basic shapes.
For example, a cylinder is defined by its radius and height.

::

    [language=C++]
    ellipse->SetRadius(  size[0] * 0.2 * spacing[0] );

    cylinder1->SetRadius(  size[0] * 0.2 * spacing[0] );
    cylinder2->SetRadius(  size[0] * 0.2 * spacing[0] );

    cylinder1->SetHeight( size[2] * 0.30 * spacing[2]);
    cylinder2->SetHeight( size[2] * 0.30 * spacing[2]);

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

    ellipse->SetObjectToParentTransform( transform1 );
    cylinder1->SetObjectToParentTransform( transform2 );
    cylinder2->SetObjectToParentTransform( transform3 );

The elementary shapes are aggregated in a parent group, that in turn is
passed as input to the filter.

::

    [language=C++]
    GroupType::Pointer group = GroupType::New();
    group->AddSpatialObject( ellipse );
    group->AddSpatialObject( cylinder1 );
    group->AddSpatialObject( cylinder2 );

    imageFilter->SetInput(  group  );

By default, the filter will rasterize the aggregation of elementary
shapes and will assign a pixel value to locations that fall inside of
any of the elementary shapes, and a different pixel value to locations
that fall outside of all of the elementary shapes. It is possible,
however, to generate richer images if we allow the filter to use the
values that the elementary spatial objects return via their {ValueAt}
methods. This is what we choose to do in this example, by using the
following code.

::

    [language=C++]
    const PixelType airHounsfieldUnits  = -1000;
    const PixelType boneHounsfieldUnits =   800;

    ellipse->SetDefaultInsideValue(   boneHounsfieldUnits );
    cylinder1->SetDefaultInsideValue( boneHounsfieldUnits );
    cylinder2->SetDefaultInsideValue( boneHounsfieldUnits );

    ellipse->SetDefaultOutsideValue(   airHounsfieldUnits );
    cylinder1->SetDefaultOutsideValue( airHounsfieldUnits );
    cylinder2->SetDefaultOutsideValue( airHounsfieldUnits );

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
