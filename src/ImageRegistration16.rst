The source code for this section can be found in the file
``ImageRegistration16.cxx``.

This example illustrates how to do registration with a 2D Translation
Transform, the Normalized Mutual Information metric and the Amoeba
optimizer.

The metric requires two parameters to be selected: the number of bins
used to compute the entropy and the number of spatial samples used to
compute the density estimates. In typical application, 50 histogram bins
are sufficient and the metric is relatively insensitive to changes in
the number of bins. The number of spatial samples to be used depends on
the content of the image. If the images are smooth and do not contain
much detail, then using approximately :math:`1` percent of the pixels
will do. On the other hand, if the images are detailed, it may be
necessary to use a much higher proportion, such as :math:`20` percent.

::

    [language=C++]
    metric->SetNumberOfHistogramBins( 20 );
    metric->SetNumberOfSpatialSamples( 10000 );

The AmoebaOptimizer moves a simplex around the cost surface. Here we set
the initial size of the simplex (5 units in each of the parameters)

::

    [language=C++]
    OptimizerType::ParametersType simplexDelta( numberOfParameters );
    simplexDelta.Fill( 5.0 );

    optimizer->AutomaticInitialSimplexOff();
    optimizer->SetInitialSimplexDelta( simplexDelta );

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

