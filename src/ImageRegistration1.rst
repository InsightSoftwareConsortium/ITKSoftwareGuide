The source code for this section can be found in the file
``ImageRegistration1.cxx``.

This example illustrates the use of the image registration framework in
Insight. It should be read as a "Hello World" for ITK registration.
Which means that for now, you don’t ask “why?”. Instead, use the example
as an introduction to the elements that are typically involved in
solving an image registration problem.

A registration method requires the following set of components: two
input images, a transform, a metric, an interpolator and an optimizer.
Some of these components are parameterized by the image type for which
the registration is intended. The following header files provide
declarations of common types used for these components.

::

    [language=C++]
    #include "itkImageRegistrationMethod.h"
    #include "itkTranslationTransform.h"
    #include "itkMeanSquaresImageToImageMetric.h"
    #include "itkRegularStepGradientDescentOptimizer.h"

The types of each one of the components in the registration methods
should be instantiated first. With that purpose, we start by selecting
the image dimension and the type used for representing image pixels.

::

    [language=C++]
    const    unsigned int    Dimension = 2;
    typedef  float           PixelType;

The types of the input images are instantiated by the following lines.

::

    [language=C++]
    typedef itk::Image< PixelType, Dimension >  FixedImageType;
    typedef itk::Image< PixelType, Dimension >  MovingImageType;

The transform that will map the fixed image space into the moving image
space is defined below.

::

    [language=C++]
    typedef itk::TranslationTransform< double, Dimension > TransformType;

An optimizer is required to explore the parameter space of the transform
in search of optimal values of the metric.

::

    [language=C++]
    typedef itk::RegularStepGradientDescentOptimizer       OptimizerType;

The metric will compare how well the two images match each other. Metric
types are usually parameterized by the image types as it can be seen in
the following type declaration.

::

    [language=C++]
    typedef itk::MeanSquaresImageToImageMetric<
    FixedImageType,
    MovingImageType >    MetricType;

Finally, the type of the interpolator is declared. The interpolator will
evaluate the intensities of the moving image at non-grid positions.

::

    [language=C++]
    typedef itk:: LinearInterpolateImageFunction<
    MovingImageType,
    double          >    InterpolatorType;

The registration method type is instantiated using the types of the
fixed and moving images. This class is responsible for interconnecting
all the components that we have described so far.

::

    [language=C++]
    typedef itk::ImageRegistrationMethod<
    FixedImageType,
    MovingImageType >    RegistrationType;

Each one of the registration components is created using its {New()}
method and is assigned to its respective {SmartPointer}.

::

    [language=C++]
    MetricType::Pointer         metric        = MetricType::New();
    TransformType::Pointer      transform     = TransformType::New();
    OptimizerType::Pointer      optimizer     = OptimizerType::New();
    InterpolatorType::Pointer   interpolator  = InterpolatorType::New();
    RegistrationType::Pointer   registration  = RegistrationType::New();

Each component is now connected to the instance of the registration
method.

::

    [language=C++]
    registration->SetMetric(        metric        );
    registration->SetOptimizer(     optimizer     );
    registration->SetTransform(     transform     );
    registration->SetInterpolator(  interpolator  );

In this example, the fixed and moving images are read from files. This
requires the {ImageRegistrationMethod} to acquire its inputs from the
output of the readers.

::

    [language=C++]
    registration->SetFixedImage(    fixedImageReader->GetOutput()    );
    registration->SetMovingImage(   movingImageReader->GetOutput()   );

The registration can be restricted to consider only a particular region
of the fixed image as input to the metric computation. This region is
defined with the {SetFixedImageRegion()} method. You could use this
feature to reduce the computational time of the registration or to avoid
unwanted objects present in the image from affecting the registration
outcome. In this example we use the full available content of the image.
This region is identified by the {BufferedRegion} of the fixed image.
Note that for this region to be valid the reader must first invoke its
{Update()} method.

::

    [language=C++]
    fixedImageReader->Update();
    registration->SetFixedImageRegion(
    fixedImageReader->GetOutput()->GetBufferedRegion() );

