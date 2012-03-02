The source code for this section can be found in the file
``FFTImageFilterFourierDomainFiltering.cxx``.

One of the most common image processing operations performed in the
Fourier Domain is the masking of the spectrum in order to eliminate a
range of spatial frequencies from the input image. This operation is
typically performed by taking the input image, computing its Fourier
transform using a FFT filter, masking the resulting image in the Fourier
domain with a mask, and finally taking the result of the masking and
computing its inverse Fourier transform.

This typical processing is what it is illustrated in the example below.

We start by including the headers of the FFT filters and the Mask image
filter. Note that we use two different types of FFT filters here. The
first one expects as input an image of real pixel type (real in the
sense of complex numbers) and produces as output a complex image. The
second FFT filter expects as in put a complex image and produces a real
image as output.

::

    [language=C++]
    #include "itkVnlForwardFFTImageFilter.h"
    #include "itkVnlInverseFFTImageFilter.h"
    #include "itkMaskImageFilter.h"

The first decision to make is related to the pixel type and dimension of
the images on which we want to compute the Fourier transform.

::

    [language=C++]
    typedef float  InputPixelType;
    const unsigned int Dimension = 2;

    typedef itk::Image< InputPixelType, Dimension > InputImageType;

Then we select the pixel type to use for the mask image and instantiate
the image type of the mask.

::

    [language=C++]
    typedef unsigned char  MaskPixelType;

    typedef itk::Image< MaskPixelType, Dimension > MaskImageType;

Both the input image and the mask image can be read from files or could
be obtained as the output of a preprocessing pipeline. We omit here the
details of reading the image since the process is quite standard.

Now the {VnlForwardFFTImageFilter} can be instantiated. Like most ITK
filters, the FFT filter is instantiated using the full image type. By
not setting the output image type, we decide to use the default one
provided by the filter. Using the type we construct one instance of the
filter.

::

    [language=C++]
    typedef itk::VnlForwardFFTImageFilter< InputImageType >  FFTFilterType;

    FFTFilterType::Pointer fftFilter = FFTFilterType::New();

    fftFilter->SetInput( inputReader->GetOutput() );

Since our purpose is to perform filtering in the frequency domain by
altering the weights of the image spectrum, we need here a filter that
will mask the Fourier transform of the input image with a binary image.
Note that the type of the spectral image is taken here from the traits
of the FFT filter.

::

    [language=C++]
    typedef FFTFilterType::OutputImageType    SpectralImageType;

    typedef itk::MaskImageFilter< SpectralImageType,
    MaskImageType,
    SpectralImageType >  MaskFilterType;

    MaskFilterType::Pointer maskFilter = MaskFilterType::New();

We connect the inputs to the mask filter by taking the outputs from the
first FFT filter and from the reader of the Mask image.

::

    [language=C++]
    maskFilter->SetInput1( fftFilter->GetOutput() );
    maskFilter->SetInput2( maskReader->GetOutput() );

For the purpose of verifying the aspect of the spectrum after being
filtered with the mask, we can write out the output of the Mask filter
to a file.

::

    [language=C++]
    typedef itk::ImageFileWriter< SpectralImageType > SpectralWriterType;
    SpectralWriterType::Pointer spectralWriter = SpectralWriterType::New();
    spectralWriter->SetFileName("filteredSpectrum.mhd");
    spectralWriter->SetInput( maskFilter->GetOutput() );
    spectralWriter->Update();

The output of the mask filter will contain the *filtered* spectrum of
the input image. We must then apply an inverse Fourier transform on it
in order to obtain the filtered version of the input image. For that
purpose we create another instance of the FFT filter.

::

    [language=C++]
    typedef itk::VnlInverseFFTImageFilter<
    SpectralImageType >  IFFTFilterType;

    IFFTFilterType::Pointer fftInverseFilter = IFFTFilterType::New();

    fftInverseFilter->SetInput( maskFilter->GetOutput() );

The execution of the pipeline can be triggered by invoking the
{Update()} method in this last filter. Since this invocation can
eventually throw and exception, the call must be placed inside a
try/catch block.

::

    [language=C++]
    try
    {
    fftInverseFilter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Error: " << std::endl;
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

The result of the filtering can now be saved into an image file, or be
passed to a subsequent processing pipeline. Here we simply write it out
to an image file.

::

    [language=C++]
    typedef itk::ImageFileWriter< InputImageType > WriterType;
    WriterType::Pointer writer = WriterType::New();
    writer->SetFileName( argv[3] );
    writer->SetInput( fftInverseFilter->GetOutput() );

Note that this example is just a minimal illustration of the multiple
types of processing that are possible in the Fourier domain.
