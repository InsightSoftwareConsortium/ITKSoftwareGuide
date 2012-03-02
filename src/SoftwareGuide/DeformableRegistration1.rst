The source code for this section can be found in the file
``DeformableRegistration1.cxx``.

The finite element (FEM) library within the Insight Toolkit can be used
to solve deformable image registration problems. The first step in
implementing a FEM-based registration is to include the appropriate
header files.

::

    [language=C++]
    #include "itkFEMRegistrationFilter.h"

Next, we use {typedef}s to instantiate all necessary classes. We define
the image and element types we plan to use to solve a two-dimensional
registration problem. We define multiple element types so that they can
be used without recompiling the code.

::

    [language=C++]
    typedef itk::Image<unsigned char, 2>                       DiskImageType;
    typedef itk::Image<float, 2>                               ImageType;
    typedef itk::fem::Element2DC0LinearQuadrilateralMembrane   ElementType;
    typedef itk::fem::Element2DC0LinearTriangularMembrane      ElementType2;
    typedef itk::fem::FEMObject<2>                             FEMObjectType;

Note that in order to solve a three-dimensional registration problem, we
would simply define 3D image and element types in lieu of those above.
The following declarations could be used for a 3D problem:

::

    [language=C++]
    typedef itk::Image<unsigned char, 3>                    fileImage3DType;
    typedef itk::Image<float, 3>                            Image3DType;
    typedef itk::fem::Element3DC0LinearHexahedronMembrane   Element3DType;
    typedef itk::fem::Element3DC0LinearTetrahedronMembrane  Element3DType2;
    typedef itk::fem::FEMObject<3>                          FEMObject3DType;

Once all the necessary components have been instantiated, we can
instantiate the {FEMRegistrationFilter}, which depends on the image
input and output types.

::

    [language=C++]
    typedef itk::fem::FEMRegistrationFilter<ImageType,ImageType,FEMObjectType> RegistrationType;

In order to begin the registration, we declare an instance of the
FEMRegistrationFilter and set its parameters. For simplicity, we will
call it {registrationFilter}.

::

    [language=C++]
    RegistrationType::Pointer registrationFilter = RegistrationType::New();
    registrationFilter->SetMaxLevel(1);
    registrationFilter->SetUseNormalizedGradient( true );
    registrationFilter->ChooseMetric( 0 );

    unsigned int maxiters = 20;
    float        E = 100;
    float        p = 1;
    registrationFilter->SetElasticity(E, 0);
    registrationFilter->SetRho(p, 0);
    registrationFilter->SetGamma(1., 0);
    registrationFilter->SetAlpha(1.);
    registrationFilter->SetMaximumIterations( maxiters, 0 );
    registrationFilter->SetMeshPixelsPerElementAtEachResolution(4, 0);
    registrationFilter->SetWidthOfMetricRegion(1, 0);
    registrationFilter->SetNumberOfIntegrationPoints(2, 0);
    registrationFilter->SetDoLineSearchOnImageEnergy( 0 );
    registrationFilter->SetTimeStep(1.);
    registrationFilter->SetEmployRegridding(false);
    registrationFilter->SetUseLandmarks(false);

In order to initialize the mesh of elements, we must first create
“dummy” material and element objects and assign them to the registration
filter. These objects are subsequently used to either read a predefined
mesh from a file or generate a mesh using the software. The values
assigned to the fields within the material object are arbitrary since
they will be replaced with those specified earlier. Similarly, the
element object will be replaced with those from the desired mesh.

::

    [language=C++]
    Create the material properties
    itk::fem::MaterialLinearElasticity::Pointer m;
    m = itk::fem::MaterialLinearElasticity::New();
    m->SetGlobalNumber(0);
    m->SetYoungsModulus(registrationFilter->GetElasticity());  Young's modulus of the membrane
    m->SetCrossSectionalArea(1.0);                             Cross-sectional area
    m->SetThickness(1.0);                                      Thickness
    m->SetMomentOfInertia(1.0);                                Moment of inertia
    m->SetPoissonsRatio(0.);                                   Poisson's ratio -- DONT CHOOSE 1.0!!
    m->SetDensityHeatProduct(1.0);                             Density-Heat capacity product

    Create the element type
    ElementType::Pointer e1=ElementType::New();
    e1->SetMaterial(m.GetPointer());
    registrationFilter->SetElement(e1.GetPointer());
    registrationFilter->SetMaterial(m);

Now we are ready to run the registration:

::

    [language=C++]
    registrationFilter->RunRegistration();

To output the image resulting from the registration, we can call
{GetWarpedImage()}. The image is written in floating point format.

::

    [language=C++]
    itk::ImageFileWriter<ImageType>::Pointer warpedImageWriter;
    warpedImageWriter = itk::ImageFileWriter<ImageType>::New();
    warpedImageWriter->SetInput( registrationFilter->GetWarpedImage() );
    warpedImageWriter->SetFileName("warpedMovingImage.mha");
    try
    {
    warpedImageWriter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

We can also output the displacement field resulting from the
registration; we can call {GetDisplacementField()} to get the
multi-component image.

::

    [language=C++]
    typedef itk::ImageFileWriter<RegistrationType::FieldType> DispWriterType;
    DispWriterType::Pointer dispWriter = DispWriterType::New();
    dispWriter->SetInput( registrationFilter->GetDisplacementField() );
    dispWriter->SetFileName("displacement.mha");
    try
    {
    dispWriter->Update();
    }
    catch( itk::ExceptionObject & excp )
    {
    std::cerr << excp << std::endl;
    return EXIT_FAILURE;
    }

