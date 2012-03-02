The source code for this section can be found in the file
``HelloWorld.cxx``.

The following code is an implementation of a small Insight program. It
tests including header files and linking with ITK libraries.

::

    [language=C++]
    #include "itkImage.h"
    #include <iostream>

    int main()
    {
    typedef itk::Image< unsigned short, 3 > ImageType;

    ImageType::Pointer image = ImageType::New();

    std::cout << "ITK Hello World !" << std::endl;

    return 0;
    }

This code instantiates a :math:`3D` image [1]_ whose pixels are
represented with type {unsigned short}. The image is then constructed
and assigned to a {SmartPointer}. Although later in the text we will
discuss {SmartPointer}’s in detail, for now think of it as a handle on
an instance of an object (see section {sec:SmartPointers} for more
information). The {Image} class will be described in
Section {sec:ImageSection}.

.. [1]
   Also known as a *volume*.
