The source code for this section can be found in the file
``FFTImageFilter.cxx``.

In this section we assume that you are familiar with Spectral Analysis,
in particular with the concepts of the Fourier Transform and the
numerical implementation of the Fast Fourier transform. If you are not
familiar with these concepts you may want to consult first any of the
many available introductory books to spectral analysis .

This example illustrates how to use the Fast Fourier Transform filter
(FFT) for processing an image in the spectral domain. Given that FFT
computation can be CPU intensive, there are multiple hardware specific
implementations of FFT. IT is convenient in many cases to delegate the
actual computation of the transform to local available libraries.
Particular examples of those libraries are fftw [1]_ and the VXL
implementation of FFT. For this reason ITK provides a base abstract
class that factorizes the interface to multiple specific implementations
of FFT. This base class is the {ForwardFFTImageFilter}, and two of its
derived classes are {VnlForwardFFTImageFilter} and
{FFTWRealToComplexConjugateImageFilter}.

A typical application that uses FFT will need to include the following
header files.

::

    [language=C++]
    #include "itkImage.h"
    #include "itkVnlForwardFFTImageFilter.h"
    #include "itkComplexToRealImageFilter.h"
    #include "itkComplexToImaginaryImageFilter.h"

The first decision to make is related to the pixel type and dimension of
the images on which we want to compute the Fourier transform.

::

    [language=C++]
    typedef float  PixelType;
    const unsigned int Dimension = 2;

    typedef itk::Image< PixelType, Dimension > ImageType;

We use the same image type in order to instantiate the FFT filter. In
this case the {VnlForwardFFTImageFilter}. Once the filter type is
instantiated, we can use it for creating one object by invoking the
{New()} method and assigning the result to a SmartPointer.

::

    [language=C++]
    typedef itk::VnlForwardFFTImageFilter< ImageType >  FFTFilterType;

    FFTFilterType::Pointer fftFilter = FFTFilterType::New();

The input to this filter can be taken from a reader, for example.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >  ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );

    fftFilter->SetInput( reader->GetOutput() );

The execution of the filter can be triggered by invoking the {Update()}
method. Since this invocation can eventually throw and exception, the
call must be placed inside a try/catch block.

::

    [language=C++]
    try
    {
    fftFilter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Error: " << std::endl;
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

In general the output of the FFT filter will be a complex image. We can
proceed to save this image in a file for further analysis. This can be
done by simply instantiating an {ImageFileWriter} using the trait of the
output image from the FFT filter. We construct one instance of the
writer and pass the output of the FFT filter as the input of the writer.

::

    [language=C++]
    typedef FFTFilterType::OutputImageType    ComplexImageType;

    typedef itk::ImageFileWriter< ComplexImageType > ComplexWriterType;

    ComplexWriterType::Pointer complexWriter = ComplexWriterType::New();
    complexWriter->SetFileName( argv[4] );

    complexWriter->SetInput( fftFilter->GetOutput() );

Finally we invoke the {Update()} method placing inside a try/catch
block.

::

    [language=C++]
    try
    {
    complexWriter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Error: " << std::endl;
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

In addition to saving the complex image into a file, we could also
extract its real and imaginary parts for further analysis. This can be
done with the {ComplexToRealImageFilter} and the
{ComplexToImaginaryImageFilter}.

We instantiate first the ImageFilter that will help us to extract the
real part from the complex image. The {ComplexToRealImageFilter} takes
as first template parameter the type of the complex image and as second
template parameter it takes the type of the output image pixel. We
create one instance of this filter and connect as its input the output
of the FFT filter.

::

    [language=C++]
    typedef itk::ComplexToRealImageFilter<
    ComplexImageType, ImageType > RealFilterType;

    RealFilterType::Pointer realFilter = RealFilterType::New();

    realFilter->SetInput( fftFilter->GetOutput() );

Since the range of intensities in the Fourier domain can be quite
concentrated, it result convenient to rescale the image in order to
visualize it. For this purpose we instantiate here a
{RescaleIntensityImageFilter} that will rescale the intensities of the
{real} image into a range suitable for writing in a file. We also set
the minimum and maximum values of the output to the range of the pixel
type used for writing.

::

    [language=C++]
    typedef itk::RescaleIntensityImageFilter<
    ImageType,
    WriteImageType > RescaleFilterType;

    RescaleFilterType::Pointer intensityRescaler = RescaleFilterType::New();

    intensityRescaler->SetInput( realFilter->GetOutput() );

    intensityRescaler->SetOutputMinimum(  0  );
    intensityRescaler->SetOutputMaximum( 255 );

We can now instantiate the ImageFilter that will help us to extract the
imaginary part from the complex image. The filter that we use here is
the {ComplexToImaginaryImageFilter}. It takes as first template
parameter the type of the complex image and as second template parameter
it takes the type of the output image pixel. An instance of the filter
is created, and its input is connected to the output of the FFT filter.

::

    [language=C++]
    typedef FFTFilterType::OutputImageType    ComplexImageType;

    typedef itk::ComplexToImaginaryImageFilter<
    ComplexImageType, ImageType > ImaginaryFilterType;

    ImaginaryFilterType::Pointer imaginaryFilter = ImaginaryFilterType::New();

    imaginaryFilter->SetInput( fftFilter->GetOutput() );

The Imaginary image can then be rescaled and saved into a file, just as
we did with the Real part.

For the sake of illustrating the use of a {ImageFileReader} on Complex
images, here we instantiate a reader that will load the Complex image
that we just saved. Note that nothing special is required in this case.
The instantiation is done just the same as for any other type of image.
Which once again illustrates the power of Generic Programming.

::

    [language=C++]
    typedef itk::ImageFileReader< ComplexImageType > ComplexReaderType;

    ComplexReaderType::Pointer complexReader = ComplexReaderType::New();

    complexReader->SetFileName( argv[4] );
    complexReader->Update();

.. [1]
   http:www.fftw.org
