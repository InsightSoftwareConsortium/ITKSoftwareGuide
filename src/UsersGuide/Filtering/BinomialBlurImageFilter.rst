The source code for this section can be found in the file
``BinomialBlurImageFilter.cxx``.

The \doxygen{BinomialBlurImageFilter} computes a nearest neighbor average along
each dimension. The process is repeated a number of times, as specified
by the user. In principle, after a large number of iterations the result
will approach the convolution with a Gaussian.

.. index::
   single: BinomialBlurImageFilter

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkBinomialBlurImageFilter.h"

Types should be chosen for the pixels of the input and output images.
Image types can be instantiated using the pixel type and dimension.

::

    [language=C++]
    typedef    float    InputPixelType;
    typedef    float    OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

The filter type is now instantiated using both the input image and the
output image types. Then a filter object is created.

::

    [language=C++]
    typedef itk::BinomialBlurImageFilter<
    InputImageType, OutputImageType >  FilterType;
    FilterType::Pointer filter = FilterType::New();

The input image can be obtained from the output of another filter. Here,
an image reader is used as the source. The number of repetitions is set
with the \code{SetRepetitions()} method. Computation time will increase
linearly with the number of repetitions selected. Finally, the filter
can be executed by calling the \code{Update()} method.

.. index::
   pair: BinomialBlurImageFilter; Update
   pair: BinomialBlurImageFilter; SetInput
   pair: BinomialBlurImageFilter; SetRepetitions

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    filter->SetRepetitions( repetitions );
    filter->Update();

    |image| |image1| [BinomialBlurImageFilter output.] {Effect of the
    BinomialBlurImageFilter on a slice from a MRI proton density image
    of the brain.} {fig:BinomialBlurImageFilterInputOutput}

Figure \ref{fig:BinomialBlurImageFilterInputOutput} illustrates the effect
of this filter on a MRI proton density image of the brain.

Note that the standard deviation :math:`\sigma` of the equivalent
Gaussian is fixed. In the spatial spectrum, the effect of every
iteration of this filter is like a multiplication with a sinus cardinal
function.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: BinomialBlurImageFilterOutput.eps
