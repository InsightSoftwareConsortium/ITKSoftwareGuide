The source code for this section can be found in the file
``ImageRegistrationHistogramPlotter.cxx``.

When fine tuning the parameters of an image registration process it is
not always clear what factor are having a larger impact on the behavior
of the registration. Even plotting the values of the metric and the
transform parameters may not provide a clear indication on the best way
to modify the optimizer and metric parameters in order to improve the
convergence rate and stability. In such circumstances it is useful to
take a closer look at the internals of the components involved in
computing the registration. One of the critical components is, of
course, the image metric. This section illustrates a mechanism that can
be used for monitoring the behavior of the Mutual Information metric by
continuously looking at the joint histogram at regular intervals during
the iterations of the optimizer.

This particular example shows how to use the
{HistogramToEntropyImageFilter} class in order to get access to the
joint histogram that is internally computed by the metric. This class
represents the joint histogram as a :math:`2D` image and therefore can
take advantage of the IO functionalities described in chapter {sec:IO}.
The example registers two images using the gradient descent optimizer.
The transform used here is a simple translation transform. The metric is
a {MutualInformationHistogramImageToImageMetric}.

In the code below we create a helper class called the {HistogramWriter}.
Its purpose is to save the joint histogram into a file using any of the
file formats supported by ITK. This object is invoked after every
iteration of the optimizer. The writer here saves the joint histogram
into files with names: {JointHistogramXXX.mhd} where {XXX} is replaced
with the iteration number. The output image contains the joint entropy
histogram given by :math:`f_{ij} = -p_{ij} \log_2 ( p_{ij} )
`

where the indices :math:`i` and :math:`j` identify the location of a
bin in the Joint Histogram of the two images and are in the ranges
:math:`i \in [0:N-1]` and :math:`j
\in [0:M-1]`. The image :math:`f` representing the joint histogram
has :math:`N x M` pixels because the intensities of the Fixed image
are quantized into :math:`N` histogram bins and the intensities of the
Moving image are quantized into :math:`M` histogram bins. The
probability value :math:`p_{ij}` is computed from the frequency count
of the histogram bins.
:math:`p_{ij} = \frac{q_{ij}}{\sum_{i=0}^{N-1} \sum_{j=0}^{M-1} q_{ij}}
` The value :math:`q_{ij}` is the frequency of a bin in the
histogram and it is computed as the number of pixels where the Fixed
image has intensities in the range of bin :math:`i` and the Moving
image has intensities on the range of bin :math:`j`. The value
:math:`p_{ij}` is therefore the probability of the occurrence of the
measurement vector centered in the bin :math:`{ij}`. The filter
produces an output image of pixel type {double}. For details on the use
of Histograms in ITK please refer to section {sec:Histogram}.

Depending on whether you want to see the joint histogram frequencies
directly, or the joint probabilities, or log of joint probabilities, you
may want to instantiate respectively any of the following classes

-  {HistogramToIntensityImageFilter}

-  {HistogramToProbabilityImageFilter}

-  {HistogramToLogProbabilityImageFilter}

The use of all of these classes is very similar. Note that the log of
the probability is equivalent to units of information, also known as
**bits**, more details on this concept can be found in
section {sec:ComputingImageEntropy}

The header files of the classes featured in this example are included as
a first step.

::

    [language=C++]
    #include "itkHistogramToEntropyImageFilter.h"
    #include "itkMutualInformationHistogramImageToImageMetric.h"

Here we will create a simple class to write the joint histograms. This
class, that we arbitrarily name as {HistogramWriter}, uses internally
the {HistogramToEntropyImageFilter} class among others.

