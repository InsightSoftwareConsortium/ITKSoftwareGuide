Mean Filter
~~~~~~~~~~~

{sec:MeanFilter}

The source code for this section can be found in the file
``MeanImageFilter.cxx``.

The {MeanImageFilter} is commonly used for noise reduction. The filter
computes the value of each output pixel by finding the statistical mean
of the neighborhood of the corresponding input pixel. The following
figure illustrates the local effect of the MeanImageFilter in a
:math:`2D` case. The statistical mean of the neighborhood on the left
is passed as the output value associated with the pixel at the center of
the neighborhood.

        (200,46) ( 5.0, 0.0 ){(30.0,15.0){25}} ( 35.0, 0.0
        ){(30.0,15.0){30}} ( 65.0, 0.0 ){(30.0,15.0){32}} ( 5.0, 15.0
        ){(30.0,15.0){27}} ( 35.0, 15.0 ){(30.0,15.0){25}} ( 65.0, 15.0
        ){(30.0,15.0){29}} ( 5.0, 30.0 ){(30.0,15.0){28}} ( 35.0, 30.0
        ){(30.0,15.0){26}} ( 65.0, 30.0 ){(30.0,15.0){50}} ( 100.0, 22.0
        ){(1,0){20.0}} ( 125.0, 15.0 ){(34.0,15.0){30.22}} ( 160.0, 22.0
        ){(1,0){20.0}} ( 185.0, 15.0 ){(30.0,15.0){30}}

Note that this algorithm is sensitive to the presence of outliers in the
neighborhood. This filter will work on images of any dimension thanks to
the internal use of {SmartNeighborhoodIterator} and
{NeighborhoodOperator}. The size of the neighborhood over which the mean
is computed can be set by the user.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkMeanImageFilter.h"

Then the pixel types for input and output image must be defined and,
with them, the image types can be instantiated.

::

    [language=C++]
    typedef   unsigned char  InputPixelType;
    typedef   unsigned char  OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

Using the image types it is now possible to instantiate the filter type
and create the filter object.

::

    [language=C++]
    typedef itk::MeanImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The size of the neighborhood is defined along every dimension by passing
a {SizeType} object with the corresponding values. The value on each
dimension is used as the semi-size of a rectangular box. For example, in
:math:`2D` a size of :math:`1,2` will result in a :math:`3 \times
5` neighborhood.

::

    [language=C++]
    InputImageType::SizeType indexRadius;

    indexRadius[0] = 1;  radius along x
    indexRadius[1] = 1;  radius along y

    filter->SetRadius( indexRadius );

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example, a writer. An update call on any downstream filter will
trigger the execution of the mean filter.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );
    writer->Update();

    |image| |image1| [Effect of the MedianImageFilter] {Effect of the
    MeanImageFilter on a slice from a MRI proton density brain image.}
    {fig:MeanImageFilterOutput}

Figure {fig:MeanImageFilterOutput} illustrates the effect of this filter
on a slice of MRI brain image using neighborhood radii of :math:`1,1`
which corresponds to a :math:` 3 \times 3 ` classical neighborhood. It
can be seen from this picture that edges are rapidly degraded by the
diffusion of intensity values among neighbors.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: MeanImageFilterOutput.eps
