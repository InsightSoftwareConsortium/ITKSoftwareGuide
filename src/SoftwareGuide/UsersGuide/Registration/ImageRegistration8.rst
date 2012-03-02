The source code for this section can be found in the file
``ImageRegistration8.cxx``.

This example illustrates the use of the {VersorRigid3DTransform} class
for performing registration of two :math:`3D` images. The example code
is for the most part identical to the code presented in
Section {sec:RigidRegistrationIn2D}. The major difference is that this
example is done in :math:`3D`. The class
{CenteredTransformInitializer} is used to initialize the center and
translation of the transform. The case of rigid registration of 3D
images is probably one of the most commonly found cases of image
registration.

The following are the most relevant headers of this example.

::

    [language=C++]
    #include "itkVersorRigid3DTransform.h"
    #include "itkCenteredTransformInitializer.h"

The parameter space of the {VersorRigid3DTransform} is not a vector
space, due to the fact that addition is not a closed operation in the
space of versor components. This precludes the use of standard gradient
descent algorithms for optimizing the parameter space of this transform.
A special optimizer should be used in this registration configuration.
The optimizer designed for this transform is the
{VersorRigid3DTransformOptimizer}. This optimizer uses Versor
composition for updating the first three components of the parameters
array, and Vector addition for updating the last three components of the
parameters array .

::

    [language=C++]
    #include "itkVersorRigid3DTransformOptimizer.h"

The Transform class is instantiated using the code below. The only
template parameter to this class is the representation type of the space
coordinates.

::

    [language=C++]
    typedef itk::VersorRigid3DTransform< double > TransformType;

The transform object is constructed below and passed to the registration
method.

::

    [language=C++]
    TransformType::Pointer  transform = TransformType::New();
    registration->SetTransform( transform );

The input images are taken from readers. It is not necessary here to
explicitly call {Update()} on the readers since the
{CenteredTransformInitializer} will do it as part of its computations.
The following code instantiates the type of the initializer. This class
is templated over the fixed and moving image type as well as the
transform type. An initializer is then constructed by calling the
{New()} method and assigning the result to a smart pointer.

::

    [language=C++]
    typedef itk::CenteredTransformInitializer< TransformType,
    FixedImageType,
    MovingImageType
    >  TransformInitializerType;
    TransformInitializerType::Pointer initializer =
    TransformInitializerType::New();

The initializer is now connected to the transform and to the fixed and
moving images.

::

    [language=C++]
    initializer->SetTransform(   transform );
    initializer->SetFixedImage(  fixedImageReader->GetOutput() );
    initializer->SetMovingImage( movingImageReader->GetOutput() );

The use of the geometrical centers is selected by calling {GeometryOn()}
while the use of center of mass is selected by calling {MomentsOn()}.
Below we select the center of mass mode.

::

    [language=C++]
    initializer->MomentsOn();

Finally, the computation of the center and translation is triggered by
the {InitializeTransform()} method. The resulting values will be passed
directly to the transform.

::

    [language=C++]
    initializer->InitializeTransform();

The rotation part of the transform is initialized using a {Versor} which
is simply a unit quaternion. The {VersorType} can be obtained from the
transform traits. The versor itself defines the type of the vector used
to indicate the rotation axis. This trait can be extracted as
{VectorType}. The following lines create a versor object and initialize
its parameters by passing a rotation axis and an angle.

::

    [language=C++]
    typedef TransformType::VersorType  VersorType;
    typedef VersorType::VectorType     VectorType;
    VersorType     rotation;
    VectorType     axis;
    axis[0] = 0.0;
    axis[1] = 0.0;
    axis[2] = 1.0;
    const double angle = 0;
    rotation.Set(  axis, angle  );
    transform->SetRotation( rotation );

We now pass the parameters of the current transform as the initial
parameters to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters( transform->GetParameters() );

Let’s execute this example over some of the images available in the ftp
site

ftp:public.kitware.com/pub/itk/Data/BrainWeb

Note that the images in the ftp site are compressed in {.tgz} files. You
should download these files an uncompress them in your local system.
After decompressing and extracting the files you could take a pair of
volumes, for example the pair:

-  {brainweb1e1a10f20.mha}

-  {brainweb1e1a10f20Rot10Tx15.mha}

