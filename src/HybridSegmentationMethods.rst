Introduction
------------

{sec:HybridSegmentationIntroduction} This section introduces the use of
hybrid methods for segmentation of image data. Typically we are dealing
with radiological patient and the Visible Human data. The hybrid
segmentation approach integrates boundary-based and region-based
segmentation methods that amplify the strength but reduce the weakness
of both techniques. The advantage of this approach comes from combining
region-based segmentation methods like the fuzzy connectedness and
Voronoi diagram classification with boundary-based deformable model
segmentation. The synergy between fundamentally different methodologies
tends to result in robustness and higher segmentation quality. A hybrid
segmentation engine can be built, as illustrated in
Figure {fig:ComponentsofaHybridSegmentationApproach}. It consists of
modules representing segmentation methods and implemented as ITK
filters. We can derive a variety of hybrid segmentation methods by
exchanging the filter used in each module. It should be noted that under
the fuzzy connectedness and deformable models modules, there are several
different filters that can be used as components. Below, we describe two
examples of hybrid segmentation methods, derived from the hybrid
segmentation engine: integration of fuzzy connectedness and Voronoi
diagram classification (hybrid method 1), and integration of Gibbs prior
and deformable models (hybrid method 2). Details regarding the concepts
behind these methods have been discussed in the literature .

Fuzzy Connectedness and Voronoi Classification
----------------------------------------------

{sec:HybridMethod1} In this section we present a hybrid segmentation
method that requires minimal manual initialization by integrating the
fuzzy connectedness and Voronoi diagram classification segmentation
algorithms. We start with a fuzzy connectedness filter to generate a
sample of tissue from a region to be segmented. From the sample, we
automatically derive image statistics that constitute the homogeneity
operator to be used in the next stage of the method. The output of the
fuzzy connectedness filter is used as a prior to the Voronoi diagram
classification filter. This filter performs iterative subdivision and
classification of the segmented image resulting in an estimation of the
boundary. The output of this filter is a 3D binary image that can be
used to display the 3D result of the segmentation, or passed to another
filter (e.g. deformable model) for further improvement of the final
segmentation. Details describing the concepts behind these methods have
been published in

In Figure {fig:UMLClassDiagramoftherFuzzyConnectednessFilter}, we
describe the base class for simple fuzzy connectedness segmentation.
This method is non-scale based and non-iterative, and requires only one
seed to initialize it. We define affinity between two nearby elements in
a image (e.g. pixels, voxels) via a degree of adjacency, similarity in
their intensity values, and their similarity to the estimated object.
The closer the elements and the more similar their intensities, the
greater the affinity between them. We compute the strength of a path and
fuzzy connectedness between each two pixels (voxels) in the segmented
image from the fuzzy affinity. Computation of the fuzzy connectedness
value of each pixel (voxel) is implemented by selecting a seed point and
using dynamic programming. The result constitutes the fuzzy map.
Thresholding of the fuzzy map gives a segmented object that is strongly
connected to the seed point (for more details, see ). Two fuzzy
connectedness filters are available in the toolkit:

-  The {SimpleFuzzyConnectednessScalarImageFilter}, an implementation of
   the fuzzy connectedness segmentation of single-channel (grayscale)
   image.

-  The {SimpleFuzzyConnectednessRGBImageFilter}, an implementation of
   fuzzy connectedness segmentation of a three-channel (RGB) image.

New classes can be derived from the base class by defining other
affinity functions and targeting multi-channel images with an arbitrary
number of channels. Note that the simple fuzzy connectedness filter can
be used as a stand-alone segmentation method and does not necessarily
need to be combined with other methods as indicated by
Figure {fig:UMLCollaborationDiagramoftheFuzzyConnectednessFilter}.

