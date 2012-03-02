The source code for this section can be found in the file
``ImageRegistration9.cxx``.

This example illustrates the use of the {AffineTransform} for performing
registration in :math:`2D`. The example code is, for the most part,
identical to that in {sec:InitializingRegistrationWithMoments}. The main
difference is the use of the AffineTransform here instead of the
{CenteredRigid2DTransform}. We will focus on the most relevant changes
in the current code and skip the basic elements already explained in
previous examples.

Let’s start by including the header file of the AffineTransform.

::

    [language=C++]
    #include "itkAffineTransform.h"

We define then the types of the images to be registered.

::

    [language=C++]
    const    unsigned int    Dimension = 2;
    typedef  float           PixelType;

    typedef itk::Image< PixelType, Dimension >  FixedImageType;
    typedef itk::Image< PixelType, Dimension >  MovingImageType;

The transform type is instantiated using the code below. The template
parameters of this class are the representation type of the space
coordinates and the space dimension.

::

    [language=C++]
    typedef itk::AffineTransform<
    double,
    Dimension  >     TransformType;

The transform object is constructed below and passed to the registration
method.

::

    [language=C++]
    TransformType::Pointer  transform = TransformType::New();
    registration->SetTransform( transform );

In this example, we again use the {CenteredTransformInitializer} helper
class in order to compute a reasonable value for the initial center of
rotation and the translation. The initializer is set to use the center
of mass of each image as the initial correspondence correction.

::

    [language=C++]
    typedef itk::CenteredTransformInitializer<
    TransformType,
    FixedImageType,
    MovingImageType >  TransformInitializerType;
    TransformInitializerType::Pointer initializer = TransformInitializerType::New();
    initializer->SetTransform(   transform );
    initializer->SetFixedImage(  fixedImageReader->GetOutput() );
    initializer->SetMovingImage( movingImageReader->GetOutput() );
    initializer->MomentsOn();
    initializer->InitializeTransform();

Now we pass the parameters of the current transform as the initial
parameters to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters(
    transform->GetParameters() );

Keeping in mind that the scale of units in scaling, rotation and
translation are quite different, we take advantage of the scaling
functionality provided by the optimizers. We know that the first
:math:`N
\times N` elements of the parameters array correspond to the rotation
matrix factor, and the last :math:`N` are the components of the
translation to be applied after multiplication with the matrix is
performed.

::

    [language=C++]
    typedef OptimizerType::ScalesType       OptimizerScalesType;
    OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() );

    optimizerScales[0] =  1.0;
    optimizerScales[1] =  1.0;
    optimizerScales[2] =  1.0;
    optimizerScales[3] =  1.0;
    optimizerScales[4] =  translationScale;
    optimizerScales[5] =  translationScale;

    optimizer->SetScales( optimizerScales );

We also set the usual parameters of the optimization method. In this
case we are using an {RegularStepGradientDescentOptimizer}. Below, we
define the optimization parameters like initial step length, minimal
step length and number of iterations. These last two act as stopping
criteria for the optimization.

::

    [language=C++]
    optimizer->SetMaximumStepLength( steplength );
    optimizer->SetMinimumStepLength( 0.0001 );
    optimizer->SetNumberOfIterations( maxNumberOfIterations );

We also set the optimizer to do minimization by calling the
{MinimizeOn()} method.

::

    [language=C++]
    optimizer->MinimizeOn();

Finally we trigger the execution of the registration method by calling
the {Update()} method. The call is placed in a {try/catch} block in case
any exceptions are thrown.

::

    [language=C++]
    try
    {
    registration->Update();
    std::cout << "Optimizer stop condition: "
    << registration->GetOptimizer()->GetStopConditionDescription()
    << std::endl;
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

Once the optimization converges, we recover the parameters from the
registration method. This is done with the
{GetLastTransformParameters()} method. We can also recover the final
value of the metric with the {GetValue()} method and the final number of
iterations with the {GetCurrentIteration()} method.

::

    [language=C++]
    OptimizerType::ParametersType finalParameters =
    registration->GetLastTransformParameters();

    const double finalRotationCenterX = transform->GetCenter()[0];
    const double finalRotationCenterY = transform->GetCenter()[1];
    const double finalTranslationX    = finalParameters[4];
    const double finalTranslationY    = finalParameters[5];

    const unsigned int numberOfIterations = optimizer->GetCurrentIteration();
    const double bestValue = optimizer->GetValue();

Let’s execute this example over two of the images provided in
{Examples/Data}:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceR10X13Y17.png}

The second image is the result of intentionally rotating the first image
by :math:`10` degrees and then translating by :math:`(-13,-17)`.
Both images have unit-spacing and are shown in Figure
{fig:FixedMovingImageRegistration9}. We execute the code using the
following parameters: step length=1.0, translation scale= 0.0001 and
maximum number of iterations = 300. With these images and parameters the
registration takes :math:`98` iterations and produces

    ::

        96 58.09 [0.986481, -0.169104, 0.166411, 0.986174, 12.461, 16.0754]

These results are interpreted as

-  Iterations = 98

-  Final Metric = 58.09

-  Center = :math:`( 111.204,   131.6   )` millimeters

-  Translation = :math:`(   12.461,  16.0754 )` millimeters

-  Affine scales = :math:`(1.00185, .999137)`

The second component of the matrix values is usually associated with
:math:`\sin{\theta}`. We obtain the rotation through SVD of the affine
matrix. The value is :math:`9.6526` degrees, which is approximately
the intentional misalignment of :math:`10.0` degrees.

    |image| |image1| [AffineTransform registration] {Fixed and moving
    images provided as input to the registration method using the
    AffineTransform.} {fig:FixedMovingImageRegistration9}

    |image2| |image3| |image4| [AffineTransform output images] {The
    resampled moving image (left), and the difference between the fixed
    and moving images before (center) and after (right) registration
    with the AffineTransform transform.} {fig:ImageRegistration9Outputs}

Figure {fig:ImageRegistration9Outputs} shows the output of the
registration. The right most image of this figure shows the squared
magnitude difference between the fixed image and the resampled moving
image.

    |image5| |image6| |image7| [AffineTransform output plots] {Metric
    values, rotation angle and translations during the registration
    using the AffineTransform transform.} {fig:ImageRegistration9Plots}

Figure {fig:ImageRegistration9Plots} shows the plots of the main output
parameters of the registration process. The metric values at every
iteration are shown on the top plot. The angle values are shown on the
bottom left plot, while the translation components of the registration
are presented on the bottom right plot. Note that the final total offset
of the transform is to be computed as a combination of the shift due
rotation plus the explicit translation set on the transform.

.. |image| image:: BrainProtonDensitySliceBorder20.eps
.. |image1| image:: BrainProtonDensitySliceR10X13Y17.eps
.. |image2| image:: ImageRegistration9Output.eps
.. |image3| image:: ImageRegistration9DifferenceBefore.eps
.. |image4| image:: ImageRegistration9DifferenceAfter.eps
.. |image5| image:: ImageRegistration9TraceMetric.eps
.. |image6| image:: ImageRegistration9TraceAngle.eps
.. |image7| image:: ImageRegistration9TraceTranslations.eps
