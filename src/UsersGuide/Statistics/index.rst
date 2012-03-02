Statistics
==========

{sec:StaisticsFramework}

This chapter introduces the statistics functionalities in Insight. The
statistics subsystem’s primary purpose is to provide general
capabilities for statistical pattern classification. However, its use is
not limited for classification. Users might want to use data containers
and algorithms in the statistics subsystem to perform other statistical
analysis or to preprocessor image data for other tasks.

The statistics subsystem mainly consists of three parts: data container
classes, statistical algorithms, and the classification framework. In
this chapter, we will discuss each major part in that order.

Data Containers
---------------

{sec:StatisticsDataContainer}

An {Statistics} {Sample} object is a data container of elements that we
call *measurement vectors*. A measurement vector is an array of values
(of the same type) measured on an object (In images, it can be a vector
of the gray intensity value and/or the gradient value of a pixel).
Strictly speaking from the design of the Sample class, a measurement
vector can be any class derived from {FixedArray}, including FixedArray
itself.

    |image| [Sample class inheritance tree] {Sample class inheritance
    diagram.} {fig:SampleInheritanceTree}

Sample Interface
~~~~~~~~~~~~~~~~

{sec:SampleInterface}

{ListSample.tex}

Sample Adaptors
~~~~~~~~~~~~~~~

{sec:SampleAdaptors}

There are two adaptor classes that provide the common {Statistics}
{Sample} interfaces for {Image} and {PointSet}, two fundamental data
container classes found in ITK. The adaptor classes do not store any
real data elements themselves. These data comes from the source data
container plugged into them. First, we will describe how to create an
{Statistics} {ImageToListSampleAdaptor} and then an {statistics}
{PointSetToListSampleAdaptor} object.

ImageToListSampleAdaptor
^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ImageToListSampleAdaptor}

{ImageToListSampleAdaptor.tex}

PointSetToListSampleAdaptor
^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:PointSetToListSampleAdaptor}

{PointSetToListSampleAdaptor.tex}

{PointSetToAdaptor.tex}

Histogram
~~~~~~~~~

{sec:Histogram}

{Histogram.tex}

Subsample
~~~~~~~~~

{sec:Subsample}

{Subsample.tex}

MembershipSample
~~~~~~~~~~~~~~~~

{sec:MembershipSample}

{MembershipSample.tex}

MembershipSampleGenerator
~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:MembershipSampleGenerator}

{MembershipSampleGenerator.tex}

K-d Tree
~~~~~~~~

{sec:KdTree}

{KdTree.tex}

Algorithms and Functions
------------------------

{sec:StatisticsAlgorithmsFunctions}

In the previous section, we described the data containers in the ITK
statistics subsystem. We also need data processing algorithms and
statistical functions to conduct statistical analysis or statistical
classification using these containers. Here we define an algorithm to be
an operation over a set of measurement vectors in a sample. A function
is an operation over individual measurement vectors. For example, if we
implement a class ({Statistics} {EuclideanDistance}) to calculate the
Euclidean distance between two measurement vectors, we call it a
function, while if we implemented a class ({Statistics}
{MeanCalculator}) to calculate the mean of a sample, we call it an
algorithm.

Sample Statistics
~~~~~~~~~~~~~~~~~

{sec:SampleStatistics}

We will show how to get sample statistics such as means and covariance
from the ({Statistics} {Sample}) classes. Statistics can tells us
characteristics of a sample. Such sample statistics are very important
for statistical classification. When we know the form of the sample
distributions and their parameters (statistics), we can conduct Bayesian
classification. In ITK, sample mean and covariance calculation
algorithms are implemented. Each algorithm also has its weighted version
(see Section {sec:WeightedMeanCovariance}). The weighted versions are
used in the expectation-maximization parameter estimation process.

Mean and Covariance
^^^^^^^^^^^^^^^^^^^

{sec:MeanCovariance}

{SampleStatistics.tex}

Weighted Mean and Covariance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:WeightedMeanCovariance}

{WeightedSampleStatistics.tex}

Sample Generation
~~~~~~~~~~~~~~~~~

{sec:SampleGeneration}

SampleToHistogramFilter
^^^^^^^^^^^^^^^^^^^^^^^

{sec:SampleToHistogramFilter}

{SampleToHistogramFilter.tex}

NeighborhoodSampler
^^^^^^^^^^^^^^^^^^^

{sec:NeighborhoodSampler}

{NeighborhoodSampler.tex}

Sample Sorting
~~~~~~~~~~~~~~

{sec:SampleSorting}

{SampleSorting.tex}

Probability Density Functions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:ProbabilityDensityFunctions}

The probability density function (PDF) for a specific distribution
returns the probability density for a measurement vector. To get the
probability density from a PDF, we use the {Evaluate(input)} method.
PDFs for different distributions require different sets of distribution
parameters. Before calling the {Evaluate()} method, make sure to set the
proper values for the distribution parameters.

