The source code for this section can be found in the file
``ImageRegistration5.cxx``.

This example illustrates the use of the {CenteredRigid2DTransform} for
performing rigid registration in :math:`2D`. The example code is for
the most part identical to that presented in Section
{sec:IntroductionImageRegistration}. The main difference is the use of
the CenteredRigid2DTransform here instead of the {TranslationTransform}.

In addition to the headers included in previous examples, the following
header must also be included.

::

    [language=C++]
    #include "itkCenteredRigid2DTransform.h"

The transform type is instantiated using the code below. The only
template parameter for this class is the representation type of the
space coordinates.

::

    [language=C++]
    typedef itk::CenteredRigid2DTransform< double > TransformType;

The transform object is constructed below and passed to the registration
method.

::

    [language=C++]
    TransformType::Pointer  transform = TransformType::New();
    registration->SetTransform( transform );

In this example, the input images are taken from readers. The code below
updates the readers in order to ensure that the image parameters (size,
origin and spacing) are valid when used to initialize the transform. We
intend to use the center of the fixed image as the rotation center and
then use the vector between the fixed image center and the moving image
center as the initial translation to be applied after the rotation.

::

    [language=C++]
    fixedImageReader->Update();
    movingImageReader->Update();

The center of rotation is computed using the origin, size and spacing of
the fixed image.

::

    [language=C++]
    FixedImageType::Pointer fixedImage = fixedImageReader->GetOutput();

    const SpacingType fixedSpacing = fixedImage->GetSpacing();
    const OriginType  fixedOrigin  = fixedImage->GetOrigin();
    const RegionType  fixedRegion  = fixedImage->GetLargestPossibleRegion();
    const SizeType    fixedSize    = fixedRegion.GetSize();

    TransformType::InputPointType centerFixed;

    centerFixed[0] = fixedOrigin[0] + fixedSpacing[0] * fixedSize[0] / 2.0;
    centerFixed[1] = fixedOrigin[1] + fixedSpacing[1] * fixedSize[1] / 2.0;

The center of the moving image is computed in a similar way.

::

    [language=C++]
    MovingImageType::Pointer movingImage = movingImageReader->GetOutput();

    const SpacingType movingSpacing = movingImage->GetSpacing();
    const OriginType  movingOrigin  = movingImage->GetOrigin();
    const RegionType  movingRegion  = movingImage->GetLargestPossibleRegion();
    const SizeType    movingSize    = movingRegion.GetSize();

    TransformType::InputPointType centerMoving;

    centerMoving[0] = movingOrigin[0] + movingSpacing[0] * movingSize[0] / 2.0;
    centerMoving[1] = movingOrigin[1] + movingSpacing[1] * movingSize[1] / 2.0;

The most straightforward method of initializing the transform parameters
is to configure the transform and then get its parameters with the
method {GetParameters()}. Here we initialize the transform by passing
the center of the fixed image as the rotation center with the
{SetCenter()} method. Then the translation is set as the vector relating
the center of the moving image to the center of the fixed image. This
last vector is passed with the method {SetTranslation()}.

::

    [language=C++]
    transform->SetCenter( centerFixed );
    transform->SetTranslation( centerMoving - centerFixed );

Let’s finally initialize the rotation with a zero angle.

::

    [language=C++]
    transform->SetAngle( 0.0 );

Now we pass the current transform’s parameters as the initial parameters
to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters( transform->GetParameters() );

Keeping in mind that the scale of units in rotation and translation is
quite different, we take advantage of the scaling functionality provided
by the optimizers. We know that the first element of the parameters
array corresponds to the angle that is measured in radians, while the
other parameters correspond to translations that are measured in
millimeters. For this reason we use small factors in the scales
associated with translations and the coordinates of the rotation center
.

::

    [language=C++]
    typedef OptimizerType::ScalesType       OptimizerScalesType;
    OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() );
    const double translationScale = 1.0 / 1000.0;

    optimizerScales[0] = 1.0;
    optimizerScales[1] = translationScale;
    optimizerScales[2] = translationScale;
    optimizerScales[3] = translationScale;
    optimizerScales[4] = translationScale;

    optimizer->SetScales( optimizerScales );

Next we set the normal parameters of the optimization method. In this
case we are using an {RegularStepGradientDescentOptimizer}. Below, we
define the optimization parameters like the relaxation factor, initial
step length, minimal step length and number of iterations. These last
two act as stopping criteria for the optimization.

::

    [language=C++]
    double initialStepLength = 0.1;

::

    [language=C++]
    optimizer->SetRelaxationFactor( 0.6 );
    optimizer->SetMaximumStepLength( initialStepLength );
    optimizer->SetMinimumStepLength( 0.001 );
    optimizer->SetNumberOfIterations( 200 );

Let’s execute this example over two of the images provided in
{Examples/Data}:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceRotated10.png}

The second image is the result of intentionally rotating the first image
by :math:`10` degrees around the geometrical center of the image. Both
images have unit-spacing and are shown in Figure
{fig:FixedMovingImageRegistration5}. The registration takes :math:`20`
iterations and produces the results:

    ::

        [0.177458, 110.489, 128.488, 0.0106296, 0.00194103]

