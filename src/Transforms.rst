{ \| p{3cm} \| p{1.8cm} \| p{2.5cm} \| p{4cm} \| }

In the Insight Toolkit, {Transform} objects encapsulate the mapping of
points and vectors from an input space to an output space. If a
transform is invertible, back transform methods are also provided.
Currently, ITK provides a variety of transforms from simple translation,
rotation and scaling to general affine and kernel transforms. Note that,
while in this section we discuss transforms in the context of
registration, transforms are general and can be used for other
applications. Some of the most commonly used transforms will be
discussed in detail later. Let’s begin by introducing the objects used
in ITK for representing basic spatial concepts.

Geometrical Representation
--------------------------

{sec:GeometricalObjects}

    |image| [Geometrical representation objects in ITK] {Geometric
    representation objects in ITK.} {fig:GeometricalObjects}

ITK implements a consistent geometric representation of the space. The
characteristics of classes involved in this representation are
summarized in Table {tab:GeometricalConcepts}. In this regard, ITK takes
full advantage of the capabilities of Object Oriented programming and
resists the temptation of using simple arrays of {float} or {double} in
order to represent geometrical objects. The use of basic arrays would
have blurred the important distinction between the different geometrical
concepts and would have allowed for the innumerable conceptual and
programming errors that result from using a vector where a point is
needed or vice versa.

            **Class** & **Geometrical concept**
             {Point} & Position in space. In :math:`N`-dimensional
            space it is represented by an array of :math:`N` numbers
            associated with space coordinates.
             {Vector} & Relative position between two points. In
            :math:`N`-dimensional space it is represented by an array
            of :math:`N` numbers, each one associated with the
            distance along a coordinate axis. Vectors do not have a
            position in space. A vector is defined as the subtraction of
            two points.
             {CovariantVector} & Orthogonal direction to a
            :math:`(N-1)`-dimensional manifold in space. For example,
            in :math:`3D` it corresponds to the vector orthogonal to a
            surface. This is the appropriate class for representing
            Gradients of functions. Covariant vectors do not have a
            position in space. Covariant vector should not be added to
            Points, nor to Vectors.

    [Geometrical Elementary Objects] {Summary of objects representing
    geometrical concepts in ITK.{tab:GeometricalConcepts}}

Additional uses of the {Point}, {Vector} and {CovariantVector} classes
have been discussed in Chapter {sec:DataRepresentation}. Each one of
these classes behaves differently under spatial transformations. It is
therefore quite important to keep their distinction clear. Figure
{fig:GeometricalObjects} illustrates the differences between these
concepts.

Transform classes provide different methods for mapping each one of the
basic space-representation objects. Points, vectors and covariant
vectors are transformed using the methods {TransformPoint()},
{TransformVector()} and {TransformCovariantVector()} respectively.

One of the classes that deserve further comments is the {Vector}. This
ITK class tend to be misinterpreted as a container of elements instead
of a geometrical object. This is a common misconception originated by
the fact that Computer Scientist and Software Engineers misuse the term
“Vector”. The actual word “Vector” is relatively young. It was coined by
William Hamilton in his book “*Elements of Quaternions*” published in
1886 (post-mortem). In the same text Hamilton coined the terms:
“*Scalar*”, “*Versor*” and “*Tensor*”. Although the modern term of
“*Tensor*” is used in Calculus in a different sense of what Hamilton
defined in his book at the time .

A “*Vector*” is, by definition, a mathematical object that embodies the
concept of “direction in space”. Strictly speaking, a Vector describes
the relationship between two Points in space, and captures both their
relative distance and orientation.

Computer scientists and software engineers misused the term vector in
order to represent the concept of an “Indexed Set” . Mechanical
Engineers and Civil Engineers, who deal with the real world of physical
objects will not commit this mistake and will keep the word “*Vector*”
attached to a geometrical concept. Biologists, on the other hand, will
associate “*Vector*” to a “vehicle” that allows them to direct something
in a particular direction, for example, a virus that allows them to
insert pieces of code into a DNA strand .

Textbooks in programming do not help to clarify those concepts and
loosely use the term “*Vector*” for the purpose of representing an
“enumerated set of common elements”. STL follows this trend and continue
using the word “*Vector*” for what it was not supposed to be used .
Linear algebra separates the “*Vector*” from its notion of geometric
reality and makes it an abstract set of numbers with arithmetic
operations associated.

For those of you who are looking for the “*Vector*” in the Software
Engineering sense, please look at the {Array} and {FixedArray} classes
that actually provide such functionalities. Additionally, the
{VectorContainer} and {MapContainer} classes may be of interest too.
These container classes are intended for algorithms that require to
insert and delete elements, and that may have large numbers of elements.

The Insight Toolkit deals with real objects that inhabit the physical
space. This is particularly true in the context of the image
registration framework. We chose to give the appropriate name to the
mathematical objects that describe geometrical relationships in
N-Dimensional space. It is for this reason that we explicitly make clear
the distinction between Point, Vector and CovariantVector, despite the
fact that most people would be happy with a simple use of {double[3]}
for the three concepts and then will proceed to perform all sort of
conceptually flawed operations such as

