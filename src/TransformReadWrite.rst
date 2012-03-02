The source code for this section can be found in the file
``TransformReadWrite.cxx``.

This example shows how to read and write a transform using the
{TransformFileReader} and {TransformFileWriter}. Let’s first include the
two appropriate header files.

::

    [language=C++]
    #include "itkTransformFileReader.h"
    #include "itkTransformFileWriter.h"

The transform reader and writer are not templated. The conversion is
done internally.when writing or reading the file. We create a writer
using smart pointers.

::

    [language=C++]
    itk::TransformFileWriter::Pointer writer;
    writer = itk::TransformFileWriter::New();

The first transform we have to write should be set using the SetInput()
function. This function takes any {Transform}

::

    [language=C++]
    writer->SetInput( affine );

Moreover, additional transforms to be written can be set using the
AddTransform() function. This function add the transform to the list.
Note that the SetInput() function reinitializes the list.

::

    [language=C++]
    writer->AddTransform(bspline);

Then we set the filename using the SetFileName() function. The file’s
extension does not matter for the transform reader/writer. Then we call
the Update() function to write the transform(s) onto the disk.

::

    [language=C++]
    writer->SetFileName( "Transforms.meta" );

::

    [language=C++]
    writer->Update();

In order to read a transform file, we instantiate a TransformFileReader.
Like the writer, the reader is not templated.

::

    [language=C++]
    itk::TransformFileReader::Pointer reader;
    reader = itk::TransformFileReader::New();

Some transforms (like the BSpline transform) might not be registered
with the factory so we add them manually.

::

    [language=C++]
    itk::TransformFactory<BSplineTransformType>::RegisterTransform();

We then set the name of the file we want to read, and call the Update()
function.

::

    [language=C++]
    reader->SetFileName( "Transforms.meta" );

::

    [language=C++]
    reader->Update();

The transform reader is not template and therefore it retunrs a list of
{Transform}. However, the reader instantiate the appropriate transform
class when reading the file but it is up to the user to do the
approriate cast. To get the output list of transform we use the
GetTransformList() function.

::

    [language=C++]
    typedef itk::TransformFileReader::TransformListType * TransformListType;
    TransformListType transforms = reader->GetTransformList();
    std::cout << "Number of transforms = " << transforms->size() << std::endl;

We then use an STL iterator to go trought the list of transforms. We
show here how to do the proper casting of the resulting transform.

::

    [language=C++]
    itk::TransformFileReader::TransformListType::const_iterator it = transforms->begin();
    if(!strcmp((*it)->GetNameOfClass(),"AffineTransform"))
    {
    AffineTransformType::Pointer affine_read = static_cast<AffineTransformType*>((*it).GetPointer());
    affine_read->Print(std::cout);
    }

    ++it;

    if(!strcmp((*it)->GetNameOfClass(),"BSplineTransform"))
    {
    BSplineTransformType::Pointer bspline_read = static_cast<BSplineTransformType*>((*it).GetPointer());
    bspline_read->Print(std::cout);
    }

