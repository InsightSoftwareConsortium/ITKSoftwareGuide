The source code for this section can be found in the file
``ImageAdaptor2.cxx``.

This example illustrates how to use the {ImageAdaptor} to access the
individual components of an RGB image. In this case, we create an
ImageAdaptor that will accept a RGB image as input and presents it as a
scalar image. The pixel data will be taken directly from the red channel
of the original image.

As with the previous example, the bulk of the effort in creating the
image adaptor is associated with the definition of the pixel accessor
class. In this case, the accessor converts a RGB vector to a scalar
containing the red channel component. Note that in the following, we do
not need to define the {Set()} method since we only expect the adaptor
to be used for reading data from the image.

::

    [language=C++]
    class RedChannelPixelAccessor
    {
    public:
    typedef itk::RGBPixel<float>   InternalType;
    typedef               float    ExternalType;

    static ExternalType Get( const InternalType & input )
    {
    return static_cast<ExternalType>( input.GetRed() );
    }
    };

The {Get()} method simply calls the {GetRed()} method defined in the
{RGBPixel} class.

Now we use the internal pixel type of the pixel accessor to define the
input image type, and then proceed to instantiate the ImageAdaptor type.

::

    [language=C++]
    typedef RedChannelPixelAccessor::InternalType  InputPixelType;
    const   unsigned int   Dimension = 2;
    typedef itk::Image< InputPixelType, Dimension >   ImageType;

    typedef itk::ImageAdaptor<  ImageType,
    RedChannelPixelAccessor > ImageAdaptorType;

    ImageAdaptorType::Pointer adaptor = ImageAdaptorType::New();

We create an image reader and connect the output to the adaptor as
before.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >   ReaderType;
    ReaderType::Pointer reader = ReaderType::New();

::

    [language=C++]
    adaptor->SetImage( reader->GetOutput() );

We create an {RescaleIntensityImageFilter} and an {ImageFileWriter} to
rescale the dynamic range of the pixel values and send the extracted
channel to an image file. Note that the image type used for the
rescaling filter is the {ImageAdaptorType} itself. That is, the adaptor
type is used in the same context as an image type.

::

    [language=C++]
    typedef itk::Image< unsigned char, Dimension >   OutputImageType;
    typedef itk::RescaleIntensityImageFilter< ImageAdaptorType,
    OutputImageType
    >   RescalerType;

    RescalerType::Pointer rescaler = RescalerType::New();
    typedef itk::ImageFileWriter< OutputImageType >   WriterType;
    WriterType::Pointer writer = WriterType::New();

Now we connect the adaptor as the input to the rescaler and set the
parameters for the intensity rescaling.

::

    [language=C++]
    rescaler->SetOutputMinimum(  0  );
    rescaler->SetOutputMaximum( 255 );

    rescaler->SetInput( adaptor );
    writer->SetInput( rescaler->GetOutput() );

Finally, we invoke the {Update()} method on the writer and take
precautions to catch any exception that may be thrown during the
execution of the pipeline.

::

    [language=C++]
    try
    {
    writer->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << "Exception caught " << excp << std::endl;
    return 1;
    }

ImageAdaptors for the green and blue channels can easily be implemented
by modifying the pixel accessor of the red channel and then using the
new pixel accessor for instantiating the type of an image adaptor. The
following define a green channel pixel accessor.

::

    [language=C++]
    class GreenChannelPixelAccessor
    {
    public:
    typedef itk::RGBPixel<float>   InternalType;
    typedef               float    ExternalType;

    static ExternalType Get( const InternalType & input )
    {
    return static_cast<ExternalType>( input.GetGreen() );
    }
    };

A blue channel pixel accessor is similarly defined.

::

    [language=C++]
    class BlueChannelPixelAccessor
    {
    public:
    typedef itk::RGBPixel<float>   InternalType;
    typedef               float    ExternalType;

    static ExternalType Get( const InternalType & input )
    {
    return static_cast<ExternalType>( input.GetBlue() );
    }
    };

    |image| |image1| |image2| |image3| [Image Adaptor to RGB Image]
    {Using ImageAdaptor to extract the components of an RGB image. The
    image on the left is a subregion of the Visible Woman cryogenic data
    set. The red, green and blue components are shown from left to right
    as scalar images extracted with an ImageAdaptor.}
    {fig:ImageAdaptorToRGBImage}

Figure {fig:ImageAdaptorToRGBImage} shows the result of extracting the
red, green and blue components from a region of the Visible Woman
cryogenic data set.

.. |image| image:: VisibleWomanEyeSlice.eps
.. |image1| image:: VisibleWomanEyeSliceRedComponent.eps
.. |image2| image:: VisibleWomanEyeSliceGreenComponent.eps
.. |image3| image:: VisibleWomanEyeSliceBlueComponent.eps
