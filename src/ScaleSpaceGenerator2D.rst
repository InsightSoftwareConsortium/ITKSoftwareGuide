The source code for this section can be found in the file
``ScaleSpaceGenerator2D.cxx``.

We now use the previous example for building the ScaleSpace of a 2D
image. Since most of the code is the same, we will focus only on the
extra lines needed for generating the Scale Space.

Interestingly, all comes down to looping over several scales, by setting
different sigma values and selecting the filename of the slice
corresponding to that scale value.

::

    [language=C++]
    char filename[2000];

    int numberOfSlices = atoi(argv[3]);
    for( int slice=0; slice < numberOfSlices; slice++ )
    {
    sprintf( filename, "%s%03d.mhd", argv[2], slice );

    writer->SetFileName( filename );

    const float sigma = static_cast< float >( slice ) / 10.0 + 1.0;

    laplacian->SetSigma( sigma );
    writer->Update();
    }

The set of images can now be loaded in a Viewer, such as VolView or
ParaView, and iso-surfaces can be traced at the zero value. These
surfaces will correspond to the zero-crossings of the laplacian and
therefore their stability along Scales will represent the significance
of these features as edges in the original image.
