The source code for this section can be found in the file
``ImageAdaptor1.cxx``.

This example illustrates how the {ImageAdaptor} can be used to cast an
image from one pixel type to another. In particular, we will *adapt* an
{unsigned char} image to make it appear as an image of pixel type
{float}.

We begin by including the relevant headers.

::

    [language=C++]
    #include "itkImageAdaptor.h"

First, we need to define a *pixel accessor* class that does the actual
conversion. Note that in general, the only valid operations for pixel
accessors are those that only require the value of the input pixel. As
such, neighborhood type operations are not possible. A pixel accessor
must provide methods {Set()} and {Get()}, and define the types of
{InternalPixelType} and {ExternalPixelType}. The {InternalPixelType}
corresponds to the pixel type of the image to be adapted ({unsigned
char} in this example). The {ExternalPixelType} corresponds to the pixel
type we wish to emulate with the ImageAdaptor ({float} in this case).

::

    [language=C++]
    class CastPixelAccessor
    {
    public:
    typedef unsigned char InternalType;
    typedef float         ExternalType;

    static void Set(InternalType & output, const ExternalType & input)
    {
    output = static_cast<InternalType>( input );
    }

    static ExternalType Get( const InternalType & input )
    {
    return static_cast<ExternalType>( input );
    }
    };

The CastPixelAccessor class simply applies a {static\_cast} to the pixel
values. We now use this pixel accessor to define the image adaptor type
and create an instance using the standard {New()} method.

::

    [language=C++]
    typedef unsigned char  InputPixelType;
    const   unsigned int   Dimension = 2;
    typedef itk::Image< InputPixelType, Dimension >   ImageType;

    typedef itk::ImageAdaptor< ImageType, CastPixelAccessor > ImageAdaptorType;
    ImageAdaptorType::Pointer adaptor = ImageAdaptorType::New();

We also create an image reader templated over the input image type and
read the input image from file.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >   ReaderType;
    ReaderType::Pointer reader = ReaderType::New();

The output of the reader is then connected as the input to the image
adaptor.

::

    [language=C++]
    adaptor->SetImage( reader->GetOutput() );

In the following code, we visit the image using an iterator instantiated
using the adapted image type and compute the sum of the pixel values.

::

    [language=C++]
    typedef itk::ImageRegionIteratorWithIndex< ImageAdaptorType >  IteratorType;
    IteratorType  it( adaptor, adaptor->GetBufferedRegion() );

    double sum = 0.0;
    it.GoToBegin();
    while( !it.IsAtEnd() )
    {
    float value = it.Get();
    sum += value;
    ++it;
    }

Although in this example, we are just performing a simple summation, the
key concept is that access to pixels is performed as if the pixel is of
type {float}. Additionally, it should be noted that the adaptor is used
as if it was an actual image and not as a filter. ImageAdaptors conform
to the same API as the {Image} class.
