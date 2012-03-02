Vector deformation fields may be visualized using ParaView. ParaView is
an open-source, multi-platform visualization application and uses the
Visualization Toolkit as the data processing and rendering engine and
has a user interface written using a unique blend of Tcl/Tk and C++. You
may download it from http://paraview.org.

Visualizing 2D deformation fields
---------------------------------

Let us visualize the deformation field obtained from Demons Registration
algorithm generated from
Insight/Examples/Registration/DeformableRegistration2.cxx.

Load the Deformation field in Paraview. (The deformation field must be
capable of handling vector data, such as MetaImages). Paraview shows a
color map of the magnitudes of the deformation fields as shown in
{fig:ParaviewScreenshot1}.

Covert the deformation field to 3D vector data using a { Calculator}.
The Calculator may be found in the { Filter} pull down menu. A
screenshot of the calculator tab is shown in Figure
{fig:ParaviewScreenshot2}. Although the deformation field is a 2D
vector, we will generate a 3D vector with the third component set to 0
since Paraview generates glyphs only for 3D vectors. You may now apply a
glyph of arrows to the resulting 3D vector field by using { Glyph} on
the menu bar. The glyphs obtained will be very dense since a glyph is
generated for each point in the data set. To better visualize the
deformation field, you may adopt one of the following approaches.

Reduce the number of glyphs by reducing the number in { Max. Number of
Glyphs} to reasonable amount. This uniformly downsamples the number of
glyphs. Alternatively, you may apply a { Threshold} filter to the {
Magnitude} of the vector dataset and then glyph the vector data that
lies above the threshold. This eliminates the smaller deformation fields
that clutter the display. You may now reduce the number of glyphs to a
reasonable value.

Figure {fig:ParaviewScreenshot3} shows the vector field visualized using
Paraview by thresholding the vector magnitudes by 2.1 and restricting
the number of glyphs to 100.

    |image| [Deformation field magnitudes] {Deformation field magnitudes
    displayed using Paraview} {fig:ParaviewScreenshot1}

    |image1| [Calculator] {Calculators and filters may be used to
    compute the vector magnitude, compose vectors etc.}
    {fig:ParaviewScreenshot2}

    |image2| [Visualized Def field] {Deformation field visualized using
    Paraview after thresholding and subsampling.}
    {fig:ParaviewScreenshot3}

Visualizing 3D deformation fields
---------------------------------

Let us create a 3D deformation field. We will use Thin Plate Splines to
warp a 3D dataset and create a deformation field. We will pick a set of
point landmarks and translate them to provide a specification of
correspondences at point landmarks. Note that the landmarks have been
picked randomly for purposes of illustration and are not intended to
portray a true deformation. The landmarks may be used to produce a
deformation field in several ways. Most techniques minimize some
regularizing functional representing the irregularity of the deformation
field, which is usually some function of the spatial derivatives of the
field. Here will we use { thin plate splines}. Thin plate splines
minimize the regularizing functional

:math:`I[f(x,y)] = \iint (f^2_{xx} + 2 f^2_{xy} + f^2_{yy}) dx dy
` where the subscripts denote partial derivatives of f.

The code for this section can be found in
Insight/Examples/Registration/ThinPlateSplineWarp.cxx

We may now proceed as before to visualize the deformation field using
Paraview as shown in Figure {fig:ParaviewScreenshot4}.

    |image3| [Visualized Def field4] {3D Deformation field visualized
    using Paraview.} {fig:ParaviewScreenshot4}

.. |image| image:: ParaviewScreenshot1.eps
.. |image1| image:: ParaviewScreenshot2.eps
.. |image2| image:: ParaviewScreenshot3.eps
.. |image3| image:: ParaviewScreenshot4.eps
