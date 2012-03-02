The source code for this section can be found in the file
``VotingBinaryIterativeHoleFillingImageFilter.cxx``.

The {VotingBinaryIterativeHoleFillingImageFilter} applies a voting
operation in order to fill-in cavities. This can be used for smoothing
contours and for filling holes in binary images. This filter runs
internally a {VotingBinaryHoleFillingImageFilter} until no pixels change
or the maximum number of iterations has been reached.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkVotingBinaryIterativeHoleFillingImageFilter.h"

Then the pixel and image types must be defined. Note that this filter
requires the input and output images to be of the same type, therefore a
single image type is required for the template instantiation.

::

    [language=C++]
    typedef   unsigned char  PixelType;

    typedef itk::Image< PixelType, 2 >   ImageType;

Using the image types, it is now possible to define the filter type and
create the filter object.

::

    [language=C++]
    typedef itk::VotingBinaryIterativeHoleFillingImageFilter<
    ImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The size of the neighborhood is defined along every dimension by passing
a {SizeType} object with the corresponding values. The value on each
dimension is used as the semi-size of a rectangular box. For example, in
:math:`2D` a size of :math:`1,2` will result in a :math:`3 \times
5` neighborhood.

::

    [language=C++]
    ImageType::SizeType indexRadius;

    indexRadius[0] = radiusX;  radius along x
    indexRadius[1] = radiusY;  radius along y

    filter->SetRadius( indexRadius );

Since the filter is expecting a binary image as input, we must specify
the levels that are going to be considered background and foreground.
This is done with the {SetForegroundValue()} and {SetBackgroundValue()}
methods.

::

    [language=C++]
    filter->SetBackgroundValue(   0 );
    filter->SetForegroundValue( 255 );

We must also specify the majority threshold that is going to be used as
the decision criterion for converting a background pixel into a
foreground pixel. The rule of conversion is that a background pixel will
be converted into a foreground pixel if the number of foreground
neighbors surpass the number of background neighbors by the majority
value. For example, in a 2D image, with neighborhood or radius 1, the
neighborhood will have size :math:`3 \times 3`. If we set the majority
value to 2, then we are requiring that the number of foreground
neighbors should be at least (3x3 -1 )/2 + majority. This is done with
the {SetMajorityThreshold()} method.

::

    [language=C++]
    filter->SetMajorityThreshold( 2 );

Finally we specify the maximum number of iterations that this filter
should be run. The number of iteration will determine the maximum size
of holes and cavities that this filter will be able to fill-in. The more
iterations you ran, the larger the cavities that will be filled in.

::

    [language=C++]
    filter->SetMaximumNumberOfIterations( numberOfIterations );

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example, a writer. An update call on any downstream filter will
trigger the execution of the median filter.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );
    writer->Update();

    |image| |image1| |image2| |image3| [Effect of the
    VotingBinaryIterativeHoleFilling filter.] {Effect of the
    VotingBinaryIterativeHoleFillingImageFilter on a slice from a MRI
    proton density brain image that has been thresholded in order to
    produce a binary image. The output images have used radius 1,2 and 3
    respectively.}
    {fig:VotingBinaryIterativeHoleFillingImageFilterOutput}

Figure {fig:VotingBinaryIterativeHoleFillingImageFilterOutput}
illustrates the effect of the
VotingBinaryIterativeHoleFillingImageFilter filter on a thresholded
slice of MRI brain image using neighborhood radii of :math:`1,1`,
:math:`2,2` and :math:`3,3` that correspond respectively to
neighborhoods of size :math:` 3 \times 3 `, :math:` 5
\times 5 `, :math:` 7 \times 7 `. The filtered image demonstrates the
capability of this filter for reducing noise both in the background and
foreground of the image, as well as smoothing the contours of the
regions.

.. |image| image:: BinaryThresholdImageFilterOutput.eps
.. |image1| image:: VotingBinaryIterativeHoleFillingImageFilterOutput1.eps
.. |image2| image:: VotingBinaryIterativeHoleFillingImageFilterOutput2.eps
.. |image3| image:: VotingBinaryIterativeHoleFillingImageFilterOutput3.eps
