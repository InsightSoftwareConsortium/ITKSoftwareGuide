The source code for this section can be found in the file
``ImageRegistration2.cxx``.

The following simple example illustrates how multiple imaging modalities
can be registered using the ITK registration framework. The first
difference between this and previous examples is the use of the
{MutualInformationImageToImageMetric} as the cost-function to be
optimized. The second difference is the use of the
{GradientDescentOptimizer}. Due to the stochastic nature of the metric
computation, the values are too noisy to work successfully with the
{RegularStepGradientDescentOptimizer}. Therefore, we will use the
simpler GradientDescentOptimizer with a user defined learning rate. The
following headers declare the basic components of this registration
method.

::

    [language=C++]
    #include "itkImageRegistrationMethod.h"
    #include "itkTranslationTransform.h"
    #include "itkMutualInformationImageToImageMetric.h"
    #include "itkGradientDescentOptimizer.h"

One way to simplify the computation of the mutual information is to
normalize the statistical distribution of the two input images. The
{NormalizeImageFilter} is the perfect tool for this task. It rescales
the intensities of the input images in order to produce an output image
with zero mean and unit variance. This filter has been discussed in
Section {sec:CastingImageFilters}.

::

    [language=C++]
    #include "itkNormalizeImageFilter.h"

Additionally, low-pass filtering of the images to be registered will
also increase robustness against noise. In this example, we will use the
{DiscreteGaussianImageFilter} for that purpose. The characteristics of
this filter have been discussed in Section {sec:BlurringFilters}.

::

    [language=C++]
    #include "itkDiscreteGaussianImageFilter.h"

The moving and fixed images types should be instantiated first.

::

    [language=C++]
    const    unsigned int    Dimension = 2;
    typedef  unsigned short  PixelType;

    typedef itk::Image< PixelType, Dimension >  FixedImageType;
    typedef itk::Image< PixelType, Dimension >  MovingImageType;

It is convenient to work with an internal image type because mutual
information will perform better on images with a normalized statistical
distribution. The fixed and moving images will be normalized and
converted to this internal type.

::

    [language=C++]
    typedef   float                                    InternalPixelType;
    typedef itk::Image< InternalPixelType, Dimension > InternalImageType;

The rest of the image registration components are instantiated as
illustrated in Section {sec:IntroductionImageRegistration} with the use
of the {InternalImageType}.

::

    [language=C++]
    typedef itk::TranslationTransform< double, Dimension > TransformType;
    typedef itk::GradientDescentOptimizer                  OptimizerType;
    typedef itk::LinearInterpolateImageFunction<
    InternalImageType,
    double             > InterpolatorType;
    typedef itk::ImageRegistrationMethod<
    InternalImageType,
    InternalImageType >  RegistrationType;

The mutual information metric type is instantiated using the image
types.

::

    [language=C++]
    typedef itk::MutualInformationImageToImageMetric<
    InternalImageType,
    InternalImageType >    MetricType;

The metric is created using the {New()} method and then connected to the
registration object.

::

    [language=C++]
    MetricType::Pointer         metric        = MetricType::New();
    registration->SetMetric( metric  );

The metric requires a number of parameters to be selected, including the
standard deviation of the Gaussian kernel for the fixed image density
estimate, the standard deviation of the kernel for the moving image
density and the number of samples use to compute the densities and
entropy values. Details on the concepts behind the computation of the
metric can be found in Section {sec:MutualInformationMetric}. Experience
has shown that a kernel standard deviation of :math:`0.4` works well
for images which have been normalized to a mean of zero and unit
variance. We will follow this empirical rule in this example.

::

    [language=C++]
    metric->SetFixedImageStandardDeviation(  0.4 );
    metric->SetMovingImageStandardDeviation( 0.4 );

The normalization filters are instantiated using the fixed and moving
image types as input and the internal image type as output.

::

    [language=C++]
    typedef itk::NormalizeImageFilter<
    FixedImageType,
    InternalImageType
    > FixedNormalizeFilterType;

    typedef itk::NormalizeImageFilter<
    MovingImageType,
    InternalImageType
    > MovingNormalizeFilterType;

    FixedNormalizeFilterType::Pointer fixedNormalizer =
    FixedNormalizeFilterType::New();

    MovingNormalizeFilterType::Pointer movingNormalizer =
    MovingNormalizeFilterType::New();

The blurring filters are declared using the internal image type as both
the input and output types. In this example, we will set the variance
for both blurring filters to :math:`2.0`.

