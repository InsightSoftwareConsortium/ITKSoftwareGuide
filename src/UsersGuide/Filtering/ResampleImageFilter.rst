The source code for this section can be found in the file
``ResampleImageFilter.cxx``.

Resampling an image is a very important task in image analysis. It is
especially important in the frame of image registration. The
{ResampleImageFilter} implements image resampling through the use of
{Transform}s. The inputs expected by this filter are an image, a
transform and an interpolator. The space coordinates of the image are
mapped through the transform in order to generate a new image. The
extent and spacing of the resulting image are selected by the user.
Resampling is performed in space coordinates, not pixel/grid
coordinates. It is quite important to ensure that image spacing is
properly set on the images involved. The interpolator is required since
the mapping from one space to the other will often require evaluation of
the intensity of the image at non-grid positions.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkResampleImageFilter.h"

The header files corresponding to the transform and interpolator must
also be included.

::

    [language=C++]
    #include "itkAffineTransform.h"
    #include "itkNearestNeighborInterpolateImageFunction.h"

The dimension and pixel types for input and output image must be defined
and with them the image types can be instantiated.

::

    [language=C++]
    const     unsigned int   Dimension = 2;
    typedef   unsigned char  InputPixelType;
    typedef   unsigned char  OutputPixelType;
    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;

Using the image and transform types it is now possible to instantiate
the filter type and create the filter object.

::

    [language=C++]
    typedef itk::ResampleImageFilter<InputImageType,OutputImageType> FilterType;
    FilterType::Pointer filter = FilterType::New();

The transform type is typically defined using the image dimension and
the type used for representing space coordinates.

::

    [language=C++]
    typedef itk::AffineTransform< double, Dimension >  TransformType;

An instance of the transform object is instantiated and passed to the
resample filter. By default, the parameters of transform is set to
represent the identity transform.

::

    [language=C++]
    TransformType::Pointer transform = TransformType::New();
    filter->SetTransform( transform );

The interpolator type is defined using the full image type and the type
used for representing space coordinates.

::

    [language=C++]
    typedef itk::NearestNeighborInterpolateImageFunction<
    InputImageType, double >  InterpolatorType;

An instance of the interpolator object is instantiated and passed to the
resample filter.

::

    [language=C++]
    InterpolatorType::Pointer interpolator = InterpolatorType::New();
    filter->SetInterpolator( interpolator );

Given that some pixels of the output image may end up being mapped
outside the extent of the input image it is necessary to decide what
values to assign to them. This is done by invoking the
{SetDefaultPixelValue()} method.

::

    [language=C++]
    filter->SetDefaultPixelValue( 0 );

The sampling grid of the output space is specified with the spacing
along each dimension and the origin.

::

    [language=C++]
    double spacing[ Dimension ];
    spacing[0] = 1.0;  pixel spacing in millimeters along X
    spacing[1] = 1.0;  pixel spacing in millimeters along Y

    filter->SetOutputSpacing( spacing );

    double origin[ Dimension ];
    origin[0] = 0.0;   X space coordinate of origin
    origin[1] = 0.0;   Y space coordinate of origin

    filter->SetOutputOrigin( origin );

::

    [language=C++]
    InputImageType::DirectionType direction;
    direction.SetIdentity();
    filter->SetOutputDirection( direction );

The extent of the sampling grid on the output image is defined by a
{SizeType} and is set using the {SetSize()} method.

::

    [language=C++]
    InputImageType::SizeType   size;

    size[0] = 300;   number of pixels along X
    size[1] = 300;   number of pixels along Y

    filter->SetSize( size );

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example a writer. An update call on any downstream filter will
trigger the execution of the resampling filter.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );
    writer->Update();

    |image| |image1| [Effect of the Resample filter] {Effect of the
    resample filter.} {fig:ResampleImageFilterOutput1}

    |image2| [Analysis of resampling in common coordinate system]
    {Analysis of the resample image done in a common coordinate system.}
    {fig:ResampleImageFilterOutput1Analysis}

