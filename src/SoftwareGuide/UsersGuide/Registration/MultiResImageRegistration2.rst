The source code for this section can be found in the file
``MultiResImageRegistration2.cxx``.

This example illustrates the use of more complex components of the
registration framework. In particular, it introduces the use of the
{AffineTransform} and the importance of fine-tuning the scale parameters
of the optimizer.

The AffineTransform is a linear transformation that maps lines into
lines. It can be used to represent translations, rotations, anisotropic
scaling, shearing or any combination of them. Details about the affine
transform can be seen in Section {sec:AffineTransform}.

In order to use the AffineTransform class, the following header must be
included.

::

    [language=C++]
    #include "itkAffineTransform.h"

The configuration of the registration method in this example closely
follows the procedure in the previous section. The main changes involve
the construction and initialization of the transform. The instantiation
of the transform type requires only the dimension of the space and the
type used for representing space coordinates.

::

    [language=C++]
    typedef itk::AffineTransform< double, Dimension > TransformType;

The transform is constructed using the standard {New()} method and
assigning it to a SmartPointer.

::

    [language=C++]
    TransformType::Pointer   transform  = TransformType::New();
    registration->SetTransform( transform );

One of the easiest ways of preparing a consistent set of parameters for
the transform is to use the {CenteredTransformInitializer}. Once the
transform is initialized, we can invoke its {GetParameters()} method to
extract the array of parameters. Finally the array is passed to the
registration method using its {SetInitialTransformParameters()} method.

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

    registration->SetInitialTransformParameters( transform->GetParameters() );

The set of parameters in the AffineTransform have different dynamic
ranges. Typically the parameters associated with the matrix have values
around :math:`[-1:1]`, although they are not restricted to this
interval. Parameters associated with translations, on the other hand,
tend to have much higher values, typically in the order of
:math:`10.0` to :math:`100.0`. This difference in dynamic range
negatively affects the performance of gradient descent optimizers. ITK
provides a mechanism to compensate for such differences in values among
the parameters when they are passed to the optimizer. The mechanism
consists of providing an array of scale factors to the optimizer. These
factors re-normalize the gradient components before they are used to
compute the step of the optimizer at the current iteration. In our
particular case, a common choice for the scale parameters is to set to
:math:`1.0` all those associated with the matrix coefficients, that
is, the first :math:`N \times N` factors. Then, we set the remaining
scale factors to a small value. The following code sets up the scale
coefficients.

::

    [language=C++]
    OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() );

    optimizerScales[0] = 1.0;  scale for M11
    optimizerScales[1] = 1.0;  scale for M12
    optimizerScales[2] = 1.0;  scale for M21
    optimizerScales[3] = 1.0;  scale for M22

    optimizerScales[4] = 1.0 / 1e7;  scale for translation on X
    optimizerScales[5] = 1.0 / 1e7;  scale for translation on Y

Here the affine transform is represented by the matrix :math:`\bf{M}`
and the vector :math:`\bf{T}`. The transformation of a point
:math:`\bf{P}` into :math:`\bf{P'}` is expressed as

:math:`\left[
\begin{array}{c}
{P'}_x  \\  {P'}_y  \\  \end{array}
\right]
=
\left[
\begin{array}{cc}
M_{11} & M_{12} \\ M_{21} & M_{22} \\  \end{array}
\right]
\cdot
\left[
\begin{array}{c}
P_x  \\ P_y  \\  \end{array}
\right]
+
\left[
\begin{array}{c}
T_x  \\ T_y  \\  \end{array}
\right]
`

The array of scales is then passed to the optimizer using the
{SetScales()} method.

::

    [language=C++]
    optimizer->SetScales( optimizerScales );

Given that the Mattes Mutual Information metric uses a random iterator
in order to collect the samples from the images, it is usually
convenient to initialize the seed of the random number generator.

::

    [language=C++]
    metric->ReinitializeSeed( 76926294 );

The step length has to be proportional to the expected values of the
parameters in the search space. Since the expected values of the matrix
coefficients are around :math:`1.0`, the initial step of the
optimization should be a small number compared to :math:`1.0`. As a
guideline, it is useful to think of the matrix coefficients as
combinations of :math:`cos(\theta)` and :math:`sin(\theta)`. This
leads to use values close to the expected rotation measured in radians.
For example, a rotation of :math:`1.0` degree is about :math:`0.017`
radians. As in the previous example, the maximum and minimum step length
of the optimizer are set by the {RegistrationInterfaceCommand} when it
is called at the beginning of registration at each multi-resolution
level.

Let’s execute this example using the same multi-modality images as
before. The registration converges after :math:`5` iterations in the
first level, :math:`7` in the second level and :math:`4` in the
third level. The final results when printed as an array of parameters
are

::

    [1.00164, 0.00147688, 0.00168372, 1.0027, 12.6296, 16.4768]

By reordering them as coefficient of matrix :math:`\bf{M}` and vector
:math:`\bf{T}` they can now be seen as

:math:`M =
\left[
\begin{array}{cc}
1.00164 & 0.0014 \\ 0.00168 & 1.0027 \\  \end{array}
\right]
\mbox{ and }
T =
\left[
\begin{array}{c}
12.6296  \\  16.4768  \\  \end{array}
\right]
`

In this form, it is easier to interpret the effect of the transform. The
matrix :math:`\bf{M}` is responsible for scaling, rotation and
shearing while :math:`\bf{T}` is responsible for translations. It can
be seen that the translation values in this case closely match the true
misalignment introduced in the moving image.

It is important to note that once the images are registered at a
sub-pixel level, any further improvement of the registration relies
heavily on the quality of the interpolator. It may then be reasonable to
use a coarse and fast interpolator in the lower resolution levels and
switch to a high-quality but slow interpolator in the final resolution
level.

    |image| |image1| |image2| [Multi-Resolution Registration Input
    Images] {Mapped moving image (left) and composition of fixed and
    moving images before (center) and after (right) multi-resolution
    registration with the AffineTransform class.}
    {fig:MultiResImageRegistration2Output}

The result of resampling the moving image is shown in the left image of
Figure {fig:MultiResImageRegistration2Output}. The center and right
images of the figure present a checkerboard composite of the fixed and
moving images before and after registration.

    |image3| |image4| [Multi-Resolution Registration output plots]
    {Sequence of translations and metric values at each iteration of the
    optimizer for multi-resolution with the AffineTransform class.}
    {fig:MultiResImageRegistration2Trace}

Figure {fig:MultiResImageRegistration2Trace} (left) presents the
sequence of translations followed by the optimizer as it searched the
parameter space. The right side of the same figure shows the sequence of
metric values computed as the optimizer explored the parameter space.

.. |image| image:: MultiResImageRegistration2Output.eps
.. |image1| image:: MultiResImageRegistration2CheckerboardBefore.eps
.. |image2| image:: MultiResImageRegistration2CheckerboardAfter.eps
.. |image3| image:: MultiResImageRegistration2TraceTranslations.eps
.. |image4| image:: MultiResImageRegistration2TraceMetric.eps
