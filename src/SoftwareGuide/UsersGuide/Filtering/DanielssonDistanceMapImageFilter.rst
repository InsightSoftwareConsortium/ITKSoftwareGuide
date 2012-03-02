The source code for this section can be found in the file
``DanielssonDistanceMapImageFilter.cxx``.

This example illustrates the use of the
{DanielssonDistanceMapImageFilter}. This filter generates a distance map
from the input image using the algorithm developed by Danielsson . As
secondary outputs, a Voronoi partition of the input elements is
produced, as well as a vector image with the components of the distance
vector to the closest point. The input to the map is assumed to be a set
of points on the input image. Each point/pixel is considered to be a
separate entity even if they share the same gray level value.

The first step required to use this filter is to include its header
file.

::

    [language=C++]
    #include "itkDanielssonDistanceMapImageFilter.h"

Then we must decide what pixel types to use for the input and output
images. Since the output will contain distances measured in pixels, the
pixel type should be able to represent at least the width of the image,
or said in :math:`N-D` terms, the maximum extension along all the
dimensions. The input and output image types are now defined using their
respective pixel type and dimension.

::

    [language=C++]
    typedef  unsigned char                   InputPixelType;
    typedef  unsigned short                  OutputPixelType;
    typedef itk::Image< InputPixelType,  2 > InputImageType;
    typedef itk::Image< OutputPixelType, 2 > OutputImageType;

The filter type can be instantiated using the input and output image
types defined above. A filter object is created with the {New()} method.

::

    [language=C++]
    typedef itk::DanielssonDistanceMapImageFilter<
    InputImageType, OutputImageType, OutputImageType >  FilterType;
    FilterType::Pointer filter = FilterType::New();

The input to the filter is taken from a reader and its output is passed
to a {RescaleIntensityImageFilter} and then to a writer.

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    scaler->SetInput( filter->GetOutput() );
    writer->SetInput( scaler->GetOutput() );

The type of input image has to be specified. In this case, a binary
image is selected.

::

    [language=C++]
    filter->InputIsBinaryOn();

    |image| |image1| |image2| [DanielssonDistanceMapImageFilter output]
    {DanielssonDistanceMapImageFilter output. Set of pixels, distance
    map and Voronoi partition.}
    {fig:DanielssonDistanceMapImageFilterInputOutput}

Figure {fig:DanielssonDistanceMapImageFilterInputOutput} illustrates the
effect of this filter on a binary image with a set of points. The input
image is shown at left, the distance map at the center and the Voronoi
partition at right. This filter computes distance maps in N-dimensions
and is therefore capable of producing :math:`N-D` Voronoi partitions.

The Voronoi map is obtained with the {GetVoronoiMap()} method. In the
lines below we connect this output to the intensity rescaler and save
the result in a file.

::

    [language=C++]
    scaler->SetInput( filter->GetVoronoiMap() );
    writer->SetFileName( voronoiMapFileName );
    writer->Update();

The distance filter also produces an image of {Offset} pixels
representing the vectorial distance to the closest object in the scene.
The type of this output image is defined by the VectorImageType trait of
the filter type.

::

    [language=C++]
    typedef FilterType::VectorImageType   OffsetImageType;

We can use this type for instantiating an {ImageFileWriter} type and
creating an object of this class in the following lines.

::

    [language=C++]
    typedef itk::ImageFileWriter< OffsetImageType >  WriterOffsetType;
    WriterOffsetType::Pointer offsetWriter = WriterOffsetType::New();

The output of the distance filter can be connected as input to the
writer.

::

    [language=C++]
    offsetWriter->SetInput(  filter->GetVectorDistanceMap()  );

Execution of the writer is triggered by the invocation of the {Update()}
method. Since this method can potentially throw exceptions it must be
placed in a {try/catch} block.

::

    [language=C++]
    try
    {
    offsetWriter->Update();
    }
    catch( itk::ExceptionObject exp )
    {
    std::cerr << "Exception caught !" << std::endl;
    std::cerr <<     exp    << std::endl;
    }

Note that only the {MetaImageIO} class supports reading and writing
images of pixel type {Offset}.

.. |image| image:: FivePoints.eps
.. |image1| image:: DanielssonDistanceMapImageFilterOutput1.eps
.. |image2| image:: DanielssonDistanceMapImageFilterOutput2.eps