The parameters of the transform are initialized by passing them in an
array. This can be used to setup an initial known correction of the
misalignment. In this particular case, a translation transform is being
used for the registration. The array of parameters for this transform is
simply composed of the translation values along each dimension. Setting
the values of the parameters to zero initializes the transform to an
*Identity* transform. Note that the array constructor requires the
number of elements to be passed as an argument.

::

    [language=C++]
    typedef RegistrationType::ParametersType ParametersType;
    ParametersType initialParameters( transform->GetNumberOfParameters() );

    initialParameters[0] = 0.0;   Initial offset in mm along X
    initialParameters[1] = 0.0;   Initial offset in mm along Y

    registration->SetInitialTransformParameters( initialParameters );

At this point the registration method is ready for execution. The
optimizer is the component that drives the execution of the
registration. However, the ImageRegistrationMethod class orchestrates
the ensemble to make sure that everything is in place before control is
passed to the optimizer.

It is usually desirable to fine tune the parameters of the optimizer.
Each optimizer has particular parameters that must be interpreted in the
context of the optimization strategy it implements. The optimizer used
in this example is a variant of gradient descent that attempts to
prevent it from taking steps that are too large. At each iteration, this
optimizer will take a step along the direction of the
{ImageToImageMetric} derivative. The initial length of the step is
defined by the user. Each time the direction of the derivative abruptly
changes, the optimizer assumes that a local extrema has been passed and
reacts by reducing the step length by a half. After several reductions
of the step length, the optimizer may be moving in a very restricted
area of the transform parameter space. The user can define how small the
step length should be to consider convergence to have been reached. This
is equivalent to defining the precision with which the final transform
should be known.

The initial step length is defined with the method
{SetMaximumStepLength()}, while the tolerance for convergence is defined
with the method {SetMinimumStepLength()}.

::

    [language=C++]
    optimizer->SetMaximumStepLength( 4.00 );
    optimizer->SetMinimumStepLength( 0.01 );

In case the optimizer never succeeds reaching the desired precision
tolerance, it is prudent to establish a limit on the number of
iterations to be performed. This maximum number is defined with the
method {SetNumberOfIterations()}.

::

    [language=C++]
    optimizer->SetNumberOfIterations( 200 );

The registration process is triggered by an invocation to the {Update()}
method. If something goes wrong during the initialization or execution
of the registration an exception will be thrown. We should therefore
place the {Update()} method inside a {try/catch} block as illustrated in
the following lines.

::

    [language=C++]
    try
    {
    registration->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

In a real life application, you may attempt to recover from the error by
taking more effective actions in the catch block. Here we are simply
printing out a message and then terminating the execution of the
program.

The result of the registration process is an array of parameters that
defines the spatial transformation in an unique way. This final result
is obtained using the {GetLastTransformParameters()} method.

::

    [language=C++]
    ParametersType finalParameters = registration->GetLastTransformParameters();

In the case of the {TranslationTransform}, there is a straightforward
interpretation of the parameters. Each element of the array corresponds
to a translation along one spatial dimension.

::

    [language=C++]
    const double TranslationAlongX = finalParameters[0];
    const double TranslationAlongY = finalParameters[1];

The optimizer can be queried for the actual number of iterations
performed to reach convergence. The {GetCurrentIteration()} method
returns this value. A large number of iterations may be an indication
that the maximum step length has been set too small, which is
undesirable since it results in long computational times.

::

    [language=C++]
    const unsigned int numberOfIterations = optimizer->GetCurrentIteration();

The value of the image metric corresponding to the last set of
parameters can be obtained with the {GetValue()} method of the
optimizer.

::

    [language=C++]
    const double bestValue = optimizer->GetValue();

Let’s execute this example over two of the images provided in
{Examples/Data}:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceShifted13x17y.png}

The second image is the result of intentionally translating the first
image by :math:`(13,17)` millimeters. Both images have unit-spacing
and are shown in Figure {fig:FixedMovingImageRegistration1}. The
registration takes 18 iterations and the resulting transform parameters
are:

