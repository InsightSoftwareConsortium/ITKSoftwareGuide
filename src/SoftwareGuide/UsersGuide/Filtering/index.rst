Filtering
=========

This chapter introduces the most commonly used filters found in the
toolkit. Most of these filters are intended to process images. They will
accept one or more images as input and will produce one or more images
as output. ITK is based on a data pipeline architecture in which the
output of one filter is passed as input to another filter. (See Section
{sec:DataProcessingPipeline} on page {sec:DataProcessingPipeline} for
more information.)

.. toctree::
   :maxdepth: 2

   Thresholding
   EdgeDetection
   CastImageFilters
   GradientsFiltering
   SecondOrderDerivatives
   NeighborhoodFilters
   SmoothingFilters
   DistanceMap
   GeometricTransformations
   FrequencyDomain
   ExtractingSurfaces
