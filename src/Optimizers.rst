    |image| [Class diagram of the Optimizer hierarchy] {Class diagram of
    the optimizers hierarchy.} {fig:OptimizersHierarchy}

Optimization algorithms are encapsulated as {Optimizer} objects within
ITK. Optimizers are generic and can be used for applications other than
registration. Within the registration framework, subclasses of
{SingleValuedNonLinearOptimizer} are used to optimize the metric
criterion with respect to the transform parameters.

The basic input to an optimizer is a cost function object. In the
context of registration, {ImageToImageMetric} classes provides this
functionality. The initial parameters are set using
{SetInitialPosition()} and the optimization algorithm is invoked by
{StartOptimization()}. Once the optimization has finished, the final
parameters can be obtained using {GetCurrentPosition()}.

Some optimizers also allow rescaling of their individual parameters.
This is convenient for normalizing parameters spaces where some
parameters have different dynamic ranges. For example, the first
parameter of {Euler2DTransform} represents an angle while the last two
parameters represent translations. A unit change in angle has a much
greater impact on an image than a unit change in translation. This
difference in scale appears as long narrow valleys in the search space
making the optimization problem more difficult. Rescaling the
translation parameters can help to fix this problem. Scales are
represented as an {Array} of doubles and set defined using
{SetScales()}.

There are two main types of optimizers in ITK. In the first type we find
optimizers that are suitable for dealing with cost functions that return
a single value. These are indeed the most common type of cost functions,
and are known as *Single Valued* functions, therefore the corresponding
optimizers are known as *Single Valued* optimizers. The second type of
optimizers are those suitable for managing cost functions that return
multiple values at each evaluation. These cost functions are common in
model-fitting problems and are known as *Multi Valued* or *Multivariate*
functions. The corresponding optimizers are therefore called
*MultipleValued* optimizers in ITK.

The {SingleValuedNonLinearOptimizer} is the base class for the first
type of optimizers while the {MultipleValuedNonLinearOptimizer} is the
base class for the second type of optimizers.

The types of single valued optimizer currently available in ITK are:

-  **Amoeba**: Nelder-Meade downhill simplex. This optimizer is actually
   implemented in the {vxl/vnl} numerics toolkit. The ITK class
   {AmoebaOptimizer} is merely an adaptor class.

-  **Conjugate Gradient**: Fletcher-Reeves form of the conjugate
   gradient with or without preconditioning
   ({ConjugateGradientOptimizer}). It is also an adaptor to an optimizer
   in {vnl}.

-  **Gradient Descent**: Advances parameters in the direction of the
   gradient where the step size is governed by a learning rate
   ({GradientDescentOptimizer}).

-  **Quaternion Rigid Transform Gradient Descent**: A specialized
   version of GradientDescentOptimizer for QuaternionRigidTransform
   parameters, where the parameters representing the quaternion are
   normalized to a magnitude of one at each iteration to represent a
   pure rotation ({QuaternionRigidTransformGradientDescent}).

-  **LBFGS**: Limited memory Broyden, Fletcher, Goldfarb and Shannon
   minimization. It is an adaptor to an optimizer in {vnl}
   ({LBFGSOptimizer}).

-  **LBFGSB**: A modified version of the LBFGS optimizer that allows to
   specify bounds for the parameters in the search space. It is an
   adaptor to an optimizer in {netlib}. Details on this optimizer can be
   found in  ({LBFGSBOptimizer}).

-  **One Plus One Evolutionary**: Strategy that simulates the biological
   evolution of a set of samples in the search space. This optimizer is
   mainly used in the process of bias correction of MRI images
   ({OnePlusOneEvolutionaryOptimizer.}). Details on this optimizer can
   be found in .

-  **Regular Step Gradient Descent**: Advances parameters in the
   direction of the gradient where a bipartition scheme is used to
   compute the step size ({RegularStepGradientDescentOptimizer}).

-  **Powell Optimizer**: Powell optimization method. For an
   N-dimensional parameter space, each iteration minimizes(maximizes)
   the function in N (initially orthogonal) directions. This optimizer
   is described in . ({PowellOptimizer}).

-  **SPSA Optimizer**: Simultaneous Perturbation Stochastic
   Approximation Method. This optimizer is described in
   http://www.jhuapl.edu/SPSA and in . ({SPSAOptimizer}).

-  **Versor Transform Optimizer**: A specialized version of the
   RegularStepGradientDescentOptimizer for VersorTransform parameters,
   where the current rotation is composed with the gradient rotation to
   produce the new rotation versor. It follows the definition of versor
   gradients defined by Hamilton  ({VersorTransformOptimizer}).

-  **Versor Rigid3D Transform Optimizer**: A specialized version of the
   RegularStepGradientDescentOptimizer for VersorRigid3DTransform
   parameters, where the current rotation is composed with the gradient
   rotation to produce the new rotation versor. The translational part
   of the transform parameters are updated as usually done in a vector
   space. ({VersorRigid3DTransformOptimizer}).

A parallel hierarchy exists for optimizing multiple-valued cost
functions. The base optimizer in this branch of the hierarchy is the
{MultipleValuedNonLinearOptimizer} whose only current derived class is:

-  **Levenberg Marquardt**: Non-linear least squares minimization.
   Adapted to an optimizer in {vnl} ({LevenbergMarquardtOptimizer}).
   This optimizer is described in .

Figure {fig:OptimizersHierarchy} illustrates the full class hierarchy of
optimizers in ITK. Optimizers in the lower right corner are adaptor
classes to optimizers existing in the {vxl/vnl} numerics toolkit. The
optimizers interact with the {CostFunction} class. In the registration
framework this cost function is reimplemented in the form of
ImageToImageMetric.

.. |image| image:: OptimizersHierarchy.eps
