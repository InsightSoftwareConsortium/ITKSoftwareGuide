.. _sec-CreatingAnImageSection:

Creating an Image
~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``Image1.cxx``.

This example illustrates how to manually construct an :itkdox:`itk::Image` class. The
following is the minimal code needed to instantiate, declare and create
the image class.

First, the header file of the Image class must be included.

::

    #include "itkImage.h"

Then we must decide with what type to represent the pixels and what the
dimension of the image will be. With these two parameters we can
instantiate the image class. Here we create a 3D image with ``unsigned
short`` pixel data.

::

    typedef itk::Image< unsigned short, 3 > ImageType;

The image can then be created by invoking the ``New()`` operator from the
corresponding image type and assigning the result to a ``SmartPointer``.

::

    ImageType::Pointer image = ImageType::New();

In ITK, images exist in combination with one or more *regions*. A region
is a subset of the image and indicates a portion of the image that may
be processed by other classes in the system. One of the most common
regions is the *LargestPossibleRegion*, which defines the image in its
entirety. Other important regions found in ITK are the *BufferedRegion*,
which is the portion of the image actually maintained in memory, and the
*RequestedRegion*, which is the region requested by a filter or other
class when operating on the image.

In ITK, manually creating an image requires that the image is
instantiated as previously shown, and that regions describing the image
are then associated with it.

A region is defined by two classes: the :itkdox:`itk::Index` and :itkdox:`itk::Size` classes. The
origin of the region within the image with which it is associated is
defined by Index. The extent, or size, of the region is defined by Size.
Index is represented by a n-dimensional array where each component is an
integer indicating—in topological image coordinates—the initial pixel of
the image. When an image is created manually, the user is responsible
for defining the image size and the index at which the image grid
starts. These two parameters make it possible to process selected
regions.

The starting point of the image is defined by an Index class that is an
n-dimensional array where each component is an integer indicating the
grid coordinates of the initial pixel of the image.

::

    ImageType::IndexType start;

    start[0] =   0;   first index on X
    start[1] =   0;   first index on Y
    start[2] =   0;   first index on Z

The region size is represented by an array of the same dimension of the
image (using the Size class). The components of the array are unsigned
integers indicating the extent in pixels of the image along every
dimension.

::

    ImageType::SizeType  size;

    size[0]  = 200;   size along X
    size[1]  = 200;   size along Y
    size[2]  = 200;   size along Z

Having defined the starting index and the image size, these two
parameters are used to create an ImageRegion object which basically
encapsulates both concepts. The region is initialized with the starting
index and size of the image.

::

    ImageType::RegionType region;

    region.SetSize( size );
    region.SetIndex( start );

Finally, the region is passed to the :itkdox:`itk::Image` object in order to define
its extent and origin. The ``SetRegions`` method sets the
LargestPossibleRegion, BufferedRegion, and RequestedRegion
simultaneously. Note that none of the operations performed to this point
have allocated memory for the image pixel data. It is necessary to
invoke the ``Allocate()`` method to do this. Allocate does not require any
arguments since all the information needed for memory allocation has
already been provided by the region.

::

    image->SetRegions( region );
    image->Allocate();

In practice it is rare to allocate and initialize an image directly.
Images are typically read from a source, such a file or data acquisition
hardware. The following example illustrates how an image can be read
from a file.

