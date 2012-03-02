.. _sec-DefiningVectorImages:

Vector Images
~~~~~~~~~~~~~

The source code for this section can be found in the file
``VectorImage.cxx``.

Many image processing tasks require images of non-scalar pixel type. A
typical example is an image of vectors. This is the image type required
to represent the gradient of a scalar image. The following code
illustrates how to instantiate and use an image whose pixels are of
vector type.

For convenience we use the :itkdox:`itk::Vector` class to define the pixel type. The
Vector class is intended to represent a geometrical vector in space. It
is not intended to be used as an array container like the
`{std::vector <http:www.sgi.com/tech/stl/Vector.html>`_} in
`STL <http:www.sgi.com/tech/stl/>`_. If you are interested in
containers, the :itkdox:`itk::VectorContainer` class may provide the functionality
you want.

The first step is to include the header file of the Vector class.

::

    #include "itkVector.h"

The Vector class is templated over the type used to represent the
coordinate in space and over the dimension of the space. In this
example, we want the vector dimension to match the image dimension, but
this is by no means a requirement. We could have defined a
four-dimensional image with three-dimensional vectors as pixels.

::

    typedef itk::Vector< float, 3 >       PixelType;
    typedef itk::Image< PixelType, 3 >    ImageType;

The Vector class inherits the operator ``[]`` from the :itkdox:`itk::FixedArray` class.
This makes it possible to access the Vector’s components using index
notation.

::

    ImageType::PixelType   pixelValue;

    pixelValue[0] =  1.345;    x component
    pixelValue[1] =  6.841;    y component
    pixelValue[2] =  3.295;    x component

We can now store this vector in one of the image pixels by defining an
index and invoking the ``SetPixel()`` method.

::

    image->SetPixel(   pixelIndex,   pixelValue  );

