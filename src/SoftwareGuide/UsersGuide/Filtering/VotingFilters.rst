Voting Filters
~~~~~~~~~~~~~~

{sec:VotingFilters}

Voting filters are quite a generic family of filters. In fact, both the
Dilate and Erode filters from Mathematical Morphology are very
particular cases of the broader family of voting filters. In a voting
filter, the outcome of a pixel is decided by counting the number of
pixels in its neighborhood and applying a rule to the result of that
counting.For example, the typical implementation of Erosion in terms of
a voting filter will be to say that a foreground pixel will become
background if the numbers of background neighbors is greater or equal
than 1. In this context, you could imagine variations of Erosion in
which the count could be changed to require at least 3 foreground.

.. toctree::
   :maxdepth: 2

   BinaryMedianImageFilter
   VotingBinaryHoleFillingImageFilter
   VotingBinaryIterativeHoleFillingImageFilter
