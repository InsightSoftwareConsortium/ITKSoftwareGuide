For the problem of intra-modality deformable registration, the Insight
Toolkit provides an implementation of Thirion’s “demons” algorithm . In
this implementation, each image is viewed as a set of iso-intensity
contours. The main idea is that a regular grid of forces deform an image
by pushing the contours in the normal direction. The orientation and
magnitude of the displacement is derived from the instantaneous optical
flow equation:

:math:`\bf{D}(\bf{X}) \cdot \nabla f(\bf{X}) = - \left(m(\bf{X}) - f(\bf{X}) \right)
\label{eqn:OpticalFlow}
`

In the above equation, :math:`f(\bf{X})` is the fixed image,
:math:`m(\bf{X})` is the moving image to be registered, and
:math:`\bf{D}(\bf{X})` is the displacement or optical flow between the
images. It is well known in optical flow literature that Equation
{eqn:OpticalFlow} is insufficient to specify :math:`\bf{D}(\bf{X})`
locally and is usually determined using some form of regularization. For
registration, the projection of the vector on the direction of the
intensity gradient is used:

:math:`\bf{D}(\bf{X}) = - \frac
{\left(  m(\bf{X}) - f(\bf{X}) \right) \nabla f(\bf{X})}
{\left\|  \nabla f \right\|^2 } 
`

However, this equation becomes unstable for small values of the image
gradient, resulting in large displacement values. To overcome this
problem, Thirion re-normalizes the equation such that:

:math:`\bf{D}(\bf{X}) = - \frac
{\left(  m(\bf{X}) - f(\bf{X}) \right) \nabla f(\bf{X})}
{\left\|  \nabla f \right\|^2 + \left(  m(\bf{X}) - f(\bf{X}) \right)^2 / K } 
\label{eqn:DemonsDisplacement}
`

Where :math:`K` is a normalization factor that accounts for the units
imbalance between intensities and gradients. This factor is computed as
the mean squared value of the pixel spacings. The inclusion of
:math:`K` make the force computation to be invariant to the pixel
scaling of the images.

Starting with an initial deformation field :math:`\bf{D}^{0}(\bf{X})`,
the demons algorithm iteratively updates the field using Equation
{eqn:DemonsDisplacement} such that the field at the :math:`N`-th
iteration is given by:

:math:`\bf{D}^{N}(\bf{X}) = \bf{D}^{N-1}(\bf{X}) - \frac
{\left(  m(\bf{X}+ \bf{D}^{N-1}(\bf{X})) 
- f(\bf{X}) \right) \nabla f(\bf{X})}
{\left\|  \nabla f \right\|^2 + \left(  
m(\bf{X}+ \bf{D}^{N-1}(\bf{X}) )
 - f(\bf{X}) \right)^2 } 
\label{eqn:DemonsUpdateEquation}
`

Reconstruction of the deformation field is an ill-posed problem where
matching the fixed and moving images has many solutions. For example,
since each image pixel is free to move independently, it is possible
that all pixels of one particular value in :math:`m(\bf{X})` could map
to a single image pixel in :math:`f(\bf{X})` of the same value. The
resulting deformation field may be unrealistic for real-world
applications. An option to solve for the field uniquely is to enforce an
elastic-like behavior, smoothing the deformation field with a Gaussian
filter between iterations.

In ITK, the demons algorithm is implemented as part of the finite
difference solver (FDS) framework and its use is demonstrated in the
following example.

Asymmetrical Demons Deformable Registration
-------------------------------------------

{sec:AsymmetricalDemonsDeformableRegistration}
{DeformableRegistration2.tex}

A variant of the force computation is also implemented in which the
gradient of the deformed moving image is also involved. This provides a
level of symmetry in the force calculation during one iteration of the
PDE update. The equation used in this case is

:math:`\bf{D}(\bf{X}) = - \frac
{2 \left(  m(\bf{X}) - f(\bf{X}) \right) \left(  \nabla f(\bf{X}) +  \nabla g(\bf{X}) \right) }
{\left\|  \nabla f + \nabla g \right\|^2 + \left(  m(\bf{X}) - f(\bf{X}) \right)^2 / K } 
\label{eqn:DemonsDisplacement2}
`

The following example illustrates the use of this deformable
registration method.

Symmetrical Demons Deformable Registration
------------------------------------------

{sec:SymmetricalDemonsDeformableRegistration}
{DeformableRegistration3.tex}
