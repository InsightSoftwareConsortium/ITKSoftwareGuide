Flip Image Filter
~~~~~~~~~~~~~~~~~

The source code for this section can be found in the file
``FlipImageFilter.cxx``.

The {FlipImageFilter} is used for flipping the image content in any of
the coordinate axis. This filter must be used with **EXTREME** caution.
You probably don’t want to appear in the newspapers as the responsible
of a surgery mistake in which a doctor extirpates the left kidney when
it should have extracted the right one [1]_ . If that prospect doesn’t
scares you, maybe it is time for you to reconsider your career in
medical image processing. Flipping effects that may seem innocuous at
first view may still have dangerous consequences. For example flipping
the cranio-caudal axis of a CT scans forces an observer to flip the
left-right axis in order to make sense of the image.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkFlipImageFilter.h"

Then the pixel types for input and output image must be defined and,
with them, the image types can be instantiated.

::

    [language=C++]
    typedef   unsigned char  PixelType;

    typedef itk::Image< PixelType,  2 >   ImageType;

Using the image types it is now possible to instantiate the filter type
and create the filter object.

::

    [language=C++]
    typedef itk::FlipImageFilter< ImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The axis to flip are specified in the form of an Array. In this case we
take them from the command line arguments.

::

    [language=C++]
    typedef FilterType::FlipAxesArrayType     FlipAxesArrayType;

    FlipAxesArrayType flipArray;

    flipArray[0] = atoi( argv[3] );
    flipArray[1] = atoi( argv[4] );

    filter->SetFlipAxes( flipArray );

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example, a writer. An update call on any downstream filter will
trigger the execution of the mean filter.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );
    writer->Update();

    |image| |image1| [Effect of the MedianImageFilter] {Effect of the
    FlipImageFilter on a slice from a MRI proton density brain image.}
    {fig:FlipImageFilterOutput}

Figure {fig:FlipImageFilterOutput} illustrates the effect of this filter
on a slice of MRI brain image using a flip array :math:`[0,1]` which
means that the :math:`Y` axis was flipped while the :math:`X` axis
was conserved.

.. [1]
   *Wrong side* surgery accounts for :math:`2\%` of the reported
   medical errors in the United States. Trivial... but equally
   dangerous.

.. |image| image:: BrainProtonDensitySlice.eps
.. |image1| image:: FlipImageFilterOutput.eps
