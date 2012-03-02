The source code for this section can be found in the file
``MathematicalMorphologyBinaryFilters.cxx``.

The following section illustrates the use of filters that perform basic
mathematical morphology operations on binary images. The
{BinaryErodeImageFilter} and {BinaryDilateImageFilter} are described
here. The filter names clearly specify the type of image on which they
operate. The header files required to construct a simple example of the
use of the mathematical morphology filters are included below.

::

    [language=C++]
    #include "itkBinaryErodeImageFilter.h"
    #include "itkBinaryDilateImageFilter.h"
    #include "itkBinaryBallStructuringElement.h"

The following code defines the input and output pixel types and their
associated image types.

::

    [language=C++]
    const unsigned int Dimension = 2;

    typedef unsigned char   InputPixelType;
    typedef unsigned char   OutputPixelType;

    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;

Mathematical morphology operations are implemented by applying an
operator over the neighborhood of each input pixel. The combination of
the rule and the neighborhood is known as *structuring element*.
Although some rules have become de facto standards for image processing,
there is a good deal of freedom as to what kind of algorithmic rule
should be applied to the neighborhood. The implementation in ITK follows
the typical rule of minimum for erosion and maximum for dilation.

The structuring element is implemented as a NeighborhoodOperator. In
particular, the default structuring element is the
{BinaryBallStructuringElement} class. This class is instantiated using
the pixel type and dimension of the input image.

::

    [language=C++]
    typedef itk::BinaryBallStructuringElement<
    InputPixelType,
    Dimension  >             StructuringElementType;

The structuring element type is then used along with the input and
output image types for instantiating the type of the filters.

::

    [language=C++]
    typedef itk::BinaryErodeImageFilter<
    InputImageType,
    OutputImageType,
    StructuringElementType >  ErodeFilterType;

    typedef itk::BinaryDilateImageFilter<
    InputImageType,
    OutputImageType,
    StructuringElementType >  DilateFilterType;

The filters can now be created by invoking the {New()} method and
assigning the result to {SmartPointer}s.

::

    [language=C++]
    ErodeFilterType::Pointer  binaryErode  = ErodeFilterType::New();
    DilateFilterType::Pointer binaryDilate = DilateFilterType::New();

The structuring element is not a reference counted class. Thus it is
created as a C++ stack object instead of using {New()} and
SmartPointers. The radius of the neighborhood associated with the
structuring element is defined with the {SetRadius()} method and the
{CreateStructuringElement()} method is invoked in order to initialize
the operator. The resulting structuring element is passed to the
mathematical morphology filter through the {SetKernel()} method, as
illustrated below.

::

    [language=C++]
    StructuringElementType  structuringElement;

    structuringElement.SetRadius( 1 );   3x3 structuring element

    structuringElement.CreateStructuringElement();

    binaryErode->SetKernel(  structuringElement );
    binaryDilate->SetKernel( structuringElement );

A binary image is provided as input to the filters. This image might be,
for example, the output of a binary threshold image filter.

::

    [language=C++]
    thresholder->SetInput( reader->GetOutput() );

    InputPixelType background =   0;
    InputPixelType foreground = 255;

    thresholder->SetOutsideValue( background );
    thresholder->SetInsideValue(  foreground );

    thresholder->SetLowerThreshold( lowerThreshold );
    thresholder->SetUpperThreshold( upperThreshold );

::

    [language=C++]
    binaryErode->SetInput( thresholder->GetOutput() );
    binaryDilate->SetInput( thresholder->GetOutput() );

The values that correspond to “objects” in the binary image are
specified with the methods {SetErodeValue()} and {SetDilateValue()}. The
value passed to these methods will be considered the value over which
the dilation and erosion rules will apply.

::

    [language=C++]
    binaryErode->SetErodeValue( foreground );
    binaryDilate->SetDilateValue( foreground );

The filter is executed by invoking its {Update()} method, or by updating
any downstream filter, like, for example, an image writer.

::

    [language=C++]
    writerDilation->SetInput( binaryDilate->GetOutput() );
    writerDilation->Update();

    |image| |image1| |image2| [Effect of erosion and dilation in a
    binary image.] {Effect of erosion and dilation in a binary image.}
    {fig:MathematicalMorphologyBinaryFilters}

Figure {fig:MathematicalMorphologyBinaryFilters} illustrates the effect
of the erosion and dilation filters on a binary image from a MRI brain
slice. The figure shows how these operations can be used to remove
spurious details from segmented images.

.. |image| image:: BinaryThresholdImageFilterOutput.eps
.. |image1| image:: MathematicalMorphologyBinaryErosionOutput.eps
.. |image2| image:: MathematicalMorphologyBinaryDilationOutput.eps
