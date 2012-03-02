Registration
============

    |image| [Image Registration Concept] {Image registration is the task
    of finding a spatial transform mapping on image into
    another.{fig:ImageRegistrationConcept}}

This chapter introduces ITK’s capabilities for performing image
registration. Image registration is the process of determining the
spatial transform that maps points from one image to homologous points
on a object in the second image. This concept is schematically
represented in Figure {fig:ImageRegistrationConcept}. In ITK,
registration is performed within a framework of pluggable components
that can easily be interchanged. This flexibility means that a
combinatorial variety of registration methods can be created, allowing
users to pick and choose the right tools for their specific application.

Registration Framework
----------------------

The components of the registration framework and their interconnections
are shown in Figure {fig:RegistrationComponents}. The basic input data
to the registration process are two images: one is defined as the
*fixed* image :math:`f(\bf{X})` and the other as the *moving* image
:math:`m(\bf{X})`. Where :math:`\bf{X}` represents a position in
N-dimensional space. Registration is treated as an optimization problem
with the goal of finding the spatial mapping that will bring the moving
image into alignment with the fixed image.

    |image1| [Registration Framework Components] {The basic components
    of the registration framework are two input images, a transform, a
    metric, an interpolator and an optimizer.}
    {fig:RegistrationComponents}

The *transform* component :math:`T(\bf{X})` represents the spatial
mapping of points from the fixed image space to points in the moving
image space. The *interpolator* is used to evaluate moving image
intensities at non-grid positions. The *metric* component
:math:`S(f,m \circ T)` provides a measure of how well the fixed image
is matched by the transformed moving image. This measure forms the
quantitative criterion to be optimized by the *optimizer* over the
search space defined by the parameters of the *transform*.

These various ITK registration components will be described in later
sections. First, we begin with some simple registration examples.

"Hello World" Registration
--------------------------

{sec:IntroductionImageRegistration} {ImageRegistration1.tex}

Features of the Registration Framework
--------------------------------------

{sec:FeaturesOfTheRegistrationFramework}

    |image2| [Registration Coordinate Systems] {Different coordinate
    systems involved in the image registration process. Note that the
    transform being optimized is the one mapping from the physical space
    of the fixed image into the physical space of the moving image.}
    {fig:ImageRegistrationCoordinateSystemsDiagram}

This section presents a discussion on the two most common difficulties
that users encounter when they start using the ITK registration
framework. They are, in order of difficulty

-  The direction of the Transform mapping

-  The fact that registration is done in physical coordinates

Probably the reason why these two topics tend to create confusion is
that they are implemented in different ways in other systems and
therefore users tend to have different expectations regarding how things
should work in ITK. The situation is further complicated by the fact
that most people describe image operations as if they were manually
performed in a picture in paper.

Direction of the Transform Mapping
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:DirectionOfTheTransformMapping}

The Transform that is optimized in the ITK registration framework is the
one that maps points from the physical space of the fixed image into the
physical space of the moving image. This is illustrated in
Figure {fig:ImageRegistrationCoordinateSystemsDiagram}. This implies
that the Transform will accept as input points from the fixed image and
it will compute the coordinates of the analogous points in the moving
image. What tends to create confusion is the fact that when the
Transform shifts a point on the **positive** X direction, the visual
effect of this mapping, once the moving image is resampled, is
equivalent to { manually shifting} the moving image along the
**negative** X direction. In the same way, when the Transform applies a
**clock-wise** rotation to the fixed image points, the visual effect of
this mapping once the moving image has been resampled is equivalent to {
manually rotating} the moving image **counter-clock-wise**.

The reason why this direction of mapping has been chosen for the ITK
implementation of the registration framework is that this is the
direction that better fits the fact that the moving image is expected to
be resampled using the grid of the fixed image. The nature of the
resampling process is such that an algorithm must go through every pixel
of the { fixed} image and compute the intensity that should be assigned
to this pixel from the mapping of the { moving} image. This computation
involves taking the integral coordinates of the pixel in the image grid,
usually called the “(i,j)” coordinates, mapping them into the physical
space of the fixed image (transform **T1** in
Figure {fig:ImageRegistrationCoordinateSystemsDiagram}), mapping those
physical coordinates into the physical space of the moving image
(Transform to be optimized), then mapping the physical coordinates of
the moving image in to the integral coordinates of the discrete grid of
the moving image (transform **T2** in the figure), where the value of
the pixel intensity will be computed by interpolation.

