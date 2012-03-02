.. _sec-RGBImages:

RGB Images
~~~~~~~~~~

The term RGB (Red, Green, Blue) stands for a color representation
commonly used in digital imaging. RGB is a representation of the human
physiological capability to analyze visual light using three
spectral-selective sensors . The human retina possess different types of
light sensitive cells. Three of them, known as *cones*, are sensitive to
color  and their regions of sensitivity loosely match regions of the
spectrum that will be perceived as red, green and blue respectively. The
*rods* on the other hand provide no color discrimination and favor high
resolution and high sensitivity [1]_. A fifth type of receptors, the
*ganglion cells*, also known as circadian [2]_ receptors are sensitive
to the lighting conditions that differentiate day from night. These
receptors evolved as a mechanism for synchronizing the physiology with
the time of the day. Cellular controls for circadian rythms are present
in every cell of an organism and are known to be exquisitively precise .

The RGB space has been constructed as a representation of a
physiological response to light by the three types of *cones* in the
human eye. RGB is not a Vector space. For example, negative numbers are
not appropriate in a color space because they will be the equivalent of
“negative stimulation” on the human eye. In the context of colorimetry,
negative color values are used as an artificial construct for color
comparison in the sense that

.. math:: ColorA = ColorB - ColorC
  :label: ColorSubtraction

just as a way of saying that we can produce :math:`ColorB` by
combining :math:`ColorA` and :math:`ColorC`. However, we must be
aware that (at least in emitted light) it is not possible to *substract
light*. So when we mention Equation :eq:`ColorSubtraction` we actually
mean

.. math:: ColorB = ColorA + ColorC
  :label: ColorAddition

On the other hand, when dealing with printed color and with paint, as
opposed to emitted light like in computer screens, the physical behavior
of color allows for subtraction. This is because strictly speaking the
objects that we see as red are those that absorb all light frequencies
except those in the red section of the spectrum .

The concept of addition and subtraction of colors has to be carefully
interpreted. In fact, RGB has a different definition regarding whether
we are talking about the channels associated to the three color sensors
of the human eye, or to the three phosphors found in most computer
monitors or to the color inks that are used for printing reproduction.
Color spaces are usually non linear and do not even from a Group. For
example, not all visible colors can be represented in RGB space .

ITK introduces the :itkdox:`itk::RGBPixel` type as a support for representing the
values of an RGB color space. As such, the :itkdox:`itk::RGBPixel` class embodies a
different concept from the one of an :itkdox:`itk::Vector` in space. For this reason,
the :itkdox:`itk::RGBPixel` lack many of the operators that may be naively expected
from it. In particular, there are no defined operations for subtraction
or addition.

When you anticipate to perform the operation of “Mean” on a RGB type you
are assuming that in the color space provides the action of finding a
color in the middle of two colors, can be found by using a linear
operation between their numerical representation. This is unfortunately
not the case in color spaces due to the fact that they are based on a
human physiological response .

If you decide to interpret RGB images as simply three independent
channels then you should rather use the :itkdox:`itk::Vector` type as pixel type. In
this way, you will have access to the set of operations that are defined
in Vector spaces. The current implementation of the :itkdox:`itk::RGBPixel` in ITK
presumes that RGB color images are intended to be used in applications
where a formal interpretation of color is desired, therefore only the
operations that are valid in a color space are available in the :itkdox:`itk::RGBPixel`
class.

The following example illustrates how RGB images can be represented in
ITK.


The source code for this section can be found in the file
``RGBImage.cxx``.

Thanks to the flexibility offered by the `Generic
Programming <http:www.boost.org/more/generic_programming.html>`_ style
on which ITK is based, it is possible to instantiate images of arbitrary
pixel type. The following example illustrates how a color image with RGB
pixels can be defined.

A class intended to support the RGB pixel type is available in ITK. You
could also define your own pixel class and use it to instantiate a
custom image type. In order to use the :itkdox:`itk::RGBPixel` class, it is necessary
to include its header file.

::

    #include "itkRGBPixel.h"

The RGB pixel class is templated over a type used to represent each one
of the red, green and blue pixel components. A typical instantiation of
the templated class is as follows.

::

    typedef itk::RGBPixel< unsigned char >    PixelType;

The type is then used as the pixel template parameter of the image.

::

    typedef itk::Image< PixelType, 3 >   ImageType;

The image type can be used to instantiate other filter, for example, an
:itkdox:`itk::ImageFileReader` object that will read the image from a file.

::

    typedef itk::ImageFileReader< ImageType >  ReaderType;

Access to the color components of the pixels can now be performed using
the methods provided by the :itkdox:`itk::RGBPixel` class.

::

    PixelType onePixel = image->GetPixel( pixelIndex );

    PixelType::ValueType red   = onePixel.GetRed();
    PixelType::ValueType green = onePixel.GetGreen();
    PixelType::ValueType blue  = onePixel.GetBlue();

The subindex notation can also be used since the :itkdox:`itk::RGBPixel` inherits the
``[]`` operator from the :itkdox:`itk::FixedArray` class.

::

    red   = onePixel[0];   extract Red   component
    green = onePixel[1];   extract Green component
    blue  = onePixel[2];   extract Blue  component

    std::cout << "Pixel values:" << std::endl;
    std::cout << "Red = "
      << itk::NumericTraits<PixelType::ValueType>::PrintType(red)
      << std::endl;
    std::cout << "Green = "
      << itk::NumericTraits<PixelType::ValueType>::PrintType(green)
      << std::endl;
    std::cout << "Blue = "
      << itk::NumericTraits<PixelType::ValueType>::PrintType(blue)
      << std::endl;

