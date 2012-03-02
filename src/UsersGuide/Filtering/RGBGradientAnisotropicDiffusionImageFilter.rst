The source code for this section can be found in the file
``RGBGradientAnisotropicDiffusionImageFilter.cxx``.

The vector anisotropic diffusion approach can equally well be applied to
color images. As in the vector case, each RGB component is diffused
independently. The following example illustrates the use of the Vector
curvature anisotropic diffusion filter on an image with {RGBPixel} type.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkVectorGradientAnisotropicDiffusionImageFilter.h"

Also the headers for {Image} and {RGBPixel} type are required.

::

    [language=C++]
    #include "itkRGBPixel.h"
    #include "itkImage.h"

It is desirable to perform the computation on the RGB image using
{float} representation. However for input and output purposes {unsigned
char} RGB components are commonly used. It is necessary to cast the type
of color components along the pipeline before writing them to a file.
The {VectorCastImageFilter} is used to achieve this goal.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"
    #include "itkVectorCastImageFilter.h"

The image type is defined using the pixel type and the dimension.

::

    [language=C++]
    typedef   itk::RGBPixel< float >     InputPixelType;
    typedef itk::Image< InputPixelType,  2 >   InputImageType;

The filter type is now instantiated and a filter object is created by
the {New()} method.

::

    [language=C++]
    typedef itk::VectorGradientAnisotropicDiffusionImageFilter<
    InputImageType, InputImageType >  FilterType;
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source.

::

    [language=C++]
    typedef itk::ImageFileReader< InputImageType >  ReaderType;
    ReaderType::Pointer reader = ReaderType::New();
    reader->SetFileName( argv[1] );
    filter->SetInput( reader->GetOutput() );

This filter requires two parameters, the number of iterations to be
performed and the time step used in the computation of the level set
evolution. These parameters are set using the methods
{SetNumberOfIterations()} and {SetTimeStep()} respectively. The filter
can be executed by invoking {Update()}.

::

    [language=C++]
    filter->SetNumberOfIterations( numberOfIterations );
    filter->SetTimeStep( timeStep );
    filter->SetConductanceParameter(1.0);
    filter->Update();

The filter output is now cast to {unsigned char} RGB components by using
the {VectorCastImageFilter}.

::

    [language=C++]
    typedef itk::RGBPixel< unsigned char >   WritePixelType;
    typedef itk::Image< WritePixelType, 2 >  WriteImageType;
    typedef itk::VectorCastImageFilter<
    InputImageType, WriteImageType >  CasterType;
    CasterType::Pointer caster = CasterType::New();

Finally, the writer type can be instantiated. One writer is created and
connected to the output of the cast filter.

::

    [language=C++]
    typedef itk::ImageFileWriter< WriteImageType >  WriterType;
    WriterType::Pointer writer = WriterType::New();
    caster->SetInput( filter->GetOutput() );
    writer->SetInput( caster->GetOutput() );
    writer->SetFileName( argv[2] );
    writer->Update();

    |image| |image1| [VectorGradientAnisotropicDiffusionImageFilter on
    RGB] {Effect of the VectorGradientAnisotropicDiffusionImageFilter on
    a RGB image from a cryogenic section of the Visible Woman data set.}
    {fig:RGBVectorGradientAnisotropicDiffusionImageFilterInputOutput}

Figure {fig:RGBVectorGradientAnisotropicDiffusionImageFilterInputOutput}
illustrates the effect of this filter on a RGB image from a cryogenic
section of the Visible Woman data set. In this example the filter was
run with a time step of :math:`0.125`, and :math:`20` iterations.
The input image has :math:`570 \times 670` pixels and the processing
took :math:`4` minutes on a Pentium 4 2Ghz.

.. |image| image:: VisibleWomanHeadSlice.eps
.. |image1| image:: RGBGradientAnisotropicDiffusionImageFilterOutput.eps
