The source code for this section can be found in the file
``BoundingBoxFromImageMaskSpatialObject.cxx``.


.. index::
   single: ImageMaskSpatialObject
   pair: ImageMaskSpatialObject; GetValue

This example illustrates how to compute the bounding box around a binary
contained in an \doxygen{ImageMaskSpatialObject}. This is typically useful for
extracting the region of interest of a segmented object and ignoring the
larger region of the image that is not occupied by the segmentation.

::

    [language=C++]
    #include "itkImageMaskSpatialObject.h"
    #include "itkImage.h"

