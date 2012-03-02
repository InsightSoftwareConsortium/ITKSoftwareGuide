The source code for this section can be found in the file
``ModelToImageRegistration2.cxx``.

This example illustrates the use of the {SpatialObject} as a component
of the registration framework in order to perform model based
registration. In this case, a SpatialObject is used for generating a
{PointSet} whose points are located in a narrow band around the edges of
the SpatialObject. This PointSet is then used in order to perform
PointSet to Image registration.

In this example we use the {BoxSpatialObject}, that is one of the
simplest SpatialObjects in ITK.

::

    [language=C++]
    #include "itkBoxSpatialObject.h"

The generation of the PointSet is done in two stages. First the
SpatialObject is rasterized in order to generate an image containing a
binary mask that represents the inside and outside of the SpatialObject.
Second, this mask is used for computing a distance map, and the points
close to the boundary of the mask are taken as elements of the final
PointSet. The pixel values associated to the point in the PointSet are
the values of distance from each point to the binary mask. The first
stage is performed by the {SpatialObjectToImageFilter}, while the second
stage is performed witht eh {BinaryMaskToNarrowBandPointSetFilter}

::

    [language=C++]
    #include "itkSpatialObjectToImageFilter.h"
    #include "itkBinaryMaskToNarrowBandPointSetFilter.h"

