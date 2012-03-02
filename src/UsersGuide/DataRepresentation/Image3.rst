.. _sec-AccessingImagePixelData:

Accessing Pixel Data
~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``Image3.cxx``.

This example illustrates the use of the ``SetPixel()`` and ``GetPixel()``
methods. These two methods provide direct access to the pixel data
contained in the image. Note that these two methods are relatively slow
and should not be used in situations where high-performance access is
required. Image iterators are the appropriate mechanism to efficiently
access image pixel data. (See Chapter :ref:`sec-ImageIteratorsChapter` on
page :ref:`sec-ImageIteratorsChapter` for information about image iterators.)

The individual position of a pixel inside the image is identified by a
unique index. An index is an array of integers that defines the position
of the pixel along each coordinate dimension of the image. The IndexType
is automatically defined by the image and can be accessed using the
scope operator like :itkdox:`itk::Index`. The length of the array will match the
dimensions of the associated image.

The following code illustrates the declaration of an index variable and
the assignment of values to each of its components. Please note that
:itkdox:`itk::Index` does not use SmartPointers to access it. This is because :itkdox:`itk::Index`
is a light-weight object that is not intended to be shared between
objects. It is more efficient to produce multiple copies of these small
objects than to share them using the SmartPointer mechanism.

The following lines declare an instance of the index type and initialize
its content in order to associate it with a pixel position in the image.

::

    ImageType::IndexType pixelIndex;

    pixelIndex[0] = 27;    x position
    pixelIndex[1] = 29;    y position
    pixelIndex[2] = 37;    z position

Having defined a pixel position with an index, it is then possible to
access the content of the pixel in the image. The ``GetPixel()`` method
allows us to get the value of the pixels.

::

    ImageType::PixelType   pixelValue = image->GetPixel( pixelIndex );

The ``SetPixel()`` method allows us to set the value of the pixel.

::

    image->SetPixel(   pixelIndex,   pixelValue+1  );

Please note that ``GetPixel()`` returns the pixel value using copy and not
reference semantics. Hence, the method cannot be used to modify image
data values.

Remember that both ``SetPixel()`` and ``GetPixel()`` are inefficient and
should only be used for debugging or for supporting interactions like
querying pixel values by clicking with the mouse.

