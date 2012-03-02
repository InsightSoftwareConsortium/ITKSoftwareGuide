Filtering
=========

This chapter introduces the most commonly used filters found in the
toolkit. Most of these filters are intended to process images. They will
accept one or more images as input and will produce one or more images
as output. ITK is based on a data pipeline architecture in which the
output of one filter is passed as input to another filter. (See Section
{sec:DataProcessingPipeline} on page {sec:DataProcessingPipeline} for
more information.)

.. toctree::
   :maxdepth: 2

   Thresholding
   EdgeDetection
   CastImageFilters
   GradientsFiltering
   SecondOrderDerivatives

Neighborhood Filters
--------------------

{sec:NeighborhoodFilters}

The concept of locality is frequently encountered in image processing in
the form of filters that compute every output pixel using information
from a small region in the neighborhood of the input pixel. The
classical form of these filters are the :math:`3 \times 3` filters in
2D images. Convolution masks based on these neighborhoods can perform
diverse tasks ranging from noise reduction, to differential operations,
to mathematical morphology.

The Insight toolkit implements an elegant approach to neighborhood-based
image filtering. The input image is processed using a special iterator
called the {NeighborhoodIterator}. This iterator is capable of moving
over all the pixels in an image and, for each position, it can address
the pixels in a local neighborhood. Operators are defined that apply an
algorithmic operation in the neighborhood of the input pixel to produce
a value for the output pixel. The following section describes some of
the more commonly used filters that take advantage of this construction.
(See Chapter {sec:ImageIteratorsChapter} on page
{sec:ImageIteratorsChapter} for more information about iterators.)

Mean Filter
~~~~~~~~~~~

{sec:MeanFilter}

{MeanImageFilter.tex}

Median Filter
~~~~~~~~~~~~~

{sec:MedianFilter}

{MedianImageFilter.tex}

Mathematical Morphology
~~~~~~~~~~~~~~~~~~~~~~~

{sec:MathematicalMorphology}

Mathematical morphology has proved to be a powerful resource for image
processing and analysis . ITK implements mathematical morphology filters
using NeighborhoodIterators and {NeighborhoodOperator}s. The toolkit
contains two types of image morphology algorithms, filters that operate
on binary images and filters that operate on grayscale images.

Binary Filters
^^^^^^^^^^^^^^

{sec:MathematicalMorphologyBinaryFilters}

{MathematicalMorphologyBinaryFilters.tex}

Grayscale Filters
^^^^^^^^^^^^^^^^^

{sec:MathematicalMorphologyGrayscaleFilters}

{MathematicalMorphologyGrayscaleFilters.tex}

Voting Filters
~~~~~~~~~~~~~~

{sec:VotingFilters}

Voting filters are quite a generic family of filters. In fact, both the
Dilate and Erode filters from Mathematical Morphology are very
particular cases of the broader family of voting filters. In a voting
filter, the outcome of a pixel is decided by counting the number of
pixels in its neighborhood and applying a rule to the result of that
counting.For example, the typical implementation of Erosion in terms of
a voting filter will be to say that a foreground pixel will become
background if the numbers of background neighbors is greater or equal
than 1. In this context, you could imagine variations of Erosion in
which the count could be changed to require at least 3 foreground.

Binary Median Filter
^^^^^^^^^^^^^^^^^^^^

One of the particular cases of Voting filters is the
BinaryMedianImageFilter. This filter is equivalent to applying a Median
filter over a binary image. The fact of having a binary image as input
makes possible to optimize the execution of the filter since there is no
real need for sorting the pixels according to their frequency in the
neighborhood.

{BinaryMedianImageFilter.tex}

The typical effect of median filtration on a noisy digital image is a
dramatic reduction in impulse noise spikes. The filter also tends to
preserve brightness differences across signal steps, resulting in
reduced blurring of regional boundaries. The filter also tends to
preserve the positions of boundaries in an image.

Figure {fig:BinaryMedianImageFilterOutputMultipleIterations} below shows
the effect of running the median filter with a 3x3 classical window size
1, 10 and 50 times. There is a tradeoff in noise reduction and the
sharpness of the image when the window size is increased

    |image| |image1| |image2| [Effect of many iterations on the
    BinaryMedian filter.] {Effect of 1, 10 and 50 iterations of the
    BinaryMedianImageFilter using a 3x3 window.}
    {fig:BinaryMedianImageFilterOutputMultipleIterations}

.

Hole Filling Filter
^^^^^^^^^^^^^^^^^^^

Another variation of Voting filters is the Hole Filling filter. This
filter converts background pixels into foreground only when the number
of foreground pixels is a majority of the neighbors. By selecting the
size of the majority, this filter can be tuned to fill-in holes of
different size. To be more precise, the effect of the filter is actually
related to the curvature of the edge in which the pixel is located.

{VotingBinaryHoleFillingImageFilter.tex}

Iterative Hole Filling Filter
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Hole Filling filter can be used in an iterative way, by applying it
repeatedly until no pixel changes. In this context, the filter can be
seen as a binary variation of a Level Set filter.

{VotingBinaryIterativeHoleFillingImageFilter.tex}

Smoothing Filters
-----------------

{sec:SmoothingFilters}

Real image data has a level of uncertainty that is manifested in the
variability of measures assigned to pixels. This uncertainty is usually
interpreted as noise and considered an undesirable component of the
image data. This section describes several methods that can be applied
to reduce noise on images.

Blurring
~~~~~~~~

{sec:BlurringFilters}

