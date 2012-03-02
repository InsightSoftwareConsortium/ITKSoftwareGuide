    |image| [Mapping moving image to fixed image in Registration] { The
    moving image is mapped into the fixed image space under some spatial
    transformation. An iterator walks through the fixed image and its
    coordinates are mapped onto the moving image.}
    {fig:ImageOverlapIterator}

    |image1| [Need for interpolation in Registration] {Grid positions of
    the fixed image map to non-grid positions of the moving image.
    {fig:ImageOverlapInterpolator}}

In the registration process, the metric typically compares intensity
values in the fixed image against the corresponding values in the
transformed moving image. When a point is mapped from one space to
another by a transform, it will in general be mapped to a non-grid
position. Therefore, interpolation is required to evaluate the image
intensity at the mapped position.

Figure {fig:ImageOverlapIterator} (left) illustrates the mapping of the
fixed image space onto the moving image space. The transform maps points
from the fixed image coordinate system onto the moving image coordinate
system. The figure highlights the region of overlap between the two
images after the mapping. The right side illustrates how an iterator is
used to walk through a region of the fixed image. Each one of the
iterator positions is mapped by the transform onto the moving image
space in order to find the homologous pixel.

Figure {fig:ImageOverlapInterpolator} presents a detailed view of the
mapping from the fixed image to the moving image. In general, the grid
positions of the fixed image will not be mapped onto grid positions of
the moving image. Interpolation is needed for estimating the intensity
of the moving image at these non-grid positions. The service is provided
in ITK by interpolator classes that can be plugged into the registration
method.

The following interpolators are available:

-  {NearestNeighborInterpolateImageFunction}

-  {LinearInterpolateImageFunction}

-  {BSplineInterpolateImageFunction}

-  {WindowedSincInterpolateImageFunction}

In the context of registration, the interpolation method affects the
smoothness of the optimization search space and the overall computation
time. On the other hand, interpolations are executed thousands of times
in a single optimization cycle. Hence, the user has to balance the
simplicity of computation with the smoothness of the optimization when
selecting the interpolation scheme.

The basic input to an {InterpolateImageFunction} is the image to be
interpolated. Once an image has been defined using {SetInputImage()}, a
user can interpolate either at a point using {Evaluate()} or an index
using {EvaluateAtContinuousIndex()}.

Interpolators provide the method {IsInsideBuffer()} that tests whether a
particular image index or a physical point falls inside the spatial
domain for which image pixels exist.

Nearest Neighbor Interpolation
------------------------------

{sec:NearestNeighborInterpolation} The
{NearestNeighborInterpolateImageFunction} simply uses the intensity of
the nearest grid position. That is, it assumes that the image intensity
is piecewise constant with jumps mid-way between grid positions. This
interpolation scheme is cheap as it does not require any floating point
computations.

Linear Interpolation
--------------------

{sec:LinearInterpolation}

The {LinearInterpolateImageFunction} assumes that intensity varies
linearly between grid positions. Unlike nearest neighbor interpolation,
the interpolated intensity is spatially continuous. However, the
intensity gradient will be discontinuous at grid positions.

B-Spline Interpolation
----------------------

{sec:BSplineInterpolation}

    |image2| [BSpline Interpolation Concepts] {The left side illustrates
    the BSpline grid and the deformations that are known on those nodes.
    The right side illustrates the region where interpolation is
    possible when the BSpline is of cubic order. The small arrows
    represent deformation values that were interpolated from the grid
    deformations shown on the left side of the diagram.}
    {fig:BSplineInterpolation}

The {BSplineInterpolateImageFunction} represents the image intensity
using B-spline basis functions. When an input image is first connected
to the interpolator, B-spline coefficients are computed using recursive
filtering (assuming mirror boundary conditions). Intensity at a non-grid
position is computed by multiplying the B-spline coefficients with
shifted B-spline kernels within a small support region of the requested
position. Figure {fig:BSplineInterpolation} illustrates on the left how
the deformation values on the BSpline grid nodes are used for computing
interpolated deformations in the rest of space. Note for example that
when a cubic BSpline is used, the grid must have one extra node in one
side of the image and two extra nodes on the other side, this along
every dimension.

Currently, this interpolator supports splines of order :math:`0` to
:math:`5`. Using a spline of order :math:`0` is almost identical to
nearest neighbor interpolation; a spline of order :math:`1` is exactly
identical to linear interpolation. For splines of order greater than
:math:`1`, both the interpolated value and its derivative are
spatially continuous.

It is important to note that when using this scheme, the interpolated
value may lie outside the range of input image intensities. This is
especially important when handling unsigned data, as it is possible that
the interpolated value is negative.

