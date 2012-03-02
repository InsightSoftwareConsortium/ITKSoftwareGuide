Grayscale Filters
^^^^^^^^^^^^^^^^^

{sec:MathematicalMorphologyGrayscaleFilters}

The source code for this section can be found in the file
``MathematicalMorphologyGrayscaleFilters.cxx``.

The following section illustrates the use of filters for performing
basic mathematical morphology operations on grayscale images. The
{GrayscaleErodeImageFilter} and {GrayscaleDilateImageFilter} are covered
in this example. The filter names clearly specify the type of image on
which they operate. The header files required for a simple example of
the use of grayscale mathematical morphology filters are presented
below.

::

    [language=C++]
    #include "itkGrayscaleErodeImageFilter.h"
    #include "itkGrayscaleDilateImageFilter.h"
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

Mathematical morphology operations are based on the application of an
operator over a neighborhood of each input pixel. The combination of the
rule and the neighborhood is known as *structuring element*. Although
some rules have become the de facto standard in image processing there
is a good deal of freedom as to what kind of algorithmic rule should be
applied on the neighborhood. The implementation in ITK follows the
typical rule of minimum for erosion and maximum for dilation.

The structuring element is implemented as a {NeighborhoodOperator}. In
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
    typedef itk::GrayscaleErodeImageFilter<
    InputImageType,
    OutputImageType,
    StructuringElementType >  ErodeFilterType;

    typedef itk::GrayscaleDilateImageFilter<
    InputImageType,
    OutputImageType,
    StructuringElementType >  DilateFilterType;

The filters can now be created by invoking the {New()} method and
assigning the result to SmartPointers.

::

    [language=C++]
    ErodeFilterType::Pointer  grayscaleErode  = ErodeFilterType::New();
    DilateFilterType::Pointer grayscaleDilate = DilateFilterType::New();

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

    grayscaleErode->SetKernel(  structuringElement );
    grayscaleDilate->SetKernel( structuringElement );

A grayscale image is provided as input to the filters. This image might
be, for example, the output of a reader.

::

    [language=C++]
    grayscaleErode->SetInput(  reader->GetOutput() );
    grayscaleDilate->SetInput( reader->GetOutput() );

The filter is executed by invoking its {Update()} method, or by updating
any downstream filter, like, for example, an image writer.

::

    [language=C++]
    writerDilation->SetInput( grayscaleDilate->GetOutput() );
    writerDilation->Update();

    |image| |image1| |image2| [Effect of erosion and dilation in a
    grayscale image.] {Effect of erosion and dilation in a grayscale
    image.} {fig:MathematicalMorphologyGrayscaleFilters}

Figure {fig:MathematicalMorphologyGrayscaleFilters} illustrates the
effect of the erosion and dilation filters on a binary image from a MRI
brain slice. The figure shows how these operations can be used to remove
spurious details from segmented images.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: MathematicalMorphologyGrayscaleErosionOutput.eps
.. |image2| image:: MathematicalMorphologyGrayscaleDilationOutput.eps