If we have used the Transform that maps coordinates from the moving
image physical space into the fixed image physical space, then the
resampling process could not guarantee that every pixel in the grid of
the fixed image was going to receive one and only one value. In other
words, the resampling will have resulted in an image with holes and with
redundant or overlapped pixel values.

As you have seen in the previous examples, and you will corroborate in
the remaining examples in this chapter, the Transform computed by the
registration framework is the Transform that can be used directly in the
resampling filter in order to map the moving image into the discrete
grid of the fixed image.

There are exceptional cases in which the transform that you want is
actually the inverse transform of the one computed by the ITK
registration framework. Only in those cases you may have to recur to
invoking the {GetInverse()} method that most transform offer. Make sure
that before you consider following that dark path, you interact with the
examples of resampling illustrated in
section {sec:GeometricalTransformationFilters} in order to get familiar
with the correct interpretation of the transforms.

Registration is done in physical space
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:RegistrationIsDoneInPhysicalSpace}

The second common difficulty that users encounter with the ITK
registration framework is related to the fact that ITK performs
registration in the context of physical space and not in the discrete
space of the image grid.
Figure {fig:ImageRegistrationCoordinateSystemsDiagram} show this concept
by crossing the transform that goes between the two image grids. One
important consequence of this fact is that having the correct image
origin and image pixel size is fundamental for the success of the
registration process in ITK. Users must make sure that they provide
correct values for the origin and spacing of both the fixed and moving
images.

A typical case that helps to understand this issue, is to consider the
registration of two images where one has a pixel size different from the
other. For example, a PET [1]_ image and a CT [2]_ image. Typically a CT
image will have a pixel size in the order of 1 millimeter, while a PET
image will have a pixel size in the order of 5 millimeters to 1
centimeter. Therefore, the CT will need about 500 pixels in order to
cover the extent across a human brain, while the PET image will only
have about 50 pixels for covering the same physical extent of a human
brain.

A user performing registration between a PET image and a CT image may be
naively expecting that because the PET image has less pixels, a {
scaling} factor is required in the Transform in order to map this image
into the CT image. At that point, this person is attempting to interpret
the registration process directly between the two image grids, or in {
pixel space}. What ITK will do in this case is to take into account the
pixel size that the user has provided and it will use that pixel size in
order to compute a scaling factor for Transforms { T1} and { T2} in
Figure {fig:ImageRegistrationCoordinateSystemsDiagram}. Since these two
transforms take care of the required scaling factor, the spatial
Transform to be computed during the registration process does not need
to be concerned about such scaling. The transform that ITK is computing
is the one that will physically map the brain from the moving image into
the brain of the fixed image.

In order to better understand this concepts, it is very useful to draw
sketches of the fixed and moving image { at scale} in the same physical
coordinate system. That is the geometrical configuration that the ITK
registration framework uses as context. Keeping this in mind helps a lot
for interpreting correctly the results of a registration process
performed with ITK.

Monitoring Registration
-----------------------

{sec:MonitoringImageRegistration} {ImageRegistration3.tex}

Multi-Modality Registration
---------------------------

{sec:MultiModalityRegistration}

Some of the most challenging cases of image registration arise when
images of different modalities are involved. In such cases, metrics
based on direct comparison of gray levels are not applicable. It has
been extensively shown that metrics based on the evaluation of mutual
information are well suited for overcoming the difficulties of
multi-modality registration.

The concept of Mutual Information is derived from Information Theory and
its application to image registration has been proposed in different
forms by different groups , a more detailed review can be found in . The
Insight Toolkit currently provides five different implementations of
Mutual Information metrics (see section {sec:Metrics} for details). The
following examples illustrate the practical use of some of these
metrics.

Viola-Wells Mutual Information
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:MultiModalityRegistrationViolaWells} {ImageRegistration2.tex}

Mattes Mutual Information
~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:MultiModalityRegistrationMattes} {ImageRegistration4.tex}

Centered Transforms
-------------------

The ITK image coordinate origin is typically located in one of the image
corners (see section  {sec:DefiningImageOriginAndSpacing} for details).
This results in counter-intuitive transform behavior when rotations and
scaling are involved. Users tend to assume that rotations and scaling
are performed around a fixed point at the center of the image. In order
to compensate for this difference in natural interpretation, the concept
of *centered* transforms have been introduced into the toolkit. The
following sections describe the main characteristics of such transforms.

