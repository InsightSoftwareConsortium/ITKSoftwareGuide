About the Cover
===============

Creating the cover image demonstrating the capabilities of the toolkit
was a challenging task. [1]_ Given that the origins of ITK are with the
Visible Human Project it seemed appropriate to create an image utilizing
the VHP data sets, and it was decided to use the more recently acquired
Visible Woman dataset. Both the RGB cryosections and the CT scans were
combined in the same scene.

Removing the Gel.
    The body of the Visible Woman was immersed in a block of gel during
    the freezing process. This gel appears as a blue material in the
    cryogenic data. To remove the gel, the joint histogram of RGB values
    was computed. This resulted in an 3D image of
    :math:`256\times256\times256` pixels. The histogram image was
    visualized in VolView. [2]_ The cluster corresponding to the
    statistical distribution of blue values was identified visually, and
    a separating plane was manually defined in RGB space. The equation
    of this plane was subsequently used to discriminate pixels in the
    gel from pixels in the anatomical structures. The gel pixels were
    zeroed out and the RGB values on the body were preserved.

The Skin.
    The skin was easy to segment once the gel was removed. A simple
    region growing algorithm was used requiring seed points in the
    region previously occupied by the gel and then set to zero values.
    An anti-aliasing filter was applied in order to generate an image of
    pixel type float where the surface was represented by the zero set.
    This data set was exported to VTK where a contouring filter was used
    to extract the surface and introduce it in the VTK visualization
    pipeline.

The Brain.
    The visible part of the brain represents the surface of the gray
    matter. The brain was segmented using the vector version of the
    confidence connected image filter. This filter implements a region
    growing algorithm that starts from a set of seed points and adds
    neighboring pixels subject to a condition of homogeneity.

    The set of sparse points obtained from the region growing algorithm
    was passed through a mathematical morphology dilation in order to
    close holes and then through a binary median filter. The binary
    median filter has the outstanding characteristic of being very
    simple in implementation by applying a sophisticated effect on the
    image. Qualitatively it is equivalent to a curvature flow evolution
    of the iso-contours. In fact the binary median filter as implemented
    in ITK is equivalent to the majority filter that belongs to the
    family of voting filters classified as a subset of the *Larger than
    Life* cellular automata. Finally, the volume resulting from the
    median filter was passed through the anti-aliasing image filter. As
    before, VTK was used to extract the surface.

The Neck Musculature.
    The neck musculature was not perfectly segmented. Indeed, the
    resulting surface is a fusion of muscles, blood vessels and other
    anatomical structures. The segmentation was performed by applying
    the VectorConfidenceConnectedImageFilter to the cryogenic dataset.
    Approximately 60 seed points were manually selected and then passed
    to the filter as input. The binary mask produced by the filter was
    dilated with a mathematical morphology filter and smoothed with the
    BinaryMedianImageFilter. The AntiAliasBinaryImageFilter was used at
    the end to reduce the pixelization effects prior to the extraction
    of the iso-surface with vtkContourFilter.

The Skull.
    The skull was segmented from the CT data set and registered to the
    cryogenic data. The segmentation was performed by simple
    thresholding, which was good enough for the cover image. As a
    result, most of the bone structures are actually fused together.
    This includes the jaw bone and the cervical vertebrae.

The Eye.
    The eye is charged with symbolism in this image. This is due in part
    because the motivation for the toolkit is the analysis of the
    Visible Human data, and in part because the name of the toolkit is
    *Insight*.

    The first step in processing the eye was to extract a sub-image of
    :math:`60\times60\times60` pixels centered around the eyeball from
    the RGB cryogenic data set. This small volume was then processed
    with the vector gradient anisotropic diffusion filter in order to
    increase the homogeneity of the pixels in the eyeball.

    The smoothed volume was segmented using the
    VectorConfidenceConnectedImageFilter using 10 seed points. The
    resulting binary mask was dilated with a mathematical morphology
    filter with a structuring element of radius one, then smoothed with
    a binary mean image filter (equivalent to majority voting cellular
    automata). Finally the mask was processed with the
    AntiAliasBinaryImageFilter in order to generate a float image with
    the eyeball contour embedded as a zero set.

Visualization.
    The visualization of the segmentation was done by passing all the
    binary masks through the AntiAliasBinaryImageFilter, generating
    iso-contours with VTK filters, and then setting up a VTK Tcl script.
    The skin surface was clipped using the vtkClipPolyDataFilter using
    the implicit function vtkCylinder. The vtkWindowToImageFilter proved
    to be quite useful for generating the final high resolution
    rendering of the scene (:math:`3000\times3000` pixels).

Cosmetic Postprocessing.
    We have to confess that we used Adobe Photoshop to post-process the
    image. In particular, the background of the image was adjusted using
    Photoshop’s color selection. The overall composition of the image
    with the cover text and graphics was also performed using Photoshop.

.. [1]
   The source code for the cover is available from
   InsightDocuments/SoftwareGuide/Cover/Source/.

.. [2]
   VolView is a commercial product from Kitware. It supports ITK
   plug-ins and is available as a free viewer or may be licensed with
   advanced functionality. See
   http://www.kitware.com/products/volview.html for information.
