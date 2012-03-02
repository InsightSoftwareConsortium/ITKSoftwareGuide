The source code for this section can be found in the file
``ResampleImageFilter7.cxx``.

The following example illustrates how to use the
{BSplineInterpolateImageFunction} for resampling an image. In this
particular case an {AffineTransform} is used to map the input space into
the output space.

The header of the affine transform is included below.

::

    [language=C++]
    #include "itkAffineTransform.h"

The Resampling filter is instantiated and created just like in previous
examples. The Transform is instantiated and connected to the resampling
filter.

::

    [language=C++]
    typedef itk::ResampleImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

    typedef itk::AffineTransform< double, Dimension >  TransformType;

    TransformType::Pointer transform = TransformType::New();

    filter->SetTransform( transform );

The salient feature of this example is the use of the
{BSplineInterpolateImageFunction}, which uses cubic BSplines in order to
interpolate the resampled image.

::

    [language=C++]
    typedef itk::BSplineInterpolateImageFunction<
    InputImageType, double >  InterpolatorType;
    InterpolatorType::Pointer interpolator = InterpolatorType::New();

    filter->SetInterpolator( interpolator );

    filter->SetDefaultPixelValue( 100 );

The parameters of the output image are taken from the input image.

::

    [language=C++]
    reader->Update();
    const InputImageType::SpacingType&
    spacing = reader->GetOutput()->GetSpacing();
    const InputImageType::PointType&
    origin  = reader->GetOutput()->GetOrigin();
    const InputImageType::DirectionType&
    direction  = reader->GetOutput()->GetDirection();
    InputImageType::SizeType size =
    reader->GetOutput()->GetLargestPossibleRegion().GetSize();
    filter->SetOutputOrigin( origin );
    filter->SetOutputSpacing( spacing );
    filter->SetOutputDirection( direction );
    filter->SetSize( size );

The output of the resampling filter is connected to a writer and the
execution of the pipeline is triggered by a writer update.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception catched !" << std::endl;
    std::cerr << excep << std::endl;
    }

