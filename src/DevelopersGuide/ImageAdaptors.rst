Image Adaptors
==============

{sec:ImageAdaptors}

    |image| [ImageAdaptor concept] { The difference between using a
    CastImageFilter and an ImageAdaptor. ImageAdaptors convert pixel
    values when they are accessed by iterators. Thus, they do not
    produces an intermediate image. In the example illustrated by this
    figure, the *Image Y* is not created by the ImageAdaptor; instead,
    the image is simulated on the fly each time an iterator from the
    filter downstream attempts to access the image data.}
    {fig:ImageAdaptorConcept}

The purpose of an *image adaptor* is to make one image appear like
another image, possibly of a different pixel type. A typical example is
to take an image of pixel type {unsigned char} and present it as an
image of pixel type {float}. The motivation for using image adaptors in
this case is to avoid the extra memory resources required by using a
casting filter. When we use the {CastImageFilter} for the conversion,
the filter creates a memory buffer large enough to store the {float}
image. The {float} image requires four times the memory of the original
image and contains no useful additional information. Image adaptors, on
the other hand, do not require the extra memory as pixels are converted
only when they are read using image iterators (see
Chapter {sec:ImageIteratorsChapter}).

Image adaptors are particularly useful when there is infrequent pixel
access, since the actual conversion occurs on the fly during the access
operation. In such cases the use of image adaptors may reduce overall
computation time as well as reduce memory usage. The use of image
adaptors, however, can be disadvantageous in some situations. For
example, when the downstream filter is executed multiple times, a
CastImageFilter will cache its output after the first execution and will
not re-execute when the filter downstream is updated. Conversely, an
image adaptor will compute the cast every time.

Another application for image adaptors is to perform lightweight
pixel-wise operations replacing the need for a filter. In the toolkit,
adaptors are defined for many single valued and single parameter
functions such as trigonometric, exponential and logarithmic functions.
For example,

-  {ExpImageAdaptor}

-  {SinImageAdaptor}

-  {CosImageAdaptor}

The following examples illustrate common applications of image adaptors.

Image Casting
-------------

{sec:ImageAdaptorForBasicCasting} {ImageAdaptor1.tex}

Adapting RGB Images
-------------------

{sec:ImageAdaptorForRGB} {ImageAdaptor2.tex}

Adapting Vector Images
----------------------

{sec:ImageAdaptorForVectors} {ImageAdaptor3.tex}

Adaptors for Simple Computation
-------------------------------

{sec:ImageAdaptorForSimpleComputation} {ImageAdaptor4.tex}

Adaptors and Writers
--------------------

Image adaptors will not behave correctly when connected directly to a
writer. The reason is that writers tend to get direct access to the
image buffer from their input, since image adaptors do not have a real
buffer their behavior in this circumstances is incorrect. You should
avoid instantiating the {ImageFileWriter} or the {ImageSeriesWriter}
over an image adaptor type.

.. |image| image:: ImageAdaptorConcept.eps
