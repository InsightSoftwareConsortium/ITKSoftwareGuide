In ITK, {ImageToImageMetric} objects quantitatively measure how well the
transformed moving image fits the fixed image by comparing the
gray-scale intensity of the images. These metrics are very flexible and
can work with any transform or interpolation method and do not require
reduction of the gray-scale images to sparse extracted information such
as edges.

The metric component is perhaps the most critical element of the
registration framework. The selection of which metric to use is highly
dependent on the registration problem to be solved. For example, some
metrics have a large capture range while others require initialization
close to the optimal position. In addition, some metrics are only
suitable for comparing images obtained from the same imaging modality,
while others can handle inter-modality comparisons. Unfortunately, there
are no clear-cut rules as to how to choose a metric.

The basic inputs to a metric are: the fixed and moving images, a
transform and an interpolator. The method {GetValue()} can be used to
evaluate the quantitative criterion at the transform parameters
specified in the argument. Typically, the metric samples points within a
defined region of the fixed image. For each point, the corresponding
moving image position is computed using the transform with the specified
parameters, then the interpolator is used to compute the moving image
intensity at the mapped position. Details on this mapping are
illustrated in Figures {fig:ImageOverlapIterator} and
{fig:ImageOverlapInterpolator}.

The metrics also support region based evaluation. The
{SetFixedImageMask()} and {SetMovingImageMask()} methods may be used to
restrict evaluation of the metric within a specified region. The masks
may be of any type derived from {SpatialObject}.

Besides the measure value, gradient-based optimization schemes also
require derivatives of the measure with respect to each transform
parameter. The methods {GetDerivatives()} and {GetValueAndDerivatives()}
can be used to obtain the gradient information.

The following is the list of metrics currently available in ITK:

-  Mean squares
   {MeanSquaresImageToImageMetric}

-  Normalized correlation
   {NormalizedCorrelationImageToImageMetric}

-  Mean reciprocal squared difference
   {MeanReciprocalSquareDifferenceImageToImageMetric}

-  Mutual information by Viola and Wells
   {MutualInformationImageToImageMetric}

-  Mutual information by Mattes
   {MattesMutualInformationImageToImageMetric}

-  Kullback Liebler distance metric by Kullback and Liebler
   {KullbackLeiblerCompareHistogramImageToImageMetric}

-  Normalized mutual information
   {NormalizedMutualInformationHistogramImageToImageMetric}

-  Mean squares histogram
   {MeanSquaresHistogramImageToImageMetric}

-  Correlation coefficient histogram
   {CorrelationCoefficientHistogramImageToImageMetric}

-  Cardinality Match metric
   {MatchCardinalityImageToImageMetric}

-  Kappa Statistics metric
   {KappaStatisticImageToImageMetric}

-  Gradient Difference metric
   {GradientDifferenceImageToImageMetric}

In the following sections, we describe each metric type in detail. For
ease of notation, we will refer to the fixed image :math:`f(\bf{X})`
and transformed moving image :math:`(m \circ T(\bf{X}))` as images
:math:`A` and :math:`B`.

Mean Squares Metric
-------------------

{sec:MeanSquaresMetric}

The {MeanSquaresImageToImageMetric} computes the mean squared pixel-wise
difference in intensity between image :math:`A` and :math:`B` over a
user defined region:

:math:`MS(A,B) = \frac{1}{N} \sum_{i=1}^N \left( A_i - B_i \right)^2
`

    :math:`A_i` is the i-th pixel of Image A
    :math:`B_i` is the i-th pixel of Image B
    :math:`N` is the number of pixels considered

The optimal value of the metric is zero. Poor matches between images
:math:`A` and :math:`B` result in large values of the metric. This
metric is simple to compute and has a relatively large capture radius.

This metric relies on the assumption that intensity representing the
same homologous point must be the same in both images. Hence, its use is
restricted to images of the same modality. Additionally, any linear
changes in the intensity result in a poor match value.

Exploring a Metric
~~~~~~~~~~~~~~~~~~

{sec:ExploringAMetric}

Getting familiar with the characteristics of the Metric as a cost
function is fundamental in order to find the best way of setting up an
optimization process that will use this metric for solving a
registration problem. The following example illustrates a typical
mechanism for studying the characteristics of a Metric. Although the
example is using the Mean Squares metric, the same methodology can be
applied to any of the other metrics available in the toolkit.

{MeanSquaresImageMetric1.tex}

Normalized Correlation Metric
-----------------------------

{sec:NormalizedCorrelationMetric}

