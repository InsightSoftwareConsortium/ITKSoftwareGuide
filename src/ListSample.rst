The source code for this section can be found in the file
``ListSample.cxx``.

This example illustrates the common interface of the {Sample} class in
Insight.

Different subclasses of {Statistics} {Sample} expect different sets of
template arguments. In this example, we use the {Statistics}
{ListSample} class that requires the type of measurement vectors. The
ListSample uses `STL <http:www.sgi.com/tech/stl/>`_ {vector} to store
measurement vectors. This class conforms to the common interface of
Sample. Most methods of the Sample class interface are for retrieving
measurement vectors, the size of a container, and the total frequency.
In this example, we will see those information retrieving methods in
addition to methods specific to the ListSample class for data input.

To use the ListSample class, we include the header file for the class.

We need another header for measurement vectors. We are going to use the
{Vector} class which is a subclass of the {FixedArray} class.

::

    [language=C++]
    #include "itkListSample.h"
    #include "itkVector.h"

The following code snippet defines the measurement vector type as three
component {float} {Vector}. The {MeasurementVectorType} is the
measurement vector type in the {SampleType}. An object is instantiated
at the third line.

::

    [language=C++]
    typedef itk::Vector< float, 3 > MeasurementVectorType ;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType ;
    SampleType::Pointer sample = SampleType::New() ;

In the above code snippet, the namespace specifier for ListSample is
{itk::Statistics::} instead of the usual namespace specifier for other
ITK classes, {itk::}.

The newly instantiated object does not have any data in it. We have two
different ways of storing data elements. The first method is using the
{PushBack} method.

::

    [language=C++]
    MeasurementVectorType mv ;
    mv[0] = 1.0 ;
    mv[1] = 2.0 ;
    mv[2] = 4.0 ;

    sample->PushBack(mv) ;

The previous code increases the size of the container by one and stores
{mv} as the first data element in it.

The other way to store data elements is calling the {Resize} method and
then calling the {SetMeasurementVector()} method with a measurement
vector. The following code snippet increases the size of the container
to three and stores two measurement vectors at the second and the third
slot. The measurement vector stored using the {PushBack} method above is
still at the first slot.

::

    [language=C++]
    sample->Resize(3) ;

    mv[0] = 2.0 ;
    mv[1] = 4.0 ;
    mv[2] = 5.0 ;
    sample->SetMeasurementVector(1, mv) ;

    mv[0] = 3.0 ;
    mv[1] = 8.0 ;
    mv[2] = 6.0 ;
    sample->SetMeasurementVector(2, mv) ;

Now that we have seen how to create an ListSample object and store
measurement vectors using the ListSample-specific interface. The
following code shows the common interface of the Sample class. The
{Size} method returns the number of measurement vectors in the sample.
The primary data stored in Sample subclasses are measurement vectors.
However, each measurement vector has its associated frequency of
occurrence within the sample. For the ListSample and the adaptor classes
(see Section {sec:SampleAdaptors}), the frequency value is always one.
{Statistics} {Histogram} can have a varying frequency ({float} type) for
each measurement vector. We retrieve measurement vectors using the
{GetMeasurementVector(unsigned long instance identifier)}, and frequency
using the {GetFrequency(unsigned long instance identifier)}.

::

    [language=C++]
    for ( unsigned long i = 0 ; i < sample->Size() ; ++i )
    {
    std::cout << "id = " << i
    << "\t measurement vector = "
    << sample->GetMeasurementVector(i)
    << "\t frequency = "
    << sample->GetFrequency(i)
    << std::endl ;
    }

The output should look like the following: {id = 0 measurement vector =
1 2 4 frequency = 1} {id = 1 measurement vector = 2 4 5 frequency = 1}
{id = 2 measurement vector = 3 8 6 frequency = 1}

We can get the same result with its iterator.

::

    [language=C++]
    SampleType::Iterator iter = sample->Begin() ;

    while( iter != sample->End() )
    {
    std::cout << "id = " << iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << iter.GetMeasurementVector()
    << "\t frequency = "
    << iter.GetFrequency()
    << std::endl ;
    ++iter ;
    }

The last method defined in the Sample class is the {GetTotalFrequency()}
method that returns the sum of frequency values associated with every
measurement vector in a container. In the case of ListSample and the
adaptor classes, the return value should be exactly the same as that of
the {Size()} method, because the frequency values are always one for
each measurement vector. However, for the {Statistics} {Histogram}, the
frequency values can vary. Therefore, if we want to develop a general
algorithm to calculate the sample mean, we must use the
{GetTotalFrequency()} method instead of the {Size()} method.

::

    [language=C++]
    std::cout << "Size = " << sample->Size() << std::endl ;
    std::cout << "Total frequency = "
    << sample->GetTotalFrequency() << std::endl ;