::

    [language=C++]
    typedef itk::DiscreteGaussianImageFilter<
    InternalImageType,
    InternalImageType
    > GaussianFilterType;

    GaussianFilterType::Pointer fixedSmoother  = GaussianFilterType::New();
    GaussianFilterType::Pointer movingSmoother = GaussianFilterType::New();

    fixedSmoother->SetVariance( 2.0 );
    movingSmoother->SetVariance( 2.0 );

The output of the readers becomes the input to the normalization
filters. The output of the normalization filters is connected as input
to the blurring filters. The input to the registration method is taken
from the blurring filters.

::

    [language=C++]
    fixedNormalizer->SetInput(  fixedImageReader->GetOutput() );
    movingNormalizer->SetInput( movingImageReader->GetOutput() );

    fixedSmoother->SetInput( fixedNormalizer->GetOutput() );
    movingSmoother->SetInput( movingNormalizer->GetOutput() );

    registration->SetFixedImage(    fixedSmoother->GetOutput()    );
    registration->SetMovingImage(   movingSmoother->GetOutput()   );

We should now define the number of spatial samples to be considered in
the metric computation. Note that we were forced to postpone this
setting until we had done the preprocessing of the images because the
number of samples is usually defined as a fraction of the total number
of pixels in the fixed image.

The number of spatial samples can usually be as low as :math:`1\%` of
the total number of pixels in the fixed image. Increasing the number of
samples improves the smoothness of the metric from one iteration to
another and therefore helps when this metric is used in conjunction with
optimizers that rely of the continuity of the metric values. The
trade-off, of course, is that a larger number of samples result in
longer computation times per every evaluation of the metric.

It has been demonstrated empirically that the number of samples is not a
critical parameter for the registration process. When you start fine
tuning your own registration process, you should start using high values
of number of samples, for example in the range of :math:`20\%` to
:math:`50\%` of the number of pixels in the fixed image. Once you have
succeeded to register your images you can then reduce the number of
samples progressively until you find a good compromise on the time it
takes to compute one evaluation of the Metric. Note that it is not
useful to have very fast evaluations of the Metric if the noise in their
values results in more iterations being required by the optimizer to
converge. You must then study the behavior of the metric values as the
iterations progress, just as illustrated in
section {sec:MonitoringImageRegistration}.

::

    [language=C++]
    const unsigned int numberOfPixels = fixedImageRegion.GetNumberOfPixels();

    const unsigned int numberOfSamples =
    static_cast< unsigned int >( numberOfPixels * 0.01 );

    metric->SetNumberOfSpatialSamples( numberOfSamples );

Since larger values of mutual information indicate better matches than
smaller values, we need to maximize the cost function in this example.
By default the GradientDescentOptimizer class is set to minimize the
value of the cost-function. It is therefore necessary to modify its
default behavior by invoking the {MaximizeOn()} method. Additionally, we
need to define the optimizer’s step size using the {SetLearningRate()}
method.

::

    [language=C++]
    optimizer->SetLearningRate( 15.0 );
    optimizer->SetNumberOfIterations( 200 );
    optimizer->MaximizeOn();

Note that large values of the learning rate will make the optimizer
unstable. Small values, on the other hand, may result in the optimizer
needing too many iterations in order to walk to the extrema of the cost
function. The easy way of fine tuning this parameter is to start with
small values, probably in the range of :math:`\{5.0,10.0\}`. Once the
other registration parameters have been tuned for producing convergence,
you may want to revisit the learning rate and start increasing its value
until you observe that the optimization becomes unstable. The ideal
value for this parameter is the one that results in a minimum number of
iterations while still keeping a stable path on the parametric space of
the optimization. Keep in mind that this parameter is a multiplicative
factor applied on the gradient of the Metric. Therefore, its effect on
the optimizer step length is proportional to the Metric values
themselves. Metrics with large values will require you to use smaller
values for the learning rate in order to maintain a similar optimizer
behavior.

Let’s execute this example over two of the images provided in
{Examples/Data}:

-  {BrainT1SliceBorder20.png}

-  {BrainProtonDensitySliceShifted13x17y.png}

    |image| |image1| [Multi-Modality Registration Inputs] {A T1 MRI
    (fixed image) and a proton density MRI (moving image) are provided
    as input to the registration method.}
    {fig:FixedMovingImageRegistration2}

The second image is the result of intentionally translating the image
{Brain-Proton-Density-Slice-Border20.png} by :math:`(13,17)`
millimeters. Both images have unit-spacing and are shown in Figure
{fig:FixedMovingImageRegistration2}. The registration is stopped at 200
iterations and produces as result the parameters:

::

    Translation X = 12.9147
    Translation Y = 17.0871

