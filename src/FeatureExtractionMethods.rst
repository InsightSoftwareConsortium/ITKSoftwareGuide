Extracting salient features from images is an important task on image
processing. It is typically used for guiding segmentation methods,
preparing data for registration methods, or as a mechanism for
recognizing anatomical structures in images. The following section
introduce some of the feature extraction methods available in ITK.

Hough Transform
---------------

{sec:HoughtTransform}

The Hough transform is a widely used technique for detection of
geometrical features in images. It is based on mapping the image into a
parametric space in which it may be easier to identify if particular
geometrical features are present in the image. The transformation is
specific for each desired geometrical shape.

Line Extraction
~~~~~~~~~~~~~~~

{sec:HoughtLineExtraction}

{HoughTransform2DLinesImageFilter.tex}

Circle Extraction
~~~~~~~~~~~~~~~~~

{sec:HoughtCircleExtraction}

{HoughTransform2DCirclesImageFilter.tex}
