The source code for this section can be found in the file
``ImageRegistration4.cxx``.

In this example, we will solve a simple multi-modality problem using
another implementation of mutual information. This implementation was
published by Mattes *et. al* . One of the main differences between
{MattesMutualInformationImageToImageMetric} and
{MutualInformationImageToImageMetric} is that only one spatial sample
set is used for the whole registration process instead of using new
samples every iteration. The use of a single sample set results in a
much smoother cost function and hence allows the use of more intelligent
optimizers. In this example, we will use the
RegularStepGradientDescentOptimizer. Another noticeable difference is
that pre-normalization of the images is not necessary as the metric
rescales internally when building up the discrete density functions.
Other differences between the two mutual information implementations are
described in detail in Section {sec:MutualInformationMetric}.

First, we include the header files of the components used in this
example.

::

    [language=C++]
    #include "itkImageRegistrationMethod.h"
    #include "itkTranslationTransform.h"
    #include "itkMattesMutualInformationImageToImageMetric.h"
    #include "itkRegularStepGradientDescentOptimizer.h"

In this example the image types and all registration components, except
the metric, are declared as in Section
{sec:IntroductionImageRegistration}. The Mattes mutual information
metric type is instantiated using the image types.

::

    [language=C++]
    typedef itk::MattesMutualInformationImageToImageMetric<
    FixedImageType,
    MovingImageType >    MetricType;

The metric is created using the {New()} method and then connected to the
registration object.

::

    [language=C++]
    MetricType::Pointer metric = MetricType::New();
    registration->SetMetric( metric  );

The metric requires two parameters to be selected: the number of bins
used to compute the entropy and the number of spatial samples used to
compute the density estimates. In typical application 50 histogram bins
are sufficient. Note however, that the number of bins may have dramatic
effects on the optimizer’s behavior. The number of spatial samples to be
used depends on the content of the image. If the images are smooth and
do not contain much detail, then using approximately :math:`1` percent
of the pixels will do. On the other hand, if the images are detailed, it
may be necessary to use a much higher proportion, such as :math:`20`
percent.

::

    [language=C++]
    unsigned int numberOfBins = 24;
    unsigned int numberOfSamples = 10000;

::

    [language=C++]
    metric->SetNumberOfHistogramBins( numberOfBins );
    metric->SetNumberOfSpatialSamples( numberOfSamples );

One mechanism for bringing the Metric to its limit is to disable the
sampling and use all the pixels present in the FixedImageRegion. This
can be done with the {UseAllPixelsOn()} method. You may want to try this
option only while you are fine tuning all other parameters of your
registration. We don’t use this method in this current example though.

Another significant difference in the metric is that it computes the
negative mutual information and hence we need to minimize the cost
function in this case. In this example we will use the same optimization
parameters as in Section {sec:IntroductionImageRegistration}.

::

    [language=C++]
    optimizer->MinimizeOn();
    optimizer->SetMaximumStepLength( 2.00 );
    optimizer->SetMinimumStepLength( 0.001 );
    optimizer->SetNumberOfIterations( 200 );

Whenever the regular step gradient descent optimizer encounters that the
direction of movement has changed in the parametric space, it reduces
the size of the step length. The rate at which the step length is
reduced is controlled by a relaxation factor. The default value of the
factor is :math:`0.5`. This value, however may prove to be inadequate
for noisy metrics since they tend to induce very erratic movements on
the optimizers and therefore result in many directional changes. In
those conditions, the optimizer will rapidly shrink the step length
while it is still too far from the location of the extrema in the cost
function. In this example we set the relaxation factor to a number
higher than the default in order to prevent the premature shrinkage of
the step length.

::

    [language=C++]
    optimizer->SetRelaxationFactor( 0.8 );

This example is executed using the same multi-modality images as the one
in section {sec:MultiModalityRegistrationViolaWells} The registration
converges after :math:`59` iterations and produces the following
results:

