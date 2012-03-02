.. _sec-ImportingImageDataFromABuffer:

Importing Image Data from a Buffer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``Image5.cxx``.

This example illustrates how to import data into the :itkdox:`itk::Image` class. This
is particularly useful for interfacing with other software systems. Many
systems use a contiguous block of memory as a buffer for image pixel
data. The current example assumes this is the case and feeds the buffer
into an :itkdox:`itk::ImportImageFilter`, thereby producing an Image as output.

For fun we create a synthetic image with a centered sphere in a locally
allocated buffer and pass this block of memory to the ImportImageFilter.
This example is set up so that on execution, the user must provide the
name of an output file as a command-line argument.

First, the header file of the :itkdox:`itk::ImportImageFilter` class must be included.

::

    #include "itkImage.h"
    #include "itkImportImageFilter.h"

Next, we select the data type to use to represent the image pixels. We
assume that the external block of memory uses the same data type to
represent the pixels.

::

    typedef unsigned char   PixelType;
    const unsigned int Dimension = 3;
    typedef itk::Image< PixelType, Dimension > ImageType;

The type of the :itkdox:`itk::ImportImageFilter` is instantiated in the following line.

::

    typedef itk::ImportImageFilter< PixelType, Dimension >   ImportFilterType;

A filter object created using the ``New()`` method is then assigned to a
:itkdox:`itk::SmartPointer`.

::

    ImportFilterType::Pointer importFilter = ImportFilterType::New();

This filter requires the user to specify the size of the image to be
produced as output. The ``SetRegion()`` method is used to this end. The
image size should exactly match the number of pixels available in the
locally allocated buffer.

::

    ImportFilterType::SizeType  size;

    size[0]  = 200;   size along X
    size[1]  = 200;   size along Y
    size[2]  = 200;   size along Z

    ImportFilterType::IndexType start;
    start.Fill( 0 );

    ImportFilterType::RegionType region;
    region.SetIndex( start );
    region.SetSize(  size  );

    importFilter->SetRegion( region );

The origin of the output image is specified with the ``SetOrigin()``
method.

::

    double origin[ Dimension ];
    origin[0] = 0.0;     X coordinate
    origin[1] = 0.0;     Y coordinate
    origin[2] = 0.0;     Z coordinate

    importFilter->SetOrigin( origin );

The spacing of the image is passed with the ``SetSpacing()`` method.

::

    double spacing[ Dimension ];
    spacing[0] = 1.0;     along X direction
    spacing[1] = 1.0;     along Y direction
    spacing[2] = 1.0;     along Z direction

    importFilter->SetSpacing( spacing );

Next we allocate the memory block containing the pixel data to be passed
to the ImportImageFilter. Note that we use exactly the same size that
was specified with the ``SetRegion()`` method. In a practical application,
you may get this buffer from some other library using a different data
structure to represent the images.

::

    [language=C++]
    const unsigned int numberOfPixels =  size[0] * size[1] * size[2];
    PixelType * localBuffer = new PixelType[ numberOfPixels ];

Here we fill up the buffer with a binary sphere. We use simple ``for()``
loops here similar to those found in the C or FORTRAN programming
languages. Note that ITK does not use ``for()`` loops in its internal code
to access pixels. All pixel access tasks are instead performed using
``ImageIterator``s that support the management of n-dimensional images.

::

    const double radius2 = radius * radius;
    PixelType * it = localBuffer;

    for(unsigned int z=0; z < size[2]; z++)
      {
      const double dz = static_cast<double>( z ) - static_cast<double>(size[2])/2.0;
      for(unsigned int y=0; y < size[1]; y++)
        {
        const double dy = static_cast<double>( y ) - static_cast<double>(size[1])/2.0;
        for(unsigned int x=0; x < size[0]; x++)
          {
          const double dx = static_cast<double>( x ) - static_cast<double>(size[0])/2.0;
          const double d2 = dx*dx + dy*dy + dz*dz;
         *it++ = ( d2 < radius2 ) ? 255 : 0;
         }
       }
     }

The buffer is passed to the ImportImageFilter with the
``SetImportPointer()``. Note that the last argument of this method
specifies who will be responsible for deleting the memory block once it
is no longer in use. A ``false`` value indicates that the
:itkdox:`itk::ImportImageFilter` will not try to delete the buffer when its destructor
is called. A ``true`` value, on the other hand, will allow the filter to
delete the memory block upon destruction of the import filter.

For the :itkdox:`itk::ImportImageFilter` to appropriately delete the memory block, the
memory must be allocated with the C++ ``new()`` operator. Memory allocated
with other memory allocation mechanisms, such as C ``malloc`` or ``calloc``,
will not be deleted properly by the ImportImageFilter. In other words,
it is the application programmer’s responsibility to ensure that
:itkdox:`itk::ImportImageFilter` is only given permission to delete the C++ ``new``
operator-allocated memory.

::

    const bool importImageFilterWillOwnTheBuffer = true;
    importFilter->SetImportPointer( localBuffer, numberOfPixels,
    importImageFilterWillOwnTheBuffer );

Finally, we can connect the output of this filter to a pipeline. For
simplicity we just use a writer here, but it could be any other filter.

::

    writer->SetInput(  importFilter->GetOutput()  );

Note that we do not call ``delete`` on the buffer since we pass ``true`` as
the last argument of ``SetImportPointer()``. Now the buffer is owned by
the :itkdox:`itk::ImportImageFilter`.
