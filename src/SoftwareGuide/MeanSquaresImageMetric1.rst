The source code for this section can be found in the file
``MeanSquaresImageMetric1.cxx``.

This example illustrates how to explore the domain of an image metric.
This is a useful exercise to do before starting a registration process,
since getting familiar with the characteristics of the metric is
fundamental for the appropriate selection of the optimizer to be use for
driving the registration process, as well as for selecting the optimizer
parameters. This process makes possible to identify how noisy a metric
may be in a given range of parameters, and it will also give an idea of
the number of local minima or maxima in which an optimizer may get
trapped while exploring the parametric space.

We start by including the headers of the basic components: Metric,
Transform and Interpolator.

::

    [language=C++]
    #include "itkMeanSquaresImageToImageMetric.h"
    #include "itkTranslationTransform.h"
    #include "itkNearestNeighborInterpolateImageFunction.h"

We define the dimension and pixel type of the images to be used in the
evaluation of the Metric.

::

    [language=C++]
    const     unsigned int   Dimension = 2;
    typedef   unsigned char  PixelType;

    typedef itk::Image< PixelType, Dimension >   ImageType;

The type of the Metric is instantiated and one is constructed. In this
case we decided to use the same image type for both the fixed and the
moving images.

::

    [language=C++]
    typedef itk::MeanSquaresImageToImageMetric<
    ImageType, ImageType >  MetricType;

    MetricType::Pointer metric = MetricType::New();

We also instantiate the transform and interpolator types, and create
objects of each class.

::

    [language=C++]
    typedef itk::TranslationTransform< double, Dimension >  TransformType;

    TransformType::Pointer transform = TransformType::New();


    typedef itk::NearestNeighborInterpolateImageFunction<
    ImageType, double >  InterpolatorType;

    InterpolatorType::Pointer interpolator = InterpolatorType::New();

The classes required by the metric are connected to it. This includes
the fixed and moving images, the interpolator and the transform.

::

    [language=C++]
    metric->SetTransform( transform );
    metric->SetInterpolator( interpolator );

    metric->SetFixedImage(  fixedImage  );
    metric->SetMovingImage( movingImage );

Finally we select a region of the parametric space to explore. In this
case we are using a translation transform in 2D, so we simply select
translations from a negative position to a positive position, in both
:math:`x` and :math:`y`. For each one of those positions we invoke
the GetValue() method of the Metric.

::

    [language=C++]
    MetricType::TransformParametersType displacement( Dimension );

    const int rangex = 50;
    const int rangey = 50;

    for( int dx = -rangex; dx <= rangex; dx++ )
    {
    for( int dy = -rangey; dy <= rangey; dy++ )
    {
    displacement[0] = dx;
    displacement[1] = dy;
    const double value = metric->GetValue( displacement );
    std::cout << dx << "   "  << dy << "   " << value << std::endl;
    }
    }

    |image| |image1| [Mean Squares Metric Plots] {Plots of the Mean
    Squares Metric for an image compared to itself under multiple
    translations.} {fig:MeanSquaresMetricPlot}

Running this code using the image BrainProtonDensitySlice.png as both
the fixed and the moving images results in the plot shown in
Figure {fig:MeanSquaresMetricPlot}. From this Figure, it can be seen
that a gradient based optimizer will be appropriate for finding the
extrema of the Metric. It is also possible to estimate a good value for
the step length of a gradient-descent optimizer.

This exercise of plotting the Metric is probably the best thing to do
when a registration process is not converging and when it is unclear how
to fine tune the different parameters involved in the registration. This
includes the optimizer parameters, the metric parameters and even
options such as preprocessing the image data with smoothing filters.

The shell and Gnuplot [1]_ scripts used for generating the graphics in
Figure {fig:MeanSquaresMetricPlot} are available in the directory

{InsightDocuments/SoftwareGuide/Art}

Of course, this plotting exercise becomes more challenging when the
transform has more than three parameters, and when those parameters have
very different range of values. In those cases is necessary to select
only a key subset of parameters from the transform and to study the
behavior of the metric when those parameters are varied.

.. [1]
   http:www.gnuplot.info

.. |image| image:: MeanSquaresMetricPlot1.eps
.. |image1| image:: MeanSquaresMetricPlot2.eps
