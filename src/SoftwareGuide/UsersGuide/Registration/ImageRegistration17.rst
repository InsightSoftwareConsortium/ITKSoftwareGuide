The source code for this section can be found in the file
``ImageRegistration17.cxx``.

This example illustrates how to do registration with a 2D Translation
Transform, the Mutual Information Histogram metric and the Amoeba
optimizer.

::

    [language=C++]
    typedef MetricType::HistogramSizeType    HistogramSizeType;

    HistogramSizeType  histogramSize;

    histogramSize.SetSize(2);

    histogramSize[0] = 256;
    histogramSize[1] = 256;

    metric->SetHistogramSize( histogramSize );

    The Amoeba optimizer doesn't need the cost function to compute derivatives
    metric->ComputeGradientOff();

The AmoebaOptimizer moves a simplex around the cost surface. Here we set
the initial size of the simplex (5 units in each of the parameters)

::

    [language=C++]
    OptimizerType::ParametersType simplexDelta( numberOfParameters );
    simplexDelta.Fill( 5.0 );

    optimizer->AutomaticInitialSimplexOff();
    optimizer->SetInitialSimplexDelta( simplexDelta );

The AmoebaOptimizer performs minimization by default. In this case
however, the MutualInformation metric must be maximized. We should
therefore invoke the {MaximizeOn()} method on the optimizer in order to
set it up for maximization.

::

    [language=C++]
    optimizer->MaximizeOn();

We also adjust the tolerances on the optimizer to define convergence.
Here, we used a tolerance on the parameters of 0.1 (which will be one
tenth of image unit, in this case pixels). We also set the tolerance on
the cost function value to define convergence. The metric we are using
returns the value of Mutual Information. So we set the function
convergence to be 0.001 bits (bits are the appropriate units for
measuring Information).

::

    [language=C++]
    optimizer->SetParametersConvergenceTolerance( 0.1 );   1/10th pixel
    optimizer->SetFunctionConvergenceTolerance(0.001);     0.001 bits

In the case where the optimizer never succeeds in reaching the desired
precision tolerance, it is prudent to establish a limit on the number of
iterations to be performed. This maximum number is defined with the
method {SetMaximumNumberOfIterations()}.

::

    [language=C++]
    optimizer->SetMaximumNumberOfIterations( 200 );

::

    [language=C++]
    optimizer->SetMaximumNumberOfIterations( 200 );

