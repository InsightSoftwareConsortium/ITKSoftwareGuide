The source code for this section can be found in the file
``ImageRegistration3.cxx``.

Given the numerous parameters involved in tuning a registration method
for a particular application, it is not uncommon for a registration
process to run for several minutes and still produce a useless result.
To avoid this situation it is quite helpful to track the evolution of
the registration as it progresses. The following section illustrates the
mechanisms provided in ITK for monitoring the activity of the
ImageRegistrationMethod class.

Insight implements the *Observer/Command* design pattern . (See
Section {sec:EventHandling} for an overview.) The classes involved in
this implementation are the {Object}, {Command} and {EventObject}
classes. The Object is the base class of most ITK objects. This class
maintains a linked list of pointers to event observers. The role of
observers is played by the Command class. Observers register themselves
with an Object, declaring that they are interested in receiving
notification when a particular event happens. A set of events is
represented by the hierarchy of the Event class. Typical events are
{Start}, {End}, {Progress} and {Iteration}.

Registration is controlled by an {Optimizer}, which generally executes
an iterative process. Most Optimizer classes invoke an {IterationEvent}
at the end of each iteration. When an event is invoked by an object,
this object goes through its list of registered observers (Commands) and
checks whether any one of them has expressed interest in the current
event type. Whenever such an observer is found, its corresponding
{Execute()} method is invoked. In this context, {Execute()} methods
should be considered *callbacks*. As such, some of the common sense
rules of callbacks should be respected. For example, {Execute()} methods
should not perform heavy computational tasks. They are expected to
execute rapidly, for example, printing out a message or updating a value
in a GUI.

The following code illustrates a simple way of creating a
Observer/Command to monitor a registration process. This new class
derives from the Command class and provides a specific implementation of
the {Execute()} method. First, the header file of the Command class must
be included.

::

    [language=C++]
    #include "itkCommand.h"

Our custom command class is called {CommandIterationUpdate}. It derives
from the Command class and declares for convenience the types {Self} and
{Superclass}. This facilitate the use of standard macros later in the
class implementation.