- Adding two Points
- Dividing a Point by a Scalar
- Adding a Covariant Vector to a Point
- Adding a Covariant Vector to a Vector

In order to enforce the correct use of the Geometrical concepts in ITK
we organized these classes in a hierarchy that supports reuse of code
and yet compartmentalize the behavior of the individual classes. The use
of the {FixedArray} as base class of the {Point}, the {Vector} and the
{CovariantVector} was a design decision based on calling things by their
correct name.

An {FixedArray} is an enumerated collection with a fixed number of
elements. You can instantiate a fixed array of letters, or a fixed array
of images, or a fixed array of transforms, or a fixed array of
geometrical shapes. Therefore, the FixedArray only implements the
functionality that is necessary to access those enumerated elements. No
assumptions can be made at this point on any other operations required
by the elements of the FixedArray, except the fact of having a default
constructor.

The {Point} is a type that represents the spatial coordinates of a
spatial location. Based on geometrical concepts we defined the valid
operations of the Point class. In particular we made sure that no
{operator+()} was defined between Points, and that no {operator\*(
scalar )} nor {operator/( scalar )} were defined for Points.

In other words, you could do in ITK operations such as:

-  Vector = Point - Point
-  Point += Vector
-  Point -= Vector
-  Point = BarycentricCombination( Point, Point )

and you cannot (because you **should not**) do operation such as

-  Point = Point \* Scalar
-  Point = Point + Point
-  Point = Point / Scalar

The {Vector} is, by Hamilton’s definition, the subtraction between two
points. Therefore a Vector must satisfy the following basic operations:

-  Vector = Point - Point
-  Point = Point + Vector
-  Point = Point - Vector
-  Vector = Vector + Vector
-  Vector = Vector - Vector

An {Vector} object is intended to be instantiated over elements that
support mathematical operation such as addition, subtraction and
multiplication by scalars.

Transform General Properties
----------------------------

{sec:TransformGeneralProperties}

Each transform class typically has several methods for setting its
parameters. For example, {Euler2DTransform} provides methods for
specifying the offset, angle, and the entire rotation matrix. However,
for use in the registration framework, the parameters are represented by
a flat Array of doubles to facilitate communication with generic
optimizers. In the case of the Euler2DTransform, the transform is also
defined by three doubles: the first representing the angle, and the last
two the offset. The flat array of parameters is defined using
{SetParameters()}. A description of the parameters and their ordering is
documented in the sections that follow.

In the context of registration, the transform parameters define the
search space for optimizers. That is, the goal of the optimization is to
find the set of parameters defining a transform that results in the best
possible value of an image metric. The more parameters a transform has,
the longer its computational time will be when used in a registration
method since the dimension of the search space will be equal to the
number of transform parameters.

Another requirement that the registration framework imposes on the
transform classes is the computation of their Jacobians. In general,
metrics require the knowledge of the Jacobian in order to compute Metric
derivatives. The Jacobian is a matrix whose element are the partial
derivatives of the output point with respect to the array of parameters
that defines the transform: [1]_

:math:`J=\left[ \begin{array}{cccc}
\frac{\partial x_{1}}{\partial p_{1}} &
\frac{\partial x_{1}}{\partial p_{2}} &
\cdots  & \frac{\partial x_{1}}{\partial p_{m}}\\
\frac{\partial x_{2}}{\partial p_{1}} &
\frac{\partial x_{2}}{\partial p_{2}} &
\cdots  & \frac{\partial x_{2}}{\partial p_{m}}\\
\vdots  & \vdots  & \ddots  & \vdots \\
\frac{\partial x_{n}}{\partial p_{1}} &
\frac{\partial x_{n}}{\partial p_{2}} &
\cdots  & \frac{\partial x_{n}}{\partial p_{m}}
\end{array}\right]`

where :math:`\{p_i\}` are the transform parameters and
:math:`\{x_i\}` are the coordinates of the output point. Within this
framework, the Jacobian is represented by an {Array2D} of doubles and is
obtained from the transform by method {GetJacobian()}. The Jacobian can
be interpreted as a matrix that indicates for a point in the input space
how much its mapping on the output space will change as a response to a
small variation in one of the transform parameters. Note that the values
of the Jacobian matrix depend on the point in the input space. So
actually the Jacobian can be noted as :math:`J(\bf{X})`, where
:math:`{\bf{X}}=\{x_i\}`. The use of transform Jacobians enables the
efficient computation of metric derivatives. When Jacobians are not
available, metrics derivatives have to be computed using finite
difference at a price of :math:`2M` evaluations of the metric value,
where :math:`M` is the number of transform parameters.

The following sections describe the main characteristics of the
transform classes available in ITK.

Identity Transform
------------------