::

    Translation X = 12.9959
    Translation Y = 17.0001

As expected, these values match quite well the misalignment that we
intentionally introduced in the moving image.

    |image| |image1| [Fixed and Moving images in registration framework]
    {Fixed and Moving image provided as input to the registration
    method.} {fig:FixedMovingImageRegistration1}

It is common, as the last step of a registration task, to use the
resulting transform to map the moving image into the fixed image space.
This is easily done with the {ResampleImageFilter}. Please refer to
Section {sec:ResampleImageFilter} for details on the use of this filter.
First, a ResampleImageFilter type is instantiated using the image types.
It is convenient to use the fixed image type as the output type since it
is likely that the transformed moving image will be compared with the
fixed image.

::

    [language=C++]
    typedef itk::ResampleImageFilter<
    MovingImageType,
    FixedImageType >    ResampleFilterType;

A resampling filter is created and the moving image is connected as its
input.

::

    [language=C++]
    ResampleFilterType::Pointer resampler = ResampleFilterType::New();
    resampler->SetInput( movingImageReader->GetOutput() );

The Transform that is produced as output of the Registration method is
also passed as input to the resampling filter. Note the use of the
methods {GetOutput()} and {Get()}. This combination is needed here
because the registration method acts as a filter whose output is a
transform decorated in the form of a {DataObject}. For details in this
construction you may want to read the documentation of the
{DataObjectDecorator}.

::

    [language=C++]
    resampler->SetTransform( registration->GetOutput()->Get() );

As described in Section {sec:ResampleImageFilter}, the
ResampleImageFilter requires additional parameters to be specified, in
particular, the spacing, origin and size of the output image. The
default pixel value is also set to a distinct gray level in order to
highlight the regions that are mapped outside of the moving image.

::

    [language=C++]
    FixedImageType::Pointer fixedImage = fixedImageReader->GetOutput();
    resampler->SetSize( fixedImage->GetLargestPossibleRegion().GetSize() );
    resampler->SetOutputOrigin(  fixedImage->GetOrigin() );
    resampler->SetOutputSpacing( fixedImage->GetSpacing() );
    resampler->SetOutputDirection( fixedImage->GetDirection() );
    resampler->SetDefaultPixelValue( 100 );

    |image2| |image3| |image4| [HelloWorld registration output images]
    {Mapped moving image and its difference with the fixed image before
    and after registration} {fig:ImageRegistration1Output}

The output of the filter is passed to a writer that will store the image
in a file. An {CastImageFilter} is used to convert the pixel type of the
resampled image to the final type used by the writer. The cast and
writer filters are instantiated below.

::

    [language=C++]
    typedef unsigned char OutputPixelType;
    typedef itk::Image< OutputPixelType, Dimension > OutputImageType;
    typedef itk::CastImageFilter<
    FixedImageType,
    OutputImageType > CastFilterType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

The filters are created by invoking their {New()} method.

::

    [language=C++]
    WriterType::Pointer      writer =  WriterType::New();
    CastFilterType::Pointer  caster =  CastFilterType::New();

The filters are connected together and the {Update()} method of the
writer is invoked in order to trigger the execution of the pipeline.

::

    [language=C++]
    caster->SetInput( resampler->GetOutput() );
    writer->SetInput( caster->GetOutput()   );
    writer->Update();

    |image5| [Pipeline structure of the registration example] {Pipeline
    structure of the registration example.}
    {fig:ImageRegistration1Pipeline}

The fixed image and the transformed moving image can easily be compared
using the {SubtractImageFilter}. This pixel-wise filter computes the
difference between homologous pixels of its two input images.

::

    [language=C++]
    typedef itk::SubtractImageFilter<
    FixedImageType,
    FixedImageType,
    FixedImageType > DifferenceFilterType;

    DifferenceFilterType::Pointer difference = DifferenceFilterType::New();

    difference->SetInput1( fixedImageReader->GetOutput() );
    difference->SetInput2( resampler->GetOutput() );

