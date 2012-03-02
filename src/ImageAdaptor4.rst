The source code for this section can be found in the file
``ImageAdaptor4.cxx``.

Image adaptors can also be used to perform simple pixel-wise
computations on image data. The following example illustrates how to use
the {ImageAdaptor} for image thresholding.

A pixel accessor for image thresholding requires that the accessor
maintain the threshold value. Therefore, it must also implement the
assignment operator to set this internal parameter.

::

    [language=C++]
    class ThresholdingPixelAccessor
    {
    public:
    typedef unsigned char      InternalType;
    typedef unsigned char      ExternalType;

    ThresholdingPixelAccessor() : m_Threshold(0) {};

    ExternalType Get( const InternalType & input ) const
    {
    return (input > m_Threshold) ? 1 : 0;
    }
    void SetThreshold( const InternalType threshold )
    {
    m_Threshold = threshold;
    }

    void operator=( const ThresholdingPixelAccessor & vpa )
    {
    m_Threshold = vpa.m_Threshold;
    }
    private:
    InternalType m_Threshold;
    };

The {Get()} method returns one if the input pixel is above the threshold
and zero otherwise. The assignment operator transfers the value of the
threshold member variable from one instance of the pixel accessor to
another.

To create an image adaptor, we first instantiate an image type whose
pixel type is the same as the internal pixel type of the pixel accessor.

::

    [language=C++]
    typedef ThresholdingPixelAccessor::InternalType     PixelType;
    const   unsigned int   Dimension = 2;
    typedef itk::Image< PixelType,  Dimension >   ImageType;

We instantiate the ImageAdaptor using the image type as the first
template parameter and the pixel accessor as the second template
parameter.

::

    [language=C++]
    typedef itk::ImageAdaptor<  ImageType,
    ThresholdingPixelAccessor > ImageAdaptorType;

    ImageAdaptorType::Pointer adaptor = ImageAdaptorType::New();

The threshold value is set from the command line. A threshold pixel
accessor is created and connected to the image adaptor in the same
manner as in the previous example.

::

    [language=C++]
    ThresholdingPixelAccessor  accessor;
    accessor.SetThreshold( atoi( argv[3] ) );
    adaptor->SetPixelAccessor( accessor );

We create a reader to load the input image and connect the output of the
reader as the input to the adaptor.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType >   ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );
    reader->Update();

    adaptor->SetImage( reader->GetOutput() );

    |image| |image1| |image2| [Image Adaptor for performing
    computations] {Using ImageAdaptor to perform a simple image
    computation. An ImageAdaptor is used to perform binary thresholding
    on the input image on the left. The center image was created using a
    threshold of 180, while the image on the right corresponds to a
    threshold of 220.} {fig:ImageAdaptorThresholding}

As before, we rescale the emulated scalar image before writing it out to
file. Figure {fig:ImageAdaptorThresholding} illustrates the result of
applying the thresholding adaptor to a typical gray scale image using
two different threshold values. Note that the same effect could have
been achieved by using the {BinaryThresholdImageFilter} but at the price
of holding an extra copy of the image in memory.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: ImageAdaptorThresholdingA.eps
.. |image2| image:: ImageAdaptorThresholdingB.eps
