The source code for this section can be found in the file
``NeighborhoodSampler.cxx``.

When we want to create an {Statistics} {Subsample} object that includes
only the measurement vectors within a radius from a center in a sample,
we can use the {Statistics} {NeighborhoodSampler}. In this example, we
will use the {Statistics} {ListSample} as the input sample.

We include the header files for the ListSample and the
NeighborhoodSampler classes.

::

    [language=C++]
    #include "itkListSample.h"
    #include "itkNeighborhoodSampler.h"

We need another header for measurement vectors. We are going to use the
{Vector} class which is a subclass of the {FixedArray}.

::

    [language=C++]
    #include "itkVector.h"

The following code snippet will create a ListSample object with
two-component int measurement vectors and put the measurement vectors:
[1,1] - 1 time, [2,2] - 2 times, [3,3] - 3 times, [4,4] - 4 times, [5,5]
- 5 times into the {listSample}.

::

    [language=C++]
    typedef int MeasurementType;
    const unsigned int MeasurementVectorLength = 2;
    typedef itk::Vector< MeasurementType , MeasurementVectorLength >
    MeasurementVectorType;
    typedef itk::Statistics::ListSample< MeasurementVectorType > SampleType;
    SampleType::Pointer sample = SampleType::New();
    sample->SetMeasurementVectorSize( MeasurementVectorLength );

    MeasurementVectorType mv;
    for ( unsigned int i = 1 ; i < 6 ; i++ )
    {
    for ( unsigned int j = 0 ; j < 2 ; j++ )
    {
    mv[j] = ( MeasurementType ) i;
    }
    for ( unsigned int j = 0 ; j < i ; j++ )
    {
    sample->PushBack(mv);
    }
    }

We plug-in the sample to the NeighborhoodSampler using the
{SetInputSample(sample\*)}. The two required inputs for the
NeighborhoodSampler are a center and a radius. We set these two inputs
using the {SetCenter(center vector\*)} and the {SetRadius(double\*)}
methods respectively. And then we call the {Update()} method to generate
the Subsample object. This sampling procedure subsamples measurement
vectors within a hyper-spherical kernel that has the center and radius
specified.

::

    [language=C++]
    typedef itk::Statistics::NeighborhoodSampler< SampleType > SamplerType;
    SamplerType::Pointer sampler = SamplerType::New();

    sampler->SetInputSample( sample );
    SamplerType::CenterType center( MeasurementVectorLength );
    center[0] = 3;
    center[1] = 3;
    double radius = 1.5;
    sampler->SetCenter( &center );
    sampler->SetRadius( &radius );
    sampler->Update();

    SamplerType::OutputType::Pointer output = sampler->GetOutput();

The {SamplerType::OutputType} is in fact {Statistics} {Subsample}. The
following code prints out the resampled measurement vectors.

::

    [language=C++]
    SamplerType::OutputType::Iterator iter = output->Begin();
    while ( iter != output->End() )
    {
    std::cout << "instance identifier = " << iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << iter.GetMeasurementVector()
    << "\t frequency = "
    << iter.GetFrequency() << std::endl;
    ++iter;
    }

