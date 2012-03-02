The source code for this section can be found in the file
``ResampleImageFilter2.cxx``.

During the computation of the resampled image all the pixels in the
output region are visited. This visit is performed using
{ImageIterators} which walk in the integer grid-space of the image. For
each pixel, we need to convert grid position to space coordinates using
the image spacing and origin.

For example, the pixel of index :math:`I=(20,50)` in an image of
origin :math:`O=(19.0, 29.0)` and pixel spacing :math:`S=(1.3,1.5)`
corresponds to the spatial position

:math:`P[i] = I[i] \times S[i] + O[i]
`

which in this case leads to
:math:`P=( 20 \times 1.3 + 19.0, 50 \times 1.5 +
29.0 )` and finally :math:`P=(45.0, 104.0)`

The space coordinates of :math:`P` are mapped using the transform
:math:`T` supplied to the {ResampleImageFilter} in order to map the
point :math:`P` to the input image space point :math:`Q = T(P)`.

The whole process is illustrated in Figure
{fig:ResampleImageFilterTransformComposition1}. In order to correctly
interpret the process of the ResampleImageFilter you should be aware of
the origin and spacing settings of both the input and output images.

In order to facilitate the interpretation of the transform we set the
default pixel value to a distinct from the image background.

::

    [language=C++]
    filter->SetDefaultPixelValue( 50 );

Let’s set up a uniform spacing for the output image.

::

    [language=C++]
    double spacing[ Dimension ];
    spacing[0] = 1.0;  pixel spacing in millimeters along X
    spacing[1] = 1.0;  pixel spacing in millimeters along Y

    filter->SetOutputSpacing( spacing );

We will preserve the orientation of the input image by using the
following call.

::

    [language=C++]
    filter->SetOutputDirection( reader->GetOutput()->GetDirection() );

Additionally, we will specify a non-zero origin. Note that the values
provided here will be those of the space coordinates for the pixel of
index :math:`(0,0)`.

::

    [language=C++]
    double origin[ Dimension ];
    origin[0] = 30.0;   X space coordinate of origin
    origin[1] = 40.0;   Y space coordinate of origin
    filter->SetOutputOrigin( origin );

We set the transform to identity in order to better appreciate the
effect of the origin selection.

::

    [language=C++]
    transform->SetIdentity();
    filter->SetTransform( transform );

The output resulting from these filter settings is analyzed in Figure
{fig:ResampleImageFilterTransformComposition1}

    |image| [ResampleImageFilter selecting the origin of the output
    image] {ResampleImageFilter selecting the origin of the output
    image.} {fig:ResampleImageFilterTransformComposition1}

In the figure, the output image point with index :math:`I=(0,0)` has
space coordinates :math:`P=(30,40)`. The identity transform maps this
point to :math:`Q=(30,40)` in the input image space. Because the input
image in this case happens to have spacing :math:`(1.0,1.0)` and
origin :math:`(0.0,0.0)`, the physical point :math:`Q=(30,40)` maps
to the pixel with index :math:`I=(30,40)`.

The code for a different selection of origin and image size is
illustrated below. The resulting output is presented in Figure
{fig:ResampleImageFilterTransformComposition2}

::

    [language=C++]
    size[0] = 150;   number of pixels along X
    size[1] = 200;   number of pixels along Y
    filter->SetSize( size );

::

    [language=C++]
    origin[0] = 60.0;   X space coordinate of origin
    origin[1] = 30.0;   Y space coordinate of origin
    filter->SetOutputOrigin( origin );

    |image1| [ResampleImageFilter selecting the origin of the output
    image] {ResampleImageFilter selecting the origin of the output
    image.} {fig:ResampleImageFilterTransformComposition2}

The output image point with index :math:`I=(0,0)` now has space
coordinates :math:`P=(60,30)`. The identity transform maps this point
to :math:`Q=(60,30)` in the input image space. Because the input image
in this case happens to have spacing :math:`(1.0,1.0)` and origin
:math:`(0.0,0.0)`, the physical point :math:`Q=(60,30)` maps to the
pixel with index :math:`I=(60,30)`.

Let’s now analyze the effect of a non-zero origin in the input image.
Keeping the output image settings of the previous example, we modify
only the origin values on the file header of the input image. The new
origin assigned to the input image is :math:`O=(50,70)`. An identity
transform is still used as input for the ResampleImageFilter. The result
of executing the filter with these parameters is presented in Figure
{fig:ResampleImageFilterTransformComposition3}

    |image2| [ResampleImageFilter selecting the origin of the input
    image] {Effect of selecting the origin of the input image with
    ResampleImageFilter.} {fig:ResampleImageFilterTransformComposition3}

The pixel with index :math:`I=(56,120)` on the output image has
coordinates :math:`P=(116,150)` in physical space. The identity
transform maps :math:`P` to the point :math:`Q=(116,150)` on the
input image space. The coordinates of :math:`Q` are associated with
the pixel of index :math:`I=(66,80)` on the input image.

Now consider the effect of the output spacing on the process of image
resampling. In order to simplify the analysis, let’s put the origin back
to zero in both the input and output images.

::

    [language=C++]
    origin[0] = 0.0;   X space coordinate of origin
    origin[1] = 0.0;   Y space coordinate of origin
    filter->SetOutputOrigin( origin );

We then specify a non-unit spacing for the output image.

::

    [language=C++]
    spacing[0] = 2.0;  pixel spacing in millimeters along X
    spacing[1] = 3.0;  pixel spacing in millimeters along Y
    filter->SetOutputSpacing( spacing );

