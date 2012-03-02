.. _sec-DefiningImageOriginAndSpacing:

Defining Origin and Spacing
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``Image4.cxx``.

Even though `ITK <http:www.itk.org>`_ can be used to perform general
image processing tasks, the primary purpose of the toolkit is the
processing of medical image data. In that respect, additional
information about the images is considered mandatory. In particular the
information associated with the physical spacing between pixels and the
position of the image in space with respect to some world coordinate
system are extremely important.

Image origin and spacing are fundamental to many applications.
Registration, for example, is performed in physical coordinates.
Improperly defined spacing and origins will result in inconsistent
results in such processes. Medical images with no spatial information
should not be used for medical diagnosis, image analysis, feature
extraction, assisted radiation therapy or image guided surgery. In other
words, medical images lacking spatial information are not only useless
but also hazardous.

.. _fig-ImageOriginAndSpacing:
   
.. figure:: ImageOriginAndSpacing.png
   :align: center
   
   Geometrical concepts associate with the ITK image.

Figure :ref:`fig-ImageOriginAndSpacing` illustrates the main geometrical
concepts associated with the :itkdox:`itk::Image`. In this figure, circles are used
to represent the center of pixels. The value of the pixel is assumed to
exist as a Dirac Delta Function located at the pixel center. Pixel
spacing is measured between the pixel centers and can be different along
each dimension. The image origin is associated with the coordinates of
the first pixel in the image. A *pixel* is considered to be the
rectangular region surrounding the pixel center holding the data value.
This can be viewed as the Voronoi region of the image grid, as
illustrated in the right side of the figure. Linear interpolation of
image values is performed inside the Delaunay region whose corners are
pixel centers.

Image spacing is represented in a :itkdox:`itk::FixedArray` whose size matches the
dimension of the image. In order to manually set the spacing of the
image, an array of the corresponding type must be created. The elements
of the array should then be initialized with the spacing between the
centers of adjacent pixels. The following code illustrates the methods
available in the Image class for dealing with spacing and origin.

::

    ImageType::SpacingType spacing;

    Note: measurement units (e.g., mm, inches, etc.) are defined by the application.
    spacing[0] = 0.33;  spacing along X
    spacing[1] = 0.33;  spacing along Y
    spacing[2] = 1.20;  spacing along Z

The array can be assigned to the image using the ``SetSpacing()`` method.

::

    image->SetSpacing( spacing );

The spacing information can be retrieved from an image by using the
``GetSpacing()`` method. This method returns a reference to a
:itkdox:`itk::FixedArray`. The returned object can then be used to read the contents
of the array. Note the use of the ``const`` keyword to indicate that the
array will not be modified.

::

    const ImageType::SpacingType& sp = image->GetSpacing();

    std::cout << "Spacing = ";
    std::cout << sp[0] << ", " << sp[1] << ", " << sp[2] << std::endl;

The image origin is managed in a similar way to the spacing. A :itkdox:`itk::Point`
of the appropriate dimension must first be allocated. The coordinates of
the origin can then be assigned to every component. These coordinates
correspond to the position of the first pixel of the image with respect
to an arbitrary reference system in physical space. It is the user’s
responsibility to make sure that multiple images used in the same
application are using a consistent reference system. This is extremely
important in image registration applications.

The following code illustrates the creation and assignment of a variable
suitable for initializing the image origin.

::

    ImageType::PointType origin;

    origin[0] = 0.0;   coordinates of the
    origin[1] = 0.0;   first pixel in N-D
    origin[2] = 0.0;

    image->SetOrigin( origin );

The origin can also be retrieved from an image by using the
``GetOrigin()`` method. This will return a reference to a :itkdox:`itk::Point`. The
reference can be used to read the contents of the array. Note again the
use of the ``const`` keyword to indicate that the array contents will not
be modified.

::

    const ImageType::PointType& orgn = image->GetOrigin();

    std::cout << "Origin = ";
    std::cout << orgn[0] << ", " << orgn[1] << ", " << orgn[2] << std::endl;

Once the spacing and origin of the image have been initialized, the
image will correctly map pixel indices to and from physical space
coordinates. The following code illustrates how a point in physical
space can be mapped into an image index for the purpose of reading the
content of the closest pixel.

First, a :itkdox:`itk::Point` type must be declared. The point type is templated over
the type used to represent coordinates and over the dimension of the
space. In this particular case, the dimension of the point must match
the dimension of the image.

::

    typedef itk::Point< double, ImageType::ImageDimension > PointType;

The Point class, like an :itkdox:`itk::Index`, is a relatively small and simple
object. For this reason, it is not reference-counted like the large data
objects in ITK. Consequently, it is also not manipulated with
``SmartPointer``'s. Point objects are simply declared as instances of any
other C++ class. Once the point is declared, its components can be
accessed using traditional array notation. In particular, the ``[]``
operator is available. For efficiency reasons, no bounds checking is
performed on the index used to access a particular point component. It
is the user’s responsibility to make sure that the index is in the range
:math:`\{0,Dimension-1\}`.

::

    PointType point;

    point[0] = 1.45;     x coordinate
    point[1] = 7.21;     y coordinate
    point[2] = 9.28;     z coordinate

The image will map the point to an index using the values of the current
spacing and origin. An index object must be provided to receive the
results of the mapping. The index object can be instantiated by using
the ``IndexType`` defined in the Image type.

::

    ImageType::IndexType pixelIndex;

The ``TransformPhysicalPointToIndex()`` method of the image class will
compute the pixel index closest to the point provided. The method checks
for this index to be contained inside the current buffered pixel data.
The method returns a boolean indicating whether the resulting index
falls inside the buffered region or not. The output index should not be
used when the returned value of the method is ``false``.

The following lines illustrate the point to index mapping and the
subsequent use of the pixel index for accessing pixel data from the
image.

::

    bool isInside = image->TransformPhysicalPointToIndex( point, pixelIndex );

    if ( isInside )
      {
      ImageType::PixelType pixelValue = image->GetPixel( pixelIndex );

      pixelValue += 5;

      image->SetPixel( pixelIndex, pixelValue );
      }

Remember that ``GetPixel()`` and ``SetPixel()`` are very inefficient methods
for accessing pixel data. Image iterators should be used when massive
access to pixel data is required.

