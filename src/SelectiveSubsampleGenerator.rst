The source code for this section can be found in the file
``SelectiveSubsampleGenerator.cxx``.

To use, an {MembershipSample} object, we include the header files for
the class itself and a {Sample} class. We will use the {ListSample} as
the input sample.

::

    [language=C++]
    #include "itkListSample.h"
    #include "itkMembershipSample.h"

We need another header for measurement vectors. We are going to use the
{Vector} class which is a subclass of the {FixedArray} in this example.

::

    [language=C++]
    #include "itkVector.h"

The following code snippet will create a {ListSample} object with
three-component float measurement vectors and put three measurement
vectors in the {ListSample} object.

::

    [language=C++]
    typedef itk::Vector< float, 3 > MeasurementVectorType ;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType ;
    SampleType::Pointer sample = SampleType::New() ;
    MeasurementVectorType mv ;
    mv[0] = 1.0 ;
    mv[1] = 2.0 ;
    mv[2] = 4.0 ;

    sample->PushBack(mv) ;

    mv[0] = 2.0 ;
    mv[1] = 4.0 ;
    mv[2] = 5.0 ;
    sample->PushBack(mv) ;

    mv[0] = 3.0 ;
    mv[1] = 8.0 ;
    mv[2] = 6.0 ;
    sample->PushBack(mv) ;

To create a {MembershipSample} instance, we define the type of the
{MembershipSample} with the source sample type, in this case, previously
defined {SampleType}. As usual, after that, we call {New()} method to
instantiate an instance. We must plug-in the source sample, {sample}
object using the {SetSample(source sample)} method. However, in regard
of **class labels**, the {membershipSample} is empty. We provide class
labels for data instances in the {sample} object using the
{AddInstance(class label, instance identifier)} method. As the required
initialization step for the {membershipSample}, we must call the
{SetNumberOfClasses(number of classes)} method with the number of
classes. We must add all instances in the source sample with their class
labels. In the following code snippet, we set the first instance’ class
label to 0, the second to 0, the third (last) to 1. After this, the
{membershipSample} has two {Subclass} objects. And the class labels for
these two {Subclass} are 0 and 1. The **0** class {Subsample} object
includes the first and second instances, and the **1** class includes
the third instance.

::

    [language=C++]
    typedef itk::Statistics::MembershipSample< SampleType >
    MembershipSampleType ;

    MembershipSampleType::Pointer membershipSample =
    MembershipSampleType::New() ;

    membershipSample->SetSample(sample) ;
    membershipSample->SetNumberOfClasses(2) ;

    membershipSample->AddInstance(0U, 0UL ) ;
    membershipSample->AddInstance(0U, 1UL ) ;
    membershipSample->AddInstance(1U, 2UL ) ;

The {Size()} and {GetTotalFrequency()} returns the same values as the
{sample} does.

::

    [language=C++]
    std::cout << "Size = " << membershipSample->Size() << std::endl ;
    std::cout << "Total frequency = "
    << membershipSample->GetTotalFrequency() << std::endl ;

The {membershipSample} is ready for use. The following code snippet
shows how to use {Iterator} interfaces. The {MembershipSample}’
{Iterator} has an additional method that returns the class label
({GetClassLabel()}).

::

    [language=C++]
    MembershipSampleType::Iterator iter = membershipSample->Begin() ;
    while ( iter != membershipSample->End() )
    {
    std::cout << "instance identifier = " << iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << iter.GetMeasurementVector()
    << "\t frequency = "
    << iter.GetFrequency()
    << "\t class label = "
    << iter.GetClassLabel()
    << std::endl ;
    ++iter ;
    }

To see the numbers of instances in each class subsample, we use the
{GetClassSampleSize(class label)} method.

::

    [language=C++]
    std::cout << "class label = 0 sample size = "
    << membershipSample->GetClassSampleSize(0) << std::endl ;
    std::cout << "class label = 1 sample size = "
    << membershipSample->GetClassSampleSize(0) << std::endl ;

We call the {GetClassSample(class label)} method to get the class
subsample in the {membershipSample}. The
{MembershipSampleType::ClassSampleType} is actually an specialization of
the {Statistics} {Subsample}. We print out the instance identifiers,
measurement vectors, and frequency values that are part of the class.
The output will be two lines for the two instances that belongs to the
class **0**. the {GetClassSampleSize(class label)} method.

::

    [language=C++]
    MembershipSampleType::ClassSampleType::Pointer classSample =
    membershipSample->GetClassSample(0) ;
    MembershipSampleType::ClassSampleType::Iterator c_iter =
    classSample->Begin() ;
    while ( c_iter != classSample->End() )
    {
    std::cout << "instance identifier = " << c_iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << c_iter.GetMeasurementVector()
    << "\t frequency = "
    << c_iter.GetFrequency() << std::endl ;
    ++c_iter ;
    }

