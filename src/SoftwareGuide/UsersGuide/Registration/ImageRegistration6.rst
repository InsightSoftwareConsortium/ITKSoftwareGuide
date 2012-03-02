The source code for this section can be found in the file
``ImageRegistration6.cxx``.

This example illustrates the use of the {CenteredRigid2DTransform} for
performing registration. The example code is for the most part identical
to the one presented in Section {sec:RigidRegistrationIn2D}. Even though
this current example is done in :math:`2D`, the class
{CenteredTransformInitializer} is quite generic and could be used in
other dimensions. The objective of the initializer class is to simplify
the computation of the center of rotation and the translation required
to initialize certain transforms such as the CenteredRigid2DTransform.
The initializer accepts two images and a transform as inputs. The images
are considered to be the fixed and moving images of the registration
problem, while the transform is the one used to register the images.

The CenteredRigid2DTransform supports two modes of operation. In the
first mode, the centers of the images are computed as space coordinates
using the image origin, size and spacing. The center of the fixed image
is assigned as the rotational center of the transform while the vector
going from the fixed image center to the moving image center is passed
as the initial translation of the transform. In the second mode, the
image centers are not computed geometrically but by using the moments of
the intensity gray levels. The center of mass of each image is computed
using the helper class {ImageMomentsCalculator}. The center of mass of
the fixed image is passed as the rotational center of the transform
while the vector going from the fixed image center of mass to the moving
image center of mass is passed as the initial translation of the
transform. This second mode of operation is quite convenient when the
anatomical structures of interest are not centered in the image. In such
cases the alignment of the centers of mass provides a better rough
initial registration than the simple use of the geometrical centers. The
validity of the initial registration should be questioned when the two
images are acquired in different imaging modalities. In those cases, the
center of mass of intensities in one modality does not necessarily
matches the center of mass of intensities in the other imaging modality.

The following are the most relevant headers in this example.

::

    [language=C++]
    #include "itkCenteredRigid2DTransform.h"
    #include "itkCenteredTransformInitializer.h"

The transform type is instantiated using the code below. The only
template parameter of this class is the representation type of the space
coordinates.

::

    [language=C++]
    typedef itk::CenteredRigid2DTransform< double > TransformType;

The transform object is constructed below and passed to the registration
method.

::

    [language=C++]
    TransformType::Pointer  transform = TransformType::New();
    registration->SetTransform( transform );

The input images are taken from readers. It is not necessary to
explicitly call {Update()} on the readers since the
CenteredTransformInitializer class will do it as part of its
initialization. The following code instantiates the initializer. This
class is templated over the fixed and moving image type as well as the
transform type. An initializer is then constructed by calling the
{New()} method and assigning the result to a {SmartPointer}.

::

    [language=C++]
    typedef itk::CenteredTransformInitializer<
    TransformType,
    FixedImageType,
    MovingImageType >  TransformInitializerType;

    TransformInitializerType::Pointer initializer = TransformInitializerType::New();

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

The remaining parameters of the transform are initialized as before.

::

    [language=C++]
    transform->SetAngle( 0.0 );

Now the parameters of the current transform are passed as the initial
parameters to be used when the registration process starts.

::

    [language=C++]
    registration->SetInitialTransformParameters( transform->GetParameters() );

Let’s execute this example over some of the images provided in
{Examples/Data}, for example:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceR10X13Y17.png}

The second image is the result of intentionally rotating the first image
by :math:`10` degrees and shifting it :math:`13mm` in :math:`X`
and :math:`17mm` in :math:`Y`. Both images have unit-spacing and are
shown in Figure {fig:FixedMovingImageRegistration5}. The registration
takes :math:`22` iterations and produces:

    ::

        [0.174475, 111.177, 131.572, 12.4566, 16.0729]

These parameters are interpreted as

-  Angle = :math:`0.174475` radians

-  Center = :math:`( 111.177    , 131.572      )` millimeters

-  Translation = :math:`(  12.4566   ,  16.0729     )` millimeters

Note that the reported translation is not the translation of
:math:`(13,17)` that might be expected. The reason is that the five
parameters of the CenteredRigid2DTransform are redundant. The actual
movement in space is described by only :math:`3` parameters. This
means that there are infinite combinations of rotation center and
translations that will represent the same actual movement in space. It
is more illustrative in this case to take a look at the actual rotation
matrix and offset resulting form the five parameters.

