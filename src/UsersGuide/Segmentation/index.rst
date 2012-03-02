Segmentation
============

Segmentation of medical images is a challenging task. A myriad of
different methods have been proposed and implemented in recent years. In
spite of the huge effort invested in this problem, there is no single
approach that can generally solve the problem of segmentation for the
large variety of image modalities existing today.

The most effective segmentation algorithms are obtained by carefully
customizing combinations of components. The parameters of these
components are tuned for the characteristics of the image modality used
as input and the features of the anatomical structure to be segmented.

The Insight Toolkit provides a basic set of algorithms that can be used
to develop and customize a full segmentation application. Some of the
most commonly used segmentation components are described in the
following sections.

Region Growing
--------------

Region growing algorithms have proven to be an effective approach for
image segmentation. The basic approach of a region growing algorithm is
to start from a seed region (typically one or more pixels) that are
considered to be inside the object to be segmented. The pixels
neighboring this region are evaluated to determine if they should also
be considered part of the object. If so, they are added to the region
and the process continues as long as new pixels are added to the region.
Region growing algorithms vary depending on the criteria used to decide
whether a pixel should be included in the region or not, the type
connectivity used to determine neighbors, and the strategy used to visit
neighboring pixels.

Several implementations of region growing are available in ITK. This
section describes some of the most commonly used.

Connected Threshold
~~~~~~~~~~~~~~~~~~~

A simple criterion for including pixels in a growing region is to
evaluate intensity value inside a specific interval.

{sec:ConnectedThreshold} {ConnectedThresholdImageFilter.tex}

Otsu Segmentation
~~~~~~~~~~~~~~~~~

Another criterion for classifying pixels is to minimize the error of
misclassification. The goal is to find a threshold that classifies the
image into two clusters such that we minimize the area under the
histogram for one cluster that lies on the other cluster’s side of the
threshold. This is equivalent to minimizing the within class variance or
equivalently maximizing the between class variance.

{sec:OtsuThreshold} {OtsuThresholdImageFilter.tex}

{sec:OtsuMultipleThreshold} {OtsuMultipleThresholdImageFilter.tex}

Neighborhood Connected
~~~~~~~~~~~~~~~~~~~~~~

{sec:NeighborhoodConnectedImageFilter}
{NeighborhoodConnectedImageFilter.tex}

Confidence Connected
~~~~~~~~~~~~~~~~~~~~

{sec:ConfidenceConnected} {ConfidenceConnected.tex}
{ConfidenceConnectedOnBrainWeb.tex}

Isolated Connected
~~~~~~~~~~~~~~~~~~

{sec:IsolatedConnected} {IsolatedConnectedImageFilter.tex}

Confidence Connected in Vector Images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:VectorConfidenceConnected} {VectorConfidenceConnected.tex}

Segmentation Based on Watersheds
--------------------------------

{sec:WatershedSegmentation} WatershedSegmentation.tex

Level Set Segmentation
----------------------

{sec:LevelSetsSegmentation} {LevelSetsSegmentation.tex}

Feature Extraction
------------------

{sec:FeatureExtractionMethods}

{FeatureExtractionMethods.tex}