The introduction of the centered transforms in the Insight Toolkit
reflects the dynamic nature of a software library when it evolves in
harmony with the requests of the community that it serves. This dynamism
has, as everything else in real life, some advantages and some
disadvantages. The main advantage is that when a need is identified by
the users, it gets implemented in a matter of days or weeks. This
capability for rapidly responding to the needs of a community is one of
the major strengths of Open Source software. It has the additional
safety that if the rest of the community does not wish to adopt a
particular change, an isolated user can always implement that change in
her local copy of the toolkit, since all the source code of ITK is
available in a BSD-style license [3]_ that does not restrict
modification nor distribution of the code, and that does not impose the
assimilation demands of viral licenses such as GPL [4]_.

The main disadvantage of dynamism, is of course, the fact that there is
continuous change and a need for perpetual adaptation. The evolution of
software occurs at different scales, some changes happen to evolve in
localized regions of the code, while from time to time accommodations of
a larger scale are needed. The need for continuous changes is addressed
in Extreme Programming with the methodology of *Refactoring*. At any
given point, the structure of the code may not project the organized and
neatly distributed architecture that may have resulted from a monolithic
and static design. There is, after all, good reasons why living beings
can not have straight angles. What you are about to witness in this
section is a clear example of the diversity of species that flourishes
when Evolution is in action .

Rigid Registration in 2D
~~~~~~~~~~~~~~~~~~~~~~~~

{sec:RigidRegistrationIn2D} {ImageRegistration5.tex}

Initializing with Image Moments
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:InitializingRegistrationWithMoments} {ImageRegistration6.tex}

Similarity Transform in 2D
~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:SimilarityRegistrationIn2D} {ImageRegistration7.tex}

Rigid Transform in 3D
~~~~~~~~~~~~~~~~~~~~~

{sec:RigidRegistrationIn3D} {ImageRegistration8.tex}

Centered Affine Transform
~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:CenteredAffineTransform} {ImageRegistration9.tex}

Multi-Resolution Registration
-----------------------------

{sec:MultiResolutionRegistration} Performing image registration using a
multi-resolution approach is widely used to improve speed, accuracy and
robustness. The basic idea is that registration is first performed at a
coarse scale where the images have fewer pixels. The spatial mapping
determined at the coarse level is then used to initialize registration
at the next finer scale. This process is repeated until it reaches the
finest possible scale. This coarse-to-fine strategy greatly improve the
registration success rate and also increases robustness by eliminating
local optima at coarser scales.

The Insight Toolkit offers a multi-resolution registration framework
that is directly compatible with all the registration framework
components. The multi-resolution registration framework has two
additional components: a pair of *image pyramids* that are used to
down-sample the fixed and moving images as illustrated in Figure
{fig:MultiResRegistrationComponents}. The pyramids smooth and subsample
the images according to user-defined scheduling of shrink factors.

    |image3| [Multi-Resolution Registration Components] {Components of
    the multi-resolution registration framework.}
    {fig:MultiResRegistrationComponents}

We now present the main capabilities of the multi-resolution framework
by way of an example.

Fundamentals
~~~~~~~~~~~~

{MultiResImageRegistration1.tex}

Parameter Tuning
~~~~~~~~~~~~~~~~

{MultiResImageRegistration2.tex}

With the completion of these examples, we will now review the main
features of the components forming the registration framework.

Transforms
----------

{sec:Transforms} {Transforms.tex}

Interpolators
-------------

{sec:Interpolators} {ImageInterpolators.tex}

Metrics
-------

{sec:Metrics} {ImageMetrics.tex}

Optimizers
----------

{sec:Optimizers} {Optimizers.tex}

Registration using Match Cardinality metric
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:RegistrationMatchCardinality} {ImageRegistration10.tex}

Registration using the One plus One Evolutionary Optimizer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:RegistrationOnePlusOne} {ImageRegistration11.tex}

Registration using masks constructed with Spatial objects
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:RegistrationSpatialObjects} {ImageRegistration12.tex}

Rigid registrations incorporating prior knowledge
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:RegistrationCentered2DTransform} {ImageRegistration13.tex}

Image Pyramids
--------------

{sec:ImagePyramids} {ImagePyramids.tex}

Deformable Registration
-----------------------

{sec:DeformableRegistration} {DeformableRegistration.tex}

Demons Deformable Registration
------------------------------

{sec:DemonsDeformableRegistration} {DemonsRegistration.tex}

