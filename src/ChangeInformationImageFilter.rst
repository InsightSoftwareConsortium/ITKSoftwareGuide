The source code for this section can be found in the file
``ChangeInformationImageFilter.cxx``.

The \doxygen{ChangeInformationImageFilter} is commonly used to modify image
metadata such as origin, spacing, and orientation. This filter leaves
intact the pixel data of the image. This filter should be used with
extreme caution, since it can easily change information that is critical
for the safety of many medical image analysis tasks, such as measurement
the volume of a tumor, or providing guidance for surgery.

The following example illustrates the use of the ChangeInformation image
filter in the context of generating synthetic inputs for image
registration tests.

.. index:: 
   single: ChangeInformationImageFilter

The header file corresponding to this filter should be included first.

::

    [language=C++]
    #include "itkChangeInformationImageFilter.h"

Then the pixel and image types of the input and output must be defined.

::

    [language=C++]
    typedef   unsigned char  PixelType;

    const unsigned int Dimension = 3;

    typedef itk::Image< PixelType,  Dimension >   ImageType;

Using the image types, it is now possible to define the filter type and
create the filter object.

::

    [language=C++]
    typedef itk::ChangeInformationImageFilter< ImageType >  FilterType;

    FilterType::Pointer filter = FilterType::New();

The input to the filter can be taken from any other filter, for example
a reader. The output can be passed down the pipeline to other filters,
for example, a writer. An update call on any downstream filter will
trigger the execution of the median filter.

.. index::
   pair: ChangeInformationImageFilter; SetInput
   pair: ChangeInformationImageFilter; GetOutput

::

    [language=C++]
    filter->SetInput( reader->GetOutput() );
    writer->SetInput( filter->GetOutput() );

