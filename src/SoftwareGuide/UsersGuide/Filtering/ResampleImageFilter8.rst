The source code for this section can be found in the file
``ResampleImageFilter8.cxx``.

The following example illustrates how to use the
{WindowedSincInterpolateImageFunction} for resampling an image. This
interpolator is in theory the best possible interpolator for
reconstructing the continous values of a discrete image. In the spectral
domain, this interpolator is performing the task of masking the central
part of the spectrum of the sampled image, that in principle corresponds
to the spectrumn of the continuous image before it was sampled into a
discrete one. In this particular case an {AffineTransform} is used to
map the input space into the output space.

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
{WindowedSincInterpolateImageFunction}, which uses a truncated *sinc*
function in order to interpolate the resampled image.

There is a close relationship between operations performed in the
spatial domain and those applied in the spectral doman. For example, the
action of truncating the *sinc* function with a box function in the
spatial domain will correspond to convolving its spectrum with the
spectrum of a box function. Since the box function spectrum has an
infinite support on the spectral domain, the result of the convolution
will also have an infinite support on the spectral domain. Due to this
effects, it is desirable to truncate the *sinc* function by using a
window that has a limited spectral support. Many different windows have
been developed to this end in the domain of image processing. Among the
most commonly used we have the **Hamming** window. We use here a Hamming
window in order to define the truncation of the sinc function. The
window is instantiated and its type is used in the instantiation of the
WindowedSinc interpolator. The size of the window is one of the critical
parameters of this class. The size must be decided at compilation time
by using a {const integer} or an {enum}.

::

    [language=C++]
    typedef itk::ConstantBoundaryCondition< InputImageType >  BoundaryConditionType;

    const unsigned int WindowRadius = 5;

    typedef itk::Function::HammingWindowFunction<WindowRadius>  WindowFunctionType;

    typedef itk::WindowedSincInterpolateImageFunction<
    InputImageType,
    WindowRadius,
    WindowFunctionType,
    BoundaryConditionType,
    double  >    InterpolatorType;

    InterpolatorType::Pointer   interpolator  = InterpolatorType::New();

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

