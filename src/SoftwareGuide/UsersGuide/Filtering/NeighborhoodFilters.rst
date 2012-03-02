Neighborhood Filters
--------------------

{sec:NeighborhoodFilters}

The concept of locality is frequently encountered in image processing in
the form of filters that compute every output pixel using information
from a small region in the neighborhood of the input pixel. The
classical form of these filters are the :math:`3 \times 3` filters in
2D images. Convolution masks based on these neighborhoods can perform
diverse tasks ranging from noise reduction, to differential operations,
to mathematical morphology.

The Insight toolkit implements an elegant approach to neighborhood-based
image filtering. The input image is processed using a special iterator
called the {NeighborhoodIterator}. This iterator is capable of moving
over all the pixels in an image and, for each position, it can address
the pixels in a local neighborhood. Operators are defined that apply an
algorithmic operation in the neighborhood of the input pixel to produce
a value for the output pixel. The following section describes some of
the more commonly used filters that take advantage of this construction.
(See Chapter {sec:ImageIteratorsChapter} on page
{sec:ImageIteratorsChapter} for more information about iterators.)

.. toctree::
   :maxdepth: 2

   MeanImageFilter
   MedianImageFilter
   MathematicalMorphology
   VotingFilters
