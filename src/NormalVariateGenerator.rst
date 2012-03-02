The source code for this section can be found in the file
``NormalVariateGenerator.cxx``.

The {Statistics} {NormalVariateGenerator} generates random variables
according to the standard normal distribution (mean = 0, standard
deviation = 1).

To use the class in a project, we must link the {itkStatistics} library
to the project.

To begin the example we include the header file for the class.

::

    [language=C++]
    #include "itkNormalVariateGenerator.h"

The NormalVariateGenerator is a non-templated class. We simply call the
{New()} method to create an instance. Then, we provide the seed value
using the {Initialize(seed value)}.

::

    [language=C++]
    typedef itk::Statistics::NormalVariateGenerator GeneratorType;
    GeneratorType::Pointer generator = GeneratorType::New();
    generator->Initialize( (int) 2003 );

    for ( unsigned int i = 0 ; i < 50 ; ++i )
    {
    std::cout << i << " : \t" << generator->GetVariate() << std::endl;
    }