::

    [language=C++]
    class CommandIterationUpdate : public itk::Command
    {
    public:
    typedef  CommandIterationUpdate   Self;
    typedef  itk::Command             Superclass;

The following typedef declares the type of the SmartPointer capable of
holding a reference to this object.

::

    [language=C++]
    typedef itk::SmartPointer<Self>  Pointer;

The {itkNewMacro} takes care of defining all the necessary code for the
{New()} method. Those with curious minds are invited to see the details
of the macro in the file {itkMacro.h} in the {Insight/Code/Common}
directory.

::

    [language=C++]
    itkNewMacro( Self );

In order to ensure that the {New()} method is used to instantiate the
class (and not the C++ {new} operator), the constructor is declared
{protected}.

::

    [language=C++]
    protected:
    CommandIterationUpdate() {};

Since this Command object will be observing the optimizer, the following
typedefs are useful for converting pointers when the {Execute()} method
is invoked. Note the use of {const} on the declaration of
{OptimizerPointer}. This is relevant since, in this case, the observer
is not intending to modify the optimizer in any way. A {const} interface
ensures that all operations invoked on the optimizer are read-only.

::

    [language=C++]
    typedef itk::RegularStepGradientDescentOptimizer     OptimizerType;
    typedef const OptimizerType *                        OptimizerPointer;

ITK enforces const-correctness. There is hence a distinction between the
{Execute()} method that can be invoked from a {const} object and the one
that can be invoked from a non-{const} object. In this particular
example the non-{const} version simply invoke the {const} version. In a
more elaborate situation the implementation of both {Execute()} methods
could be quite different. For example, you could imagine a non-{const}
interaction in which the observer decides to stop the optimizer in
response to a divergent behavior. A similar case could happen when a
user is controlling the registration process from a GUI.

::

    [language=C++]
    void Execute(itk::Object *caller, const itk::EventObject & event)
    {
    Execute( (const itk::Object *)caller, event);
    }

Finally we get to the heart of the observer, the {Execute()} method. Two
arguments are passed to this method. The first argument is the pointer
to the object that invoked the event. The second argument is the event
that was invoked.

::

    [language=C++]
    void Execute(const itk::Object * object, const itk::EventObject & event)
    {

Note that the first argument is a pointer to an Object even though the
actual object invoking the event is probably a subclass of Object. In
our case we know that the actual object is an optimizer. Thus we can
perform a {dynamic\_cast} to the real type of the object.

::

    [language=C++]
    OptimizerPointer optimizer =
    dynamic_cast< OptimizerPointer >( object );

The next step is to verify that the event invoked is actually the one in
which we are interested. This is checked using the RTTI [1]_ support.
The {CheckEvent()} method allows us to compare the actual type of two
events. In this case we compare the type of the received event with an
IterationEvent. The comparison will return true if {event} is of type
{IterationEvent} or derives from {IterationEvent}. If we find that the
event is not of the expected type then the {Execute()} method of this
command observer should return without any further action.

::

    [language=C++]
    if( ! itk::IterationEvent().CheckEvent( &event ) )
    {
    return;
    }

If the event matches the type we are looking for, we are ready to query
data from the optimizer. Here, for example, we get the current number of
iterations, the current value of the cost function and the current
position on the parameter space. All of these values are printed to the
standard output. You could imagine more elaborate actions like updating
a GUI or refreshing a visualization pipeline.

::

    [language=C++]
    std::cout << optimizer->GetCurrentIteration() << " = ";
    std::cout << optimizer->GetValue() << " : ";
    std::cout << optimizer->GetCurrentPosition() << std::endl;

This concludes our implementation of a minimal Command class capable of
observing our registration method. We can now move on to configuring the
registration process.

Once all the registration components are in place we can create one
instance of our observer. This is done with the standard {New()} method
and assigned to a SmartPointer.

::

    [language=C++]
    CommandIterationUpdate::Pointer observer = CommandIterationUpdate::New();

    |image| [Command/Observer and the Registration Framework]
    {Interaction between the Command/Observer and the Registration
    Method.} {fig:ImageRegistration3Observer}

The newly created command is registered as observer on the optimizer,
using the {AddObserver()} method. Note that the event type is provided
as the first argument to this method. In order for the RTTI mechanism to
work correctly, a newly created event of the desired type must be passed
as the first argument. The second argument is simply the smart pointer
to the optimizer. Figure {fig:ImageRegistration3Observer} illustrates
the interaction between the Command/Observer class and the registration
method.

::

    [language=C++]
    optimizer->AddObserver( itk::IterationEvent(), observer );

At this point, we are ready to execute the registration. The typical
call to {StartRegistration()} will do it. Note again the use of the
{try/catch} block around the {StartRegistration()} method in case an
exception is thrown.

::

    [language=C++]
    try
    {
    registration->Update();
    std::cout << "Optimizer stop condition: "
    << registration->GetOptimizer()->GetStopConditionDescription()
    << std::endl;
    }
    catch( itk::ExceptionObject & err )
    {
    std::cout << "ExceptionObject caught !" << std::endl;
    std::cout << err << std::endl;
    return EXIT_FAILURE;
    }

The registration process is applied to the following images in
{Examples/Data}:

-  {BrainProtonDensitySliceBorder20.png}

-  {BrainProtonDensitySliceShifted13x17y.png}

It produces the following output.

::

    0 = 4499.45 : [2.9287, 2.72447]
    1 = 3860.84 : [5.62751, 5.67683]
    2 = 3450.68 : [8.85516, 8.03952]
    3 = 3152.07 : [11.7997, 10.7469]
    4 = 2189.97 : [13.3628, 14.4288]
    5 = 1047.21 : [11.292, 17.851]
    6 = 900.189 : [13.1602, 17.1372]
    7 = 19.6301 : [12.3268, 16.5846]
    8 = 237.317 : [12.7824, 16.7906]
    9 = 38.1331 : [13.1833, 17.0894]
    10 = 18.9201 : [12.949, 17.002]
    11 = 1.15456 : [13.074, 16.9979]
    12 = 2.42488 : [13.0115, 16.9994]
    13 = 0.0590549 : [12.949, 17.002]
    14 = 1.15451 : [12.9803, 17.001]
    15 = 0.173731 : [13.0115, 16.9997]
    16 = 0.0586584 : [12.9959, 17.0001]

You can verify from the code in the {Execute()} method that the first
column is the iteration number, the second column is the metric value
and the third and fourth columns are the parameters of the transform,
which is a :math:`2D` translation transform in this case. By tracking
these values as the registration progresses, you will be able to
determine whether the optimizer is advancing in the right direction and
whether the step-length is reasonable or not. That will allow you to
interrupt the registration process and fine-tune parameters without
having to wait until the optimizer stops by itself.

.. [1]
   RTTI stands for: Run-Time Type Information

.. |image| image:: ImageRegistration3Observer.eps