The {NormalizedCorrelationImageToImageMetric} computes pixel-wise
cross-correlation and normalizes it by the square root of the
autocorrelation of the images:

:math:`NC(A,B) = -1 \times \frac{ \sum_{i=1}^N \left( A_i \cdot B_i \right) }
        { \sqrt { \sum_{i=1}^N A_i^2  \cdot \sum_{i=1}^N B_i^2 } }
`

    :math:`A_i` is the i-th pixel of Image A
    :math:`B_i` is the i-th pixel of Image B
    :math:`N` is the number of pixels considered

Note the :math:`-1` factor in the metric computation. This factor is
used to make the metric be optimal when its minimum is reached. The
optimal value of the metric is then minus one. Misalignment between the
images results in small measure values. The use of this metric is
limited to images obtained using the same imaging modality. The metric
is insensitive to multiplicative factors between the two images. This
metric produces a cost function with sharp peaks and well defined
minima. On the other hand, it has a relatively small capture radius.

Mean Reciprocal Square Differences
----------------------------------

{sec:MeanReciprocalSquareDifferenceMetric}

The {MeanReciprocalSquareDifferenceImageToImageMetric} computes
pixel-wise differences and adds them after passing them through a
bell-shaped function :math:`\frac{1}{1+x^2}`:

:math:`PI(A,B) =  \sum_{i=1}^N \frac{ 1 }{ 1 + \frac{ \left( A_i - B_i \right) ^ 2}{ \lambda^2 }  }
`

    :math:`A_i` is the i-th pixel of Image A
    :math:`B_i` is the i-th pixel of Image B
    :math:`N` is the number of pixels considered
    :math:`\lambda` controls the capture radius

The optimal value is :math:`N` and poor matches results in small
measure values. The characteristics of this metric have been studied by
Penney and Holden

This image metric has the advantage of producing poor values when few
pixels are considered. This makes it consistent when its computation is
subject to the size of the overlap region between the images. The
capture radius of the metric can be regulated with the parameter
:math:`\lambda`. The profile of this metric is very peaky. The sharp
peaks of the metric help to measure spatial misalignment with high
precision. Note that the notion of capture radius is used here in terms
of the intensity domain, not the spatial domain. In that regard,
:math:`\lambda` should be given in intensity units and be associated
with the differences in intensity that will make drop the metric by
:math:`50\%`.

The metric is limited to images of the same image modality. The fact
that its derivative is large at the central peak is a problem for some
optimizers that rely on the derivative to decrease as the extrema are
reached. This metric is also sensitive to linear changes in intensity.

Mutual Information Metric
-------------------------

{sec:MutualInformationMetric}

The {MutualInformationImageToImageMetric} computes the mutual
information between image :math:`A` and image :math:`B`. Mutual
information (MI) measures how much information one random variable
(image intensity in one image) tells about another random variable
(image intensity in the other image). The major advantage of using MI is
that the actual form of the dependency does not have to be specified.
Therefore, complex mapping between two images can be modeled. This
flexibility makes MI well suited as a criterion of multi-modality
registration .

Mutual information is defined in terms of entropy. Let
:math:`H(A) = - \int p_A(a) \log p_A(a)\, da
` be the entropy of random variable :math:`A`, :math:`H(B)` the
entropy of random variable :math:`B` and
:math:`H(A,B) = \int p_{AB}(a,b) \log p_{AB}(a,b)\,da\,db
` be the joint entropy of :math:`A` and :math:`B`. If :math:`A`
and :math:`B` are independent, then
:math:`p_{AB}(a,b) = p_A(a) p_B(b)
` and :math:`H(A,B) = H(A) + H(B).
` However, if there is any dependency, then :math:`H(A,B)<H(A)+H(B).
` The difference is called Mutual Information : :math:` I(A,B) `
:math:`I(A,B)=H(A)+H(B)-H(A,B)
`

Parzen Windowing
~~~~~~~~~~~~~~~~

    |image| [Parzen Windowing in Mutual Information] { In Parzen
    windowing, a continuous density function is constructed by
    superimposing kernel functions (Gaussian function in this case)
    centered on the intensity samples obtained from the
    image.{fig:ParzenWindowing}}

In a typical registration problem, direct access to the marginal and
joint probability densities is not available and hence the densities
must be estimated from the image data. Parzen windows (also known as
kernel density estimators) can be used for this purpose. In this scheme,
the densities are constructed by taking intensity samples :math:`S`
from the image and super-positioning kernel functions :math:`K(\cdot)`
centered on the elements of :math:`S` as illustrated in Figure
{fig:ParzenWindowing}:

A variety of functions can be used as the smoothing kernel with the
requirement that they are smooth, symmetric, have zero mean and
integrate to one. For example, boxcar, Gaussian and B-spline functions
are suitable candidates. A smoothing parameter is used to scale the
kernel function. The larger the smoothing parameter, the wider the
kernel function used and hence the smoother the density estimate. If the
parameter is too large, features such as modes in the density will get
smoothed out. On the other hand, if the smoothing parameter is too
small, the resulting density may be too noisy. The estimation is given
by the following equation.

:math:`p(a) \approx P^{*}(a) = \frac{1}{N} \sum_{s_j \in S} K\left(a - s_j\right)
`

Choosing the optimal smoothing parameter is a difficult research problem
and beyond the scope of this software guide. Typically, the optimal
value of the smoothing parameter will depend on the data and the number
of samples used.

Viola and Wells Implementation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Insight Toolkit has multiple implementations of the mutual
information metric. One of the most commonly used is
{MutualInformationImageToImageMetric} and follows the method specified
by Viola and Wells in .

In this implementation, two separate intensity samples :math:`S` and
:math:`R` are drawn from the image: the first to compute the density,
and the second to approximate the entropy as a sample mean:
:math:`H(A) = \frac{1}{N} \sum_{r_j \in R} \log P^{*}(r_j).
` Gaussian density is used as a smoothing kernel, where the standard
deviation :math:`\sigma` acts as the smoothing parameter.

The number of spatial samples used for computation is defined using the
{SetNumberOfSpatialSamples()} method. Typical values range from 50 to
100. Note that computation involves an :math:`N \times N` loop and
hence, the computation burden becomes very expensive when a large number
of samples is used.

The quality of the density estimates depends on the choice of the
standard deviation of the Gaussian kernel. The optimal choice will
depend on the content of the images. In our experience with the toolkit,
we have found that a standard deviation of 0.4 works well for images
that have been normalized to have a mean of zero and standard deviation
of 1.0. The standard deviation of the fixed image and moving image
kernel can be set separately using methods
{SetFixedImageStandardDeviation()} and
{SetMovingImageStandardDeviation()}.

Mattes et al. Implementation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Another form of mutual information metric available in ITK follows the
method specified by Mattes et al. in and is implemented by the
{MattesMutualInformationImageToImageMetric} class.

In this implementation, only one set of intensity samples is drawn from
the image. Using this set, the marginal and joint probability density
function (PDF) is evaluated at discrete positions or bins uniformly
spread within the dynamic range of the images. Entropy values are then
computed by summing over the bins.

The number of spatial samples used is set using method
{SetNumberOfSpatialSamples()}. The number of bins used to compute the
entropy values is set via {SetNumberOfHistogramBins()}.

Since the fixed image PDF does not contribute to the metric derivatives,
it does not need to be smooth. Hence, a zero order (boxcar) B-spline
kernel is used for computing the PDF. On the other hand, to ensure
smoothness, a third order B-spline kernel is used to compute the moving
image intensity PDF. The advantage of using a B-spline kernel over a
Gaussian kernel is that the B-spline kernel has a finite support region.
This is computationally attractive, as each intensity sample only
affects a small number of bins and hence does not require a
:math:`N \times N` loop to compute the metric value.

During the PDF calculations, the image intensity values are linearly
scaled to have a minimum of zero and maximum of one. This rescaling
means that a fixed B-spline kernel bandwidth of one can be used to
handle image data with arbitrary magnitude and dynamic range.

Kullback-Leibler distance metric
--------------------------------

The {KullbackLeiblerCompareHistogramImageToImageMetric} is yet another
information based metric. Kullback-Leibler distance measures the
relative entropy between two discrete probability distributions. The
distributions are obtained from the histograms of the two input images,
:math:`A` and :math:`B`.

The Kullback-Liebler distance between two histograms is given by
:math:`KL(A,B) =  \sum_i^N p_A(i) \times \log \frac{ p_A(i) }{p_B(i) }
`

The distance is always non-negative and is zero only if the two
distributions are the same. Note that the distance is not symmetric. In
other words, :math:`KL(A,B) \neq KL(B,A)`. Nevertheless, if the
distributions are not too dissimilar, the difference between
:math:`KL(A,B)` and :math:`KL(B,A)` is small.

The implementation in ITK is based on .

Normalized Mutual Information Metric
------------------------------------