Blurring is the traditional approach for removing noise from images. It
is usually implemented in the form of a convolution with a kernel. The
effect of blurring on the image spectrum is to attenuate high spatial
frequencies. Different kernels attenuate frequencies in different ways.
One of the most commonly used kernels is the Gaussian. Two
implementations of Gaussian smoothing are available in the toolkit. The
first one is based on a traditional convolution while the other is based
on the application of IIR filters that approximate the convolution with
a Gaussian .

Discrete Gaussian
^^^^^^^^^^^^^^^^^

{sec:DiscreteGaussianImageFilter}

{DiscreteGaussianImageFilter.tex}

Binomial Blurring
^^^^^^^^^^^^^^^^^

{sec:BinomialBlurImageFilter}

{BinomialBlurImageFilter.tex}

Recursive Gaussian IIR
^^^^^^^^^^^^^^^^^^^^^^

{sec:RecursiveGaussianImageFilter}

{SmoothingRecursiveGaussianImageFilter.tex}

Local Blurring
~~~~~~~~~~~~~~

{sec:BlurringFunctions}

In some cases it is desirable to compute smoothing in restricted regions
of the image, or to do it using different parameters that are computed
locally. The following sections describe options for applying local
smoothing in images.

Gaussian Blur Image Function
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:GaussianBlurImageFunction}

{GaussianBlurImageFunction.tex}

Edge Preserving Smoothing
~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:EdgePreservingSmoothingFilters}

Introduction to Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:IntroductionAnisotropicDiffusion}
{AnisotropicDiffusionFiltering.tex}

Gradient Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:GradientAnisotropicDiffusionImageFilter}

{GradientAnisotropicDiffusionImageFilter.tex}

Curvature Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:CurvatureAnisotropicDiffusionImageFilter}

{CurvatureAnisotropicDiffusionImageFilter.tex}

Curvature Flow
^^^^^^^^^^^^^^

{sec:CurvatureFlowImageFilter}

{CurvatureFlowImageFilter.tex}

MinMaxCurvature Flow
^^^^^^^^^^^^^^^^^^^^

{sec:MinMaxCurvatureFlowImageFilter}

{MinMaxCurvatureFlowImageFilter.tex}

Bilateral Filter
^^^^^^^^^^^^^^^^

{sec:BilateralImageFilter}

{BilateralImageFilter.tex}

Edge Preserving Smoothing in Vector Images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:VectorAnisotropicDiffusion}

Anisotropic diffusion can also be applied to images whose pixels are
vectors. In this case the diffusion is computed independently for each
vector component. The following classes implement versions of
anisotropic diffusion on vector images.

Vector Gradient Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:VectorGradientAnisotropicDiffusionImageFilter}

{VectorGradientAnisotropicDiffusionImageFilter.tex}

Vector Curvature Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:VectorCurvatureAnisotropicDiffusionImageFilter}

{VectorCurvatureAnisotropicDiffusionImageFilter.tex}

Edge Preserving Smoothing in Color Images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:ColorAnisotropicDiffusion}

Gradient Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ColorGradientAnisotropicDiffusion}

{RGBGradientAnisotropicDiffusionImageFilter.tex}

Curvature Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ColorCurvatureAnisotropicDiffusion}

{RGBCurvatureAnisotropicDiffusionImageFilter.tex}

Distance Map
------------

{sec:DistanceMap}

{DanielssonDistanceMapImageFilter.tex}

{SignedDanielssonDistanceMapImageFilter.tex}

Geometric Transformations
-------------------------

{sec:GeometricalTransformationFilters}

Filters You Should be Afraid to Use
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:ScaryImageFilters} {Change Information Image Filter}

This one is the scariest and more dangerous filter in the entire
toolkit. You should not use this filter unless you are entirely certain
that you know what you are doing. In fact if you decide to use this
filter, you should write your code, then go for a long walk, get more
coffee and ask yourself if you really needed to use this filter. If the
answer is yes, then you should discuss this issue with someone you trust
and get his/her opinion in writing. In general, if you need to use this
filter, it means that you have a poor image provider that is putting
your career at risk along with the life of any potential patient whose
images you may end up processing.

Flip Image Filter
~~~~~~~~~~~~~~~~~

{FlipImageFilter.tex}

Resample Image Filter
~~~~~~~~~~~~~~~~~~~~~

{sec:ResampleImageFilter}

Introduction
^^^^^^^^^^^^

{ResampleImageFilter.tex}

Importance of Spacing and Origin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{ResampleImageFilter2.tex}

A Complete Example
^^^^^^^^^^^^^^^^^^

{ResampleImageFilter3.tex}

Rotating an Image
^^^^^^^^^^^^^^^^^

{ResampleImageFilter4.tex}

Rotating and Scaling an Image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{ResampleImageFilter5.tex}

Resampling using a deformation field
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{WarpImageFilter1.tex}

Subsampling and image in the same space
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{SubsampleVolume}

{SubsampleVolume.tex}

Resampling an Anisotropic image to make it Isotropic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{ResampleVolumesToBeIsotropic}

{ResampleVolumesToBeIsotropic.tex}

Frequency Domain
----------------

{sec:FrequencyDomain}

Computing a Fast Fourier Transform (FFT)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{FFTImageFilter}

{FFTImageFilter.tex}

Filtering on the Frequency Domain
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{FFTImageFilterFourierDomainFiltering}

{FFTImageFilterFourierDomainFiltering.tex}

Extracting Surfaces
-------------------

{sec:ExtractingSurfaces}

Surface extraction
~~~~~~~~~~~~~~~~~~

{sec:SufaceExtraction}

{SurfaceExtraction.tex}

.. |image| image:: BinaryMedianImageFilterOutput1.eps
.. |image1| image:: BinaryMedianImageFilterOutput10.eps
.. |image2| image:: BinaryMedianImageFilterOutput50.eps
