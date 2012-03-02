The source code for this section can be found in the file
``DeformableRegistration2.cxx``.

This example demonstrates how to use the “demons” algorithm to
deformably register two images. The first step is to include the header
files.

::

    [language=C++]
    #include "itkDemonsRegistrationFilter.h"
    #include "itkHistogramMatchingImageFilter.h"
    #include "itkCastImageFilter.h"
    #include "itkWarpImageFilter.h"

Second, we declare the types of the images.

::

    [language=C++]
    const unsigned int Dimension = 2;
    typedef unsigned short PixelType;

    typedef itk::Image< PixelType, Dimension >  FixedImageType;
    typedef itk::Image< PixelType, Dimension >  MovingImageType;

Image file readers are set up in a similar fashion to previous examples.
To support the re-mapping of the moving image intensity, we declare an
internal image type with a floating point pixel type and cast the input
images to the internal image type.

::

    [language=C++]
    typedef float                                      InternalPixelType;
    typedef itk::Image< InternalPixelType, Dimension > InternalImageType;
    typedef itk::CastImageFilter< FixedImageType,
    InternalImageType >  FixedImageCasterType;
    typedef itk::CastImageFilter< MovingImageType,
    InternalImageType >  MovingImageCasterType;

    FixedImageCasterType::Pointer fixedImageCaster   = FixedImageCasterType::New();
    MovingImageCasterType::Pointer movingImageCaster = MovingImageCasterType::New();

    fixedImageCaster->SetInput( fixedImageReader->GetOutput() );
    movingImageCaster->SetInput( movingImageReader->GetOutput() );

The demons algorithm relies on the assumption that pixels representing
the same homologous point on an object have the same intensity on both
the fixed and moving images to be registered. In this example, we will
preprocess the moving image to match the intensity between the images
using the {HistogramMatchingImageFilter}.

The basic idea is to match the histograms of the two images at a
user-specified number of quantile values. For robustness, the histograms
are matched so that the background pixels are excluded from both
histograms. For MR images, a simple procedure is to exclude all gray
values that are smaller than the mean gray value of the image.

::

    [language=C++]
    typedef itk::HistogramMatchingImageFilter<
    InternalImageType,
    InternalImageType >   MatchingFilterType;
    MatchingFilterType::Pointer matcher = MatchingFilterType::New();

For this example, we set the moving image as the source or input image
and the fixed image as the reference image.

::

    [language=C++]
    matcher->SetInput( movingImageCaster->GetOutput() );
    matcher->SetReferenceImage( fixedImageCaster->GetOutput() );

We then select the number of bins to represent the histograms and the
number of points or quantile values where the histogram is to be
matched.

::

    [language=C++]
    matcher->SetNumberOfHistogramLevels( 1024 );
    matcher->SetNumberOfMatchPoints( 7 );

Simple background extraction is done by thresholding at the mean
intensity.

::

    [language=C++]
    matcher->ThresholdAtMeanIntensityOn();

In the {DemonsRegistrationFilter}, the deformation field is represented
as an image whose pixels are floating point vectors.

::

    [language=C++]
    typedef itk::Vector< float, Dimension >           VectorPixelType;
    typedef itk::Image<  VectorPixelType, Dimension > DisplacementFieldType;
    typedef itk::DemonsRegistrationFilter<
    InternalImageType,
    InternalImageType,
    DisplacementFieldType>   RegistrationFilterType;
    RegistrationFilterType::Pointer filter = RegistrationFilterType::New();

The input fixed image is simply the output of the fixed image casting
filter. The input moving image is the output of the histogram matching
filter.

::

    [language=C++]
    filter->SetFixedImage( fixedImageCaster->GetOutput() );
    filter->SetMovingImage( matcher->GetOutput() );

The demons registration filter has two parameters: the number of
iterations to be performed and the standard deviation of the Gaussian
smoothing kernel to be applied to the deformation field after each
iteration.

::

    [language=C++]
    filter->SetNumberOfIterations( 50 );
    filter->SetStandardDeviations( 1.0 );

The registration algorithm is triggered by updating the filter. The
filter output is the computed deformation field.

::

    [language=C++]
    filter->Update();

The {WarpImageFilter} can be used to warp the moving image with the
output deformation field. Like the {ResampleImageFilter}, the
WarpImageFilter requires the specification of the input image to be
resampled, an input image interpolator, and the output image spacing and
origin.

::

    [language=C++]
    typedef itk::WarpImageFilter<
    MovingImageType,
    MovingImageType,
    DisplacementFieldType  >     WarperType;
    typedef itk::LinearInterpolateImageFunction<
    MovingImageType,
    double          >  InterpolatorType;
    WarperType::Pointer warper = WarperType::New();
    InterpolatorType::Pointer interpolator = InterpolatorType::New();
    FixedImageType::Pointer fixedImage = fixedImageReader->GetOutput();

    warper->SetInput( movingImageReader->GetOutput() );
    warper->SetInterpolator( interpolator );
    warper->SetOutputSpacing( fixedImage->GetSpacing() );
    warper->SetOutputOrigin( fixedImage->GetOrigin() );
    warper->SetOutputDirection( fixedImage->GetDirection() );

Unlike the ResampleImageFilter, the WarpImageFilter warps or transform
the input image with respect to the deformation field represented by an
image of vectors. The resulting warped or resampled image is written to
file as per previous examples.

::

    [language=C++]
    warper->SetDisplacementField( filter->GetOutput() );

Let’s execute this example using the rat lung data from the previous
example. The associated data files can be found in {Examples/Data}:

-  {RatLungSlice1.mha}

-  {RatLungSlice2.mha}

    |image| |image1| [Demon’s deformable registration output]
    {Checkerboard comparisons before and after demons-based deformable
    registration.} {fig:DeformableRegistration2Output}

The result of the demons-based deformable registration is presented in
Figure {fig:DeformableRegistration2Output}. The checkerboard comparison
shows that the algorithm was able to recover the misalignment due to
expiration.

It may be also desirable to write the deformation field as an image of
vectors. This can be done with the following code.

::

    [language=C++]
    typedef itk::ImageFileWriter< DisplacementFieldType > FieldWriterType;
    FieldWriterType::Pointer fieldWriter = FieldWriterType::New();
    fieldWriter->SetFileName( argv[4] );
    fieldWriter->SetInput( filter->GetOutput() );

    fieldWriter->Update();

Note that the file format used for writing the deformation field must be
capable of representing multiple components per pixel. This is the case
for the MetaImage and VTK file formats for example.

.. |image| image:: DeformableRegistration2CheckerboardBefore.eps
.. |image1| image:: DeformableRegistration2CheckerboardAfter.eps
