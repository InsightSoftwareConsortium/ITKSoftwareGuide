The source code for this section can be found in the file
``CovariantVectorImageWrite.cxx``.

This example illustrates how to write an image whose pixel type is
{CovariantVector}. For practical purposes all the content in this
example is applicable to images of pixel type {Vector}, {Point} and
{FixedArray}. These pixel types are similar in that they are all arrays
of fixed size in which the components have the same representational
type.

In order to make this example a bit more interesting we setup a pipeline
to read an image, compute its gradient and write the gradient to a file.
Gradients are represented with {CovariantVector}s as opposed to Vectors.
In this way, gradients are transformed correctly under
{AffineTransform}s or in general, any transform having anisotropic
scaling.

Let’s start by including the relevant header files.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

We use the {GradientRecursiveGaussianImageFilter} in order to compute
the image gradient. The output of this filter is an image whose pixels
are CovariantVectors.

::

    [language=C++]
    #include "itkGradientRecursiveGaussianImageFilter.h"

We select to read an image of {signed short} pixels and compute the
gradient to produce an image of CovariantVector where each component is
of type {float}.

::

    [language=C++]
    typedef signed short          InputPixelType;
    typedef float                 ComponentType;
    const   unsigned int          Dimension = 2;

    typedef itk::CovariantVector< ComponentType,
    Dimension  >      OutputPixelType;

    typedef itk::Image< InputPixelType,  Dimension >    InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >    OutputImageType;

The {ImageFileReader} and {ImageFileWriter} are instantiated using the
image types.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType  >  ReaderType;
    typedef itk::ImageFileWriter< OutputImageType >  WriterType;

The GradientRecursiveGaussianImageFilter class is instantiated using the
input and output image types. A filter object is created with the New()
method and assigned to a {SmartPointer}.

::

    [language=C++]
    typedef itk::GradientRecursiveGaussianImageFilter<
    InputImageType,
    OutputImageType    > FilterType;

    FilterType::Pointer filter = FilterType::New();

We select a value for the :math:`\sigma` parameter of the
GradientRecursiveGaussianImageFilter. Note that this :math:`\sigma` is
specified in millimeters.

::

    [language=C++]
    filter->SetSigma( 1.5 );       Sigma in millimeters

Below, we create the reader and writer using the New() method and
assigning the result to a SmartPointer.

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

Below we connect the reader, filter and writer to form the data
processing pipeline.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );

Finally we execute the pipeline by invoking Update() on the writer. The
call is placed in a {try/catch} block in case exceptions are thrown.

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