Windowed Sinc Interpolation
---------------------------

{sec:WindowedSincInterpolation}

The {WindowedSincInterpolateImageFunction} is the best possible
interpolator for data that has been digitized in a discrete grid. This
interpolator has been developed based on Fourier Analysis
considerations. It is well known in signal processing that the process
of sampling a spatial function using a periodic discrete grid results in
a replication of the spectrum of that signal in the frequency domain.

The process of recovering the continuous signal from the discrete
sampling is equivalent to the removal of the replicated spectra in the
frequency domain. This can be done by multiplying the spectra with a box
function that will set to zero all the frequencies above the highest
frequency in the original signal. Multiplying the spectrum with a box
function is equivalent to convolving the spatial discrete signal with a
sinc function

:math:`sinc(x) = \sin{(x)} / x  
`

The sinc function has infinite support, which of course in practice can
not really be implemented. Therefore, the sinc is usually truncated by
multiplying it with a Window function. The Windowed Sinc interpolator is
the result of such operation.

This interpolator presents a series of trade-offs in its utilization.
Probably the most significant is that the larger the window, the more
precise will be the resulting interpolation. However, large windows will
also result in long computation times. Since the user can select the
window size in this interpolator, it is up to the user to determine how
much interpolation quality is required in her/his application and how
much computation time can be justified. For details on the signal
processing theory behind this interpolator, please refer to Meijering
*et. al* .

The region of the image used for computing the interpolator is
determined by the window *radius*. For example, in a :math:`2D` image
where we want to interpolate the value at position :math:`(x,y)` the
following computation will be performed.

:math:`I(x,y) = 
\sum_{i = \lfloor x \rfloor + 1 - m}^{\lfloor x \rfloor + m} 
\sum_{j = \lfloor y \rfloor + 1 - m}^{\lfloor y \rfloor + m}
I_{i,j} K(x-i) K(y-j)
`

where :math:`m` is the *radius* of the window. Typically, values such
as 3 or 4 are reasonable for the window radius. The function kernel
:math:`K(t)` is composed by the :math:`sinc` function and one of the
windows listed above.

:math:`K(t) = w(t) \textrm{sinc}(t) = w(t) \frac{\sin(\pi t)}{\pi t}
`

Some of the windows that can be used with this interpolator are

Cosinus window :math:`w(x) = cos ( \frac{\pi x}{2 m} ) 
`

Hamming window :math:`w(x) = 0.54 + 0.46 cos ( \frac{\pi x}{m} ) 
`

Welch window :math:`w(x) = 1 - ( \frac{x^2}{m^2} )
`

Lancos window :math:`w(x) = \textrm{sinc} ( \frac{x}{m} ) 
`

Blackman window
:math:`w(x) = 0.42 + 0.5 cos(\frac{\pi x}{m}) + 0.08 cos(\frac{2 \pi x}{m}) 
`

The window functions listed above are available inside the itk::Function
namespace. The conclusions of the referenced paper suggest to use the
Welch, Cosine, Kaiser, and Lancos windows for m = 4,5. These are based
on error in rotating medical images with respect to the linear
interpolation method. In some cases the results achieve a 20-fold
improvement in accuracy.

This filter can be used in the same way you would use any
ImageInterpolationFunction. For instance, you can plug it into the
ResampleImageFilter class. In order to instantiate the filter you must
choose several template parameters.

{ typedef WindowedSincInterpolateImageFunction< TInputImage, VRadius,
TWindowFunction, TBoundaryCondition, TCoordRep > InterpolatorType; }

{TInputImage} is the image type, as for any other interpolator.

{VRadius} is the radius of the kernel, i.e., the :math:`m` from the
formula above.

{TWindowFunction} is the window function object, which you can choose
from about five different functions defined in this header. The default
is the Hamming window, which is commonly used but not optimal according
to the cited paper.

{TBoundaryCondition} is the boundary condition class used to determine
the values of pixels that fall off the image boundary. This class has
the same meaning here as in the {NeighborhoodIterator} classes.

{TCoordRep} is again standard for interpolating functions, and should be
float or double.

The WindowedSincInterpolateImageFunction is probably not the
interpolator that you want to use for performing registration. Its
computation burden makes it too expensive for this purpose. The best use
of this interpolator is for the final resampling of the image, once that
the transform has been found using another less expensive interpolator
in the registration process.

.. |image| image:: ImageOverlap.eps
.. |image1| image:: ImageOverlapInterpolator.eps
.. |image2| image:: BSplineInterpolation.eps
