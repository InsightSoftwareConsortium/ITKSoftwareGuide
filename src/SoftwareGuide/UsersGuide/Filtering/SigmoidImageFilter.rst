.. _sec-IntensityNonLinearMapping:

Non Linear Mappings
~~~~~~~~~~~~~~~~~~~

The following filter can be seen as a variant of the casting filters.
Its main difference is the use of a smooth and continuous transition
function of non-linear form.

The source code for this section can be found in the file
``SigmoidImageFilter.cxx``.

The {SigmoidImageFilter} is commonly used as an intensity transform. It
maps a specific range of intensity values into a new intensity range by
making a very smooth and continuous transition in the borders of the
range. Sigmoids are widely used as a mechanism for focusing attention on
a particular set of values and progressively attenuating the values
outside that range. In order to extend the flexibility of the Sigmoid
filter, its implementation in ITK includes four parameters that can be
tuned to select its input and output intensity ranges. The following
equation represents the Sigmoid intensity transformation, applied
pixel-wise.

:math:`I' = (Max-Min)\cdot \frac{1}{\left(1+e^{-\left(\frac{ I - \beta }{\alpha } \right)} \right)} + Min
`

In the equation above, :math:`I` is the intensity of the input pixel,
:math:`I'` the intensity of the output pixel, :math:`Min,Max` are
the minimum and maximum values of the output image, :math:`\alpha`
defines the width of the input intensity range, and :math:`\beta`
defines the intensity around which the range is centered.
Figure {fig:SigmoidParameters} illustrates the significance of each
parameter.

    |image| |image1| [Sigmoid Parameters] {Effects of the various
    parameters in the SigmoidImageFilter. The alpha parameter defines
    the width of the intensity window. The beta parameter defines the
    center of the intensity window.} {fig:SigmoidParameters}

This filter will work on images of any dimension and will take advantage
of multiple processors when available.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkSigmoidImageFilter.h"

Then pixel and image types for the filter input and output must be
defined.

::

    [language=C++]
    typedef   unsigned char  InputPixelType;
    typedef   unsigned char  OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

Using the image types, we instantiate the filter type and create the
filter object.

::

    [language=C++]
    typedef itk::SigmoidImageFilter<
    InputImageType, OutputImageType >  SigmoidFilterType;
    SigmoidFilterType::Pointer sigmoidFilter = SigmoidFilterType::New();

The minimum and maximum values desired in the output are defined using
the methods {SetOutputMinimum()} and {SetOutputMaximum()}.

::

    [language=C++]
    sigmoidFilter->SetOutputMinimum(   outputMinimum  );
    sigmoidFilter->SetOutputMaximum(   outputMaximum  );

The coefficients :math:`\alpha` and :math:`\beta` are set with the
methods {SetAlpha()} and {SetBeta()}. Note that :math:`\alpha` is
proportional to the width of the input intensity window. As rule of
thumb, we may say that the window is the interval
:math:`[-3\alpha, 3\alpha]`. The boundaries of the intensity window
are not sharp. The :math:`\alpha` curve approaches its extrema
smoothly, as shown in Figure {fig:SigmoidParameters}. You may want to
think about this in the same terms as when taking a range in a
population of measures by defining an interval of
:math:`[-3 \sigma, +3 \sigma]` around the population mean.

::

    [language=C++]
    sigmoidFilter->SetAlpha(  alpha  );
    sigmoidFilter->SetBeta(   beta   );

The input to the SigmoidImageFilter can be taken from any other filter,
such as an image file reader, for example. The output can be passed down
the pipeline to other filters, like an image file writer. An update call
on any downstream filter will trigger the execution of the Sigmoid
filter.

::

    [language=C++]
    sigmoidFilter->SetInput( reader->GetOutput() );
    writer->SetInput( sigmoidFilter->GetOutput() );
    writer->Update();

    |image2| |image3| [Effect of the Sigmoid filter.] {Effect of the
    Sigmoid filter on a slice from a MRI proton density brain image.}
    {fig:SigmoidImageFilterOutput}

Figure {fig:SigmoidImageFilterOutput} illustrates the effect of this
filter on a slice of MRI brain image using the following parameters.

-  Minimum = 10

-  Maximum = 240

-  :math:`\alpha` = 10

-  :math:`\beta` = 170

As can be seen from the figure, the intensities of the white matter were
expanded in their dynamic range, while intensity values lower than
:math:`\beta - 3 \alpha` and higher than :math:`\beta + 3\alpha`
became progressively mapped to the minimum and maximum output values.
This is the way in which a Sigmoid can be used for performing smooth
intensity windowing.

Note that both :math:`\alpha` and :math:`\beta` can be positive and
negative. A negative :math:`\alpha` will have the effect of *negating*
the image. This is illustrated on the left side of
Figure {fig:SigmoidParameters}. An application of the Sigmoid filter as
preprocessing for segmentation is presented in
Section {sec:FastMarchingImageFilter}.

Sigmoid curves are common in the natural world. They represent the plot
of sensitivity to a stimulus. They are also the integral curve of the
Gaussian and, therefore, appear naturally as the response to signals
whose distribution is Gaussian.

.. |image| image:: SigmoidParameterAlpha.eps
.. |image1| image:: SigmoidParameterBeta.eps
.. |image2| image:: BrainProtonDensitySlice.eps
.. |image3| image:: SigmoidImageFilterOutput.eps
