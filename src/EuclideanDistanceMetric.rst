The source code for this section can be found in the file
``EuclideanDistanceMetric.cxx``.

The Euclidean distance function ({Statistics} {EuclideanDistanceMetric}
requires as template parameter the type of the measurement vector. We
can use this function for any subclass of the {FixedArray}. As a
subclass of the {Statistics} {DistanceMetric}, it has two basic methods,
the {SetOrigin(measurement vector)} and the {Evaluate(measurement
vector)}. The {Evaluate()} method returns the distance between its
argument (a measurement vector) and the measurement vector set by the
{SetOrigin()} method.

In addition to the two methods, EuclideanDistanceMetric has two more
methods that return the distance of two measurements —
{Evaluate(measurement vector, measurement vector)} and the coordinate
distance between two measurements (not vectors) — {Evaluate(measurement,
measurement)}. The argument type of the latter method is the type of the
component of the measurement vector.

We include the header files for the class and the {Vector}.

::

    [language=C++]
    #include "itkVector.h"
    #include "itkArray.h"
    #include "itkEuclideanDistanceMetric.h"

We define the type of the measurement vector that will be input of the
Euclidean distance function. As a result, the measurement type is
{float}.

::

    [language=C++]
    typedef itk::Array< float > MeasurementVectorType;

The instantiation of the function is done through the usual {New()}
method and a smart pointer.

::

    [language=C++]
    typedef itk::Statistics::EuclideanDistanceMetric< MeasurementVectorType >
    DistanceMetricType;
    DistanceMetricType::Pointer distanceMetric = DistanceMetricType::New();

We create three measurement vectors, the {originPoint}, the
{queryPointA}, and the {queryPointB}. The type of the {originPoint} is
fixed in the {Statistics} {DistanceMetric} base class as {itk::Vector<
double, length of the measurement vector of the each distance metric
instance>}.

::

    [language=C++]
    The Distance metric does not know about the length of the measurement vectors.
    We must set it explicitly using the \code{SetMeasurementVectorSize()} method.

::

    [language=C++]
    DistanceMetricType::OriginType originPoint( 2 );
    MeasurementVectorType queryPointA( 2 );
    MeasurementVectorType queryPointB( 2 );

    originPoint[0] = 0;
    originPoint[1] = 0;

    queryPointA[0] = 2;
    queryPointA[1] = 2;

    queryPointB[0] = 3;
    queryPointB[1] = 3;

In the following code snippet, we show the uses of the three different
{Evaluate()} methods.

::

    [language=C++]
    distanceMetric->SetOrigin( originPoint );
    std::cout << "Euclidean distance between the origin and the query point A = "
    << distanceMetric->Evaluate( queryPointA )
    << std::endl;

    std::cout << "Euclidean distance between the two query points (A and B) = "
    << distanceMetric->Evaluate( queryPointA, queryPointB )
    << std::endl;

    std::cout << "Coordinate distance between "
    << "the first components of the two query points = "
    << distanceMetric->Evaluate( queryPointA[0], queryPointB[0] )
    << std::endl;

