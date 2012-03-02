The source code for this section can be found in the file
``DeformableModel1.cxx``.

This example illustrates the use of the {DeformableMesh3DFilter} and
{BinaryMask3DMeshSource} in the hybrid segmentation framework.

    |image| [Deformable model collaboration diagram] {Collaboration
    diagram for the DeformableMesh3DFilter applied to a segmentation
    task.} {fig:DeformableModelCollaborationDiagram}

The purpose of the DeformableMesh3DFilter is to take an initial surface
described by an {Mesh} and deform it in order to adapt it to the shape
of an anatomical structure in an image.
Figure {fig:DeformableModelCollaborationDiagram} illustrates a typical
setup for a segmentation method based on deformable models. First, an
initial mesh is generated using a binary mask and an isocontouring
algorithm (such as marching cubes) to produce an initial mesh. The
binary mask used here contains a simple shape which vaguely resembles
the anatomical structure that we want to segment. The application of the
isocontouring algorithm produces a :math:`3D` mesh that has the shape
of this initial structure. This initial mesh is passed as input to the
deformable model which will apply forces to the mesh points in order to
reshape the surface until make it fit to the anatomical structures in
the image.

The forces to be applied on the surface are computed from an approximate
physical model that simulates an elastic deformation. Among the forces
to be applied we need one that will pull the surface to the position of
the edges in the anatomical structure. This force component is
represented here in the form of a vector field and is computed as
illustrated in the lower left of
Figure {fig:DeformableModelCollaborationDiagram}. The input image is
passed to a {GradientMagnitudeRecursiveGaussianImageFilter}, which
computes the magnitude of the image gradient. This scalar image is then
passed to another gradient filter
({GradientRecursiveGaussianImageFilter}). The output of this second
gradient filter is a vector field in which every vector points to the
closest edge in the image and has a magnitude proportional to the second
derivative of the image intensity along the direction of the gradient.
Since this vector field is computed using Gaussian derivatives, it is
possible to regulate the smoothness of the vector field by playing with
the value of sigma assigned to the Gaussian. Large values of sigma will
result in a large capture radius, but will have poor precision in the
location of the edges. A reasonable strategy may involve the use of
large sigmas for the initial iterations of the model and small sigmas to
refine the model when it is close to the edges. A similar effect could
be achieved using multiresolution and taking advantage of the image
pyramid structures already illustrated in the registration framework.

We start by including the headers of the main classes required for this
example. The BinaryMask3DMeshSource is used to produce an initial
approximation of the shape to be segmented. This filter takes a binary
image as input and produces a Mesh as output using the marching cube
isocontouring algorithm.

::

    [language=C++]
    #include "itkBinaryMask3DMeshSource.h"

Then we include the header of the DeformableMesh3DFilter that implements
the deformable model algorithm.

::

    [language=C++]
    #include "itkDeformableMesh3DFilter.h"

We also need the headers of the gradient filters that will be used for
computing the vector field. In our case they are the
GradientMagnitudeRecursiveGaussianImageFilter and
GradientRecursiveGaussianImageFilter.

::

    [language=C++]
    #include "itkGradientRecursiveGaussianImageFilter.h"
    #include "itkGradientMagnitudeRecursiveGaussianImageFilter.h"

The main data structures required in this example are the Image and the
Mesh classes. The deformable model *per se* is represented as a Mesh.

::

    [language=C++]

The {PixelType} of the image derivatives is represented with a
{CovariantVector}. We include its header in the following line.

::

    [language=C++]

The deformed mesh is converted into a binary image using the
{PointSetToImageFilter}.

::

    [language=C++]
    #include "itkPointSetToImageFilter.h"

In order to read both the input image and the mask image, we need the
{ImageFileReader} class. We also need the {ImageFileWriter} to save the
resulting deformed mask image.

::

    [language=C++]
    #include "itkImageFileReader.h"
    #include "itkImageFileWriter.h"

Here we declare the type of the image to be processed. This implies a
decision about the {PixelType} and the dimension. The
DeformableMesh3DFilter is specialized for :math:`3D`, so the choice is
clear in our case.