::

    [language=C++]
    class HistogramWriter
    {
    public:
    typedef float InternalPixelType;
    itkStaticConstMacro( Dimension, unsigned int, 2);

    typedef itk::Image< InternalPixelType, Dimension > InternalImageType;

    typedef itk::MutualInformationHistogramImageToImageMetric<
    InternalImageType,
    InternalImageType >    MetricType;

::

    [language=C++]
    typedef MetricType::HistogramType   HistogramType;

    typedef itk::HistogramToEntropyImageFilter< HistogramType >
    HistogramToEntropyImageFilterType;

    typedef HistogramToEntropyImageFilterType::Pointer
    HistogramToImageFilterPointer;

    typedef HistogramToEntropyImageFilterType::OutputImageType OutputImageType;

    typedef itk::ImageFileWriter< OutputImageType > HistogramFileWriterType;
    typedef HistogramFileWriterType::Pointer        HistogramFileWriterPointer;

The {HistogramWriter} has a member variable {m\_Filter} of type
HistogramToEntropyImageFilter.

::

    [language=C++]
    this->m_Filter = HistogramToEntropyImageFilterType::New();

It also has an ImageFileWriter that has been instantiated using the
image type that is produced as output from the histogram to image
filter. We connect the output of the filter as input to the writer.

::

    [language=C++]
    this->m_HistogramFileWriter = HistogramFileWriterType::New();
    this->m_HistogramFileWriter->SetInput( this->m_Filter->GetOutput() );

The method of this class that is most relevant to our discussion is the
one that writes the image into a file. In this method we assign the
output histogram of the metric to the input of the histogram to image
filter. In this way we construct an ITK :math:`2D` image where every
pixel corresponds to one of the Bins of the joint histogram computed by
the Metric.

::

    [language=C++]
    void WriteHistogramFile( const char * outputFilename  )
    {

::

    [language=C++]
    this->m_Filter->SetInput( m_Metric->GetHistogram() );

The output of the filter is connected to a filter that will rescale the
intensities in order to improve the visualization of the values. This is
done because it is common to find histograms of medical images that have
a minority of bins that are largely dominant. Visualizing such histogram
in direct values is challenging because only the dominant bins tend to
become visible.

The following are the member variables of our {HistogramWriter} class.

::

    [language=C++]
    private:
    MetricPointer                   m_Metric;
    HistogramToImageFilterPointer   m_Filter;
    HistogramFileWriterPointer      m_HistogramFileWriter;

We invoke the histogram writer within the Command/Observer of the
optimizer to write joint histograms after every iteration.

::

    [language=C++]
    m_JointHistogramWriter.WriteHistogramFile( m_InitialHistogramFile.c_str() );

We instantiate an optimizer, interpolator and the registration method as
shown in previous examples.

The number of bins in the metric is set with the {SetHistogramSize()}
method. This will determine the number of pixels along each dimension of
the joint histogram. Note that in this case we arbitrarily decided to
use the same number of bins for the intensities of the Fixed image and
those of the Moving image. However, this does not have to be the case,
we could have selected different numbers of bins for each image.

::

    [language=C++]
    unsigned int numberOfHistogramBins = atoi( argv[7] );
    MetricType::HistogramType::SizeType histogramSize;
    histogramSize[0] = numberOfHistogramBins;
    histogramSize[1] = numberOfHistogramBins;
    metric->SetHistogramSize( histogramSize );

Mutual information attempts to re-group the joint entropy histograms
into a more “meaningful” formation. An optimizer that minimizes the
joint entropy seeks a transform that produces a small number of high
value bins and a large majority of almost zero bins. Multi-modality
registration seeks such a transform while also attempting to maximize
the information contribution by the fixed and the moving images in the
overall region of the metric.

A T1 MRI (fixed image) and a proton density MRI (moving image) as shown
in Figure {fig:FixedMovingImageRegistration2} are provided as input to
this example.

Figure {fig:JointEntropyHistograms} shows the joint histograms before
and after registration.

    |image| |image1| [Multi-modality joint histograms] {Joint entropy
    histograms before and after registration. The final transform was
    within half a pixel of true misalignment.}
    {fig:JointEntropyHistograms}

.. |image| image:: JointEntropyHistogramPriorToRegistration.eps
.. |image1| image:: JointEntropyHistogramAfterRegistration.eps