{sec:IdentityTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Maps every point to itself, every vector to itself and
            every covariant vector to itself. & 0 & NA & Only defined
            when the input and output space has the same number of
            dimensions.

    [Identity Transform Characteristics] {Characteristics of the
    identity transform. {tab:IdentityTransformCharacteristics}}

The identity transform {IdentityTransform} is mainly used for debugging
purposes. It is provided to methods that require a transform and in
cases where we want to have the certainty that the transform will have
no effect whatsoever in the outcome of the process. It is just a {NULL}
operation. The main characteristics of the identity transform are
summarized in Table {tab:IdentityTransformCharacteristics}

Translation Transform
---------------------

{sec:TranslationTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a simple translation of points in the input
            space and has no effect on vectors or covariant vectors. &
            Same as the input space dimension. & The :math:`i`-th
            parameter represents the translation in the :math:`i`-th
            dimension. & Only defined when the input and output space
            has the same number of dimensions.

    [Translation Transform Characteristics] {Characteristics of the
    TranslationTransform class.
    {tab:TranslationTransformCharacteristics}}

The {TranslationTransform} is probably the simplest yet one of the most
useful transformations. It maps all Points by adding a Vector to them.
Vector and covariant vectors remain unchanged under this transformation
since they are not associated with a particular position in space.
Translation is the best transform to use when starting a registration
method. Before attempting to solve for rotations or scaling it is
important to overlap the anatomical objects in both images as much as
possible. This is done by resolving the translational misalignment
between the images. Translations also have the advantage of being fast
to compute and having parameters that are easy to interpret. The main
characteristics of the translation transform are presented in
Table {tab:TranslationTransformCharacteristics}.

Scale Transform
---------------

{sec:ScaleTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Points are transformed by multiplying each one of their
            coordinates by the corresponding scale factor for the
            dimension. Vectors are transformed as points. Covariant
            vectors are transformed by *dividing* their components by
            the scale factor in the corresponding dimension. & Same as
            the input space dimension. & The :math:`i`-th parameter
            represents the scaling in the :math:`i`-th dimension. &
            Only defined when the input and output space has the same
            number of dimensions.

    [Scale Transform Characteristics] {Characteristics of the
    ScaleTransform class. {tab:ScaleTransformCharacteristics}}

The {ScaleTransform} represents a simple scaling of the vector space.
Different scaling factors can be applied along each dimension. Points
are transformed by multiplying each one of their coordinates by the
corresponding scale factor for the dimension. Vectors are transformed in
the same way as points. Covariant vectors, on the other hand, are
transformed differently since anisotropic scaling does not preserve
angles. Covariant vectors are transformed by *dividing* their components
by the scale factor of the corresponding dimension. In this way, if a
covariant vector was orthogonal to a vector, this orthogonality will be
preserved after the transformation. The following equations summarize
the effect of the transform on the basic geometric objects.

:math:`\begin{array}{lccccccc}
\mbox{Point }          & \bf{P'} &  =  & T(\bf{P})  & : & \bf{P'}_i &  = & \bf{P}_i \cdot S_i \\
\mbox{Vector}          & \bf{V'} &  =  & T(\bf{V})  & : & \bf{V'}_i &  = & \bf{V}_i \cdot S_i \\
\mbox{CovariantVector} & \bf{C'} &  =  & T(\bf{C})  & : & \bf{C'}_i &  = & \bf{C}_i /     S_i \\
\end{array}
`

where :math:`\bf{P}_i`, :math:`\bf{V}_i` and :math:`\bf{C}_i` are
the point, vector and covariant vector :math:`i`-th components while
:math:`\bf{S}_i` is the scaling factor along dimension :math:`i-th`.
The following equation illustrates the effect of the scaling transform
on a :math:`3D` point.

:math:`\left[
\begin{array}{c}
x' \\
y' \\
z' \\
\end{array}
\right]
=
\left[
\begin{array}{ccc}
S_1 &  0  &  0  \\
 0  & S_2 &  0  \\
 0  &  0  & S_3 \\
\end{array}
\right]
\cdot
\left[
\begin{array}{c}
x  \\
y  \\
z  \\
\end{array}
\right]`

Scaling appears to be a simple transformation but there are actually a
number of issues to keep in mind when using different scale factors
along every dimension. There are subtle effects—for example, when
computing image derivatives. Since derivatives are represented by
covariant vectors, their values are not intuitively modified by scaling
transforms.

One of the difficulties with managing scaling transforms in a
registration process is that typical optimizers manage the parameter
space as a vector space where addition is the basic operation. Scaling
is better treated in the frame of a logarithmic space where additions
result in regular multiplicative increments of the scale. Gradient
descent optimizers have trouble updating step length, since the effect
of an additive increment on a scale factor diminishes as the factor
grows. In other words, a scale factor variation of
:math:`(1.0+ \epsilon)` is quite different from a scale variation of
:math:`(5.0+\epsilon)`.

Registrations involving scale transforms require careful monitoring of
the optimizer parameters in order to keep it progressing at a stable
pace. Note that some of the transforms discussed in following sections,
for example, the AffineTransform, have hidden scaling parameters and are
therefore subject to the same vulnerabilities of the ScaleTransform.

In cases involving misalignments with simultaneous translation, rotation
and scaling components it may be desirable to solve for these components
independently. The main characteristics of the scale transform are
presented in Table {tab:ScaleTransformCharacteristics}.

Scale Logarithmic Transform
---------------------------

{sec:ScaleLogarithmicTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Points are transformed by multiplying each one of their
            coordinates by the corresponding scale factor for the
            dimension. Vectors are transformed as points. Covariant
            vectors are transformed by *dividing* their components by
            the scale factor in the corresponding dimension. & Same as
            the input space dimension. & The :math:`i`-th parameter
            represents the scaling in the :math:`i`-th dimension. &
            Only defined when the input and output space has the same
            number of dimensions. The difference between this transform
            and the ScaleTransform is that here the scaling factors are
            passed as logarithms, in this way their behavior is closer
            to the one of a Vector space.

    [Scale Logarithmic Transform Characteristics] {Characteristics of
    the ScaleLogarithmicTransform class.
    {tab:ScaleLogarithmicTransformCharacteristics}}

The {ScaleLogarithmicTransform} is a simple variation of the
{ScaleTransform}. It is intended to improve the behavior of the scaling
parameters when they are modified by optimizers. The difference between
this transform and the ScaleTransform is that the parameter factors are
passed here as logarithms. In this way, multiplicative variations in the
scale become additive variations in the logarithm of the scaling
factors.

Euler2DTransform
----------------

{sec:Euler2DTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a :math:`2D` rotation and a :math:`2D`
            translation. Note that the translation component has no
            effect on the transformation of vectors and covariant
            vectors. & 3 & The first parameter is the angle in radians
            and the last two parameters are the translation in each
            dimension. & Only defined for two-dimensional input and
            output spaces.

    [Euler2D Transform Characteristics] {Characteristics of the
    Euler2DTransform class. {tab:Euler2DTransformCharacteristics}}

{Euler2DTransform} implements a rigid transformation in :math:`2D`. It
is composed of a plane rotation and a two-dimensional translation. The
rotation is applied first, followed by the translation. The following
equation illustrates the effect of this transform on a :math:`2D`
point,

:math:`\left[
\begin{array}{c}
x' \\
y' \\
\end{array}
\right]
=
\left[
\begin{array}{cc}
\cos{\theta} & -\sin{\theta} \\
\sin{\theta} &  \cos{\theta} \\
\end{array}
\right]
\cdot
\left[
\begin{array}{c}
x  \\
y  \\
\end{array}
\right]
+
\left[
\begin{array}{c}
T_x  \\
T_y  \\
\end{array}
\right]`

where :math:`\theta` is the rotation angle and :math:`(T_x,T_y)` are
the components of the translation.

A challenging aspect of this transformation is the fact that
translations and rotations do not form a vector space and cannot be
managed as linear independent parameters. Typical optimizers make the
loose assumption that parameters exist in a vector space and rely on the
step length to be small enough for this assumption to hold
approximately.

In addition to the non-linearity of the parameter space, the most common
difficulty found when using this transform is the difference in units
used for rotations and translations. Rotations are measured in radians;
hence, their values are in the range :math:`[-\pi,\pi]`. Translations
are measured in millimeters and their actual values vary depending on
the image modality being considered. In practice, translations have
values on the order of :math:`10` to :math:`100`. This scale
difference between the rotation and translation parameters is
undesirable for gradient descent optimizers because they deviate from
the trajectories of descent and make optimization slower and more
unstable. In order to compensate for these differences, ITK optimizers
accept an array of scale values that are used to normalize the parameter
space.

Registrations involving angles and translations should take advantage of
the scale normalization functionality in order to obtain the best
performance out of the optimizers. The main characteristics of the
Euler2DTransform class are presented in
Table {tab:Euler2DTransformCharacteristics}.

CenteredRigid2DTransform
------------------------

{sec:CenteredRigid2DTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a :math:`2D` rotation around a user-provided
            center followed by a :math:`2D` translation.& 5 & The
            first parameter is the angle in radians. Second and third
            are the center of rotation coordinates and the last two
            parameters are the translation in each dimension. & Only
            defined for two-dimensional input and output spaces.

    [CenteredRigid2D Transform Characteristics] {Characteristics of the
    CenteredRigid2DTransform class.
    {tab:CenteredRigid2DTransformCharacteristics}}

{CenteredRigid2DTransform} implements a rigid transformation in
:math:`2D`. The main difference between this transform and the
{Euler2DTransform} is that here we can specify an arbitrary center of
rotation, while the Euler2DTransform always uses the origin of the
coordinate system as the center of rotation. This distinction is quite
important in image registration since ITK images usually have their
origin in the corner of the image rather than the middle. Rotational
mis-registrations usually exist, however, as rotations around the center
of the image, or at least as rotations around a point in the middle of
the anatomical structure captured by the image. Using gradient descent
optimizers, it is almost impossible to solve non-origin rotations using
a transform with origin rotations since the deep basin of the real
solution is usually located across a high ridge in the topography of the
cost function.

In practice, the user must supply the center of rotation in the input
space, the angle of rotation and a translation to be applied after the
rotation. With these parameters, the transform initializes a rotation
matrix and a translation vector that together perform the equivalent of
translating the center of rotation to the origin of coordinates,
rotating by the specified angle, translating back to the center of
rotation and finally translating by the user-specified vector.

As with the Euler2DTransform, this transform suffers from the difference
in units used for rotations and translations. Rotations are measured in
radians; hence, their values are in the range :math:`[-\pi,\pi]`. The
center of rotation and the translations are measured in millimeters, and
their actual values vary depending on the image modality being
considered. Registrations involving angles and translations should take
advantage of the scale normalization functionality of the optimizers in
order to get the best performance out of them.

The following equation illustrates the effect of the transform on an
input point :math:`(x,y)` that maps to the output point
:math:`(x',y')`,

:math:`\left[
\begin{array}{c}
x' \\
y' \\
\end{array}
\right]
=
\left[
\begin{array}{cc}
\cos{\theta} & -\sin{\theta} \\
\sin{\theta} &  \cos{\theta} \\
\end{array}
\right]
\cdot
\left[
\begin{array}{c}
x - C_x \\
y - C_y \\
\end{array}
\right]
+
\left[
\begin{array}{c}
T_x + C_x \\
T_y + C_y \\
\end{array}
\right]`

where :math:`\theta` is the rotation angle, :math:`(C_x,C_y)` are
the coordinates of the rotation center and :math:`(T_x,T_y)` are the
components of the translation. Note that the center coordinates are
subtracted before the rotation and added back after the rotation. The
main features of the CenteredRigid2DTransform are presented in
Table {tab:CenteredRigid2DTransformCharacteristics}.

Similarity2DTransform
---------------------

{sec:Similarity2DTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a :math:`2D` rotation, homogeneous scaling and
            a :math:`2D` translation. Note that the translation
            component has no effect on the transformation of vectors and
            covariant vectors. & 4 & The first parameter is the scaling
            factor for all dimensions, the second is the angle in
            radians, and the last two parameters are the translations in
            :math:`(x,y)` respectively. & Only defined for
            two-dimensional input and output spaces.

    [Similarity2D Transform Characteristics] {Characteristics of the
    Similarity2DTransform class.
    {tab:Similarity2DTransformCharacteristics}}

The {Similarity2DTransform} can be seen as a rigid transform combined
with an isotropic scaling factor. This transform preserves angles
between lines. In its :math:`2D` implementation, the four parameters
of this transformation combine the characteristics of the
{ScaleTransform} and {Euler2DTransform}. In particular, those relating
to the non-linearity of the parameter space and the non-uniformity of
the measurement units. Gradient descent optimizers should be used with
caution on such parameter spaces since the notions of gradient direction
and step length are ill-defined.

The following equation illustrates the effect of the transform on an
input point :math:`(x,y)` that maps to the output point
:math:`(x',y')`,

:math:`\left[
\begin{array}{c}
x' \\
y' \\
\end{array}
\right]
=
\left[
\begin{array}{cc}
\lambda &    0     \\
   0    &  \lambda \\
\end{array}
\right]
\cdot
\left[
\begin{array}{cc}
\cos{\theta} & -\sin{\theta} \\
\sin{\theta} &  \cos{\theta} \\
\end{array}
\right]
\cdot
\left[
\begin{array}{c}
x - C_x \\
y - C_y \\
\end{array}
\right]
+
\left[
\begin{array}{c}
T_x + C_x \\
T_y + C_y \\
\end{array}
\right]`

where :math:`\lambda` is the scale factor, :math:`\theta` is the
rotation angle, :math:`(C_x,C_y)` are the coordinates of the rotation
center and :math:`(T_x,T_y)` are the components of the translation.
Note that the center coordinates are subtracted before the rotation and
scaling, and they are added back afterwards. The main features of the
Similarity2DTransform are presented in
Table {tab:Similarity2DTransformCharacteristics}.

A possible approach for controlling optimization in the parameter space
of this transform is to dynamically modify the array of scales passed to
the optimizer. The effect produced by the parameter scaling can be used
to steer the walk in the parameter space (by giving preference to some
of the parameters over others). For example, perform some iterations
updating only the rotation angle, then balance the array of scale
factors in the optimizer and perform another set of iterations updating
only the translations.

QuaternionRigidTransform
------------------------

{sec:QuaternionRigidTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a :math:`3D` rotation and a :math:`3D`
            translation. The rotation is specified as a quaternion,
            defined by a set of four numbers :math:`\bf{q}`. The
            relationship between quaternion and rotation about vector
            :math:`\bf{n}` by angle :math:`\theta` is as follows:
            :math:`\bf{q} = (\bf{n}\sin(\theta/2), \cos(\theta/2))`
            Note that if the quaternion is not of unit length, scaling
            will also result. & 7 & The first four parameters defines
            the quaternion and the last three parameters the translation
            in each dimension. & Only defined for three-dimensional
            input and output spaces.

    [QuaternionRigid Transform Characteristics] {Characteristics of the
    QuaternionRigidTransform class.
    {tab:QuaternionRigidTransformCharacteristics}}

The {QuaternionRigidTransform} class implements a rigid transformation
in :math:`3D` space. The rotational part of the transform is
represented using a quaternion while the translation is represented with
a vector. Quaternions components do not form a vector space and hence
raise the same concerns as the {Similarity2DTransform} when used with
gradient descent optimizers.

The {QuaternionRigidTransformGradientDescentOptimizer} was introduced
into the toolkit to address these concerns. This specialized optimizer
implements a variation of a gradient descent algorithm adapted for a
quaternion space. This class insures that after advancing in any
direction on the parameter space, the resulting set of transform
parameters is mapped back into the permissible set of parameters. In
practice, this comes down to normalizing the newly-computed quaternion
to make sure that the transformation remains rigid and no scaling is
applied. The main characteristics of the QuaternionRigidTransform are
presented in Table {tab:QuaternionRigidTransformCharacteristics}.

The Quaternion rigid transform also accepts a user-defined center of
rotation. In this way, the transform can easily be used for registering
images where the rotation is mostly relative to the center of the image
instead one of the corners. The coordinates of this rotation center are
not subject to optimization. They only participate in the computation of
the mappings for Points and in the computation of the Jacobian. The
transformations for Vectors and CovariantVector are not affected by the
selection of the rotation center.

VersorTransform
---------------

{sec:VersorTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a :math:`3D` rotation. The rotation is
            specified by a versor or unit quaternion. The rotation is
            performed around a user-specified center of rotation.& 3 &
            The three parameters define the versor.& Only defined for
            three-dimensional input and output spaces.

    [Versor Transform Characteristics] {Characteristics of the Versor
    Transform {tab:VersorTransformCharacteristics}}

By definition, a *Versor* is the rotational part of a Quaternion. It can
also be defined as a *unit-quaternion* . Versors only have three
independent components, since they are restricted to reside in the space
of unit-quaternions. The implementation of versors in the toolkit uses a
set of three numbers. These three numbers correspond to the first three
components of a quaternion. The fourth component of the quaternion is
computed internally such that the quaternion is of unit length. The main
characteristics of the {VersorTransform} are presented in
Table {tab:VersorTransformCharacteristics}.

This transform exclusively represents rotations in :math:`3D`. It is
intended to rapidly solve the rotational component of a more general
misalignment. The efficiency of this transform comes from using a
parameter space of reduced dimensionality. Versors are the best possible
representation for rotations in :math:`3D` space. Sequences of versors
allow the creation of smooth rotational trajectories; for this reason,
they behave stably under optimization methods.

The space formed by versor parameters is not a vector space. Standard
gradient descent algorithms are not appropriate for exploring this
parameter space. An optimizer specialized for the versor space is
available in the toolkit under the name of {VersorTransformOptimizer}.
This optimizer implements versor derivatives as originally defined by
Hamilton .

The center of rotation can be specified by the user with the
{SetCenter()} method. The center is not part of the parameters to be
optimized, therefore it remains the same during an optimization process.
Its value is used during the computations for transforming Points and
when computing the Jacobian.

VersorRigid3DTransform
----------------------

{sec:VersorRigid3DTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a :math:`3D` rotation and a :math:`3D`
            translation. The rotation is specified by a versor or unit
            quaternion, while the translation is represented by a
            vector. Users can specify the coordinates of the center of
            rotation. & 6 & The first three parameters define the versor
            and the last three parameters the translation in each
            dimension. & Only defined for three-dimensional input and
            output spaces.

    [Versor Rigid3D Transform Characteristics] {Characteristics of the
    VersorRigid3DTransform class.
    {tab:VersorRigid3DTransformCharacteristics}}

The {VersorRigid3DTransform} implements a rigid transformation in
:math:`3D` space. It is a variant of the {QuaternionRigidTransform}
and the {VersorTransform}. It can be seen as a {VersorTransform} plus a
translation defined by a vector. The advantage of this class with
respect to the QuaternionRigidTransform is that it exposes only six
parameters, three for the versor components and three for the
translational components. This reduces the search space for the
optimizer to six dimensions instead of the seven dimensional used by the
QuaternionRigidTransform. This transform also allows the users to set a
specific center of rotation. The center coordinates are not modified
during the optimization performed in a registration process. The main
features of this transform are summarized in
Table {tab:VersorRigid3DTransformCharacteristics}. This transform is
probably the best option to use when dealing with rigid transformations
in :math:`3D`.

Given that the space of Versors is not a Vector space, typical gradient
descent optimizers are not well suited for exploring the parametric
space of this transform. The {VersorRigid3DTranformOptimizer} has been
introduced in the ITK toolkit with the purpose of providing an optimizer
that is aware of the Versor space properties on the rotational part of
this transform, as well as the Vector space properties on the
translational part of the transform.

Euler3DTransform
----------------

{sec:Euler3DTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a rigid rotation in :math:`3D` space. That is,
            a rotation followed by a :math:`3D` translation. The
            rotation is specified by three angles representing rotations
            to be applied around the X, Y and Z axis one after another.
            The translation part is represented by a Vector. Users can
            also specify the coordinates of the center of rotation. & 6
            & The first three parameters are the rotation angles around
            X, Y and Z axis, and the last three parameters are the
            translations along each dimension. & Only defined for
            three-dimensional input and output spaces.

    [Euler3D Transform Characteristics] {Characteristics of the
    Euler3DTransform class. {tab:Euler3DTransformCharacteristics}}

The {Euler3DTransform} implements a rigid transformation in :math:`3D`
space. It can be seen as a rotation followed by a translation. This
class exposes six parameters, three for the Euler angles that represent
the rotation and three for the translational components. This transform
also allows the users to set a specific center of rotation. The center
coordinates are not modified during the optimization performed in a
registration process. The main features of this transform are summarized
in Table {tab:Euler3DTransformCharacteristics}.

The fact that the three rotational parameters are non-linear and do not
behave like Vector spaces must be taken into account when selecting an
optimizer to work with this transform and when fine tuning the
parameters of such optimizer. It is strongly recommended to use this
transform by introducing very small variations on the rotational
components. A small rotation will be in the range of 1 degree, which in
radians is approximately :math:`0.0.1745`.

You should not expect this transform to be able to compensate for large
rotations just by being driven with the optimizer. In practice you must
provide a reasonable initialization of the transform angles and only
need to correct for residual rotations in the order of :math:`10` or
:math:`20` degrees.

Similarity3DTransform
---------------------

{sec:Similarity3DTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a :math:`3D` rotation, a :math:`3D`
            translation and homogeneous scaling. The scaling factor is
            specified by a scalar, the rotation is specified by a
            versor, and the translation is represented by a vector.
            Users can also specify the coordinates of the center of
            rotation, that is the same center used for scaling. & 7 &
            The first three parameters define the Versor, the next three
            parameters the translation in each dimension, and the last
            parameter is the isotropic scaling factor. & Only defined
            for three-dimensional input and output spaces.

    [Similarity3D Transform Characteristics] {Characteristics of the
    Similarity3DTransform class.
    {tab:Similarity3DTransformCharacteristics}}

The {Similarity3DTransform} implements a similarity transformation in
:math:`3D` space. It can be seen as an homogeneous scaling followed by
a {VersorRigid3DTransform}. This class exposes seven parameters, one for
the scaling factor, three for the versor components and three for the
translational components. This transform also allows the users to set a
specific center of rotation. The center coordinates are not modified
during the optimization performed in a registration process. Both the
rotation and scaling operations are performed with respect to the center
of rotation. The main features of this transform are summarized in
Table {tab:Similarity3DTransformCharacteristics}.

The fact that the scaling and rotational spaces are non-linear and do
not behave like Vector spaces must be taken into account when selecting
an optimizer to work with this transform and when fine tuning the
parameters of such optimizer.

Rigid3DPerspectiveTransform
---------------------------

{sec:Rigid3DPerspectiveTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a rigid :math:`3D` transformation followed by
            a perspective projection. The rotation is specified by a
            Versor, while the translation is represented by a Vector.
            Users can specify the coordinates of the center of rotation.
            They must specifically a focal distance to be used for the
            perspective projection. The rotation center and the focal
            distance parameters are not modified during the optimization
            process. & 6 & The first three parameters define the Versor
            and the last three parameters the Translation in each
            dimension. & Only defined for three-dimensional input and
            two-dimensional output spaces. This is one of the few
            transforms where the input space has a different dimension
            from the output space.

    [Rigid3DPerspective Transform Characteristics] {Characteristics of
    the Rigid3DPerspectiveTransform class.
    {tab:Rigid3DPerspectiveTransformCharacteristics}}

The {Rigid3DPerspectiveTransform} implements a rigid transformation in
:math:`3D` space followed by a perspective projection. This transform
is intended to be used in :math:`3D/2D` registration problems where a
3D object is projected onto a 2D plane. This is the case of Fluoroscopic
images used for image guided intervention, and it is also the case for
classical radiography. Users must provide a value for the focal distance
to be used during the computation of the perspective transform. This
transform also allows users to set a specific center of rotation. The
center coordinates are not modified during the optimization performed in
a registration process. The main features of this transform are
summarized in Table {tab:Rigid3DPerspectiveTransformCharacteristics}.
This transform is also used when creating Digitally Reconstructed
Radiographs (DRRs).

The strategies for optimizing the parameters of this transform are the
same ones used for optimizing the VersorRigid3DTransform. In particular,
you can use the same Versor-Rigid3D-Tranform-Optimizer in order to
optimize the parameters of this class.

AffineTransform
---------------

{sec:AffineTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents an affine transform composed of rotation,
            scaling, shearing and translation. The transform is
            specified by a :math:`N \times N` matrix and a :math:`N
            \times 1` vector where :math:`N` is the space dimension.
            & :math:`(N+1) \times N` & The first :math:`N \times N`
            parameters define the matrix in column-major order (where
            the column index varies the fastest). The last :math:`N`
            parameters define the translations for each dimension. &
            Only defined when the input and output space have the same
            dimension.

    [Affine Transform Characteristics] {Characteristics of the
    AffineTransform class. {tab:AffineTransformCharacteristics}}

The {AffineTransform} is one of the most popular transformations used
for image registration. Its main advantage comes from the fact that it
is represented as a linear transformation. The main features of this
transform are presented in Table {tab:AffineTransformCharacteristics}.

The set of AffineTransform coefficients can actually be represented in a
vector space of dimension :math:`(N+1) \times N`. This makes it
possible for optimizers to be used appropriately on this search space.
However, the high dimensionality of the search space also implies a high
computational complexity of cost-function derivatives. The best
compromise in the reduction of this computational time is to use the
transform’s Jacobian in combination with the image gradient for
computing the cost-function derivatives.

The coefficients of the :math:`N \times N` matrix can represent
rotations, anisotropic scaling and shearing. These coefficients are
usually of a very different dynamic range compared to the translation
coefficients. Coefficients in the matrix tend to be in the range
:math:`[-1:1]`, but are not restricted to this interval. Translation
coefficients, on the other hand, can be on the order of :math:`10` to
:math:`100`, and are basically related to the image size and pixel
spacing.

This difference in scale makes it necessary to take advantage of the
functionality offered by the optimizers for rescaling the parameter
space. This is particularly relevant for optimizers based on gradient
descent approaches. This transform lets the user set an arbitrary center
of rotation. The coordinates of the rotation center do not make part of
the parameters array passed to the optimizer.
Equation {eqn:AffineTransform} illustrates the effect of applying the
AffineTransform in a point in :math:`3D` space.

:math:`\label{eqn:AffineTransform}
\left[
\begin{array}{c}
x' \\
y' \\
z' \\
\end{array}
\right]
=
\left[
\begin{array}{ccc}
M_{00} & M_{01} & M_{02} \\
M_{10} & M_{11} & M_{12} \\
M_{20} & M_{21} & M_{22} \\
\end{array}
\right]
\cdot
\left[
\begin{array}{c}
x - C_x \\
y - C_y \\
z - C_z \\
\end{array}
\right]
+
\left[
\begin{array}{c}
T_x + C_x \\
T_y + C_y \\
T_z + C_z \\
\end{array}
\right]`

A registration based on the affine transform may be more effective when
applied after simpler transformations have been used to remove the major
components of misalignment. Otherwise it will incur an overwhelming
computational cost. For example, using an affine transform, the first
set of optimization iterations would typically focus on removing large
translations. This task could instead be accomplished by a translation
transform in a parameter space of size :math:`N` instead of the
:math:`(N+1) \times N` associated with the affine transform.

Tracking the evolution of a registration process that uses
AffineTransforms can be challenging, since it is difficult to represent
the coefficients in a meaningful way. A simple printout of the transform
coefficients generally does not offer a clear picture of the current
behavior and trend of the optimization. A better implementation uses the
affine transform to deform wire-frame cube which is shown in a
:math:`3D` visualization display.

BSplineDeformableTransform
--------------------------

{sec:BSplineDeformableTransform}

            **Behavior** & **Number of Parameters** & **Parameter
            Ordering** & **Restrictions**
             Represents a free from deformation by providing a
            deformation field from the interpolation of deformations in
            a coarse grid. & :math:`M \times N` & Where :math:`M` is
            the number of nodes in the BSpline grid and :math:`N` is
            the dimension of the space. & Only defined when the input
            and output space have the same dimension. This transform has
            the advantage of allowing to compute deformable
            registration. It also has the disadvantage of having a very
            high dimensional parametric space, and therefore requiring
            long computation times.

    [BSpline Deformable Transform Characteristics] {Characteristics of
    the BSplineDeformableTransform class.
    {tab:BSplineDeformableTransformCharacteristics}}

The {BSplineDeformableTransform} is designed to be used for solving
deformable registration problems. This transform is equivalent to
generation a deformation field where a deformation vector is assigned to
every point in space. The deformation vectors are computed using BSpline
interpolation from the deformation values of points located in a coarse
grid, that is usually referred to as the BSpline grid.

The BSplineDeformableTransform is not flexible enough for accounting for
large rotations or shearing, or scaling differences. In order to
compensate for this limitation, it provides the functionality of being
composed with an arbitrary transform. This transform is known as the
*Bulk* transform and it is applied to points before they are mapped with
the displacement field.

This transform do not provide functionalities for mapping Vectors nor
CovariantVectors, only Points can be mapped. The reason is that the
variations of a vector under a deformable transform actually depend on
the location of the vector in space. In other words, Vector only make
sense as the relative position between two points.

The BSplineDeformableTransform has a very large number of parameters and
therefore is well suited for the {LBFGSOptimizer} and {LBFGSBOptimizer}.
The use of this transform for was proposed in the following papers .

KernelTransforms
----------------

{sec:KernelTransforms}

Kernel Transforms are a set of Transforms that are also suitable for
performing deformable registration. These transforms compute on the fly
the displacements corresponding to a deformation field. The displacement
values corresponding to every point in space are computed by
interpolation from the vectors defined by a set of *Source Landmarks*
and a set of *Target Landmarks*.

Several variations of these transforms are available in the toolkit.
They differ on the type of interpolation kernel that is used when
computing the deformation in a particular point of space. Note that
these transforms are computationally expensive and that their numerical
complexity is proportional to the number of landmarks and the space
dimension.

The following is the list of Transforms based on the KernelTransform.

- {ElasticBodySplineKernelTransform}
- {ElasticBodyReciprocalSplineKernelTransform}
- {ThinPlateSplineKernelTransform}
- {ThinPlateR2LogRSplineKernelTransform}
- {VolumeSplineKernelTransform}

Details about the mathematical background of these transform can be
found in the paper by Davis *et. al*  and the papers by Rohr *et. al* .

.. [1]
   Note that the term *Jacobian* is also commonly used for the matrix
   representing the derivatives of output point coordinates with respect
   to input point coordinates. Sometimes the term is loosely used to
   refer to the determinant of such a matrix. 

.. |image| image:: GeometricalObjects.eps