Visualizing Deformation fields
------------------------------

{sec:VisualizingDeformationFields}
{VisualizingDeformationFieldsUsingParaview.tex}

{DeformableRegistration4OnBrain.tex}

Model Based Registration
------------------------

{sec:ModelBasedRegistration} {ModelBasedRegistration.tex}

Point Set Registration
----------------------

{sec:PointSetRegistration}

PointSet-to-PointSet registration is a common problem in medical image
analysis. It usually arises in cases where landmarks are extracted from
images and are used for establishing the spatial correspondence between
the images. This type of registration can be considered to be the
simplest case of feature-based registration. In general terms,
feature-based registration is more efficient than the intensity based
method that we have presented so far. However, feature-base registration
brings the new problem of identifying and extracting the features from
the images, which is not a minor challenge.

The two most common scenarios in PointSet to PointSet registration are

-  Two PointSets with the same number of points, and where each point in
   one set has a known correspondence to exactly one point in the second
   set.

-  Two PointSets without known correspondences between the points of one
   set and the points of the other. In this case the PointSets may have
   different numbers of points.

The first case can be solved with a closed form solution when we are
dealing with a Rigid or an Affine Transform . This is done in ITK with
the class {LandmarkBasedTransformInitializer}. If we are interested in a
deformable Transformation then the problem can be solved with the
{KernelTransform} family of classes, which includes Thin Plate Splines
among others . In both circumstances, the availability o f
correspondences between the points make possible to apply a straight
forward solution to the problem.

The classical algorithm for performing PointSet to PointSet registration
is the Iterative Closest Point (ICP) algorithm. The following examples
illustrate how this can be used in ITK.

Point Set Registration in 2D
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:PointSetRegistrationIn2D}

{IterativeClosestPoint1.tex}

Point Set Registration in 3D
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:PointSetRegistrationIn3D}

{IterativeClosestPoint2.tex}

Point Set to Distance Map Metric
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:PointSetToDistanceMapMetric}

{IterativeClosestPoint3.tex}

Registration Troubleshooting
----------------------------

So you read the previous sections, you wrote the code, it compiles and
links fine, but when you run it the registration results are not what
you were expecting. In that case, this section is for you. This is a
compilation of the most common problems that users face when performing
image registration. It provides explanations on the potential sources of
the problems, and advice on how to deal with those problems.

Most of the material in this section has been taken from frequently
asked questions of the ITK users list.

Too many samples outside moving image buffer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

http://public.kitware.com/pipermail/insight-users/2007-March/021442.html

This is a common error message in image registration.

It means that at the current iteration of the optimization, the two
images as so off-registration that their spatial overlap is not large
enough for bringing them back into registration.

The common causes of this problem are:

-  Poor initialization: You must initialize the transform properly.
   Please read the ITK Software Guide
   http://www.itk.org/ItkSoftwareGuide.pdf for a description of the use
   of the CenteredTransformInitializer class.

-  Optimzer steps too large. If you optimizer takes steps that are too
   large, it risks to become unstable and to send the images too far
   appart. You may want to start the optimizer with a maximum step
   lenght of 1.0, and only increase it once you have managed to fine
   tune all other registration parameters.

   Increasing the step length makes your program faster, but it also
   makes it more unstable.

-  Poor set up o the transform parameters scaling. This is extremely
   critical in registration. You must make sure that you balance the
   relative difference of scale between the rotation parameters and the
   translation parameters.

   In typical medical datasets such as CT and MR, translations are
   measured in millimeters, and therefore are in the range of -100:100,
   while rotations are measured in radians, and therefore they tend to
   be in the range of -1:1.

   A rotation of 3 radians is catastrophic, while a translation of 3
   millimeters is rather inoffensive. That difference in scale is the
   one that must be accounted for.

General heuristics for parameter fine-tunning
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

http://public.kitware.com/pipermail/insight-users/2007-March/021435.html

Here is some advice on how to fine tune the parameters of the
registration process.

1) Set Maximum step length to 0.1 and do not change it until all other
parameters are stable.

2) Set Minimum step length to 0.001 and do not change it.

You could interpret these two parameters as if their units were radians.
So, 0.1 radian = 5.7 degrees.

3) Number of histogram bins:

First plot the histogram of your image using the example program in

Insight/Examples/Statistics/ImageHistogram2.cxx

In that program use first a large number of bins (for example 2000) and
identify the different populations of intensity level and to what
anatomical structures they correspond.