::

    [language=C++]
    const     unsigned int    Dimension = 3;
    typedef   double                         PixelType;
    typedef itk::Image<PixelType, Dimension> ImageType;

The input to BinaryMask3DMeshSource is a binary mask that we will read
from a file. This mask could be the result of a rough segmentation
algorithm applied previously to the same anatomical structure. We
declare below the type of the binary mask image.

::

    [language=C++]
    typedef itk::Image< unsigned char, Dimension >   BinaryImageType;

Then we define the type of the deformable mesh. We represent the
deformable model using the Mesh class. The {double} type used as
template parameter here is to be used to assign values to every point of
the Mesh.

::

    [language=C++]
    typedef  itk::Mesh<double>     MeshType;

The following lines declare the type of the gradient image:

::

    [language=C++]
    typedef itk::CovariantVector< double, Dimension >  GradientPixelType;
    typedef itk::Image< GradientPixelType, Dimension > GradientImageType;

With it we can declare the type of the gradient filter and the gradient
magnitude filter:

::

    [language=C++]
    typedef itk::GradientRecursiveGaussianImageFilter<ImageType, GradientImageType>
    GradientFilterType;
    typedef itk::GradientMagnitudeRecursiveGaussianImageFilter<ImageType,ImageType>
    GradientMagnitudeFilterType;

The filter implementing the isocontouring algorithm is the
BinaryMask3DMeshSource filter.

::

    [language=C++]
    typedef itk::BinaryMask3DMeshSource< BinaryImageType, MeshType >  MeshSourceType;

Now we instantiate the type of the DeformableMesh3DFilter that
implements the deformable model algorithm. Note that both the input and
output types of this filter are {Mesh} classes.

::

    [language=C++]
    typedef itk::DeformableMesh3DFilter<MeshType,MeshType>  DeformableFilterType;

Let’s declare two readers. The first will read the image to be
segmented. The second will read the binary mask containing a first
approximation of the segmentation that will be used to initialize a mesh
for the deformable model.

::

    [language=C++]
    typedef itk::ImageFileReader< ImageType       >  ReaderType;
    typedef itk::ImageFileReader< BinaryImageType >  BinaryReaderType;
    ReaderType::Pointer       imageReader   =  ReaderType::New();
    BinaryReaderType::Pointer maskReader    =  BinaryReaderType::New();

In this example we take the filenames of the input image and the binary
mask from the command line arguments.

::

    [language=C++]
    imageReader->SetFileName( argv[1] );
    maskReader->SetFileName(  argv[2] );

We create here the GradientMagnitudeRecursiveGaussianImageFilter that
will be used to compute the magnitude of the input image gradient. As
usual, we invoke its {New()} method and assign the result to a
{SmartPointer}.

::

    [language=C++]
    GradientMagnitudeFilterType::Pointer  gradientMagnitudeFilter
    = GradientMagnitudeFilterType::New();

The output of the image reader is connected as input to the gradient
magnitude filter. Then the value of sigma used to blur the image is
selected using the method {SetSigma()}.

::

    [language=C++]
    gradientMagnitudeFilter->SetInput( imageReader->GetOutput() );
    gradientMagnitudeFilter->SetSigma( 1.0 );

In the following line, we construct the gradient filter that will take
the gradient magnitude of the input image that will be passed to the
deformable model algorithm.

::

    [language=C++]
    GradientFilterType::Pointer gradientMapFilter = GradientFilterType::New();

The magnitude of the gradient is now passed to the next step of gradient
computation. This allows us to obtain a second derivative of the initial
image with the gradient vector pointing to the maxima of the input image
gradient. This gradient map will have the properties desirable for
attracting the deformable model to the edges of the anatomical structure
on the image. Once again we must select the value of sigma to be used in
the blurring process.

::

    [language=C++]
    gradientMapFilter->SetInput( gradientMagnitudeFilter->GetOutput());
    gradientMapFilter->SetSigma( 1.0 );

At this point, we are ready to compute the vector field. This is done
simply by invoking the {Update()} method on the second derivative
filter. This was illustrated in
Figure {fig:DeformableModelCollaborationDiagram}.

::

    [language=C++]
    gradientMapFilter->Update();

Now we can construct the mesh source filter that implements the
isocontouring algorithm.

