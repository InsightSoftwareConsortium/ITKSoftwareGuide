The source code for this section can be found in the file
``Histogram.cxx``.

This example shows how to create an {Statistics} {Histogram} object and
use it.

We call an instance in a {Histogram} object a *bin*. The Histogram
differs from the {Statistics} {ListSample}, {Statistics}
{ImageToListSampleAdaptor}, or {Statistics}
{PointSetToListSampleAdaptor} in significant ways. Histogram can have a
variable number of values ({float} type) for each measurement vector,
while the three other classes have a fixed value (one) for all
measurement vectors. Also those array-type containers can have multiple
instances (data elements) that have identical measurement vector values.
However, in a Histogram object, there is one unique instance for any
given measurement vector.

    |image| [Histogram] {Conceptual histogram data structure.}
    {fig:StatHistogram}

::

    [language=C++]
    #include "itkHistogram.h"
    #include "itkDenseFrequencyContainer2.h"

Here we create a histogram with dense frequency containers. In this
example we will not have any zero frequency measurements, so the dense
frequency container is the appropriate choice. If the histogram is
expected to have many empty (zero) bins, a sparse frequency container
would be the better option. Here we also set the size of the measurement
vectors to be 2 components.

::

    [language=C++]
    typedef float                                         MeasurementType;
    typedef itk::Statistics::DenseFrequencyContainer2     FrequencyContainerType;
    typedef FrequencyContainerType::AbsoluteFrequencyType FrequencyType;

    const unsigned int numberOfComponents = 2;
    typedef itk::Statistics::Histogram< MeasurementType,
    FrequencyContainerType > HistogramType;

    HistogramType::Pointer histogram = HistogramType::New();
    histogram->SetMeasurementVectorSize( numberOfComponents );

We initialize it as a :math:`3\times3` histogram with equal size
intervals.

::

    [language=C++]
    HistogramType::SizeType size( numberOfComponents );
    size.Fill(3);
    HistogramType::MeasurementVectorType lowerBound( numberOfComponents );
    HistogramType::MeasurementVectorType upperBound( numberOfComponents );
    lowerBound[0] = 1.1;
    lowerBound[1] = 2.6;
    upperBound[0] = 7.1;
    upperBound[1] = 8.6;

    histogram->Initialize(size, lowerBound, upperBound );

Now the histogram is ready for storing frequency values. We will fill
the each bin’s frequency according to the Figure {fig:StatHistogram}.
There are three ways of accessing data elements in the histogram:

-  using instance identifiers—just like any other Sample object;

-  using n-dimensional indices—just like an Image object;

-  using an iterator—just like any other Sample object.

In this example, the index :math:`(0, 0)` refers the same bin as the
instance identifier (0) refers to. The instance identifier of the index
(0, 1) is (3), (0, 2) is (6), (2, 2) is (8), and so on.

::

    [language=C++]
    histogram->SetFrequency(0UL, static_cast<FrequencyType>(0.0));
    histogram->SetFrequency(1UL, static_cast<FrequencyType>(2.0));
    histogram->SetFrequency(2UL, static_cast<FrequencyType>(3.0));
    histogram->SetFrequency(3UL, static_cast<FrequencyType>(2.0f));
    histogram->SetFrequency(4UL, static_cast<FrequencyType>(0.5f));
    histogram->SetFrequency(5UL, static_cast<FrequencyType>(1.0f));
    histogram->SetFrequency(6UL, static_cast<FrequencyType>(5.0f));
    histogram->SetFrequency(7UL, static_cast<FrequencyType>(2.5f));
    histogram->SetFrequency(8UL, static_cast<FrequencyType>(0.0f));

Let us examine if the frequency is set correctly by calling the
{GetFrequency(index)} method. We can use the {GetFrequency(instance
identifier)} method for the same purpose.

::

    [language=C++]
    HistogramType::IndexType index( numberOfComponents );
    index[0] = 0;
    index[1] = 2;
    std::cout << "Frequency of the bin at index  " << index
    << " is " << histogram->GetFrequency(index)
    << ", and the bin's instance identifier is "
    << histogram->GetInstanceIdentifier(index) << std::endl;

For test purposes, we create a measurement vector and an index that
belongs to the center bin.

::

    [language=C++]
    HistogramType::MeasurementVectorType mv( numberOfComponents );
    mv[0] = 4.1;
    mv[1] = 5.6;
    index.Fill(1);

We retrieve the measurement vector at the index value (1, 1), the center
bin’s measurement vector. The output is [4.1, 5.6].

::

    [language=C++]
    std::cout << "Measurement vector at the center bin is "
    << histogram->GetMeasurementVector(index) << std::endl;

Since all the measurement vectors are unique in the Histogram class, we
can determine the index from a measurement vector.

::

    [language=C++]
    HistogramType::IndexType resultingIndex;
    histogram->GetIndex(mv,resultingIndex);
    std::cout << "Index of the measurement vector " << mv
    << " is " << resultingIndex << std::endl;

In a similar way, we can get the instance identifier from the index.

::

    [language=C++]
    std::cout << "Instance identifier of index " << index
    << " is " << histogram->GetInstanceIdentifier(index)
    << std::endl;

If we want to check if an index is a valid one, we use the method
{IsIndexOutOfBounds(index)}. The following code snippet fills the index
variable with (100, 100). It is obviously not a valid index.

::

    [language=C++]
    index.Fill(100);
    if ( histogram->IsIndexOutOfBounds(index) )
    {
    std::cout << "Index " << index << " is out of bounds." << std::endl;
    }

The following code snippets show how to get the histogram size and
frequency dimension.

::

    [language=C++]
    std::cout << "Number of bins = " << histogram->Size()
    << " Total frequency = " << histogram->GetTotalFrequency()
    << " Dimension sizes = " << histogram->GetSize() << std::endl;

The Histogram class has a quantile calculation method,
{Quantile(dimension, percent)}. The following code returns the 50th
percentile along the first dimension. Note that the quantile calculation
considers only one dimension.

::

    [language=C++]
    std::cout << "50th percentile along the first dimension = "
    << histogram->Quantile(0, 0.5) << std::endl;

.. |image| image:: Histogram.eps