These results are interpreted as

-  Angle = :math:`0.177458` radians

-  Center = :math:`( 110.489    , 128.488      )` millimeters

-  Translation = :math:`(   0.0106296,   0.00194103 )` millimeters

As expected, these values match the misalignment intentionally
introduced into the moving image quite well, since :math:`10` degrees
is about :math:`0.174532` radians.

    |image| |image1| [Rigid2D Registration input images] {Fixed and
    moving images are provided as input to the registration method using
    the CenteredRigid2D transform.} {fig:FixedMovingImageRegistration5}

    |image2| |image3| |image4| [Rigid2D Registration output images]
    {Resampled moving image (left). Differences between the fixed and
    moving images, before (center) and after (right) registration using
    the CenteredRigid2D transform.} {fig:ImageRegistration5Outputs}

Figure {fig:ImageRegistration5Outputs} shows from left to right the
resampled moving image after registration, the difference between fixed
and moving images before registration, and the difference between fixed
and resampled moving image after registration. It can be seen from the
last difference image that the rotational component has been solved but
that a small centering misalignment persists.

    |image5| |image6| |image7| [Rigid2D Registration output plots]
    {Metric values, rotation angle and translations during registration
    with the CenteredRigid2D transform.} {fig:ImageRegistration5Plots}

Figure {fig:ImageRegistration5Plots} shows plots of the main output
parameters produced from the registration process. This includes, the
metric values at every iteration, the angle values at every iteration,
and the translation components of the transform as the registration
progress.

Let’s now consider the case in which rotations and translations are
present in the initial registration, as in the following pair of images:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceR10X13Y17.png}

The second image is the result of intentionally rotating the first image
by :math:`10` degrees and then translating it :math:`13mm` in
:math:`X` and :math:`17mm` in :math:`Y`. Both images have
unit-spacing and are shown in Figure
{fig:FixedMovingImageRegistration5b}. In order to accelerate convergence
it is convenient to use a larger step length as shown here.

{optimizer->SetMaximumStepLength( 1.0 );}

The registration now takes :math:`46` iterations and produces the
following results:

    ::

        [0.174454, 110.361, 128.647, 12.977, 15.9761]

These parameters are interpreted as

-  Angle = :math:`0.174454` radians

-  Center = :math:`( 110.361     , 128.647      )` millimeters

-  Translation = :math:`(  12.977     ,  15.9761     )` millimeters

These values approximately match the initial misalignment intentionally
introduced into the moving image, since :math:`10` degrees is about
:math:`0.174532` radians. The horizontal translation is well resolved
while the vertical translation ends up being off by about one
millimeter.

    |image8| |image9| [Rigid2D Registration input images] {Fixed and
    moving images provided as input to the registration method using the
    CenteredRigid2D transform.} {fig:FixedMovingImageRegistration5b}

    |image10| |image11| |image12| [Rigid2D Registration output images]
    {Resampled moving image (left). Differences between the fixed and
    moving images, before (center) and after (right) registration with
    the CenteredRigid2D transform.} {fig:ImageRegistration5Outputs2}

Figure {fig:ImageRegistration5Outputs2} shows the output of the
registration. The rightmost image of this figure shows the difference
between the fixed image and the resampled moving image after
registration.

    |image13| |image14| |image15| [Rigid2D Registration output plots]
    {Metric values, rotation angle and translations during the
    registration using the CenteredRigid2D transform on an image with
    rotation and translation mis-registration.}
    {fig:ImageRegistration5Plots2}

Figure {fig:ImageRegistration5Plots2} shows plots of the main output
registration parameters when the rotation and translations are combined.
These results include, the metric values at every iteration, the angle
values at every iteration, and the translation components of the
registration as the registration converges. It can be seen from the
smoothness of these plots that a larger step length could have been
supported easily by the optimizer. You may want to modify this value in
order to get a better idea of how to tune the parameters.

.. |image| image:: BrainProtonDensitySliceBorder20.eps
.. |image1| image:: BrainProtonDensitySliceRotated10.eps
.. |image2| image:: ImageRegistration5Output.eps
.. |image3| image:: ImageRegistration5DifferenceBefore.eps
.. |image4| image:: ImageRegistration5DifferenceAfter.eps
.. |image5| image:: ImageRegistration5TraceMetric1.eps
.. |image6| image:: ImageRegistration5TraceAngle1.eps
.. |image7| image:: ImageRegistration5TraceTranslations1.eps
.. |image8| image:: BrainProtonDensitySliceBorder20.eps
.. |image9| image:: BrainProtonDensitySliceR10X13Y17.eps
.. |image10| image:: ImageRegistration5Output2.eps
.. |image11| image:: ImageRegistration5DifferenceBefore2.eps
.. |image12| image:: ImageRegistration5DifferenceAfter2.eps
.. |image13| image:: ImageRegistration5TraceMetric2.eps
.. |image14| image:: ImageRegistration5TraceAngle2.eps
.. |image15| image:: ImageRegistration5TraceTranslations2.eps
