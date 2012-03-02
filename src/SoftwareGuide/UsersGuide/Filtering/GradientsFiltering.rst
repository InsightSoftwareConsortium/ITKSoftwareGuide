Gradients
---------

{sec:GradientFiltering}

Computation of gradients is a fairly common operation in image
processing. The term “gradient” may refer in some contexts to the
gradient vectors and in others to the magnitude of the gradient vectors.
ITK filters attempt to reduce this ambiguity by including the
*magnitude* term when appropriate. ITK provides filters for computing
both the image of gradient vectors and the image of magnitudes.

.. toctree::
   :maxdepth: 2

   GradientMagnitudeImageFilter
   GradientMagnitudeRecursiveGaussianImageFilter
   DerivativeImageFilter