Given two images, :math:`A` and :math:`B`, the normalized mutual
information may be computed as
:math:`NMI(A,B) = 1 + \frac{I(A,B)}{H(A,B)} = \frac{H(A) + H(B)}{H(A,B)}
` where the entropy of the images, :math:`H(A)`, :math:`H(B)`, the
mutual information, :math:`I(A,B)` and the joint entropy
:math:`H(A,B)` are computed as mentioned in
{sec:MutualInformationMetric}. Details of the implementation may be
found in the .

Mean Squares Histogram
----------------------

The {MeanSquaresHistogramImageToImageMetric} is an alternative
implementation of the Mean Squares Metric. In this implementation the
joint histogram of the fixed and the mapped moving image is built first.
The user selects the number of bins to use in this joint histogram. Once
the joint histogram is computed, the bins are visited with an iterator.
Given that each bin is associated to a pair of intensities of the form:
{fixed intensity, moving intensity}, along with the number of pixels
pairs in the images that fell in this bin, it is then possible to
compute the sum of square distances between the intensities of both
images at the quantization levels defined by the joint histogram bins.

This metric can be represented with
Equation {eqn:MeanSquaresHistogramImageToImageMetric}

:math:`\label{eqn:MeanSquaresHistogramImageToImageMetric}
MSH = \sum_f \sum_m { H(f,m) { \left( f - m \right) } ^ 2 }
`

where :math:`H(f,m)` is the count on the joint histogram bin
identified with fixed image intensity :math:`f` and moving image
intensity :math:`m`.

Correlation Coefficient Histogram
---------------------------------

The {CorrelationCoefficientHistogramImageToImageMetric} computes the
cross correlation coefficient between the intensities in the fixed image
and the intensities on the mapped moving image. This metric is intended
to be used in images of the same modality where the relationship between
the intensities of the fixed image and the intensities on the moving
images is given by a linear equation.

The correlation coefficient is computed from the Joint histogram as

:math:`\label{eqn:CorrelationCoefficientHistogramImageToImageMetric}
CC = \frac{ \sum_f \sum_m { \
            H(f,m) \left( f \cdot m - \
            \overline{f} \cdot \overline{m} \right)  } }{ \
            \sum_f { H(f) \left( (f - \overline{f})^2 \right) } \cdot \
            \sum_m { H(m) \left( (m - \overline{m})^2 \right) } }
`

Where :math:`H(f,m)` is the joint histogram count for the bin
identified with the fixed image intensity :math:`f` and the moving
image intensity :math:`m`. The values :math:`\overline{f}` and
:math:`\overline{m}` are the mean values of the fixed and moving
images respectively. :math:`H(f)` and :math:`H(m)` are the histogram
counts of the fixed and moving images respectively. The optimal value of
the correlation coefficient is :math:`1`, which would indicate a
perfect straight line in the histogram.

Cardinality Match Metric
------------------------

The {MatchCardinalityImageToImageMetric} computes cardinality of the set
of pixels that match exactly between the moving and fixed images. In
other words, it computes the number of pixel matches and mismatches
between the two images. The match is designed for label maps. All pixel
mismatches are considered equal whether they are between label 1 and
label 2 or between label 1 and label 500. In other words, the magnitude
of an individual label mismatch is not relevant, or the occurrence of a
label mismatch is important.

The spatial correspondence between the fixed and moving images is
established using a {Transform} using the {SetTransform()} method and an
interpolator using {SetInterpolator()}. Given that we are matching
pixels with labels, it is advisable to use Nearest Neighbor
interpolation.

Kappa Statistics Metric
-----------------------

The {KappaStatisticImageToImageMetric} computes spatial intersection of
two binary images. The metric here is designed for matching pixels in
two images with the same exact value, which may be set using
{SetForegroundValue()}. Given two images :math:`A` and :math:`B`,
the :math:`\kappa` coefficient is computed as

:math:`\kappa = \frac{|A| \cap |B|}{|A| + |B|}
`

where :math:`|A|` is the number of foreground pixels in image
:math:`A`. This computes the fraction of area in the two images that
is common to both the images. In the computation of the metric, only
foreground pixels are considered.

Gradient Difference Metric
--------------------------

This {GradientDifferenceImageToImageMetric} metric evaluates the
difference in the derivatives of the moving and fixed images. The
derivatives are passed through a function :math:`\frac{1}{1+x}` and
then they are added. The purpose of this metric is to focus the
registration on the edges of structures in the images. In this way the
borders exert larger influence on the result of the registration than do
the inside of the homogeneous regions on the image.

.. |image| image:: ParzenWindowing13.eps