::

    [language=C++]
    MeshSourceType::Pointer meshSource = MeshSourceType::New();

Then we create the filter implementing the deformable model and set its
input to the output of the binary mask mesh source. We also set the
vector field using the {SetGradient()} method.

::

    [language=C++]
    DeformableFilterType::Pointer deformableModelFilter =
    DeformableFilterType::New();
    deformableModelFilter->SetGradient( gradientMapFilter->GetOutput() );

Here we connect the output of the binary mask reader to the input of the
BinaryMask3DMeshSource that will apply the isocontouring algorithm and
generate the initial mesh to be deformed. We must also select the value
to be used for representing the binary object in the image. In this case
we select the value :math:`200` and pass it to the filter using its
method {SetObjectValue()}.

::

    [language=C++]
    BinaryImageType::Pointer mask = maskReader->GetOutput();
    meshSource->SetInput( mask );
    meshSource->SetObjectValue( 200 );

    std::cout << "Creating mesh..." << std::endl;
    try
    {
    meshSource->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception Caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

    deformableModelFilter->SetInput(  meshSource->GetOutput() );

Next, we set the parameters of the deformable model computation.
{Stiffness} defines the model stiffness in the vertical and horizontal
directions on the deformable surface. {Scale} helps to accommodate the
deformable mesh to gradient maps of different size.

::

    [language=C++]
    typedef itk::CovariantVector<double, 2>           double2DVector;
    typedef itk::CovariantVector<double, 3>           double3DVector;

    double2DVector stiffness;
    stiffness[0] = 0.0001;
    stiffness[1] = 0.1;

    double3DVector scale;
    scale[0] = 1.0;
    scale[1] = 1.0;
    scale[2] = 1.0;

    deformableModelFilter->SetStiffness( stiffness );
    deformableModelFilter->SetScale( scale );

Other parameters to be set are the gradient magnitude, the time step and
the step threshold. The gradient magnitude controls the magnitude of the
external force. The time step controls the length of each step during
deformation. Step threshold is the number of the steps the model will
deform.

::

    [language=C++]
    deformableModelFilter->SetGradientMagnitude( 0.8 );
    deformableModelFilter->SetTimeStep( 0.01 );
    deformableModelFilter->SetStepThreshold( 60 );

Finally, we trigger the execution of the deformable model computation
using the {Update()} method of the DeformableMesh3DFilter. As usual, the
call to {Update()} should be placed in a {try/catch} block in case any
exceptions are thrown.

::

    [language=C++]
    try
    {
    deformableModelFilter->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception Caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

The {PointSetToImageFilter} takes the deformed mesh and produce a binary
image corresponding to the node of the mesh. Note that only the nodes
are producing the image and not the cells. See the section on
SpatialObjects to produce a complete binary image from cells using the
{MeshSpatialObject} combined with the {SpatialObjectToImageFilter}.
However, using SpatialObjects is computationally more expensive.

::

    [language=C++]
    typedef itk::PointSetToImageFilter<MeshType,ImageType> MeshFilterType;
    MeshFilterType::Pointer meshFilter = MeshFilterType::New();
    meshFilter->SetOrigin(mask->GetOrigin());
    meshFilter->SetSize(mask->GetLargestPossibleRegion().GetSize());
    meshFilter->SetSpacing(mask->GetSpacing());
    meshFilter->SetInput(meshSource->GetOutput());
    try
    {
    meshFilter->Update();
    }
    catch( itk::ExceptionObject & excep )
    {
    std::cerr << "Exception Caught !" << std::endl;
    std::cerr << excep << std::endl;
    }

The resulting deformed binary mask can be written on disk using the
{ImageFileWriter}.

::

    [language=C++]
    typedef itk::ImageFileWriter<ImageType> WriterType;
    WriterType::Pointer writer = WriterType::New();
    writer->SetInput(meshFilter->GetOutput());
    writer->SetFileName(argv[3]);
    writer->Update();

Note that in order to successfully segment images, input parameters must
be adjusted to reflect the characteristics of the data. The output of
the filter is an Mesh. Users can use their own visualization packages to
see the segmentation results.

.. |image| image:: DeformableModelCollaborationDiagram.eps
