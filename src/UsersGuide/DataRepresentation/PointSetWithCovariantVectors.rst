.. _sec-PointSetWithCovariantVectorsAsPixelType:

Normals as Pixel Type
~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``PointSetWithCovariantVectors.cxx``.

It is common to represent geometric object by using points on their
surfaces and normals associated with those points. This structure can be
easily instantiated with the :itkdox:`itk::PointSet` class.

The natural class for representing normals to surfaces and gradients of
functions is the :itkdox:`itk::CovariantVector`. A covariant vector differs from a
vector in the way they behave under affine transforms, in particular
under anisotropic scaling. If a covariant vector represents the gradient
of a function, the transformed covariant vector will still be the valid
gradient of the transformed function, a property which would not hold
with a regular vector.

The following code shows how vector values can be used as pixel type on
the PointSet class. The CovariantVector class is used here as the pixel
type. The example illustrates how a deformable model could move under
the influence of the gradient of potential function.

In order to use the :itkdox:`itk::CovariantVector` class it is necessary to include its
header file along with the header of the point set.

::

    #include "itkCovariantVector.h"
    #include "itkPointSet.h"

The :itkdox:`itk::CovariantVector` class is templated over the type used to represent
the spatial coordinates and over the space dimension. Since the
PixelType is independent of the ``PointType``, we are free to select any
dimension for the covariant vectors to be used as pixel type. However,
we want to illustrate here the spirit of a deformable model. It is then
required for the vectors representing gradients to be of the same
dimension as the points in space.

::

    const unsigned int Dimension = 3;
    typedef itk::CovariantVector< float, Dimension >    PixelType;

Then we use the ``PixelType`` (which are actually CovariantVectors) to
instantiate the :itkdox:`itk::PointSet` type and subsequently create a PointSet object.

::

    typedef itk::PointSet< PixelType, Dimension > PointSetType;
    PointSetType::Pointer  pointSet = PointSetType::New();

The following code generates a sphere and assigns gradient values to the
points. The components of the CovariantVectors in this example are
computed to represent the normals to the circle.

::

    PointSetType::PixelType   gradient;
    PointSetType::PointType   point;

    unsigned int pointId =  0;
    const double radius = 300.0;

    for(unsigned int i=0; i<360; i++)
      {
      const double angle = i * vcl_atan(1.0) / 45.0;
      point[0] = radius * vcl_sin( angle );
      point[1] = radius * vcl_cos( angle );
      point[2] = 1.0;    flat on the Z plane
      gradient[0] =  vcl_sin(angle);
      gradient[1] =  vcl_cos(angle);
      gradient[2] = 0.0;   flat on the Z plane
      pointSet->SetPoint( pointId, point );
      pointSet->SetPointData( pointId, gradient );
      pointId++;
      }

We can now visit all the points and use the vector on the pixel values
to apply a deformation on the points by following the gradient of the
function. This is along the spirit of what a deformable model could do
at each one of its iterations. To be more formal we should use the
function gradients as forces and multiply them by local stress tensors
in order to obtain local deformations. The resulting deformations would
finally be used to apply displacements on the points. However, to
shorten the example, we will ignore this complexity for the moment.

::

    typedef  PointSetType::PointDataContainer::ConstIterator PointDataIterator;
    PointDataIterator pixelIterator = pointSet->GetPointData()->Begin();
    PointDataIterator pixelEnd      = pointSet->GetPointData()->End();

    typedef  PointSetType::PointsContainer::Iterator     PointIterator;
    PointIterator pointIterator = pointSet->GetPoints()->Begin();
    PointIterator pointEnd      = pointSet->GetPoints()->End();

    while( pixelIterator != pixelEnd  && pointIterator != pointEnd )
      {
      point    = pointIterator.Value();
      gradient = pixelIterator.Value();
      for(unsigned int i=0; i<Dimension; i++)
        {
        point[i] += gradient[i];
        }
      pointIterator.Value() = point;
      ++pixelIterator;
      ++pointIterator;
      }

The CovariantVector class does not overload the ``+`` operator with the
:itkdox:`itk::Point`. In other words, CovariantVectors can not be added to points in
order to get new points. Further, since we are ignoring physics in the
example, we are also forced to do the illegal addition manually between
the components of the gradient and the coordinates of the points.

Note that the absence of some basic operators on the ITK geometry
classes is completely intentional with the aim of preventing the
incorrect use of the mathematical concepts they represent.