Gaussian Distribution
^^^^^^^^^^^^^^^^^^^^^

{sec:GaussianMembershipFunction}

{GaussianMembershipFunction.tex}

Distance Metric
~~~~~~~~~~~~~~~

{sec:DistanceMetric}

Euclidean Distance
^^^^^^^^^^^^^^^^^^

{sec:EuclideanDistanceMetric}

{EuclideanDistanceMetric.tex}

Decision Rules
~~~~~~~~~~~~~~

{sec:DecisionRules}

A decision rule is a function that returns the index of one data element
in a vector of data elements. The index returned depends on the internal
logic of each decision rule. The decision rule is an essential part of
the ITK statistical classification framework. The scores from a set of
membership functions (e.g. probability density functions, distance
metrics) are compared by a decision rule and a class label is assigned
based on the output of the decision rule. The common interface is very
simple. Any decision rule class must implement the {Evaluate()} method.
In addition to this method, certain decision rule class can have
additional method that accepts prior knowledge about the decision task.
The {MaximumRatioDecisionRule} is an example of such a class.

The argument type for the {Evaluate()} method is {std::vector< double
>}. The decision rule classes are part of the {itk} namespace instead of
{itk::Statistics} namespace.

For a project that uses a decision rule, it must link the {itkCommon}
library. Decision rules are not templated classes.

Maximum Decision Rule
^^^^^^^^^^^^^^^^^^^^^

{sec:MaximumDecisionRule}

{MaximumDecisionRule.tex}

Minimum Decision Rule
^^^^^^^^^^^^^^^^^^^^^

{sec:MinimumDecisionRule}

{MinimumDecisionRule.tex}

Maximum Ratio Decision Rule
^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:MaximumRatioDecisionRule}

{MaximumRatioDecisionRule.tex}

Random Variable Generation
~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:RandomVariableGeneration}

A random variable generation class returns a variate when the
{GetVariate()} method is called. When we repeatedly call the method for
“enough” times, the set of variates we will get follows the distribution
form of the random variable generation class.

Normal (Gaussian) Distribution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:NormalVariateGeneration}

{NormalVariateGenerator.tex}

Statistics applied to Images
----------------------------

{sec:StatisticsAppliedToImages}

Image Histograms
~~~~~~~~~~~~~~~~

{sec:ImageHistogram}

Scalar Image Histogram with Adaptor
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ScalarImageHistogramAdaptor} {ImageHistogram1.tex}

Scalar Image Histogram with Generator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ScalarImageHistogramGenerator} {ImageHistogram2.tex}

Color Image Histogram with Generator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ColorImageHistogramGenerator} {ImageHistogram3.tex}

Color Image Histogram Writing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ColorImageHistogramGeneratorWriting} {ImageHistogram4.tex}

Image Information Theory
~~~~~~~~~~~~~~~~~~~~~~~~

{sec:ImageInformationTheory}

Many concepts from Information Theory have been used successfully in the
domain of image processing. This section introduces some of such
concepts and illustrates how the statistical framework in ITK can be
used for computing measures that have some relevance in terms of
Information Theory .

Computing Image Entropy
^^^^^^^^^^^^^^^^^^^^^^^

{sec:ComputingImageEntropy}

The concept of Entropy has been introduced into image processing as a
crude mapping from its application in Communications. The notions of
Information Theory can be deceiving and misleading when applied to
images because their language from Communication Theory does not
necessarily maps to what people in the Imaging Community use.

For example, it is commonly said that

*“The Entropy of an image is a measure of the amount of information
contained in an image”*.

This statement is fundamentally **incorrect**.

The way the notion of Entropy is commonly measured in images is by first
assuming that the spatial location of a pixel in an image is irrelevant!
That is, we simply take the statistical distribution of the pixel values
as it can be evaluated in a histogram and from that histogram we
estimate the frequency of the value associated to each bin. In other
words, we simply assume that the image is a set of pixels that are
passing through a channel, just as things are commonly considered for
communication purposes.

Once the frequency of every pixel value has been estimated, Information
Theory defines that the amount of uncertainty that an observer will lose
by taking one pixel and finding its real value to be the one associated
with the i-th bin of the histogram, is given by
:math:`-\log_2{(p_i)}`, where :math:`p_i` is the frequency in that
histogram bin. Since a reduction in uncertainty is equivalent to an
increase in the amount of information in the observer, we conclude that
measuring one pixel and finding its level to be in the i-th bin results
in an acquisition of :math:`-\log_2{(p_i)}` bits of information [1]_.

Since we could have picked any pixel at random, our chances or picking
the ones that are associated to the i-th histogram bin are given by
:math:`p_i`. Therefore, the expected reduction in uncertainty that we
can get from measuring the value of one pixel is given by

:math:`H = - \sum_i{ p_i  \cdot \log_2{(p_i)} }
`

