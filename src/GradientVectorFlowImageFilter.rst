The source code for this section can be found in the file
``GradientVectorFlowImageFilter.cxx``.

The {GradientVectorFlowImageFilter} smooths multi-components images such
as vector fields and color images by applying a computation of the
diffusion equation. A typical use of this filter is to smooth the vector
field resulting from computing the gradient of an image, with the
purpose of using the smoothed field in order to guide a deformable
model.

The input image must be a multi-components images.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkGradientVectorFlowImageFilter.h"

Types should be selected based on the pixel types required for the input
and output images. In this particular case, the input and output pixel
types are multicomponents type such as itk::Vectors.

::

    [language=C++]
    const unsigned int  Dimension = 3;
    typedef    float    InputValueType;
    typedef    float    OutputValueType;
    typedef    itk::Vector< InputValueType,  Dimension >  InputPixelType;
    typedef    itk::Vector< OutputValueType, Dimension >  OutputPixelType;

With them, the input and output image types can be instantiated.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;

The GradientVectorFlow filter type is now instantiated using both the
input image and the output image types.

::

    [language=C++]
    typedef itk::GradientVectorFlowImageFilter<
    InputImageType, OutputImageType >  FilterType;

A filter object is created by invoking the {New()} method and assigning
the result to a {SmartPointer}.

::

    [language=C++]
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as source.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );

The GradientVectorFlow filter requires two parameters, the number of
iterations to be performed and the noise level of the input image. The
noise level will be used to estimate the time step that should be used
in the computation of the diffusion. These two parameters are set using
the methods {SetNumberOfIterations()} and {SetNoiseLevel()}
respectively. Then the filter can be executed by invoking {Update()}.

::

    [language=C++]
    filter->SetIterationNum( numberOfIterations );
    filter->SetNoiseLevel( noiseLevel );
    filter->Update();

When using as input the result of a gradient filter, then the typical
values for the noise level will be around 2000.0.

If the output of this filter has been connected to other filters down
the pipeline, updating any of the downstream filters will triggered the
execution of this one. For example, a writer filter could have been used
after the curvature flow filter.

::

    [language=C++]
    writer->SetInput( filter->GetOutput() );
    writer->Update();

