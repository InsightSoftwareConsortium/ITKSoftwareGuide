.. _sec-GaussianSpatialObject:

GaussianSpatialObject
~~~~~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``GaussianSpatialObject.cxx``.

This example shows how to create a :itkdox:`itk::GaussianSpatialObject` which defines
a Gaussian in a N-dimensional space. This object is particularly useful
to query the value at a point in physical space. Let’s begin by
including the appropriate header file.

::

    #include "itkGaussianSpatialObject.h"

The :itkdox:`itk::GaussianSpatialObject` is templated over the dimensionality of the
object.

::

    typedef itk::GaussianSpatialObject<3>   GaussianType;
    GaussianType::Pointer myGaussian = GaussianType::New();

The ``SetMaximum()`` function is used to set the maximum value of the
Gaussian.

::

    myGaussian->SetMaximum(2);

The radius of the Gaussian is defined by the ``SetRadius()`` method. By
default the radius is set to 1.0.

::

    myGaussian->SetRadius(3);

The standard ``ValueAt()`` function is used to determine the value of the
Gaussian at a particular point in physical space.

::

    itk::Point<double,3> pt;
    pt[0]=1;
    pt[1]=2;
    pt[2]=1;
    double value;
    myGaussian->ValueAt(pt, value);
    std::cout << "ValueAt(" << pt << ") = " << value << std::endl;

