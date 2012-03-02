Resampling using a deformation field
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The source code for this section can be found in the file
``WarpImageFilter1.cxx``.

This example illustrates how to use the WarpImageFilter and a
deformation field for resampling an image. This is typically done as the
last step of a deformable registration algorithm.

::

    [language=C++]
    #include "itkWarpImageFilter.h"

The deformation field is represented as an image of vector pixel types.
The dimension of the vectors is the same as the dimension of the input
image. Each vector in the deformation field represents the distance
between a geometric point in the input space and a point in the output
space such that: :math:`p_{in} = p_{out} + distance`

::

    [language=C++]
    typedef   float                                         VectorComponentType;
    typedef   itk::Vector< VectorComponentType, Dimension > VectorPixelType;
    typedef   itk::Image< VectorPixelType,  Dimension >     DisplacementFieldType;

    typedef   unsigned char                         PixelType;
    typedef   itk::Image< PixelType,  Dimension >   ImageType;

The field is read from a file, through a reader instantiated over the
vector pixel types.

::

    [language=C++]
    typedef   itk::ImageFileReader< DisplacementFieldType >  FieldReaderType;

::

    [language=C++]
    FieldReaderType::Pointer fieldReader = FieldReaderType::New();
    fieldReader->SetFileName( argv[2] );
    fieldReader->Update();

    DisplacementFieldType::ConstPointer deformationField = fieldReader->GetOutput();

The {WarpImageFilter} is templated over the input image type, output
image type and the deformation field type.

::

    [language=C++]
    typedef itk::WarpImageFilter< ImageType,
    ImageType,
    DisplacementFieldType  >  FilterType;

    FilterType::Pointer filter = FilterType::New();

Typically the mapped position does not correspond to an integer pixel
position in the input image. Interpolation via an image function is used
to compute values at non-integer positions. This is done via the
{SetInterpolator()} method.

::

    [language=C++]
    typedef itk::LinearInterpolateImageFunction<
    ImageType, double >  InterpolatorType;

    InterpolatorType::Pointer interpolator = InterpolatorType::New();

    filter->SetInterpolator( interpolator );

The output image spacing and origin may be set via SetOutputSpacing(),
SetOutputOrigin(). This is taken from the deformation field.

::

    [language=C++]
    filter->SetOutputSpacing( deformationField->GetSpacing() );
    filter->SetOutputOrigin(  deformationField->GetOrigin() );
    filter->SetOutputDirection(  deformationField->GetDirection() );

    filter->SetDisplacementField( deformationField );
