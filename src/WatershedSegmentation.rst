Overview
--------

{sec:AboutWatersheds} Watershed segmentation classifies pixels into
regions using gradient descent on image features and analysis of weak
points along region boundaries. Imagine water raining onto a landscape
topology and flowing with gravity to collect in low basins. The size of
those basins will grow with increasing amounts of precipitation until
they spill into one another, causing small basins to merge together into
larger basins. Regions (catchment basins) are formed by using local
geometric structure to associate points in the image domain with local
extrema in some feature measurement such as curvature or gradient
magnitude. This technique is less sensitive to user-defined thresholds
than classic region-growing methods, and may be better suited for fusing
different types of features from different data sets. The watersheds
technique is also more flexible in that it does not produce a single
image segmentation, but rather a hierarchy of segmentations from which a
single region or set of regions can be extracted a-priori, using a
threshold, or interactively, with the help of a graphical user interface
.

The strategy of watershed segmentation is to treat an image :math:`f`
as a height function, i.e., the surface formed by graphing :math:`f`
as a function of its independent parameters, :math:`\vec{x} \in U`.
The image :math:`f` is often not the original input data, but is
derived from that data through some filtering, graded (or fuzzy) feature
extraction, or fusion of feature maps from different sources. The
assumption is that higher values of :math:`f` (or :math:`-f`)
indicate the presence of boundaries in the original data. Watersheds may
therefore be considered as a final or intermediate step in a hybrid
segmentation method, where the initial segmentation is the generation of
the edge feature map.

Gradient descent associates regions with local minima of :math:`f`
(clearly interior points) using the watersheds of the graph of
:math:`f`, as in Figure {fig:segment}.

    |image| [Watershed Catchment Basins] {A fuzzy-valued boundary map,
    from an image or set of images, is segmented using local minima and
    catchment basins.} {fig:segment}

That is, a segment consists of all points in :math:`U` whose paths of
steepest descent on the graph of :math:`f` terminate at the same
minimum in :math:`f`. Thus, there are as many segments in an image as
there are minima in :math:`f`. The segment boundaries are “ridges” in
the graph of :math:`f`. In the 1D case (:math:`U \subset \Re`), the
watershed boundaries are the local maxima of :math:`f`, and the
results of the watershed segmentation is trivial. For higher-dimensional
image domains, the watershed boundaries are not simply local phenomena;
they depend on the shape of the entire watershed.

The drawback of watershed segmentation is that it produces a region for
each local minimum—in practice too many regions—and an over segmentation
results. To alleviate this, we can establish a minimum watershed depth.
The watershed depth is the difference in height between the watershed
minimum and the lowest boundary point. In other words, it is the maximum
depth of water a region could hold without flowing into any of its
neighbors. Thus, a watershed segmentation algorithm can sequentially
combine watersheds whose depths fall below the minimum until all of the
watersheds are of sufficient depth. This depth measurement can be
combined with other saliency measurements, such as size. The result is a
segmentation containing regions whose boundaries and size are
significant. Because the merging process is sequential, it produces a
hierarchy of regions, as shown in Figure {fig:watersheds}.

    |image1| [Watersheds Hierarchy of Regions] {A watershed segmentation
    combined with a saliency measure (watershed depth) produces a
    hierarchy of regions. Structures can be derived from images by
    either thresholding the saliency measure or combining subtrees
    within the hierarchy.} {fig:watersheds}

Previous work has shown the benefit of a user-assisted approach that
provides a graphical interface to this hierarchy, so that a technician
can quickly move from the small regions that lie within an area of
interest to the union of regions that correspond to the anatomical
structure .

There are two different algorithms commonly used to implement
watersheds: top-down and bottom-up. The top-down, gradient descent
strategy was chosen for ITK because we want to consider the output of
multi-scale differential operators, and the :math:`f` in question will
therefore have floating point values. The bottom-up strategy starts with
seeds at the local minima in the image and grows regions outward and
upward at discrete intensity levels (equivalent to a sequence of
morphological operations and sometimes called { morphological
watersheds} .) This limits the accuracy by enforcing a set of discrete
gray levels on the image.

    |image2| [Watersheds filter composition] {The construction of the
    Insight watersheds filter.} {fig:constructionWatersheds}

Figure {fig:constructionWatersheds} shows how the ITK image-to-image
watersheds filter is constructed. The filter is actually a collection of
smaller filters that modularize the several steps of the algorithm in a
mini-pipeline. The segmenter object creates the initial segmentation via
steepest descent from each pixel to local minima. Shallow background
regions are removed (flattened) before segmentation using a simple
minimum value threshold (this helps to minimize oversegmentation of the
image). The initial segmentation is passed to a second sub-filter that
generates a hierarchy of basins to a user-specified maximum watershed
depth. The relabeler object at the end of the mini-pipeline uses the
hierarchy and the initial segmentation to produce an output image at any
scale { below} the user-specified maximum. Data objects are cached in
the mini-pipeline so that changing watershed depths only requires a
(fast) relabeling of the basic segmentation. The three parameters that
control the filter are shown in Figure {fig:constructionWatersheds}
connected to their relevant processing stages.

Using the ITK Watershed Filter
------------------------------

{sec:UsingWatersheds} {WatershedSegmentation1.tex}

.. |image| image:: WatershedCatchmentBasins.eps
.. |image1| image:: WatershedsHierarchy.eps
.. |image2| image:: WatershedImageFilter.eps
