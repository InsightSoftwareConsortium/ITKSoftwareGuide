The source code for this section can be found in the file
``PointSetToAdaptor.cxx``.

We will describe how to use {PointSet} as a {Sample} using an adaptor in
this example.

{Statistics} {PointSetToListSampleAdaptor} class requires the type of
input {PointSet} object. The {PointSet} class is an associative data
container. Each point in a {PointSet} object can have its associated
data value (optional). For the statistics subsystem, current
implementation of {PointSetToListSampleAdaptor} takes only the point
part into consideration. In other words, the measurement vectors from a
{PointSetToListSampleAdaptor} object are points from the {PointSet}
object that is plugged-into the adaptor object.

To use, an {PointSetToListSampleAdaptor} object, we include the header
file for the class.

::

    [language=C++]
    #include "itkPointSetToListSampleAdaptor.h"

Since, we are using an adaptor, we also include the header file for the
{PointSet} class.

::

    [language=C++]
    #include "itkPointSet.h"

We assume you already know how to create an {PointSet} object. The
following code snippet will create a 2D image of float pixels filled
with random values.

::

    [language=C++]
    typedef itk::PointSet<float,2> FloatPointSet2DType ;

    itk::RandomPointSetSource<FloatPointSet2DType>::Pointer random ;
    random = itk::RandomPointSetSource<FloatPointSet2DType>::New() ;
    random->SetMin(0.0) ;
    random->SetMax(1000.0) ;

    unsigned long size[2] = {20, 20} ;
    random->SetSize(size) ;
    float spacing[2] = {0.7, 2.1} ;
    random->SetSpacing( spacing ) ;
    float origin[2] = {15, 400} ;
    random->SetOrigin( origin ) ;

We now have an {PointSet} object and need to cast it to an {PointSet}
object with array type (anything derived from the {FixedArray} class)
pixels.

Since, the {PointSet} object’s pixel type is {float}, We will use single
element {float} {FixedArray} as our measurement vector type. And that
will also be our pixel type for the cast filter.

::

    [language=C++]
    typedef itk::FixedArray< float, 1 > MeasurementVectorType ;
    typedef itk::PointSet< MeasurementVectorType, 2 > ArrayPointSetType ;
    typedef itk::ScalarToArrayCastPointSetFilter< FloatPointSet2DType,
    ArrayPointSetType > CasterType ;

    CasterType::Pointer caster = CasterType::New() ;
    caster->SetInput( random->GetOutput() ) ;
    caster->Update() ;

Up to now, we spend most of time to prepare an {PointSet} object
suitable for the adaptor. Actually, the hard part of this example is
done. Now, we must define an adaptor with the image type and instantiate
an object.

::

    [language=C++]
    typedef itk::Statistics::PointSetToListSampleAdaptor< ArrayPointSetType > SampleType ;
    SampleType::Pointer sample = SampleType::New() ;

The final thing we have to is to plug-in the image object to the
adaptor. After that, we can use the common methods and iterator
interfaces shown in {sec:SampleInterface}.

::

    [language=C++]
    sample->SetPointSet( caster->GetOutput() ) ;

