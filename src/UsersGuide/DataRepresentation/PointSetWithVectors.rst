.. _sec-PointSetWithVectorsAsPixelType:

Vectors as Pixel Type
~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``PointSetWithVectors.cxx``.

This example illustrates how a point set can be parameterized to manage
a particular pixel type. It is quite common to associate vector values
with points for producing geometric representations. The following code
shows how vector values can be used as pixel type on the PointSet class.
The :itkdox:`itk::Vector` class is used here as the pixel type. This class is
appropriate for representing the relative position between two points.
It could then be used to manage displacements, for example.

In order to use the vector class it is necessary to include its header
file along with the header of the point set.

::

    #include "itkVector.h"
    #include "itkPointSet.h"


.. _fig-PointSetWithVectors:

.. figure:: PointSetWithVectors.png
   :align: center
   
   PointSet with Vectors as PixelType.

The Vector class is templated over the type used to represent the
spatial coordinates and over the space dimension. Since the PixelType is
independent of the ``PointType``, we are free to select any dimension for
the vectors to be used as pixel type. However, for the sake of producing
an interesting example, we will use vectors that represent displacements
of the points in the :itkdox:`itk::PointSet`. Those vectors are then selected to be of
the same dimension as the :itkdox:`itk::PointSet`.

::

    const unsigned int Dimension = 3;
    typedef itk::Vector< float, Dimension >    PixelType;

Then we use the ``PixelType`` (which are actually Vectors) to instantiate
the PointSet type and subsequently create a PointSet object.

::

    typedef itk::PointSet< PixelType, Dimension > PointSetType;
    PointSetType::Pointer  pointSet = PointSetType::New();

The following code is generating a sphere and assigning vector values to
the points. The components of the vectors in this example are computed
to represent the tangents to the circle as shown in
Figure :ref:`fig-PointSetWithVectors`.

::

    PointSetType::PixelType   tangent;
    PointSetType::PointType   point;

    unsigned int pointId =  0;
    const double radius = 300.0;

    for(unsigned int i=0; i<360; i++)
      {
      const double angle = i * vnl_math::pi / 180.0;
      point[0] = radius * vcl_sin( angle );
      point[1] = radius * vcl_cos( angle );
      point[2] = 1.0;    flat on the Z plane
      tangent[0] =  vcl_cos(angle);
      tangent[1] = -vcl_sin(angle);
      tangent[2] = 0.0;   flat on the Z plane
      pointSet->SetPoint( pointId, point );
      pointSet->SetPointData( pointId, tangent );
      pointId++;
      }

We can now visit all the points and use the vector on the pixel values
to apply a displacement on the points. This is along the spirit of what
a deformable model could do at each one of its iterations.

::

    typedef  PointSetType::PointDataContainer::ConstIterator PointDataIterator;
    PointDataIterator pixelIterator = pointSet->GetPointData()->Begin();
    PointDataIterator pixelEnd      = pointSet->GetPointData()->End();

    typedef  PointSetType::PointsContainer::Iterator     PointIterator;
    PointIterator pointIterator = pointSet->GetPoints()->Begin();
    PointIterator pointEnd      = pointSet->GetPoints()->End();

    while( pixelIterator != pixelEnd  && pointIterator != pointEnd )
      {
      pointIterator.Value() = pointIterator.Value() + pixelIterator.Value();
      ++pixelIterator;
      ++pointIterator;
      }

Note that the ``ConstIterator`` was used here instead of the normal
``Iterator`` since the pixel values are only intended to be read and not
modified. ITK supports const-correctness at the API level.

The :itkdox:`itk::Vector` class has overloaded the ``+`` operator with the :itkdox:`itk::Point`. In
other words, vectors can be added to points in order to produce new
points. This property is exploited in the center of the loop in order to
update the points positions with a single statement.

We can finally visit all the points and print out the new values

::

    pointIterator = pointSet->GetPoints()->Begin();
    pointEnd      = pointSet->GetPoints()->End();
    while( pointIterator != pointEnd )
      {
      std::cout << pointIterator.Value() << std::endl;
      ++pointIterator;
      }

Note that :itkdox:`itk::Vector` is not the appropriate class for representing normals
to surfaces and gradients of functions. This is due to the way in which
vectors behave under affine transforms. ITK has a specific class for
representing normals and function gradients. This is the
:itkdox:`itk::CovariantVector` class.