This quantity :math:`H` is what is usually defined as the *Entropy of
the Image*. It would be more accurate to call it the Entropy of the
random variable associated to the intensity value of *one* pixel. The
fact that :math:`H` is unrelated to the spatial arrangement of the
pixels in an image shows how little of the real *Image Information* is
:math:`H` actually representing. The Entropy of an image, as measured
above, is only a crude indication of how the intensity values are spread
in the dynamic range of intensities. For example, an image with maximum
entropy will be the one that has a large dynamic range and every value
in that range is equally probable.

The common acceptation of :math:`H` as a representation of image
information has terribly undermined the enormous potential on the
application of Information Theory to image processing and analysis.

The real concepts of Information Theory would require that we define the
amount of information in an image based on our expectations and prior
knowledge from that image. In particular, the *Amount of Information*
provided by an image should measure the number of features that we are
not able to predict based on our prior knowledge about that image. For
example, if we know that we are going to analyze a CT scan of the
abdomen of an adult human male in the age range of 40 to 45, there is
already a good deal that we could predict about the content of that
image. The real amount of information in the image is the representation
of the features in the image that we could not predict from knowing that
it is a CT scan from a human adult male.

The application of Information Theory to image analysis is still in its
early infancy and it is an exciting an promising field to be explored
further. All that being said, let’s now look closer at how the concept
of Entropy (which is not the amount of information in an image) can be
measured with the ITK statistics framework.

{ImageEntropy1.tex}

Computing Images Mutual Information
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{sec:ComputingImagesMutualInformation}

{ImageMutualInformation1.tex}

Classification
--------------

{sec:Classification}

In statistical classification, each object is represented by :math:`d`
features (a measurement vector), and the goal of classification becomes
finding compact and disjoint regions (decision regions) for classes in a
:math:`d`-dimensional feature space. Such decision regions are defined
by decision rules that are known or can be trained. The simplest
configuration of a classification consists of a decision rule and
multiple membership functions; each membership function represents a
class. Figure {fig:simple} illustrates this general framework.

    |image1| [Simple conceptual classifier] {Simple conceptual
    classifier.} {fig:simple}

This framework closely follows that of Duda and Hart. The classification
process can be described as follows:

#.
#.
#.

    |image2| [Statistical classification framework] {Statistical
    classification framework.} {fig:StatisticalClassificationFramework}

This simple configuration can be used to formulated various
classification tasks by using different membership functions and
incorporating task specific requirements and prior knowledge into the
decision rule. For example, instead of using probability density
functions as membership functions, through distance functions and a
minimum value decision rule (which assigns a class from the distance
function that returns the smallest value) users can achieve a least
squared error classifier. As another example, users can add a rejection
scheme to the decision rule so that even in a situation where the
membership scores suggest a “winner”, a measurement vector can be
flagged as ill defined. Such a rejection scheme can avoid risks of
assigning a class label without a proper win margin.

k-d Tree Based k-Means Clustering
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:KdTreeBasedKMeansClustering} {KdTreeBasedKMeansClustering.tex}

K-Means Classification
~~~~~~~~~~~~~~~~~~~~~~

{sec:KMeansClassifier} {ScalarImageKmeansClassifier.tex}

Bayesian Plug-In Classifier
~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:BayesianPluginClassifier}

{BayesianPluginClassifier.tex}

Expectation Maximization Mixture Model Estimation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:ExpectationMaximizationMixtureModelEstimation}

{ExpectationMaximizationMixtureModelEstimator.tex}

Classification using Markov Random Field
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:MarkovRandomField}

Markov Random Fields are probabilistic models that use the correlation
between pixels in a neighborhood to decide the object region. The
{Statistics} {MRFImageFilter} uses the maximum a posteriori (MAP)
estimates for modeling the MRF. The object traverses the data set and
uses the model generated by the Mahalanobis distance classifier to gets
the the distance between each pixel in the data set to a set of known
classes, updates the distances by evaluating the influence of its
neighboring pixels (based on a MRF model) and finally, classifies each
pixel to the class which has the minimum distance to that pixel (taking
the neighborhood influence under consideration). The energy function
minimization is done using the iterated conditional modes (ICM)
algorithm .

{ScalarImageMarkovRandomField1.tex}

.. [1]
   Note that **bit** is the unit of amount of information. Our modern
   culture has vulgarized the bit and its multiples, the Byte, KiloByte,
   MegaByte, GigaByte and so on as simple measures of the amount of RAM
   memory and capacity of a hard drive in a computer. In that sense, a
   confusion is created between the encoding of a piece of data and its
   actual amount of information. For example a file composed of one
   million letters will take one million bytes in a hard disk, but it
   does not necessarily has one million bytes of information, since in
   many cases parts of the file can be predicted from others. This is
   the reason why data compression can manage to compact files.

.. |image| image:: SampleInheritanceTree.eps
.. |image1| image:: DudaClassifier.eps
.. |image2| image:: StatisticalClassificationFramework.eps