Additionally, we reduce the output image extent, since the new pixels
are now covering a larger area of
:math:`2.0\mbox{mm} \times 3.0\mbox{mm}`.

::

    [language=C++]
    size[0] = 80;   number of pixels along X
    size[1] = 50;   number of pixels along Y
    filter->SetSize( size );

With these new parameters the physical extent of the output image is
:math:`160` millimeters by :math:`150` millimeters.

Before attempting to analyze the effect of the resampling image filter
it is important to make sure that the image viewer used to display the
input and output images take the spacing into account and use it to
appropriately scale the images on the screen. Please note that images in
formats like PNG are not capable of representing origin and spacing. The
toolkit assume trivial default values for them. Figure
{fig:ResampleImageFilterOutput7} (center) illustrates the effect of
using a naive viewer that does not take pixel spacing into account. A
correct display is presented at the right in the same figure [1]_.

    |image3| |image4| |image5| [ResampleImageFilter use of naive
    viewers] {Resampling with different spacing seen by a naive viewer
    (center) and a correct viewer (right), input image (left).}
    {fig:ResampleImageFilterOutput7}

    |image6| [ResampleImageFilter and output image spacing] {Effect of
    selecting the spacing on the output image.}
    {fig:ResampleImageFilterTransformComposition4}

The filter output is analyzed in a common coordinate system with the
input from Figure {fig:ResampleImageFilterTransformComposition4}. In
this figure, pixel :math:`I=(33,27)` of the output image is located at
coordinates :math:`P=(66.0,81.0)` of the physical space. The identity
transform maps this point to :math:`Q=(66.0,81.0)` in the input image
physical space. The point :math:`Q` is then associated to the pixel of
index :math:`I=(66,81)` on the input image, because this image has
zero origin and unit spacing.

    |image7| |image8| [ResampleImageFilter naive viewers] {Input image
    with :math:`2 \times
    3 \mbox{mm}` spacing as seen with a naive viewer (left) and a
    correct viewer (right).{fig:ResampleImageFilterInput2}}

The input image spacing is also an important factor in the process of
resampling an image. The following example illustrates the effect of
non-unit pixel spacing on the input image. An input image similar to the
those used in Figures {fig:ResampleImageFilterTransformComposition1} to
{fig:ResampleImageFilterTransformComposition4} has been resampled to
have pixel spacing of :math:`2\mbox{mm} \times 3\mbox{mm}`. The input
image is presented in Figure {fig:ResampleImageFilterInput2} as viewed
with a naive image viewer (left) and with a correct image viewer
(right).

The following code is used to transform this non-unit spacing input
image into another non-unit spacing image located at a non-zero origin.
The comparison between input and output in a common reference system is
presented in figure {fig:ResampleImageFilterTransformComposition5}.

Here we start by selecting the origin of the output image.

::

    [language=C++]
    origin[0] = 25.0;   X space coordinate of origin
    origin[1] = 35.0;   Y space coordinate of origin
    filter->SetOutputOrigin( origin );

We then select the number of pixels along each dimension.

::

    [language=C++]
    size[0] = 40;   number of pixels along X
    size[1] = 45;   number of pixels along Y
    filter->SetSize( size );

Finally, we set the output pixel spacing.

::

    [language=C++]
    spacing[0] = 4.0;  pixel spacing in millimeters along X
    spacing[1] = 4.5;  pixel spacing in millimeters along Y
    filter->SetOutputSpacing( spacing );

Figure {fig:ResampleImageFilterTransformComposition5} shows the analysis
of the filter output under these conditions. First, notice that the
origin of the output image corresponds to the settings
:math:`O=(25.0,35.0)` millimeters, spacing :math:`(4.0,4.5)`
millimeters and size :math:`(40,45)` pixels. With these parameters the
pixel of index :math:`I=(10,10)` in the output image is associated
with the spatial point of coordinates
:math:`P=(10 \times 4.0 + 25.0, 10 \times 4.5 + 35.0)) =(65.0,80.0)`.
This point is mapped by the transform—identity in this particular
case—to the point :math:`Q=(65.0,80.0)` in the input image space. The
point :math:`Q` is then associated with the pixel of index
:math:`I=( ( 65.0 - 0.0 )/2.0 - (80.0
- 0.0)/3.0) =(32.5,26.6)`. Note that the index does not fall on grid
position, for this reason the value to be assigned to the output pixel
is computed by interpolating values on the input image around the
non-integer index :math:`I=(32.5,26.6)`.

    |image9| [ResampleImageFilter with non-unit spacing] {Effect of
    non-unit spacing on the input and output images.}
    {fig:ResampleImageFilterTransformComposition5}

Note also that the discretization of the image is more visible on the
output presented on the right side of Figure
{fig:ResampleImageFilterTransformComposition5} due to the choice of a
low resolution—just :math:`40 \times 45` pixels.

.. [1]
   A viewer is provided with ITK under the name of MetaImageViewer. This
   viewer takes into account pixel spacing.

.. |image| image:: ResampleImageFilterTransformComposition1.eps
.. |image1| image:: ResampleImageFilterTransformComposition2.eps
.. |image2| image:: ResampleImageFilterTransformComposition3.eps
.. |image3| image:: BrainProtonDensitySlice.eps
.. |image4| image:: ResampleImageFilterOutput7.eps
.. |image5| image:: ResampleImageFilterOutput7b.eps
.. |image6| image:: ResampleImageFilterTransformComposition4.eps
.. |image7| image:: BrainProtonDensitySlice2x3.eps
.. |image8| image:: BrainProtonDensitySlice2x3b.eps
.. |image9| image:: ResampleImageFilterTransformComposition5.eps