Figure {fig:ResampleImageFilterOutput1} illustrates the effect of this
filter on a slice of MRI brain image using an affine transform
containing an identity transform. Note that any analysis of the behavior
of this filter must be done on the space coordinate system in
millimeters, not with respect to the sampling grid in pixels. The figure
shows the resulting image in the lower left quarter of the extent. This
may seem odd if analyzed in terms of the image grid but is quite clear
when seen with respect to space coordinates. Figure
{fig:ResampleImageFilterOutput1} is particularly misleading because the
images are rescaled to fit nicely on the text of this book. Figure
{fig:ResampleImageFilterOutput1Analysis} clarifies the situation. It
shows the two same images placed on a equally scaled coordinate system.
It becomes clear here that an identity transform is being used to map
the image data, and that simply, we have requested to resample
additional empty space around the image. The input image is
:math:`181 \times 217` pixels in size and we have requested an output
of :math:`300
\times 300` pixels. In this case, the input and output images both have
spacing of :math:`1mm \times 1mm` and origin of :math:`(0.0,0.0)`.

Let’s now set values on the transform. Note that the supplied transform
represents the mapping of points from the output space to the input
space. The following code sets up a translation.

::

    [language=C++]
    TransformType::OutputVectorType translation;
    translation[0] = -30;   X translation in millimeters
    translation[1] = -50;   Y translation in millimeters
    transform->Translate( translation );

    |image3| |image4| [ResampleImageFilter with a translation by
    :math:`(-30,-50)`] {ResampleImageFilter with a translation by
    :math:`(-30,-50)`.} {fig:ResampleImageFilterOutput2}

    |image5| [ResampleImageFilter. Analysis of a translation by
    :math:`(-30,-50)`] {ResampleImageFilter. Analysis of a translation
    by :math:`(-30,-50)`.} {fig:ResampleImageFilterOutput2Analysis}

The output image resulting from the translation can be seen in Figure
{fig:ResampleImageFilterOutput2}. Again, it is better to interpret the
result in a common coordinate system as illustrated in Figure
{fig:ResampleImageFilterOutput2Analysis}.

Probably the most important thing to keep in mind when resampling images
is that the transform is used to map points from the **output** image
space into the **input** image space. In this case, Figure
{fig:ResampleImageFilterOutput2Analysis} shows that the translation is
applied to every point of the output image and the resulting position is
used to read the intensity from the input image. In this way, the gray
level of the point :math:`P` in the output image is taken from the
point :math:`T(P)` in the input image. Where :math:`T` is the
transformation. In the specific case of the Figure
{fig:ResampleImageFilterOutput2Analysis}, the value of point
:math:`(105,188)` in the output image is taken from the point
:math:`(75,138)` of the input image because the transformation applied
was a translation of :math:`(-30,-50)`.

It is sometimes useful to intentionally set the default output value to
a distinct gray value in order to highlight the mapping of the image
borders. For example, the following code sets the default external value
of :math:`100`. The result is shown in the right side of Figure
{fig:ResampleImageFilterOutput3Analysis}

::

    [language=C++]
    filter->SetDefaultPixelValue( 100 );

    |image6| [ResampleImageFilter highlighting image borders]
    {ResampleImageFilter highlighting image borders with
    SetDefaultPixelValue().} {fig:ResampleImageFilterOutput3Analysis}

With this change we can better appreciate the effect of the previous
translation transform on the image resampling. Figure
{fig:ResampleImageFilterOutput3Analysis} illustrates how the point
:math:`(30,50)` of the output image gets its gray value from the point
:math:`(0,0)` of the input image.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: ResampleImageFilterOutput1.eps
.. |image2| image:: ResampleImageFilterOutput1Analysis.eps
.. |image3| image:: BrainProtonDensitySlice.eps
.. |image4| image:: ResampleImageFilterOutput2.eps
.. |image5| image:: ResampleImageFilterOutput2Analysis.eps
.. |image6| image:: ResampleImageFilterOutput3Analysis.eps
