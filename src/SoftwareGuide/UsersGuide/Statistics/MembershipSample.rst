The source code for this section can be found in the file
``MembershipSample.cxx``.

The {Statistics} {MembershipSample} is derived from the class
{Statistics} {Sample} that associates a class label with each
measurement vector. It needs another Sample object for storing
measurement vectors. A {MembershipSample} object stores a subset of
instance identifiers from another Sample object. *Any* subclass of
Sample can be the source Sample object. The MembershipSample class is
useful for storing classification results from a test Sample object. The
MembershipSample class can be considered as an associative container
that stores measurement vectors, frequency values, and *class labels*.

To use a MembershipSample object, we include the header files for the
class itself and the Sample class. We will use the {Statistics}
{ListSample} as the input sample. We need another header for measurement
vectors. We are going to use the {Vector} class which is a subclass of
the {FixedArray}.

::

    [language=C++]
    #include "itkListSample.h"
    #include "itkMembershipSample.h"
    #include "itkVector.h"

The following code snippet will create a {ListSample} object with
three-component float measurement vectors and put three measurement
vectors in the {ListSample} object.

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

To create a MembershipSample instance, we define the type of the
MembershipSample using the source sample type using the previously
defined {SampleType}. As usual, after that, we call the {New()} method
to create an instance. We must plug in the source sample, Sample, using
the {SetSample()} method. We provide class labels for data instances in
the Sample object using the {AddInstance()} method. As the required
initialization step for the {membershipSample}, we must call the
{SetNumberOfClasses()} method with the number of classes. We must add
all instances in the source sample with their class labels. In the
following code snippet, we set the first instance’ class label to 0, the
second to 0, the third (last) to 1. After this, the {membershipSample}
has two {Subsample} objects. And the class labels for these two
{Subsample} objects are 0 and 1. The :math:`0` class {Subsample}
object includes the first and second instances, and the :math:`1`
class includes the third instance.

::

    [language=C++]
    typedef itk::Statistics::MembershipSample< SampleType >
    MembershipSampleType;

    MembershipSampleType::Pointer membershipSample =
    MembershipSampleType::New();

    membershipSample->SetSample(sample);
    membershipSample->SetNumberOfClasses(2);

    membershipSample->AddInstance(0U, 0UL );
    membershipSample->AddInstance(0U, 1UL );
    membershipSample->AddInstance(1U, 2UL );

The {Size()} and {GetTotalFrequency()} returns the same information that
Sample does.

::

    [language=C++]
    std::cout << "Total frequency = "
    << membershipSample->GetTotalFrequency() << std::endl;

The {membershipSample} is ready for use. The following code snippet
shows how to use the {Iterator} interface. The MembershipSample’s
{Iterator} has an additional method that returns the class label
({GetClassLabel()}).

::

    [language=C++]
    MembershipSampleType::ConstIterator iter = membershipSample->Begin();
    while ( iter != membershipSample->End() )
    {
    std::cout << "instance identifier = " << iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << iter.GetMeasurementVector()
    << "\t frequency = "
    << iter.GetFrequency()
    << "\t class label = "
    << iter.GetClassLabel()
    << std::endl;
    ++iter;
    }

To see the numbers of instances in each class subsample, we use the
{Size()} method of the {ClassSampleType} instance returned by the
{GetClassSample(index)} method.

::

    [language=C++]
    std::cout << "class label = 0 sample size = "
    << membershipSample->GetClassSample(0)->Size() << std::endl;
    std::cout << "class label = 1 sample size = "
    << membershipSample->GetClassSample(1)->Size() << std::endl;

We call the {GetClassSample()} method to get the class subsample in the
{membershipSample}. The {MembershipSampleType::ClassSampleType} is
actually a specialization of the {Statistics} {Subsample}. We print out
the instance identifiers, measurement vectors, and frequency values that
are part of the class. The output will be two lines for the two
instances that belong to the class :math:`0`.

::

    [language=C++]
    MembershipSampleType::ClassSampleType::ConstPointer classSample =
    membershipSample->GetClassSample( 0 );

    MembershipSampleType::ClassSampleType::ConstIterator c_iter =
    classSample->Begin();

    while ( c_iter != classSample->End() )
    {
    std::cout << "instance identifier = " << c_iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << c_iter.GetMeasurementVector()
    << "\t frequency = "
    << c_iter.GetFrequency() << std::endl;
    ++c_iter;
    }