Once you identify the anatomical structures in the histogram, then rerun
that same program with less and less number of bins, until you reach the
minimun number of bins for which all the tissues that are important for
your application, are still distinctly differentiated in the histogram.
At that point, take that number of bins and us it for your Mutual
Information metric.

4) Number of Samples: The trade-off with the number of samples is the
following:

a) computation time of registration is linearly proportional to the
number of samples b) the samples must be enough to significantly
populate the joint histogram. c) Once the histogram is populated, there
is not much use in adding more samples. Therefore do the following:

Plot the joint histogram of both images, using the number of bins that
you selected in item (3). You can do this by modifying the code of the
example:

Insight/Examples/Statistics/ ImageMutualInformation1.cxx you have to
change the code to print out the values of the bins. Then use a plotting
program such as gnuplot, or Matlab, or even Excel and look at the
distribution. The number of samples to take must be enough for producing
the same "appearance" of the joint histogram. As an arbitrary rule of
thumb you may want to start using a high number of samples (80change it
until you have mastered the other parameters of the registration. Once
you get your registration to converge you can revisit the number of
samples and reduce it in order to make the registration run faster. You
can simply reduce it until you find that the registration becomes
unstable. That’s your critical bound for the minimum number of samples.
Take that number and multiply it by the magic number 1.5, to send it
back to a stable region, or if your application is really critical, then
use an even higher magic number x2.0.

This is just engineering: you figure out what is the minimal size of a
piece of steel that will support a bridge, and then you enlarge it to
keep it away from the critical value.

5) The MOST critical values of the registration process are the scaling
parameters that define the proportions between the parameters of the
transform. In your case, for an Affine Transform in 2D, you have 6
parameters. The first four are the ones of the Matrix, and the last two
are the translation. The rotation matrix value must be in the ranges of
radians which is typically [ -1 to 1 ], while the translation values are
in the ranges of millimeters (your image size units). You want to start
by setting the scaling of the matrix parameters to 1.0, and the scaling
of the Translation parameters to the holy esoteric values:

1.0 / ( 10.0 \* pixelspacing[0] \* imagesize[0] ) 1.0 / ( 10.0 \*
pixelspacing[1] \* imagesize[1] )

This is telling the optimizer that you consider that rotating the image
by 57 degrees is as "significant" as translating the image by half its
physical extent.

Note that esoteric value has included the arbitrary number 10.0 in the
denominator, for no other reason that we have been lucky when using that
factor. This of course is just a supersticion, so you should feel free
to experiment with different values of this number.

Just keep in mind that what the optimizer will do is to "jump" in a
paramteric space of 6 dimension, and that the component of the jump on
every dimension will be proporitional to 1/scaling factor \*
OptimizerStepLenght. Since you put the optimizer Step Length to 0.1,
then the optimizer will start by exploring the rotations at jumps of
about 5degrees, which is a conservative rotation for most medical
applications.

If you have reasons to think that your rotations are larger or smaller,
then you should modify the scaling factor of the matrix parameters
accordingly.

In the same way, if you thinkl that 1/10 of the image size is too large
as the first step for exploring the translations, then you should modify
the scaling of translation parameters accordingly.

In order to drive all these you need to analyze the feedback that the
observer is providing you. For example, plot the metric values, and plot
the translation coordinates so that you can get a feeling of how the
registration is behaving.

Note also that image registration is not a science. it is a pure
engineerig practice, and therefore, there are no correct answers, nor
"truths" to be found. It is all about how much quality your want, and
how must computation time, and development time are you willing to pay
for that quality. The "satisfying" answer for your specific application
must be found by exploring the trade-offs between the different
parameters that regulate the image registration process.

If you are proficient in VTK you may want to consider attaching some
visualization to the Event observer, so that you can have a visual
feedback on the progress of the registration. This is a lot more
productive than trying to interpret the values printed out on the
console by the observer.

.. [1]
   Positron Emission Tomography

.. [2]
   Computer Tomography in X-rays

.. [3]
   http://www.opensource.org/licenses/bsd-license.php

.. [4]
   http://www.gnu.org/copyleft/gpl.html

.. |image| image:: ImageRegistrationConcept.eps
.. |image1| image:: RegistrationComponentsDiagram.eps
.. |image2| image:: ImageRegistrationCoordinateSystemsDiagram.eps
.. |image3| image:: MultiResRegistrationComponents.eps
