Subsampling and image in the same space
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:SubsampleVolume}

The source code for this section can be found in the file
``SubsampleVolume.cxx``.

This example illustrates how to perform subsampling of a volume using
ITK classes. In order to avoid aliasing artifacts, the volume must be
processed by a low-pass filter before resampling. Here we use the
{RecursiveGaussianImageFilter} as low-pass filter. The image is then
resampled by using three different factors, one per dimension of the
image.

The most important headers to include here are the ones corresponding to
the resampling image filter, the transform, the interpolator and the
smoothing filter.

::

    [language=C++]
    #include "itkResampleImageFilter.h"
    #include "itkIdentityTransform.h"
    #include "itkRecursiveGaussianImageFilter.h"

We explicitly instantiate the pixel type and dimension of the input
image, and the images that will be used internally for computing the
resampling.

::

    [language=C++]
    const     unsigned int    Dimension = 3;

    typedef   unsigned char   InputPixelType;

    typedef   float           InternalPixelType;
    typedef   unsigned char   OutputPixelType;

    typedef itk::Image< InputPixelType,    Dimension >   InputImageType;
    typedef itk::Image< InternalPixelType, Dimension >   InternalImageType;
    typedef itk::Image< OutputPixelType,   Dimension >   OutputImageType;

In this particular case we take the factors for resampling directly from
the command line arguments.

::

    [language=C++]
    const double factorX = atof( argv[3] );
    const double factorY = atof( argv[4] );
    const double factorZ = atof( argv[5] );

A casting filter is instantiated in order to convert the pixel type of
the input image into the pixel type desired for computing the
resampling.

::

    [language=C++]
    typedef itk::CastImageFilter< InputImageType,
    InternalImageType >   CastFilterType;

    CastFilterType::Pointer caster = CastFilterType::New();

    caster->SetInput( inputImage );

The smoothing filter of choice is the {RecursiveGaussianImageFilter}. We
create three of them in order to have the freedom of performing
smoothing with different Sigma values along each dimension.

::

    [language=C++]
    typedef itk::RecursiveGaussianImageFilter<
    InternalImageType,
    InternalImageType > GaussianFilterType;

    GaussianFilterType::Pointer smootherX = GaussianFilterType::New();
    GaussianFilterType::Pointer smootherY = GaussianFilterType::New();
    GaussianFilterType::Pointer smootherZ = GaussianFilterType::New();

The smoothing filters are connected in a cascade in the pipeline.

::

    [language=C++]
    smootherX->SetInput( caster->GetOutput() );
    smootherY->SetInput( smootherX->GetOutput() );
    smootherZ->SetInput( smootherY->GetOutput() );

The Sigma values to use in the smoothing filters is computed based on
the pixel spacings of the input image and the factors provided as
arguments.

::

    [language=C++]
    const InputImageType::SpacingType& inputSpacing = inputImage->GetSpacing();

    const double sigmaX = inputSpacing[0] * factorX;
    const double sigmaY = inputSpacing[1] * factorY;
    const double sigmaZ = inputSpacing[2] * factorZ;

    smootherX->SetSigma( sigmaX );
    smootherY->SetSigma( sigmaY );
    smootherZ->SetSigma( sigmaZ );

We instruct each one of the smoothing filters to act along a particular
direction of the image, and set them to use normalization across scale
space in order to prevent for the reduction of intensity that
accompanies the diffusion process associated with the Gaussian
smoothing.

::

    [language=C++]
    smootherX->SetDirection( 0 );
    smootherY->SetDirection( 1 );
    smootherZ->SetDirection( 2 );

    smootherX->SetNormalizeAcrossScale( false );
    smootherY->SetNormalizeAcrossScale( false );
    smootherZ->SetNormalizeAcrossScale( false );

The type of the resampling filter is instantiated using the internal
image type and the output image type.

::

    [language=C++]
    typedef itk::ResampleImageFilter<
    InternalImageType, OutputImageType >  ResampleFilterType;

    ResampleFilterType::Pointer resampler = ResampleFilterType::New();

Since the resampling is performed in the same physical extent of the
input image, we select the IdentityTransform as the one to be used by
the resampling filter.

::

    [language=C++]
    typedef itk::IdentityTransform< double, Dimension >  TransformType;

    TransformType::Pointer transform = TransformType::New();
    transform->SetIdentity();
    resampler->SetTransform( transform );

The Linear interpolator is selected given that it provides a good
run-time performance. For applications that require better precision you
may want to replace this interpolator with the
{BSplineInterpolateImageFunction} interpolator or with the
{WindowedSincInterpolateImageFunction} interpolator.

::

    [language=C++]
    typedef itk::LinearInterpolateImageFunction<
    InternalImageType, double >  InterpolatorType;

    InterpolatorType::Pointer interpolator = InterpolatorType::New();

    resampler->SetInterpolator( interpolator );

The spacing to be used in the grid of the resampled image is computed
using the input image spacing and the factors provided in the command
line arguments.

::

    [language=C++]
    OutputImageType::SpacingType spacing;

    spacing[0] = inputSpacing[0] * factorX;
    spacing[1] = inputSpacing[1] * factorY;
    spacing[2] = inputSpacing[2] * factorZ;

    resampler->SetOutputSpacing( spacing );

The origin and direction of the input image is preserved and passed to
the output image.

::

    [language=C++]
    resampler->SetOutputOrigin( inputImage->GetOrigin() );
    resampler->SetOutputDirection( inputImage->GetDirection() );

The number of pixels to use along each direction on the grid of the
resampled image is computed using the number of pixels in the input
image and the sampling factors.

::

    [language=C++]
    InputImageType::SizeType   inputSize =
    inputImage->GetLargestPossibleRegion().GetSize();

    typedef InputImageType::SizeType::SizeValueType SizeValueType;

    InputImageType::SizeType   size;

    size[0] = static_cast< SizeValueType >( inputSize[0] / factorX );
    size[1] = static_cast< SizeValueType >( inputSize[1] / factorY );
    size[2] = static_cast< SizeValueType >( inputSize[2] / factorZ );

    resampler->SetSize( size );

Finally, the input to the resampler is taken from the output of the
smoothing filter.

::

    [language=C++]
    resampler->SetInput( smootherZ->GetOutput() );

At this point we can trigger the execution of the resampling by calling
the {Update()} method, or we can chose to pass the output of the
resampling filter to another section of pipeline, for example, an image
writer.
