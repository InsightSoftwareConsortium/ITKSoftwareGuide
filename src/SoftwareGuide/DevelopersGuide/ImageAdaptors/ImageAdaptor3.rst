The source code for this section can be found in the file
``ImageAdaptor3.cxx``.

This example illustrates the use of {ImageAdaptor} to obtain access to
the components of a vector image. Specifically, it shows how to manage
pixel accessors containing internal parameters. In this example we
create an image of vectors by using a gradient filter. Then, we use an
image adaptor to extract one of the components of the vector image. The
vector type used by the gradient filter is the {CovariantVector} class.

We start by including the relevant headers.

::

    [language=C++]
    #include "itkGradientRecursiveGaussianImageFilter.h"

A pixel accessors class may have internal parameters that affect the
operations performed on input pixel data. Image adaptors support
parameters in their internal pixel accessor by using the assignment
operator. Any pixel accessor which has internal parameters must
therefore implement the assignment operator. The following defines a
pixel accessor for extracting components from a vector pixel. The
{m\_Index} member variable is used to select the vector component to be
returned.

::

    [language=C++]
    class VectorPixelAccessor
    {
    public:
    typedef itk::CovariantVector<float,2>   InternalType;
    typedef                      float      ExternalType;

    VectorPixelAccessor() : m_Index(0) {}

    void operator=( const VectorPixelAccessor & vpa )
    {
    m_Index = vpa.m_Index;
    }
    ExternalType Get( const InternalType & input ) const
    {
    return static_cast<ExternalType>( input[ m_Index ] );
    }
    void SetIndex( unsigned int index )
    {
    m_Index = index;
    }
    private:
    unsigned int m_Index;
    };

The {Get()} method simply returns the *i*-th component of the vector as
indicated by the index. The assignment operator transfers the value of
the index member variable from one instance of the pixel accessor to
another.

In order to test the pixel accessor, we generate an image of vectors
using the {GradientRecursiveGaussianImageFilter}. This filter produces
an output image of {CovariantVector} pixel type. Covariant vectors are
the natural representation for gradients since they are the equivalent
of normals to iso-values manifolds.

::

    [language=C++]
    typedef unsigned char  InputPixelType;
    const   unsigned int   Dimension = 2;
    typedef itk::Image< InputPixelType,  Dimension  >   InputImageType;
    typedef itk::CovariantVector< float, Dimension  >   VectorPixelType;
    typedef itk::Image< VectorPixelType, Dimension  >   VectorImageType;
    typedef itk::GradientRecursiveGaussianImageFilter< InputImageType,
    VectorImageType> GradientFilterType;

    GradientFilterType::Pointer gradient = GradientFilterType::New();

We instantiate the ImageAdaptor using the vector image type as the first
template parameter and the pixel accessor as the second template
parameter.

::

    [language=C++]
    typedef itk::ImageAdaptor<  VectorImageType,
    VectorPixelAccessor > ImageAdaptorType;

    ImageAdaptorType::Pointer adaptor = ImageAdaptorType::New();

The index of the component to be extracted is specified from the command
line. In the following, we create the accessor, set the index and
connect the accessor to the image adaptor using the {SetPixelAccessor()}
method.

::

    [language=C++]
    VectorPixelAccessor  accessor;
    accessor.SetIndex( atoi( argv[3] ) );
    adaptor->SetPixelAccessor( accessor );

We create a reader to load the image specified from the command line and
pass its output as the input to the gradient filter.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType >   ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    gradient->SetInput( reader->GetOutput() );

    reader->SetFileName( argv[1] );
    gradient->Update();

We now connect the output of the gradient filter as input to the image
adaptor. The adaptor emulates a scalar image whose pixel values are
taken from the selected component of the vector image.

::

    [language=C++]
    adaptor->SetImage( gradient->GetOutput() );

    |image| |image1| |image2| [Image Adaptor to Vector Image] {Using
    ImageAdaptor to access components of a vector image. The input image
    on the left was passed through a gradient image filter and the two
    components of the resulting vector image were extracted using an
    image adaptor.} {fig:ImageAdaptorToVectorImage}

As in the previous example, we rescale the scalar image before writing
the image out to file. Figure {fig:ImageAdaptorToVectorImage} shows the
result of applying the example code for extracting both components of a
two dimensional gradient.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: ImageAdaptorToVectorImageComponentX.eps
.. |image2| image:: ImageAdaptorToVectorImageComponentY.eps
