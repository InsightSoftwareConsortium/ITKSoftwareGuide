The source code for this section can be found in the file
``Subsample.cxx``.

The {Statistics} {Subsample} is a derived sample. In other words, it
requires another {Statistics} {Sample} object for storing measurement
vectors. The Subsample class stores a subset of instance identifiers
from another Sample object. *Any* Sample’s subclass can be the source
Sample object. You can create a Subsample object out of another
Subsample object. The Subsample class is useful for storing
classification results from a test Sample object or for just extracting
some part of interest in a Sample object. Another good use of Subsample
is sorting a Sample object. When we use an {Image} object as the data
source, we do not want to change the order of data element in the image.
However, we sometimes want to sort or select data elements according to
their order. Statistics algorithms for this purpose accepts only
Subsample objects as inputs. Changing the order in a Subsample object
does not change the order of the source sample.

To use a Subsample object, we include the header files for the class
itself and a Sample class. We will use the {Statistics} {ListSample} as
the input sample.

::

    [language=C++]
    #include "itkListSample.h"
    #include "itkSubsample.h"

We need another header for measurement vectors. We are going to use the
{Vector} class in this example.

::

    [language=C++]
    #include "itkVector.h"

The following code snippet will create a ListSample object with
three-component float measurement vectors and put three measurement
vectors into the list.

::

    [language=C++]
    typedef itk::Vector< float, 3 > MeasurementVectorType;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    MeasurementVectorType mv;
    mv[0] = 1.0;
    mv[1] = 2.0;
    mv[2] = 4.0;

    sample->PushBack(mv);

    mv[0] = 2.0;
    mv[1] = 4.0;
    mv[2] = 5.0;
    sample->PushBack(mv);

    mv[0] = 3.0;
    mv[1] = 8.0;
    mv[2] = 6.0;
    sample->PushBack(mv);

To create a Subsample instance, we define the type of the Subsample with
the source sample type, in this case, the previously defined
{SampleType}. As usual, after that, we call the {New()} method to create
an instance. We must plug in the source sample, {sample}, using the
{SetSample()} method. However, with regard to data elements, the
Subsample is empty. We specify which data elements, among the data
elements in the Sample object, are part of the Subsample. There are two
ways of doing that. First, if we want to include every data element
(instance) from the sample, we simply call the
{InitializeWithAllInstances()} method like the following:

::

    subsample->InitializeWithAllInstances();

This method is useful when we want to create a Subsample object for
sorting all the data elements in a Sample object. However, in most
cases, we want to include only a subset of a Sample object. For this
purpose, we use the {AddInstance(instance identifier)} method in this
example. In the following code snippet, we include only the first and
last instance in our subsample object from the three instances of the
Sample class.

::

    [language=C++]
    typedef itk::Statistics::Subsample< SampleType > SubsampleType;
    SubsampleType::Pointer subsample = SubsampleType::New();
    subsample->SetSample( sample );

    subsample->AddInstance( 0UL );
    subsample->AddInstance( 2UL );

The Subsample is ready for use. The following code snippet shows how to
use {Iterator} interfaces.

::

    [language=C++]
    SubsampleType::Iterator iter = subsample->Begin();
    while ( iter != subsample->End() )
    {
    std::cout << "instance identifier = " << iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << iter.GetMeasurementVector()
    << "\t frequency = "
    << iter.GetFrequency()
    << std::endl;
    ++iter;
    }

As mentioned earlier, the instances in a Subsample can be sorted without
changing the order in the source Sample. For this purpose, the Subsample
provides an additional instance indexing scheme. The indexing scheme is
just like the instance identifiers for the Sample. The index is an
integer value starting at 0, and the last value is one less than the
number of all instances in a Subsample. The {Swap(0, 1)} method, for
example, swaps two instance identifiers of the first data element and
the second element in the Subsample. Internally, the {Swap()} method
changes the instance identifiers in the first and second position. Using
indices, we can print out the effects of the {Swap()} method. We use the
{GetMeasurementVectorByIndex(index)} to get the measurement vector at
the index position. However, if we want to use the common methods of
Sample that accepts instance identifiers, we call them after we get the
instance identifiers using {GetInstanceIdentifier(index)} method.

::

    [language=C++]
    subsample->Swap(0, 1);

    for ( int index = 0 ; index < subsample->Size() ; ++index )
    {
    std::cout << "instance identifier = "
    << subsample->GetInstanceIdentifier(index)
    << "\t measurement vector = "
    << subsample->GetMeasurementVectorByIndex(index)
    << std::endl;
    }

Since we are using a ListSample object as the source sample, the
following code snippet will return the same value (2) for the {Size()}
and the {GetTotalFrequency()} methods. However, if we used a Histogram
object as the source sample, the two return values might be different
because a Histogram allows varying frequency values for each instance.

::

    [language=C++]
    std::cout << "Size = " << subsample->Size() << std::endl;
    std::cout << "Total frequency = "
    << subsample->GetTotalFrequency() << std::endl;

If we want to remove all instances that are associated with the
Subsample, we call the {Clear()} method. After this invocation, the
{Size()} and the {GetTotalFrequency()} methods return 0.

::

    [language=C++]
    subsample->Clear();
    std::cout << "Size = " << subsample->Size() << std::endl;
    std::cout << "Total frequency = "
    << subsample->GetTotalFrequency() << std::endl;

