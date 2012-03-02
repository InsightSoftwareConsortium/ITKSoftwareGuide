The source code for this section can be found in the file
``SampleToHistogramFilter.cxx``.

Sometimes we want to work with a histogram instead of a list of
measurement vectors (e.g. {Statistics} {ListSample}, {Statistics}
{ImageToListSampleAdaptor}, or {Statistics} {PointSetToListSample}) to
use less memory or to perform a particular type od analysis. In such
cases, we can import data from a sample type to a {Statistics}
{Histogram} object using the {Statistics} {SampleToHistogramFiler}.

We use a ListSample object as the input for the filter. We include the
header files for the ListSample and Histogram classes, as well as the
filter.

::

    [language=C++]
    #include "itkListSample.h"
    #include "itkHistogram.h"
    #include "itkSampleToHistogramFilter.h"

We need another header for the type of the measurement vectors. We are
going to use the {Vector} class which is a subclass of the {FixedArray}
in this example.

::

    [language=C++]
    #include "itkVector.h"

The following code snippet creates a ListSample object with
two-component {int} measurement vectors and put the measurement vectors:
[1,1] - 1 time, [2,2] - 2 times, [3,3] - 3 times, [4,4] - 4 times, [5,5]
- 5 times into the {listSample}.

::

    [language=C++]
    typedef int MeasurementType;
    const unsigned int MeasurementVectorLength = 2;
    typedef itk::Vector< MeasurementType , MeasurementVectorLength >
    MeasurementVectorType;
    typedef itk::Statistics::ListSample< MeasurementVectorType > ListSampleType;
    ListSampleType::Pointer listSample = ListSampleType::New();
    listSample->SetMeasurementVectorSize( MeasurementVectorLength );

    MeasurementVectorType mv;
    for ( unsigned int i = 1 ; i < 6 ; i++ )
    {
    for ( unsigned int j = 0 ; j < 2 ; j++ )
    {
    mv[j] = ( MeasurementType ) i;
    }
    for ( unsigned int j = 0 ; j < i ; j++ )
    {
    listSample->PushBack(mv);
    }
    }

Here, we set up the size and bound of the output histogram.

::

    [language=C++]
    typedef float HistogramMeasurementType;
    const unsigned int numberOfComponents = 2;
    typedef itk::Statistics::Histogram< HistogramMeasurementType >
    HistogramType;

    HistogramType::SizeType size( numberOfComponents );
    size.Fill(5);

    HistogramType::MeasurementVectorType lowerBound( numberOfComponents );
    HistogramType::MeasurementVectorType upperBound( numberOfComponents );

    lowerBound[0] = 0.5;
    lowerBound[1] = 0.5;

    upperBound[0] = 5.5;
    upperBound[1] = 5.5;

Now, we set up the {SampleToHistogramFilter} object by passing
{listSample} as the input and initializing the histogram size and bounds
with the {SetHistogramSize()}, {SetHistogramBinMinimum()}, and
{SetHistogramBinMaximum()} methods. We execute the filter by calling the
{Update()} method.

::

    [language=C++]
    typedef itk::Statistics::SampleToHistogramFilter< ListSampleType,
    HistogramType > FilterType;
    FilterType::Pointer filter = FilterType::New();

    filter->SetInput( listSample );
    filter->SetHistogramSize( size );
    filter->SetHistogramBinMinimum( lowerBound );
    filter->SetHistogramBinMaximum( upperBound );
    filter->Update();

The {Size()} and {GetTotalFrequency()} methods return the same values as
the {sample} does.

::

    [language=C++]

    const HistogramType* histogram = filter->GetOutput();

    HistogramType::ConstIterator iter = histogram->Begin();
    while ( iter != histogram->End() )
    {
    std::cout << "Measurement vectors = " << iter.GetMeasurementVector()
    << " frequency = " << iter.GetFrequency() << std::endl;
    ++iter;
    }

    std::cout << "Size = " << histogram->Size() << std::endl;
    std::cout << "Total frequency = "
    << histogram->GetTotalFrequency() << std::endl;