The second image is the result of intentionally rotating the first image
by :math:`10` degrees around the origin and shifting it :math:`15mm`
in :math:`X`. The registration takes :math:`24` iterations and
produces:

    ::

        [-6.03744e-05, 5.91487e-06, -0.0871932, 2.64659, -17.4637, -0.00232496]

That are interpreted as

-  Versor = :math:`(-6.03744e-05, 5.91487e-06, -0.0871932)`

-  Translation = :math:`(2.64659,  -17.4637,  -0.00232496)`
   millimeters

This Versor is equivalent to a rotation of :math:`9.98` degrees around
the :math:`Z` axis.

Note that the reported translation is not the translation of
:math:`(15.0,0.0,0.0)` that we may be naively expecting. The reason is
that the {VersorRigid3DTransform} is applying the rotation around the
center found by the {CenteredTransformInitializer} and then adding the
translation vector shown above.

It is more illustrative in this case to take a look at the actual
rotation matrix and offset resulting form the :math:`6` parameters.

::

    [language=C++]
    transform->SetParameters( finalParameters );
    TransformType::MatrixType matrix = transform->GetRotationMatrix();
    TransformType::OffsetType offset = transform->GetOffset();
    std::cout << "Matrix = " << std::endl << matrix << std::endl;
    std::cout << "Offset = " << std::endl << offset << std::endl;

The output of this print statements is

    ::

        Matrix =
        0.984795 0.173722 2.23132e-05
        -0.173722 0.984795 0.000119257
        -1.25621e-06 -0.00012132 1

        Offset =
        [-15.0105, -0.00672343, 0.0110854]

From the rotation matrix it is possible to deduce that the rotation is
happening in the X,Y plane and that the angle is on the order of
:math:`\arcsin{(0.173722)}` which is very close to 10 degrees, as we
expected.

    |image| |image1| [CenteredTransformInitializer input images] {Fixed
    and moving image provided as input to the registration method using
    CenteredTransformInitializer.} {fig:FixedMovingImageRegistration8}

    |image2| |image3| |image4| [CenteredTransformInitializer output
    images] {Resampled moving image (left). Differences between fixed
    and moving images, before (center) and after (right) registration
    with the CenteredTransformInitializer.}
    {fig:ImageRegistration8Outputs}

Figure {fig:ImageRegistration8Outputs} shows the output of the
registration. The center image in this figure shows the differences
between the fixed image and the resampled moving image before the
registration. The image on the right side presents the difference
between the fixed image and the resampled moving image after the
registration has been performed. Note that these images are individual
slices extracted from the actual volumes. For details, look at the
source code of this example, where the ExtractImageFilter is used to
extract a slice from the the center of each one of the volumes. One of
the main purposes of this example is to illustrate that the toolkit can
perform registration on images of any dimension. The only limitations
are, as usual, the amount of memory available for the images and the
amount of computation time that it will take to complete the
optimization process.

    |image5| |image6| |image7| [CenteredTransformInitializer output
    plots] {Plots of the metric, rotation angle, center of rotation and
    translations during the registration using
    CenteredTransformInitializer.} {fig:ImageRegistration8Plots}

Figure {fig:ImageRegistration8Plots} shows the plots of the main output
parameters of the registration process. The metric values at every
iteration. The Z component of the versor is plotted as an indication of
how the rotation progress. The X,Y translation components of the
registration are plotted at every iteration too.

Shell and Gnuplot scripts for generating the diagrams in
Figure {fig:ImageRegistration8Plots} are available in the directory

{InsightDocuments/SoftwareGuide/Art}

You are strongly encouraged to run the example code, since only in this
way you can gain a first hand experience with the behavior of the
registration process. Once again, this is a simple reflection of the
philosophy that we put forward in this book:

*If you can not replicate it, then it does not exist!*.

We have seen enough published papers with pretty pictures, presenting
results that in practice are impossible to replicate. That is vanity,
not science.

.. |image| image:: BrainProtonDensitySliceBorder20.eps
.. |image1| image:: BrainProtonDensitySliceR10X13Y17.eps
.. |image2| image:: ImageRegistration8Output.eps
.. |image3| image:: ImageRegistration8DifferenceBefore.eps
.. |image4| image:: ImageRegistration8DifferenceAfter.eps
.. |image5| image:: ImageRegistration8TraceMetric.eps
.. |image6| image:: ImageRegistration8TraceAngle.eps
.. |image7| image:: ImageRegistration8TraceTranslations.eps