::

    Translation X = 13.0283
    Translation Y = 17.007

These values are a very close match to the true misalignment introduced
in the moving image.

    |image| |image1| |image2| [MattesMutualInformationImageToImageMetric
    output images] {The mapped moving image (left) and the composition
    of fixed and moving images before (center) and after (right)
    registration with Mattes mutual information.}
    {fig:ImageRegistration4Output}

The result of resampling the moving image is presented on the left of
Figure {fig:ImageRegistration4Output}. The center and right parts of the
figure present a checkerboard composite of the fixed and moving images
before and after registration respectively.

    |image3| |image4| |image5|
    [MattesMutualInformationImageToImageMetric output plots] {Sequence
    of translations and metric values at each iteration of the
    optimizer.} {fig:ImageRegistration4TraceTranslations}

Figure {fig:ImageRegistration4TraceTranslations} (upper-left) shows the
sequence of translations followed by the optimizer as it searched the
parameter space. The upper-right figure presents a closer look at the
convergence basin for the last iterations of the optimizer. The bottom
of the same figure shows the sequence of metric values computed as the
optimizer searched the parameter space. Comparing these trace plots with
Figures {fig:ImageRegistration2TraceTranslations} and
{fig:ImageRegistration2TraceMetric}, we can see that the measures
produced by MattesMutualInformationImageToImageMetric are smoother than
those of the MutualInformationImageToImageMetric. This smoothness allows
the use of more sophisticated optimizers such as the
{RegularStepGradientDescentOptimizer} which efficiently locks onto the
optimal value.

You must note however that there are a number of non-trivial issues
involved in the fine tuning of parameters for the optimization. For
example, the number of bins used in the estimation of Mutual Information
has a dramatic effect on the performance of the optimizer. In order to
illustrate this effect, this same example has been executed using a
range of different values for the number of bins, from :math:`10` to
:math:`30`. If you repeat this experiment, you will notice that
depending on the number of bins used, the optimizer’s path may get
trapped early on in local minima. Figure
{fig:ImageRegistration4TraceTranslationsNumberOfBins} shows the multiple
paths that the optimizer took in the parametric space of the transform
as a result of different selections on the number of bins used by the
Mattes Mutual Information metric. Note that many of the paths die in
local minima instead of reaching the extrema value on the upper right
corner.

    |image6| [MattesMutualInformationImageToImageMetric number of bins]
    {Sensitivity of the optimization path to the number of Bins used for
    estimating the value of Mutual Information with Mattes et al.
    approach.} {fig:ImageRegistration4TraceTranslationsNumberOfBins}

Effects such as the one illustrated here highlight how useless is to
compare different algorithms based on a non-exhaustive search of their
parameter setting. It is quite difficult to be able to claim that a
particular selection of parameters represent the best combination for
running a particular algorithm. Therefore, when comparing the
performance of two or more different algorithms, we are faced with the
challenge of proving that none of the algorithms involved in the
comparison is being run with a sub-optimal set of parameters.

The plots in Figures {fig:ImageRegistration4TraceTranslations}
and {fig:ImageRegistration4TraceTranslationsNumberOfBins} were generated
using Gnuplot. The scripts used for this purpose are available in the
{InsightDocuments} CVS module under the directory

 {InsightDocuments/SoftwareGuide/Art}

The use of these scripts was similar to what was described at the end of
section {sec:MultiModalityRegistrationViolaWells}.

.. |image| image:: ImageRegistration4Output.eps
.. |image1| image:: ImageRegistration4CheckerboardBefore.eps
.. |image2| image:: ImageRegistration4CheckerboardAfter.eps
.. |image3| image:: ImageRegistration4TraceTranslations.eps
.. |image4| image:: ImageRegistration4TraceTranslations2.eps
.. |image5| image:: ImageRegistration4TraceMetric.eps
.. |image6| image:: ImageRegistration4TraceTranslationsNumberOfBins.eps
