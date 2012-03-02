The source code for this section can be found in the file
``PointSetToListSampleAdaptor.cxx``.

We will describe how to use {PointSet} as a {Statistics} {Sample} using
an adaptor in this example.

The {Statistics} {PointSetToListSampleAdaptor} class requires a PointSet
as input. The PointSet class is an associative data container. Each
point in a PointSet object can have an associated optional data value.
For the statistics subsystem, the current implementation of
PointSetToListSampleAdaptor takes only the point part into
consideration. In other words, the measurement vectors from a
PointSetToListSampleAdaptor object are points from the PointSet object
that is plugged into the adaptor object.

To use an PointSetToListSampleAdaptor class, we include the header file
for the class.

::

    [language=C++]
    #include "itkPointSetToListSampleAdaptor.h"

Since we are using an adaptor, we also include the header file for the
PointSet class.

::

    [language=C++]
    #include "itkPointSet.h"
    #include "itkVector.h"

Next we create a PointSet object (see Section {sec:CreatingAPointSet}
otherwise). The following code snippet will create a PointSet object
that stores points (its coordinate value type is float) in 3D space.

::

    [language=C++]
    typedef itk::PointSet< short > PointSetType;
    PointSetType::Pointer pointSet = PointSetType::New();

Note that the {short} type used in the declaration of {PointSetType}
pertains to the pixel type associated with every point, not to the type
used to represent point coordinates. If we want to change the type of
point in terms of the coordinate value and/or dimension, we have to
modify the {TMeshTraits} (one of the optional template arguments for the
{PointSet} class). The easiest way of create a custom mesh traits
instance is to specialize the existing {DefaultStaticMeshTraits}. By
specifying the {TCoordRep} template argument, we can change the
coordinate value type of a point. By specifying the {VPointDimension}
template argument, we can change the dimension of the point. As
mentioned earlier, a {PointSetToListSampleAdaptor} object cares only
about the points, and the type of measurement vectors is the type of
points. Therefore, we can define the measurement vector type as in the
following code snippet.

::

    [language=C++]
    typedef PointSetType::PointType MeasurementVectorType;

To make the example a little bit realistic, we add two point into the
{pointSet}.

::

    [language=C++]
    PointSetType::PointType point;
    point[0] = 1.0;
    point[1] = 2.0;
    point[2] = 3.0;

    pointSet->SetPoint( 0UL, point);

    point[0] = 2.0;
    point[1] = 4.0;
    point[2] = 6.0;

    pointSet->SetPoint( 1UL, point );

Now we have a PointSet object that has two points in it. And the
pointSet is ready to be plugged into the adaptor. First, we create an
instance of the PointSetToListSampleAdaptor class with the type of the
input PointSet object.

::

    [language=C++]
    typedef itk::Statistics::PointSetToListSampleAdaptor< PointSetType > SampleType;
    SampleType::Pointer sample = SampleType::New();

Second, all we have to do is to plug in the PointSet object to the
adaptor. After that, we can use the common methods and iterator
interfaces shown in Section {sec:SampleInterface}.

::

    [language=C++]
    sample->SetPointSet( pointSet );

    SampleType::Iterator iter = sample->Begin();

    while( iter != sample->End() )
    {
    std::cout << "id = " << iter.GetInstanceIdentifier()
    << "\t measurement vector = "
    << iter.GetMeasurementVector()
    << "\t frequency = "
    << iter.GetFrequency()
    << std::endl;
    ++iter;
    }

