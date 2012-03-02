The source code for this section can be found in the file
``RelabelComponentImageFilter.cxx``.

The {RelabelComponentImageFilter} is commonly used for reorganizing the
labels in an image that has been produced as the result of a
segmentation method. For example, region growing, or a K-means
statistical classification.

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkRelabelComponentImageFilter.h"

Then the pixel types for input and output image must be defined and,
with them, the image types can be instantiated.

::

    [language=C++]
    typedef   unsigned char  InputPixelType;
    typedef   unsigned char  OutputPixelType;

    typedef itk::Image< InputPixelType,  2 >   InputImageType;
    typedef itk::Image< OutputPixelType, 2 >   OutputImageType;

Using the image types it is now possible to instantiate the filter type
and create the filter object.

::

    [language=C++]
    typedef itk::RelabelComponentImageFilter<
    InputImageType, OutputImageType >  FilterType;

    FilterType::Pointer relabeler = FilterType::New();

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example, a writer. An update call on any downstream filter will
trigger the execution of the mean filter.

::

    [language=C++]
    relabeler->SetInput( reader->GetOutput() );
    writer->SetInput( relabeler->GetOutput() );
    writer->Update();

We can now query the size of each one of the connected components, both
in pixel units and in physical units.

::

    [language=C++]
    typedef std::vector< itk::SizeValueType > SizesInPixelsType;

    const SizesInPixelsType &  sizesInPixels = relabeler->GetSizeOfObjectsInPixels();

    SizesInPixelsType::const_iterator sizeItr = sizesInPixels.begin();
    SizesInPixelsType::const_iterator sizeEnd = sizesInPixels.end();

    std::cout << "Number of pixels per class " << std::endl;
    unsigned int kclass = 0;
    while( sizeItr != sizeEnd )
    {
    std::cout << "Class " << kclass << " = " << *sizeItr << std::endl;
    ++kclass;
    ++sizeItr;
    }

::

    [language=C++]
    typedef std::vector< float > SizesInPhysicalUnitsType;

    const SizesInPhysicalUnitsType  sizesInUnits = relabeler->GetSizeOfObjectsInPhysicalUnits();

    SizesInPhysicalUnitsType::const_iterator physicalSizeItr = sizesInUnits.begin();
    SizesInPhysicalUnitsType::const_iterator physicalSizeEnd = sizesInUnits.end();

    std::cout << "Area in Physical Units per class " << std::endl;
    unsigned int jclass = 0;
    while( physicalSizeItr != physicalSizeEnd )
    {
    std::cout << "Class " << jclass << " = " << *physicalSizeItr << std::endl;
    ++jclass;
    ++physicalSizeItr;
    }

