Blurring
~~~~~~~~

{sec:BlurringFilters}

Blurring is the traditional approach for removing noise from images. It
is usually implemented in the form of a convolution with a kernel. The
effect of blurring on the image spectrum is to attenuate high spatial
frequencies. Different kernels attenuate frequencies in different ways.
One of the most commonly used kernels is the Gaussian. Two
implementations of Gaussian smoothing are available in the toolkit. The
first one is based on a traditional convolution while the other is based
on the application of IIR filters that approximate the convolution with
a Gaussian .

.. toctree::
   :maxdepth: 2

   DiscreteGaussianImageFilter
   BinomialBlurImageFilter
   SmoothingRecursiveGaussianImageFilter
