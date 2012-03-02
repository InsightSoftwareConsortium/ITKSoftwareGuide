Introduction to Anisotropic Diffusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The drawback of image denoising (smoothing) is that it tends to blur
away the sharp boundaries in the image that help to distinguish between
the larger-scale anatomical structures that one is trying to
characterize (which also limits the size of the smoothing kernels in
most applications). Even in cases where smoothing does not obliterate
boundaries, it tends to distort the fine structure of the image and
thereby changes subtle aspects of the anatomical shapes in question.

Perona and Malik \cite{Perona1990} introduced an alternative to
linear-filtering that they called *anisotropic diffusion*. Anisotropic
diffusion is closely related to the earlier work of Grossberg
\cite{Grossberg1984}, who used similar nonlinear diffusion processes to model
human vision. The motivation for anisotropic diffusion (also called
*nonuniform* or *variable conductance* diffusion) is that a Gaussian smoothed
image is a single time slice of the solution to the heat equation, that has the
original image as its initial conditions. Thus, the solution to
:math:`\frac{\partial g(x, y, t) }{\partial t} = \nabla \cdot \nabla g(x, y,
t),` where :math:`g(x, y, 0) = f(x, y)` is the input image, is
:math:`g(x, y, t) = G(\sqrt{2t}) \otimes f(x, y)`, where :math:`G(\sigma)`
is a Gaussian with standard deviation :math:`\sigma`.

Anisotropic diffusion includes a variable conductance term that, in turn,
depends on the differential structure of the image. Thus, the variable
conductance can be formulated to limit the smoothing at “edges” in images, as
measured by high gradient magnitude, for example.  :math:`g_{t} = \nabla
\cdot c(\left| \nabla g \right|) \nabla g, \label{eq:aniso}` where, for
notational convenience, we leave off the independent parameters of :math:`g`
and use the subscripts with respect to those parameters to indicate partial
derivatives. The function :math:`c(|\nabla g|)` is a fuzzy cutoff that
reduces the conductance at areas of large :math:`|\nabla g|`, and can be any
one of a number of functions. The literature has shown :math:`c(|\nabla g|) =
e^{-\frac{|\nabla g|^{2}}{2k^{2}}}` to be quite effective. Notice that
conductance term introduces a free parameter :math:`k`, the { conductance
parameter}, that controls the sensitivity of the process to edge contrast.
Thus, anisotropic diffusion entails two free parameters: the conductance
parameter, :math:`k`, and the time parameter, :math:`t`, that is analogous
to :math:`\sigma`, the effective width of the filter when using Gaussian
kernels.

Equation {eq:aniso} is a nonlinear partial differential equation that can be
solved on a discrete grid using finite forward differences. Thus, the smoothed
image is obtained only by an iterative process, not a convolution or
non-stationary, linear filter. Typically, the number of iterations required for
practical results are small, and large 2D images can be processed in several
tens of seconds using carefully written code running on modern, general
purpose, single-processor computers. The technique applies readily and
effectively to 3D images, but requires more processing time.

In the early 1990’s several research groups \cite{Gerig1991,Whitaker1993d}
demonstrated the effectiveness of anisotropic diffusion on medical images. In a
series of papers on the subject
\cite{Whitaker1993,Whitaker1993b,Whitaker1993c,Whitaker1993d,Whitaker-thesis,Whitaker1994},
Whitaker described a detailed analytical and empirical analysis, introduced a
smoothing term in the conductance that made the process more robust, invented a
numerical scheme that virtually eliminated directional artifacts in the
original algorithm, and generalized anisotropic diffusion to vector-valued
images, an image processing technique that can be used on vector-valued medical
data (such as the color cryosection data of the Visible Human Project).

For a vector-valued input :math:`\vec{F}:U \mapsto \Re^{m}` the process takes
the form :math:`\vec{F}_{t} = \nabla \cdot c({\cal D}\vec{F}) \vec{F},
\label{eq:vector_diff}` where :math:`{\cal D}\vec{F}` is a {
dissimilarity} measure of :math:`\vec{F}`, a generalization of the gradient
magnitude to vector-valued images, that can incorporate linear and nonlinear
coordinate transformations on the range of :math:`\vec{F}`. In this way, the
smoothing of the multiple images associated with vector-valued data is coupled
through the conductance term, that fuses the information in the different
images. Thus vector-valued, nonlinear diffusion can combine low-level image
features (e.g. edges) across all “channels” of a vector-valued image in order
to preserve or enhance those features in all of image “channels”.

Vector-valued anisotropic diffusion is useful for denoising data from devices
that produce multiple values such as MRI or color photography.  When performing
nonlinear diffusion on a color image, the color channels are diffused
separately, but linked through the conductance term.  Vector-valued diffusion
it is also useful for processing registered data from different devices or for
denoising higher-order geometric or statistical features from scalar-valued
images \cite{Whitaker1994,Yoo1993}.

The output of anisotropic diffusion is an image or set of images that
demonstrates reduced noise and texture but preserves, and can also enhance,
edges. Such images are useful for a variety of processes including statistical
classification, visualization, and geometric feature extraction. Previous work
has shown \cite{Whitaker-thesis} that anisotropic diffusion, over a wide range
of conductance parameters, offers quantifiable advantages over linear filtering
for edge detection in medical images.

Since the effectiveness of nonlinear diffusion was first demonstrated, numerous
variations of this approach have surfaced in the literature \cite{Romeny1994}.
These include alternatives for constructing dissimilarity measures
\cite{Sapiro1996}, directional (i.e., tensor-valued) conductance
terms\cite{Weickert1996,Alvarez1994} and level set interpretations
\cite{Whitaker2001}.
