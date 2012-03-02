The source code for this section can be found in the file
``OtsuMultipleThresholdImageFilter.cxx``. This example illustrates how
to use the {OtsuMultipleThresholdsCalculator}.

::

    [language=C++]
    #include "itkOtsuMultipleThresholdsCalculator.h"

OtsuMultipleThresholdsCalculator calculates thresholds for a given
histogram so as to maximize the between-class variance. We use
ScalarImageToHistogramGenerator to generate histograms. The histogram
type defined by the generator is then used for instantiating the type of
the Otsu threshold calculator.

::

    [language=C++]
    typedef itk::Statistics::ScalarImageToHistogramGenerator<
    InputImageType >
    ScalarImageToHistogramGeneratorType;

    typedef ScalarImageToHistogramGeneratorType::HistogramType    HistogramType;

    typedef itk::OtsuMultipleThresholdsCalculator< HistogramType >   CalculatorType;

Once thresholds are computed we will use BinaryThresholdImageFilter to
segment the input image into segments.

::

    [language=C++]
    typedef itk::BinaryThresholdImageFilter<
    InputImageType, OutputImageType >  FilterType;

::

    [language=C++]
    ScalarImageToHistogramGeneratorType::Pointer scalarImageToHistogramGenerator =
    ScalarImageToHistogramGeneratorType::New();

    CalculatorType::Pointer calculator = CalculatorType::New();
    FilterType::Pointer filter = FilterType::New();

::

    [language=C++]
    scalarImageToHistogramGenerator->SetNumberOfBins( 128 );
    calculator->SetNumberOfThresholds( atoi( argv[4] ) );

The pipeline will look as follows:

::

    [language=C++]
    scalarImageToHistogramGenerator->SetInput( reader->GetOutput() );
    calculator->SetInputHistogram( scalarImageToHistogramGenerator->GetOutput() );
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );

Thresholds are obtained using the {GetOutput} method

::

    [language=C++]
    const CalculatorType::OutputType &thresholdVector = calculator->GetOutput();
    CalculatorType::OutputType::const_iterator itNum = thresholdVector.begin();

::

    [language=C++]
    for(; itNum < thresholdVector.end(); itNum++)
    {
    std::cout << "OtsuThreshold["
    << (int)(itNum - thresholdVector.begin())
    << "] = "
    << static_cast<itk::NumericTraits<CalculatorType::MeasurementType>::PrintType>(*itNum)
    << std::endl;

::

    [language=C++]
    }

