FEM-Based Image Registration
----------------------------

{sec:FEMBasedImageRegistration}

    |image| |image1| [FEM-based deformable registration results]
    {Checkerboard comparisons before and after FEM-based deformable
    registration.} {fig:DeformableRegistration1Output}

{DeformableRegistration1.tex}

Figure {fig:DeformableRegistration1Output} presents the results of the
FEM-based deformable registration applied to two time-separated slices
of a living rat dataset. Checkerboard comparisons of the two images are
shown before registration (left) and after registration (right). Both
images were acquired from the same living rat, the first after
inspiration of air into the lungs and the second after exhalation.
Deformation occurs due to the relaxation of the diaphragm and the
intercostal muscles, both of which exert force on the lung tissue and
cause air to be expelled.

The following is a documented sample parameter file that can be used
with this deformable registration example. This example demonstrates the
setup of a basic registration problem that does not use multi-resolution
strategies. As a result, only one value for the parameters between {(#
of pixels per element)} and ``(maximum iterations)`` is necessary. In
order to use a multi-resolution strategy, you would have to specify
values for those parameters at each level of the pyramid.

``timinput{FiniteElementRegistr``tionParameters1.txt}

BSplines Image Registration
---------------------------

{sec:BSplinesImageRegistration}

{DeformableRegistration4.tex}

Level Set Motion for Deformable Registration
--------------------------------------------

{sec:LevelSetMotionForDeformableRegistration}

{DeformableRegistration5.tex}

BSplines Multi-Grid Image Registration
--------------------------------------

{sec:BSplinesMultiGridImageRegistration}

{DeformableRegistration6.tex}

BSplines Multi-Grid Image Registration
--------------------------------------

{sec:BSplinesMultiGridImageRegistration}

{DeformableRegistration7.tex}

BSplines Image Registration in 3D
---------------------------------

{sec:BSplinesImageRegistrationIn3D}

{DeformableRegistration8.tex}

Image Warping with Kernel Splines
---------------------------------

{sec:ImageWarpingWithKernelSplines}

{LandmarkWarping2.tex}

Image Warping with BSplines
---------------------------

{sec:ImageWarpingWithBSplines}

{BSplineWarping1.tex}

.. |image| image:: DeformableRegistration1CheckerboardBefore.eps
.. |image1| image:: DeformableRegistration1CheckerboardAfter.eps
