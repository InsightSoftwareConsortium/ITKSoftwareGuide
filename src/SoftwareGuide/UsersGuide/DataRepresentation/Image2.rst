.. _sec-ReadingImageFromFile:

Reading an Image from a File
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``Image2.cxx``.

The first thing required to read an image from a file is to include the
header file of the :itkdox:`itk::ImageFileReader` class.

::

    #include "itkImageFileReader.h"

Then, the image type should be defined by specifying the type used to
represent pixels and the dimensions of the image.

::

    typedef unsigned char          PixelType;
    const unsigned int             Dimension = 3;

    typedef itk::Image< PixelType, Dimension >   ImageType;

Using the image type, it is now possible to instantiate the image reader
class. The image type is used as a template parameter to define how the
data will be represented once it is loaded into memory. This type does
not have to correspond exactly to the type stored in the file. However,
a conversion based on C-style type casting is used, so the type chosen
to represent the data on disk must be sufficient to characterize it
accurately. Readers do not apply any transformation to the pixel data
other than casting from the pixel type of the file to the pixel type of
the :itkdox:`itk::ImageFileReader`. The following illustrates a typical instantiation
of the :itkdox:`itk::ImageFileReader` type.

::

    typedef itk::ImageFileReader< ImageType >  ReaderType;

The reader type can now be used to create one reader object. A
:itkdox:`itk::SmartPointer` (defined by the ``::Pointer`` notation) is used to receive
the reference to the newly created reader. The ``New()`` method is invoked
to create an instance of the image reader.

::

    ReaderType::Pointer reader = ReaderType::New();

The minimum information required by the reader is the filename of the
image to be loaded in memory. This is provided through the
``SetFileName()`` method. The file format here is inferred from the
filename extension. The user may also explicitly specify the data format
explicitly using the ``ImageIO`` (See Chapter :ref:`sec-ImagReadWrite` 
:ref:`sec-ImagReadWrite` for more information).

::

    const char * filename = argv[1];
    reader->SetFileName( filename );

Reader objects are referred to as pipeline source objects; they respond
to pipeline update requests and initiate the data flow in the pipeline.
The pipeline update mechanism ensures that the reader only executes when
a data request is made to the reader and the reader has not read any
data. In the current example we explicitly invoke the ``Update()`` method
because the output of the reader is not connected to other filters. In
normal application the reader’s output is connected to the input of an
image filter and the update invocation on the filter triggers an update
of the reader. The following line illustrates how an explicit update is
invoked on the reader.

::

    reader->Update();

Access to the newly read image can be gained by calling the
``GetOutput()`` method on the reader. This method can also be called
before the update request is sent to the reader. The reference to the
image will be valid even though the image will be empty until the reader
actually executes.

::

    ImageType::Pointer image = reader->GetOutput();

Any attempt to access image data before the reader executes will yield
an image with no pixel data. It is likely that a program crash will
result since the image will not have been properly initialized.