::

    [language=C++]
    transform->SetParameters( finalParameters );

    TransformType::MatrixType matrix = transform->GetRotationMatrix();
    TransformType::OffsetType offset = transform->GetOffset();

    std::cout << "Matrix = " << std::endl << matrix << std::endl;
    std::cout << "Offset = " << std::endl << offset << std::endl;

Which produces the following output.

::

    Matrix =
    0.984818 -0.173591
    0.173591 0.984818

    Offset =
    [36.9843, -1.22896]

This output illustrates how counter-intuitive the mix of center of
rotation and translations can be. Figure
{fig:TranslationAndRotationCenter} will clarify this situation. The
figure shows the original image on the left. A rotation of
:math:`10^{\circ}` around the center of the image is shown in the
middle. The same rotation performed around the origin of coordinates is
shown on the right. It can be seen here that changing the center of
rotation introduces additional translations.

Let’s analyze what happens to the center of the image that we just
registered. Under the point of view of rotating :math:`10^{\circ}`
around the center and then applying a translation of
:math:`(13mm,17mm)`. The image has a size of
:math:`(221 \times 257)` pixels and unit spacing. Hence its center has
coordinates :math:`(110.5,128.5)`. Since the rotation is done around
this point, the center behaves as the fixed point of the transformation
and remains unchanged. Then with the :math:`(13mm,17mm)` translation
it is mapped to :math:`(123.5,145.5)` which becomes its final
position.

The matrix and offset that we obtained at the end of the registration
indicate that this should be equivalent to a rotation of
:math:`10^{\circ}` around the origin, followed by a translations of
:math:`(36.98,-1.22)`. Let’s compute this in detail. First the
rotation of the image center by :math:`10^{\circ}` around the origin
will move the point to :math:`(86.52,147.97)`. Now, applying a
translation of :math:`(36.98,-1.22)` maps this point to
:math:`(123.5,146.75)`. Which is close to the result of our previous
computation.

It is unlikely that we could have chosen such translations as the
initial guess, since we tend to think about image in a coordinate system
whose origin is in the center of the image.

    |image| [Effect of changing the center of rotation] {Effect of
    changing the center of rotation.} {fig:TranslationAndRotationCenter}

You may be wondering why the actual movement is represented by three
parameters when we take the trouble of using five. In particular, why
use a :math:`5`-dimensional optimizer space instead of a
:math:`3`-dimensional one. The answer is that by using five parameters
we have a much simpler way of initializing the transform with the
rotation matrix and offset. Using the minimum three parameters it is not
obvious how to determine what the initial rotation and translations
should be.

    |image1| |image2| [CenteredTransformInitializer input images] {Fixed
    and moving images provided as input to the registration method using
    CenteredTransformInitializer.} {fig:FixedMovingImageRegistration6}

    |image3| |image4| |image5| [CenteredTransformInitializer output
    images] {Resampled moving image (left). Differences between fixed
    and moving images, before registration (center) and after
    registration (right) with the CenteredTransformInitializer.}
    {fig:ImageRegistration6Outputs}

Figure {fig:ImageRegistration6Outputs} shows the output of the
registration. The image on the right of this figure shows the
differences between the fixed image and the resampled moving image after
registration.

    |image6| |image7| |image8| [CenteredTransformInitializer output
    plots] {Plots of the Metric, rotation angle, center of rotation and
    translations during the registration using
    CenteredTransformInitializer.} {fig:ImageRegistration6Plots}

Figure {fig:ImageRegistration6Plots} plots the output parameters of the
registration process. It includes, the metric values at every iteration,
the angle values at every iteration, and the values of the translation
components as the registration progress. Note that this is the
complementary translation as used in the transform, not the actual total
translation that is used in the transform offset. We could modify the
observer to print the total offset instead of printing the array of
parameters. Let’s call that an exercise for the reader!

.. |image| image:: TranslationAndRotationCenter.eps
.. |image1| image:: BrainProtonDensitySliceBorder20.eps
.. |image2| image:: BrainProtonDensitySliceR10X13Y17.eps
.. |image3| image:: ImageRegistration6Output.eps
.. |image4| image:: ImageRegistration6DifferenceBefore.eps
.. |image5| image:: ImageRegistration6DifferenceAfter.eps
.. |image6| image:: ImageRegistration6TraceMetric.eps
.. |image7| image:: ImageRegistration6TraceAngle.eps
.. |image8| image:: ImageRegistration6TraceTranslations.eps
