The source code for this section can be found in the file
``ResampleImageFilter3.cxx``.

Previous examples have described the basic principles behind the
{ResampleImageFilter}. Now it’s time to have some fun with it.

Figure {fig:ResampleImageFilterTransformComposition6} illustrates the
general case of the resampling process. The origin and spacing of the
output image has been selected to be different from those of the input
image. The circles represent the *center* of pixels. They are inscribed
in a rectangle representing the *coverage* of this pixel. The spacing
specifies the distance between pixel centers along every dimension.

The transform applied is a rotation of :math:`30` degrees. It is
important to note here that the transform supplied to the
{ResampleImageFilter} is a *clockwise* rotation. This transform rotates
the *coordinate system* of the output image 30 degrees clockwise. When
the two images are relocated in a common coordinate system—as in Figure
{fig:ResampleImageFilterTransformComposition6}—the result is that the
frame of the output image appears rotated 30 degrees *clockwise*. If the
output image is seen with its coordinate system vertically aligned—as in
Figure {fig:ResampleImageFilterOutput9}—the image content appears
rotated 30 degrees *counter-clockwise*. Before continuing to read this
section, you may want to meditate a bit on this fact while enjoying a
cup of (Columbian) coffee.

    |image| |image1| [Effect of a rotation on the resampling filter.]
    {Effect of a rotation on the resampling filter. Input image at left,
    output image at right.} {fig:ResampleImageFilterOutput9}

    |image2| [Input and output image placed in a common reference
    system] {Input and output image placed in a common reference
    system.} {fig:ResampleImageFilterTransformComposition6}

The following code implements the conditions illustrated in Figure
{fig:ResampleImageFilterTransformComposition6} with the only difference
of the output spacing being :math:`40` times smaller and a number of
pixels :math:`40` times larger in both dimensions. Without these
changes, few detail will be recognizable on the images. Note that the
spacing and origin of the input image should be prepared in advance by
using other means since this filter cannot alter in any way the actual
content of the input image.

In order to facilitate the interpretation of the transform we set the
default pixel value to value distinct from the image background.

::

    [language=C++]
    filter->SetDefaultPixelValue( 100 );

The spacing is selected here to be 40 times smaller than the one
illustrated in Figure {fig:ResampleImageFilterTransformComposition6}.

::

    [language=C++]
    double spacing[ Dimension ];
    spacing[0] = 40.0 / 40.0;  pixel spacing in millimeters along X
    spacing[1] = 30.0 / 40.0;  pixel spacing in millimeters along Y
    filter->SetOutputSpacing( spacing );

We will preserve the orientation of the input image by using the
following call.

::

    [language=C++]
    filter->SetOutputDirection( reader->GetOutput()->GetDirection() );

Let us now set up the origin of the output image. Note that the values
provided here will be those of the space coordinates for the output
image pixel of index :math:`(0,0)`.

::

    [language=C++]
    double origin[ Dimension ];
    origin[0] =  50.0;   X space coordinate of origin
    origin[1] = 130.0;   Y space coordinate of origin
    filter->SetOutputOrigin( origin );

The output image size is defined to be :math:`40` times the one
illustrated on the Figure
{fig:ResampleImageFilterTransformComposition6}.

::

    [language=C++]
    InputImageType::SizeType   size;
    size[0] = 5 * 40;   number of pixels along X
    size[1] = 4 * 40;   number of pixels along Y
    filter->SetSize( size );

Rotations are performed around the origin of physical coordinates—not
the image origin nor the image center. Hence, the process of positioning
the output image frame as it is shown in Figure
{fig:ResampleImageFilterTransformComposition6} requires three steps.
First, the image origin must be moved to the origin of the coordinate
system, this is done by applying a translation equal to the negative
values of the image origin.

::

    [language=C++]
    TransformType::OutputVectorType translation1;
    translation1[0] =   -origin[0];
    translation1[1] =   -origin[1];
    transform->Translate( translation1 );

In a second step, a rotation of :math:`30` degrees is performed. In
the {AffineTransform}, angles are specified in *radians*. Also, a second
boolean argument is used to specify if the current modification of the
transform should be pre-composed or post-composed with the current
transform content. In this case the argument is set to {false} to
indicate that the rotation should be applied *after* the current
transform content.

::

    [language=C++]
    const double degreesToRadians = vcl_atan(1.0) / 45.0;
    transform->Rotate2D( -30.0 * degreesToRadians, false );

The third and final step implies translating the image origin back to
its previous location. This is be done by applying a translation equal
to the origin values.

::

    [language=C++]
    TransformType::OutputVectorType translation2;
    translation2[0] =   origin[0];
    translation2[1] =   origin[1];
    transform->Translate( translation2, false );
    filter->SetTransform( transform );

Figure {fig:ResampleImageFilterOutput9} presents the actual input and
output images of this example as shown by a correct viewer which takes
spacing into account. Note the *clockwise* versus *counter-clockwise*
effect discussed previously between the representation in Figure
{fig:ResampleImageFilterTransformComposition6} and Figure
{fig:ResampleImageFilterOutput9}.

As a final exercise, let’s track the mapping of an individual pixel.
Keep in mind that the transformation is initiated by walking through the
pixels of the *output* image. This is the only way to ensure that the
image will be generated without holes or redundant values. When you
think about transformation it is always useful to analyze things from
the output image towards the input image.

Let’s take the pixel with index :math:`I=(1,2)` from the output image.
The physical coordinates of this point in the output image reference
system are
:math:`P=( 1 \times 40.0 + 50.0, 2 \times 30.0 + 130.0 ) = (90.0,190.0)`
millimeters.

This point :math:`P` is now mapped through the {AffineTransform} into
the input image space. The operation requires to subtract the origin,
apply a :math:`30` degrees rotation and add the origin back. Let’s
follow those steps. Subtracting the origin from :math:`P` leads to
:math:`P1=(40.0,60.0)`, the rotation maps :math:`P1` to
:math:`P2=( 40.0 \times cos
(30.0) + 60.0 \times sin (30.0), 40.0 \times sin(30.0) - 60.0 \times
cos(30.0)) = (64.64,31.96)`. Finally this point is translated back by
the amount of the image origin. This moves :math:`P2` to
:math:`P3=(114.64,161.96)`.

The point :math:`P3` is now in the coordinate system of the input
image. The pixel of the input image associated with this physical
position is computed using the origin and spacing of the input image.
:math:`I=( ( 114.64 -
60.0 )/ 20.0 , ( 161 - 70.0 ) / 30.0 )` which results in
:math:`I=(2.7,3.0)`. Note that this is a non-grid position since the
values are non-integers. This means that the gray value to be assigned
to the output image pixel :math:`I=(1,2)` must be computed by
interpolation of the input image values.

In this particular code the interpolator used is simply a
{NearestNeighborInterpolateImageFunction} which will assign the value of
the closest pixel. This ends up being the pixel of index
:math:`I=(3,3)` and can be seen from Figure
{fig:ResampleImageFilterTransformComposition6}.

.. |image| image:: ResampleImageFilterInput2x3.eps
.. |image1| image:: ResampleImageFilterOutput9.eps
.. |image2| image:: ResampleImageFilterTransformComposition6.eps
