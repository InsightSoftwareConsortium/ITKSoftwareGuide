The source code for this section can be found in the file
``ImageRegistration13.cxx``.

This example illustrates how to do registration with a 2D Rigid
Transform and with MutualInformation metric.

::

    [language=C++]
    #include "itkMattesMutualInformationImageToImageMetric.h"

The CenteredRigid2DTransform applies a rigid transform in 2D space.

::

    [language=C++]
    typedef itk::CenteredRigid2DTransform< double >  TransformType;
    typedef itk::RegularStepGradientDescentOptimizer OptimizerType;

::

    [language=C++]
    typedef itk::MattesMutualInformationImageToImageMetric<
    FixedImageType,
    MovingImageType >    MetricType;

::

    [language=C++]
    TransformType::Pointer      transform     = TransformType::New();
    OptimizerType::Pointer      optimizer     = OptimizerType::New();

The {CenteredRigid2DTransform} is initialized by 5 parameters,
indicating the angle of rotation, the center coordinates and the
translation to be applied after rotation. The initialization is done by
the {CenteredTransformInitializer}. The transform can operate in two
modes, one assumes that the anatomical objects to be registered are
centered in their respective images. Hence the best initial guess for
the registration is the one that superimposes those two centers. This
second approach assumes that the moments of the anatomical objects are
similar for both images and hence the best initial guess for
registration is to superimpose both mass centers. The center of mass is
computed from the moments obtained from the gray level values. Here we
adopt the first approach. The {GeometryOn()} method toggles between the
approaches.

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
    initializer->GeometryOn();
    initializer->InitializeTransform();

The optimizer scales the metrics (the gradient in this case) by the
scales during each iteration. Hence a large value of the center scale
will prevent movement along the center during optimization. Here we
assume that the fixed and moving images are likely to be related by a
translation.

::

    [language=C++]
    typedef OptimizerType::ScalesType       OptimizerScalesType;
    OptimizerScalesType optimizerScales( transform->GetNumberOfParameters() );

    const double translationScale = 1.0 / 128.0;
    const double centerScale      = 1000.0;  prevents it from moving
    during the optimization
    optimizerScales[0] = 1.0;
    optimizerScales[1] = centerScale;
    optimizerScales[2] = centerScale;
    optimizerScales[3] = translationScale;
    optimizerScales[4] = translationScale;

    optimizer->SetScales( optimizerScales );

    optimizer->SetMaximumStepLength( 0.5   );
    optimizer->SetMinimumStepLength( 0.0001 );
    optimizer->SetNumberOfIterations( 400 );

Let’s execute this example over some of the images provided in
{Examples/Data}, for example:

-  {BrainProtonDensitySlice.png}

-  {BrainProtonDensitySliceBorder20.png}

The second image is the result of intentionally shifting the first image
by :math:`20mm` in :math:`X` and :math:`20mm` in :math:`Y`. Both
images have unit-spacing and are shown in Figure
{fig:FixedMovingImageRegistration1}. The example yielded the following
results.

::

    Translation X = 20
    Translation Y = 20

These values match the true misalignment introduced in the moving image.
