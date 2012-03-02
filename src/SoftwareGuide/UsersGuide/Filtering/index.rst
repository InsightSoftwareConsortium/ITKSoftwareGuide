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

Distance Map
------------

{sec:DistanceMap}

{DanielssonDistanceMapImageFilter.tex}

{SignedDanielssonDistanceMapImageFilter.tex}

Geometric Transformations
-------------------------

{sec:GeometricalTransformationFilters}

Filters You Should be Afraid to Use
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:ScaryImageFilters} {Change Information Image Filter}

This one is the scariest and more dangerous filter in the entire
toolkit. You should not use this filter unless you are entirely certain
that you know what you are doing. In fact if you decide to use this
filter, you should write your code, then go for a long walk, get more
coffee and ask yourself if you really needed to use this filter. If the
answer is yes, then you should discuss this issue with someone you trust
and get his/her opinion in writing. In general, if you need to use this
filter, it means that you have a poor image provider that is putting
your career at risk along with the life of any potential patient whose
images you may end up processing.

Flip Image Filter
~~~~~~~~~~~~~~~~~

{FlipImageFilter.tex}

Resample Image Filter
~~~~~~~~~~~~~~~~~~~~~

{sec:ResampleImageFilter}

Introduction
^^^^^^^^^^^^

{ResampleImageFilter.tex}

Importance of Spacing and Origin
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{ResampleImageFilter2.tex}

A Complete Example
^^^^^^^^^^^^^^^^^^

{ResampleImageFilter3.tex}

Rotating an Image
^^^^^^^^^^^^^^^^^

{ResampleImageFilter4.tex}

Rotating and Scaling an Image
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{ResampleImageFilter5.tex}

Resampling using a deformation field
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{WarpImageFilter1.tex}

Subsampling and image in the same space
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{SubsampleVolume}

{SubsampleVolume.tex}

Resampling an Anisotropic image to make it Isotropic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

{ResampleVolumesToBeIsotropic}

{ResampleVolumesToBeIsotropic.tex}

Frequency Domain
----------------

{sec:FrequencyDomain}

Computing a Fast Fourier Transform (FFT)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{FFTImageFilter}

{FFTImageFilter.tex}

Filtering on the Frequency Domain
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{FFTImageFilterFourierDomainFiltering}

{FFTImageFilterFourierDomainFiltering.tex}

Extracting Surfaces
-------------------

{sec:ExtractingSurfaces}

Surface extraction
~~~~~~~~~~~~~~~~~~

{sec:SufaceExtraction}

{SurfaceExtraction.tex}

.. |image| image:: BinaryMedianImageFilterOutput1.eps
.. |image1| image:: BinaryMedianImageFilterOutput10.eps
.. |image2| image:: BinaryMedianImageFilterOutput50.eps
