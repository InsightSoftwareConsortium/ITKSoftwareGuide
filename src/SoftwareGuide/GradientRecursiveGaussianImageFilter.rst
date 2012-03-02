The source code for this section can be found in the file
``GradientRecursiveGaussianImageFilter.cxx``.

This example illustrates the use of the
{GradientRecursiveGaussianImageFilter}.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkGradientRecursiveGaussianImageFilter.h"

Types should be instantiated based on the pixels of the input and output
images.

::

    [language=C++]
    const unsigned int  Dimension = 3;
    typedef    float    InputPixelType;
    typedef    float    OutputComponentPixelType;

    typedef itk::CovariantVector<
    OutputComponentPixelType, Dimension > OutputPixelType;

With them, the input and output image types can be instantiated.

::

    [language=C++]
    typedef itk::Image< InputPixelType,  Dimension >   InputImageType;
    typedef itk::Image< OutputPixelType, Dimension >   OutputImageType;

The filter type is now instantiated using both the input image and the
output image types.

::

    [language=C++]
    typedef itk::GradientRecursiveGaussianImageFilter<
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

The standard deviation of the Gaussian smoothing kernel is now set.

::

    [language=C++]
    filter->SetSigma( sigma );

Finally the filter is executed by invoking the {Update()} method.

::

    [language=C++]
    filter->Update();

If connected to other filters in a pipeline, this filter will
automatically update when any downstream filters are updated. For
example, we may connect this gradient magnitude filter to an image file
writer and then update the writer.

::

    [language=C++]
    writer->SetInput( filter->GetOutput() );
    writer->Update();