In Figure {fig:UMLVoronoiSegmentationClassFilter} we present the base
class for Voronoi diagram classification. We initialize the method with
a number of random seed points and compute the Voronoi diagram over the
segmented 2D image. Each Voronoi region in the subdivision is classified
as internal or external, based on the homogeneity operator derived from
the fuzzy connectedness algorithm. We define boundary regions as the
external regions that are adjacent to the internal regions. We further
subdivide the boundary regions by adding seed points to them. We
converge to the final segmentation using simple stopping criteria (for
details, see ). Two Voronoi-based segmentation methods are available in
ITK: the {VoronoiSegmentationImageFilter} for processing single-channel
(grayscale) images, and the {VoronoiSegmentationRGBImageFilter}, for
segmenting three-channel (RGB) images. New classes can be derived from
the base class by defining other homogeneity measurements and targeting
multichannel images with an arbitrary number of channels. The other
classes that are used for computing a 2D Voronoi diagram are shown in
Figure {fig:UMLClassesforImplementationofVoronoiDiagramFilter}. Note
that the Voronoi diagram filter can be used as a stand-alone
segmentation method, as depicted in
Figure {fig:UMLCollaborationDiagramoftheVoronoiSegmentationFilter}.

Figures {fig:UMLHybridMethodDiagram1} and {fig:UMLHybridMethodDiagram2}
illustrate hybrid segmentation methods that integrate fuzzy
connectedness with Voronoi diagrams, and fuzzy connectedness, Voronoi
diagrams and deformable models, respectively.

    |image| [Hybrid Segmentation Engine] {The hybrid segmentation
    engine.} {fig:ComponentsofaHybridSegmentationApproach}

    |image1| [FuzzyConectedness Filter Diagram] {Inheritance diagram for
    the fuzzy connectedness filter.}
    {fig:UMLClassDiagramoftherFuzzyConnectednessFilter}

    |image2| [Fuzzy Connectedness Segmentation Diagram] {Inputs and
    outputs to FuzzyConnectednessImageFilter segmentation algorithm.}
    {fig:UMLCollaborationDiagramoftheFuzzyConnectednessFilter}

    |image3| [Voronoi Filter class diagram] {Inheritance diagram for the
    Voronoi segmentation filters.}
    {fig:UMLVoronoiSegmentationClassFilter}

    |image4| [Voronoi Diagram Filter classes] {Classes used by the
    Voronoi segmentation filters.}
    {fig:UMLClassesforImplementationofVoronoiDiagramFilter}

    |image5| [Voronoi Diagram Segmentation] {Input and output to the
    VoronoiSegmentationImageFilter.}
    {fig:UMLCollaborationDiagramoftheVoronoiSegmentationFilter}

    |image6| [Fuzzy Connectedness and Voronoi Diagram Classification]
    {Integration of the fuzzy connectedness and Voronoi segmentation
    filters.} {fig:UMLHybridMethodDiagram1}

    |image7| [Fuzzy Connectedness, Voronoi diagram, and Deformable
    Models] {Integration of the fuzzy connectedness, Voronoi, and
    deformable model segmentation methods.}
    {fig:UMLHybridMethodDiagram2}

Example of a Hybrid Segmentation Method
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:HybridMethod1:Example}

{HybridSegmentationFuzzyVoronoi.tex}

Deformable Models and Gibbs Prior
---------------------------------

Another combination that can be used in a hybrid segmentation method is
the set of Gibbs prior filters with deformable models.

Deformable Model
~~~~~~~~~~~~~~~~

{DeformableModel1.tex}

Gibbs Prior Image Filter
~~~~~~~~~~~~~~~~~~~~~~~~

{GibbsPriorImageFilter1.tex}

.. |image| image:: HybridSegmentationEngine1.eps
.. |image1| image:: FuzzyConnectednessClassDiagram1.eps
.. |image2| image:: FuzzyConnectednessCollaborationDiagram1.eps
.. |image3| image:: VoronoiSegmentationClassDiagram1.eps
.. |image4| image:: VoronoiSegmentationCollaborationDiagram1.eps
.. |image5| image:: VoronoiSegmentationCollaborationDiagram2.eps
.. |image6| image:: FuzzyVoronoiCollaborationDiagram1.eps
.. |image7| image:: FuzzyVoronoiDeformableCollaborationDiagram1.eps