These values are approximately within one tenth of a pixel from the true
misalignment introduced in the moving image.

    |image2| |image3| |image4| [Multi-Modality Registration outputs]
    {Mapped moving image (left) and composition of fixed and moving
    images before (center) and after (right) registration.}
    {fig:ImageRegistration2Output}

The moving image after resampling is presented on the left side of
Figure {fig:ImageRegistration2Output}. The center and right figures
present a checkerboard composite of the fixed and moving images before
and after registration.

    |image5| |image6| [Multi-Modality Registration plot of translations]
    {Sequence of translations during the registration process. On the
    left are iterations 0 to 200. On the right are iterations 150 to
    200.} {fig:ImageRegistration2TraceTranslations}

Figure {fig:ImageRegistration2TraceTranslations} shows the sequence of
translations followed by the optimizer as it searched the parameter
space. The left plot shows iterations :math:`0` to :math:`200` while
the right figure zooms into iterations :math:`150` to :math:`200`.
The area covered by the right figure has been highlighted by a rectangle
in the left image. It can be seen that after a certain number of
iterations the optimizer oscillates within one or two pixels of the true
solution. At this point it is clear that more iterations will not help.
Instead it is time to modify some of the parameters of the registration
process, for example, reducing the learning rate of the optimizer and
continuing the registration so that smaller steps are taken.

    |image7| |image8| [Multi-Modality Registration plot of metrics] {The
    sequence of metric values produced during the registration process.
    On the left are iterations 0 to 200. On the right are iterations 150
    to 200.} {fig:ImageRegistration2TraceMetric}

Figure {fig:ImageRegistration2TraceMetric} shows the sequence of metric
values computed as the optimizer searched the parameter space. The left
plot shows values when iterations are extended from :math:`0` to
:math:`200` while the right figure zooms into iterations :math:`150`
to :math:`200`. The fluctuations in the metric value are due to the
stochastic nature in which the measure is computed. At each call of
{GetValue()}, two new sets of intensity samples are randomly taken from
the image to compute the density and entropy estimates. Even with the
fluctuations, the measure initially increases overall with the number of
iterations. After about 150 iterations, the metric value merely
oscillates without further noticeable convergence. The trace plots in
Figure {fig:ImageRegistration2TraceMetric} highlight one of the
difficulties associated with this particular metric: the stochastic
oscillations make it difficult to determine convergence and limit the
use of more sophisticated optimization methods. As explained above, the
reduction of the learning rate as the registration progresses is very
important in order to get precise results.

This example shows the importance of tracking the evolution of the
registration method in order to obtain insight into the characteristics
of the particular problem at hand and the components being used. The
behavior revealed by these plots usually helps to identify possible
improvements in the setup of the registration parameters.

The plots in Figures {fig:ImageRegistration2TraceTranslations}
and {fig:ImageRegistration2TraceMetric} were generated using
Gnuplot [1]_. The scripts used for this purpose are available in the
{InsightDocuments} CVS module under the directory

 {InsightDocuments/SoftwareGuide/Art}

Data for the plots was taken directly from the output that the
Command/Observer in this example prints out to the console. The output
was processed with the UNIX editor {sed} [2]_ in order to remove commas
and brackets that were confusing for Gnuplot’s parser. Both the shell
script for running {sed} and for running {Gnuplot} are available in the
directory indicated above. You may find useful to run them in order to
verify the results presented here, and to eventually modify them for
profiling your own registrations.

Open Science is not just an abstract concept. Open Science is something
to be practiced every day with the simple gesture of sharing information
with your peers, and by providing all the tools that they need for
replicating the results that you are reporting. In Open Science, the
only bad results are those that can not be replicated [3]_. Science is
dead when people blindly trust authorities  [4]_ instead of verifying
their statements by performing their own experiments  .

.. [1]
   http:www.gnuplot.info/

.. [2]
   http:www.gnu.org/software/sed/sed.html

.. [3]
   http:science.creativecommons.org/

.. [4]
   For example: Reviewers of Scientific Journals.

.. |image| image:: BrainT1SliceBorder20.eps
.. |image1| image:: BrainProtonDensitySliceShifted13x17y.eps
.. |image2| image:: ImageRegistration2Output.eps
.. |image3| image:: ImageRegistration2CheckerboardBefore.eps
.. |image4| image:: ImageRegistration2CheckerboardAfter.eps
.. |image5| image:: ImageRegistration2TraceTranslations.eps
.. |image6| image:: ImageRegistration2TraceTranslations2.eps
.. |image7| image:: ImageRegistration2TraceMetric.eps
.. |image8| image:: ImageRegistration2TraceMetric2.eps
