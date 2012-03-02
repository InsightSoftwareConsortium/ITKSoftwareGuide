The source code for this section can be found in the file
``ImageReadWrite.cxx``.

The classes responsible for reading and writing images are located at
the beginning and end of the data processing pipeline. These classes are
known as data sources (readers) and data sinks (writers). Generally
speaking they are referred to as filters, although readers have no
pipeline input and writers have no pipeline output.

The reading of images is managed by the class {ImageFileReader} while
writing is performed by the class {ImageFileWriter}. These two classes
are independent of any particular file format. The actual low level task
of reading and writing specific file formats is done behind the scenes
by a family of classes of type {ImageIO}.

The first step for performing reading and writing is to include the
following headers.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

Then, as usual, a decision must be made about the type of pixel used to
represent the image processed by the pipeline. Note that when reading
and writing images, the pixel type of the image **is not necessarily**
the same as the pixel type stored in the file. Your choice of the pixel
type (and hence template parameter) should be driven mainly by two
considerations:

-  It should be possible to cast the file pixel type in the file to the
   pixel type you select. This casting will be performed using the
   standard C-language rules, so you will have to make sure that the
   conversion does not result in information being lost.

-  The pixel type in memory should be appropriate to the type of
   processing you intended to apply on the images.

A typical selection for medical images is illustrated in the following
lines.

::

    [language=C++]
    typedef short      PixelType;
    const   unsigned int        Dimension = 2;
    typedef itk::Image< PixelType, Dimension >    ImageType;

Note that the dimension of the image in memory should match the one of
the image in file. There are a couple of special cases in which this
condition may be relaxed, but in general it is better to ensure that
both dimensions match.

We can now instantiate the types of the reader and writer. These two
classes are parameterized over the image type.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >  ReaderType;
    typedef itk::ImageFileWriter< ImageType >  WriterType;

Then, we create one object of each type using the New() method and
assigning the result to a {SmartPointer}.

::

    [language=C++]
    ReaderType::Pointer reader = ReaderType::New();
    WriterType::Pointer writer = WriterType::New();

The name of the file to be read or written is passed with the
SetFileName() method.

::

    [language=C++]
    reader->SetFileName( inputFilename  );
    writer->SetFileName( outputFilename );

We can now connect these readers and writers to filters to create a
pipeline. For example, we can create a short pipeline by passing the
output of the reader directly to the input of the writer.

::

    [language=C++]
    writer->SetInput( reader->GetOutput() );

At first view, this may seem as a quite useless program, but it is
actually implementing a powerful file format conversion tool! The
execution of the pipeline is triggered by the invocation of the
{Update()} methods in one of the final objects. In this case, the final
data pipeline object is the writer. It is a wise practice of defensive
programming to insert any {Update()} call inside a {try/catch} block in
case exceptions are thrown during the execution of the pipeline.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & err )
    {
    std::cerr << "ExceptionObject caught !" << std::endl;
    std::cerr << err << std::endl;
    return EXIT_FAILURE;
    }

Note that exceptions should only be caught by pieces of code that know
what to do with them. In a typical application this {catch} block should
probably reside on the GUI code. The action on the {catch} block could
inform the user about the failure of the IO operation.

The IO architecture of the toolkit makes it possible to avoid explicit
specification of the file format used to read or write images. [1]_ The
object factory mechanism enables the ImageFileReader and ImageFileWriter
to determine (at run-time) with which file format it is working with.
Typically, file formats are chosen based on the filename extension, but
the architecture supports arbitrarily complex processes to determine
whether a file can be read or written. Alternatively, the user can
specify the data file format by explicit instantiation and assignment
the appropriate {ImageIO} subclass.

For historical reasons and as a convenience to the user, the
{ImageFileWriter} also has a Write() method that is aliased to the
{Update()} method. You can in principle use either of them but
{Update()} is recommended since Write() may be deprecated in the future.

.. [1]
   In this example no file format is specified; this program can be used
   as a general file conversion utility.
