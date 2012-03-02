The source code for this section can be found in the file
``ImageRegistration7.cxx``.

This example illustrates the use of the {CenteredSimilarity2DTransform}
class for performing registration in :math:`2D`. The of example code
is for the most part identical to the code presented in Section
{sec:InitializingRegistrationWithMoments}. The main difference is the
use of {CenteredSimilarity2DTransform} here rather than the
{CenteredRigid2DTransform} class.

A similarity transform can be seen as a composition of rotations,
translations and uniform scaling. It preserves angles and map lines into
lines. This transform is implemented in the toolkit as deriving from a
rigid :math:`2D` transform and with a scale parameter added.

When using this transform, attention should be paid to the fact that
scaling and translations are not independent. In the same way that
rotations can locally be seen as translations, scaling also result in
local displacements. Scaling is performed in general with respect to the
origin of coordinates. However, we already saw how ambiguous that could
be in the case of rotations. For this reason, this transform also allows
users to setup a specific center. This center is use both for rotation
and scaling.

In addition to the headers included in previous examples, here the
following header must be included.

::

    [language=C++]
    #include "itkCenteredSimilarity2DTransform.h"

The Transform class is instantiated using the code below. The only
template parameter of this class is the representation type of the space
coordinates.

::

    [language=C++]
    typedef itk::CenteredSimilarity2DTransform< double > TransformType;

The transform object is constructed below and passed to the registration
method.

::

    [language=C++]
    TransformType::Pointer  transform = TransformType::New();
    registration->SetTransform( transform );

In this example, we again use the helper class
{CenteredTransformInitializer} to compute a reasonable value for the
initial center of rotation and the translation.

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

The remaining parameters of the transform are initialized below.

::

    [language=C++]
    transform->SetScale( initialScale );
    transform->SetAngle( initialAngle );

We now pass the parameter of the current transform as the initial
parameters to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters( transform->GetParameters() );

Keeping in mind that the scale of units in scaling, rotation and
translation are quite different, we take advantage of the scaling
functionality provided by the optimizers. We know that the first element
of the parameters array corresponds to the scale factor, the second
corresponds to the angle, third and forth are the center of rotation and
fifth and sixth are the remaining translation. We use henceforth small
factors in the scales associated with translations and the rotation
center.

::

    [language=C++]
    typedef OptimizerType::ScalesType       OptimizerScalesType;
    OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() );
    const double translationScale = 1.0 / 100.0;

    optimizerScales[0] = 10.0;
    optimizerScales[1] =  1.0;
    optimizerScales[2] =  translationScale;
    optimizerScales[3] =  translationScale;
    optimizerScales[4] =  translationScale;
    optimizerScales[5] =  translationScale;

    optimizer->SetScales( optimizerScales );

We set also the normal parameters of the optimization method. In this
case we are using A {RegularStepGradientDescentOptimizer}. Below, we
define the optimization parameters like initial step length, minimal
step length and number of iterations. These last two act as stopping
criteria for the optimization.

::

    [language=C++]
    optimizer->SetMaximumStepLength( steplength );
    optimizer->SetMinimumStepLength( 0.0001 );
    optimizer->SetNumberOfIterations( 500 );

Let’s execute this example over some of the images provided in
{Examples/Data}, for example:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceR10X13Y17S12.png}

The second image is the result of intentionally rotating the first image
by :math:`10` degrees, scaling by :math:`1/1.2` and then translating
by :math:`(-13,-17)`. Both images have unit-spacing and are shown in
Figure {fig:FixedMovingImageRegistration7}. The registration takes
:math:`16` iterations and produces:

    ::

        [0.833222, -0.174521, 111.437, 131.741, -12.8272, -12.7862]

That are interpreted as

-  Scale factor = :math:`0.833222`

-  Angle = :math:`0.174521` radians

-  Center = :math:`( 111.437     , 131.741     )` millimeters

-  Translation = :math:`( -12.8272    , -12.7862    )` millimeters

These values approximate the misalignment intentionally introduced into
the moving image. Since :math:`10` degrees is about :math:`0.174532`
radians.

    |image| |image1| [Fixed and Moving image registered with
    CenteredSimilarity2DTransform] {Fixed and Moving image provided as
    input to the registration method using the Similarity2D transform.}
    {fig:FixedMovingImageRegistration7}

    |image2| |image3| |image4| [Output of the
    CenteredSimilarity2DTransform registration] {Resampled moving image
    (left). Differences between fixed and moving images, before (center)
    and after (right) registration with the Similarity2D transform.}
    {fig:ImageRegistration7Outputs}

Figure {fig:ImageRegistration7Outputs} shows the output of the
registration. The right image shows the squared magnitude of pixel
differences between the fixed image and the resampled moving image.

    |image5| |image6| |image7| |image8| [CenteredSimilarity2DTransform
    registration plots] {Plots of the Metric, rotation angle and
    translations during the registration using Similarity2D transform.}
    {fig:ImageRegistration7Plots}

Figure {fig:ImageRegistration7Plots} shows the plots of the main output
parameters of the registration process. The metric values at every
iteration are shown on the top. The angle values are shown in the plot
at left while the translation components of the registration are
presented in the plot at right.

.. |image| image:: BrainProtonDensitySliceBorder20.eps
.. |image1| image:: BrainProtonDensitySliceR10X13Y17S12.eps
.. |image2| image:: ImageRegistration7Output.eps
.. |image3| image:: ImageRegistration7DifferenceBefore.eps
.. |image4| image:: ImageRegistration7DifferenceAfter.eps
.. |image5| image:: ImageRegistration7TraceMetric.eps
.. |image6| image:: ImageRegistration7TraceAngle.eps
.. |image7| image:: ImageRegistration7TraceScale.eps
.. |image8| image:: ImageRegistration7TraceTranslations.eps