Note that the use of subtraction as a method for comparing the images is
appropriate here because we chose to represent the images using a pixel
type {float}. A different filter would have been used if the pixel type
of the images were any of the {unsigned} integer type.

Since the differences between the two images may correspond to very low
values of intensity, we rescale those intensities with a
{RescaleIntensityImageFilter} in order to make them more visible. This
rescaling will also make possible to visualize the negative values even
if we save the difference image in a file format that only support
unsigned pixel values [1]_. We also reduce the {DefaultPixelValue} to
“1” in order to prevent that value from absorbing the dynamic range of
the differences between the two images.

::

    [language=C++]
    typedef itk::RescaleIntensityImageFilter<
    FixedImageType,
    OutputImageType >   RescalerType;

    RescalerType::Pointer intensityRescaler = RescalerType::New();

    intensityRescaler->SetInput( difference->GetOutput() );
    intensityRescaler->SetOutputMinimum(   0 );
    intensityRescaler->SetOutputMaximum( 255 );

    resampler->SetDefaultPixelValue( 1 );

Its output can be passed to another writer.

::

    [language=C++]
    WriterType::Pointer writer2 = WriterType::New();
    writer2->SetInput( intensityRescaler->GetOutput() );

For the purpose of comparison, the difference between the fixed image
and the moving image before registration can also be computed by simply
setting the transform to an identity transform. Note that the resampling
is still necessary because the moving image does not necessarily have
the same spacing, origin and number of pixels as the fixed image.
Therefore a pixel-by-pixel operation cannot in general be performed. The
resampling process with an identity transform will ensure that we have a
representation of the moving image in the grid of the fixed image.

::

    [language=C++]
    TransformType::Pointer identityTransform = TransformType::New();
    identityTransform->SetIdentity();
    resampler->SetTransform( identityTransform );

The complete pipeline structure of the current example is presented in
Figure {fig:ImageRegistration1Pipeline}. The components of the
registration method are depicted as well. Figure
{fig:ImageRegistration1Output} (left) shows the result of resampling the
moving image in order to map it onto the fixed image space. The top and
right borders of the image appear in the gray level selected with the
{SetDefaultPixelValue()} in the ResampleImageFilter. The center image
shows the difference between the fixed image and the original moving
image. That is, the difference before the registration is performed. The
right image shows the difference between the fixed image and the
transformed moving image. That is, after the registration has been
performed. Both difference images have been rescaled in intensity in
order to highlight those pixels where differences exist. Note that the
final registration is still off by a fraction of a pixel, which results
in bands around edges of anatomical structures to appear in the
difference image. A perfect registration would have produced a null
difference image.

    |image6| |image7| [Trace of translations and metrics during
    registration] {The sequence of translations and metric values at
    each iteration of the optimizer.} {fig:ImageRegistration1Trace}

It is always useful to keep in mind that registration is essentially an
optimization problem. Figure {fig:ImageRegistration1Trace} helps to
reinforce this notion by showing the trace of translations and values of
the image metric at each iteration of the optimizer. It can be seen from
the top figure that the step length is reduced progressively as the
optimizer gets closer to the metric extrema. The bottom plot clearly
shows how the metric value decreases as the optimization advances. The
log plot helps to highlight the normal oscillations of the optimizer
around the extrema value.

.. [1]
   This is the case of PNG, BMP, JPEG and TIFF among other common file
   formats.

.. |image| image:: BrainProtonDensitySliceBorder20.eps
.. |image1| image:: BrainProtonDensitySliceShifted13x17y.eps
.. |image2| image:: ImageRegistration1Output.eps
.. |image3| image:: ImageRegistration1DifferenceBefore.eps
.. |image4| image:: ImageRegistration1DifferenceAfter.eps
.. |image5| image:: ImageRegistration1Pipeline.eps
.. |image6| image:: ImageRegistration1TraceTranslations.eps
.. |image7| image:: ImageRegistration1TraceMetric.eps
