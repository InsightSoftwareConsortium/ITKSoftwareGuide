The source code for this section can be found in the file
``SampleSorting.cxx``.

Sometimes we want to sort the measurement vectors in a sample. The
sorted vectors may reveal some characteristics of the sample. The
*insert sort*, the *heap sort*, and the *introspective sort* algorithms
for samples are implemented in ITK. To learn pros and cons of each
algorithm, please refer to . ITK also offers the *quick select*
algorithm.

Among the subclasses of the {Statistics} {Sample}, only the class
{Statistics} {Subsample} allows users to change the order of the
measurement vector. Therefore, we must create a Subsample to do any
sorting or selecting.

We include the header files for the {Statistics} {ListSample} and the
{Subsample} classes.

::

    [language=C++]
    #include "itkListSample.h"

The sorting and selecting related functions are in the include file
{itkStatisticsAlgorithm.h}. Note that all functions in this file are in
the {itk::Statistics::Algorithm} namespace.

::

    [language=C++]
    #include "itkStatisticsAlgorithm.h"

We need another header for measurement vectors. We are going to use the
{Vector} class which is a subclass of the {FixedArray} in this example.

We define the types of the measurement vectors, the sample, and the
subsample.

::

    [language=C++]
    #include "itkVector.h"

We define two functions for convenience. The first one clears the
content of the subsample and fill it with the measurement vectors from
the sample.

::

    [language=C++]
    void initializeSubsample(SubsampleType* subsample, SampleType* sample)
    {
    subsample->Clear();
    subsample->SetSample(sample);
    subsample->InitializeWithAllInstances();
    }

The second one prints out the content of the subsample using the
Subsample’s iterator interface.

::

    [language=C++]
    void printSubsample(SubsampleType* subsample, const char* header)
    {
    std::cout << std::endl;
    std::cout << header << std::endl;
    SubsampleType::Iterator iter = subsample->Begin();
    while ( iter != subsample->End() )
    {
    std::cout << "instance identifier = " << iter.GetInstanceIdentifier()
    << " \t measurement vector = "
    << iter.GetMeasurementVector()
    << std::endl;
    ++iter;
    }
    }

The following code snippet will create a ListSample object with
two-component int measurement vectors and put the measurement vectors:
[5,5] - 5 times, [4,4] - 4 times, [3,3] - 3 times, [2,2] - 2 times,[1,1]
- 1 time into the {sample}.

::

    [language=C++]
    SampleType::Pointer sample = SampleType::New();

    MeasurementVectorType mv;
    for ( unsigned int i = 5 ; i > 0 ; --i )
    {
    for (unsigned int j = 0 ; j < 2 ; j++ )
    {
    mv[j] = ( MeasurementType ) i;
    }
    for ( unsigned int j = 0 ; j < i ; j++ )
    {
    sample->PushBack(mv);
    }
    }

We create a Subsample object and plug-in the {sample}.

::

    [language=C++]
    SubsampleType::Pointer subsample = SubsampleType::New();
    subsample->SetSample(sample);
    initializeSubsample(subsample, sample);
    printSubsample(subsample, "Unsorted");

The common parameters to all the algorithms are the Subsample object
({subsample}), the dimension ({activeDimension}) that will be considered
for the sorting or selecting (only the component belonging to the
dimension of the measurement vectors will be considered), the beginning
index, and the ending index of the measurement vectors in the
{subsample}. The sorting or selecting algorithms are applied only to the
range specified by the beginning index and the ending index. The ending
index should be the actual last index plus one.

The {InsertSort} function does not require any other optional arguments.
The following function call will sort the all measurement vectors in the
{subsample}. The beginning index is {0}, and the ending index is the
number of the measurement vectors in the {subsample}.

::

    [language=C++]
    int activeDimension = 0 ;
    itk::Statistics::Algorithm::InsertSort< SubsampleType >( subsample,
    activeDimension, 0, subsample->Size() );
    printSubsample(subsample, "InsertSort");

We sort the {subsample} using the heap sort algorithm. The arguments are
identical to those of the insert sort.

::

    [language=C++]
    initializeSubsample(subsample, sample);
    itk::Statistics::Algorithm::HeapSort< SubsampleType >( subsample,
    activeDimension, 0, subsample->Size() );
    printSubsample(subsample, "HeapSort");

The introspective sort algorithm needs an additional argument that
specifies when to stop the introspective sort loop and sort the fragment
of the sample using the heap sort algorithm. Since we set the threshold
value as {16}, when the sort loop reach the point where the number of
measurement vectors in a sort loop is not greater than {16}, it will
sort that fragment using the insert sort algorithm.

::

    [language=C++]
    initializeSubsample(subsample, sample);
    itk::Statistics::Algorithm::IntrospectiveSort< SubsampleType >
    ( subsample, activeDimension, 0, subsample->Size(), 16 );
    printSubsample(subsample, "IntrospectiveSort");

We query the median of the measurements along the {activeDimension}. The
last argument tells the algorithm that we want to get the
{subsample->Size()/2}-th element along the {activeDimension}. The quick
select algorithm changes the order of the measurement vectors.

::

    [language=C++]
    initializeSubsample(subsample, sample);
    SubsampleType::MeasurementType median =
    itk::Statistics::Algorithm::QuickSelect< SubsampleType >( subsample,
    activeDimension,
    0, subsample->Size(),
    subsample->Size()/2 );
    std::cout << std::endl;
    std::cout << "Quick Select: median = " << median << std::endl;

