Reading and Writing Images
==========================

{sec:IO}

This chapter describes the toolkit architecture supporting reading and
writing of images to files. ITK does not enforce any particular file
format, instead, it provides a structure supporting a variety of formats
that can be easily extended by the user as new formats become available.

We begin the chapter with some simple examples of file I/O.

Basic Example
-------------

{sec:ImagReadWrite} {ImageReadWrite.tex}

To better understand the IO architecture, please refer to Figures
{fig:ImageIOCollaborationDiagram}, {fig:ImageIOFactoriesUseCases}, and
{fig:ImageIOFactoriesClassDiagram}.

    |image| [Collaboration diagram of the ImageIO classes]
    {Collaboration diagram of the ImageIO classes.}
    {fig:ImageIOCollaborationDiagram}

    |image1| [Use cases of ImageIO factories] {Use cases of ImageIO
    factories.} {fig:ImageIOFactoriesUseCases}

    |image2| [Class diagram of ImageIO factories] {Class diagram of the
    ImageIO factories.} {fig:ImageIOFactoriesClassDiagram}

The following section describes the internals of the IO architecture
provided in the toolkit.

Pluggable Factories
-------------------

{sec:ImageIOPluggableFactories}

The principle behind the input/output mechanism used in ITK is known as
*pluggable-factories* . This concept is illustrated in the UML diagram
in Figure {fig:ImageIOCollaborationDiagram}. From the user’s point of
view the objects responsible for reading and writing files are the
{ImageFileReader} and {ImageFileWriter} classes. These two classes,
however, are not aware of the details involved in reading or writing
particular file formats like PNG or DICOM. What they do is to dispatch
the user’s requests to a set of specific classes that are aware of the
details of image file formats. These classes are the {ImageIO} classes.
The ITK delegation mechanism enables users to extend the number of
supported file formats by just adding new classes to the ImageIO
hierarchy.

Each instance of ImageFileReader and ImageFileWriter has a pointer to an
ImageIO object. If this pointer is empty, it will be impossible to read
or write an image and the image file reader/writer must determine which
ImageIO class to use to perform IO operations. This is done basically by
passing the filename to a centralized class, the {ImageIOFactory} and
asking it to identify any subclass of ImageIO capable of reading or
writing the user-specified file. This is illustrated by the use cases on
the right side of Figure {fig:ImageIOFactoriesUseCases}. The
ImageIOFactory acts here as a dispatcher that help to locate the actual
IO factory classes corresponding to each file format.

Each class derived from ImageIO must provide an associated factory class
capable of producing an instance of the ImageIO class. For example, for
PNG files, there is a {PNGImageIO} object that knows how to read this
image files and there is a {PNGImageIOFactory} class capable of
constructing a PNGImageIO object and returning a pointer to it. Each
time a new file format is added (i.e., a new ImageIO subclass is
created), a factory must be implemented as a derived class of the
ObjectFactoryBase class as illustrated in
Figure {fig:ImageIOFactoriesClassDiagram}.

For example, in order to read PNG files, a PNGImageIOFactory is created
and registered with the central ImageIOFactory singleton [1]_ class as
illustrated in the left side of Figure {fig:ImageIOFactoriesUseCases}.
When the ImageFileReader asks the ImageIOFactory for an ImageIO capable
of reading the file identified with *filename* the ImageIOFactory will
iterate over the list of registered factories and will ask each one of
them is they know how to read the file. The factory that responds
affirmatively will be used to create the specific ImageIO instance that
will be returned to the ImageFileReader and used to perform the read
operations.

In most cases the mechanism is transparent to the user who only
interacts with the ImageFileReader and ImageFileWriter. It is possible,
however, to explicitly select the type of ImageIO object to use. This is
illustrated by the following example.

Using ImageIO Classes Explicitly
--------------------------------

{sec:ImageReadExportVTK} {ImageReadExportVTK.tex}

Reading and Writing RGB Images
------------------------------

{sec:RGBImagReadWrite} {RGBImageReadWrite.tex}

Reading, Casting and Writing Images
-----------------------------------

{sec:ImagReadCastWrite} {ImageReadCastWrite.tex}

Extracting Regions
------------------

{sec:ImagReadRegionOfInterestWrite} {ImageReadRegionOfInterestWrite.tex}

Extracting Slices
-----------------

{sec:ImagReadExtractWrite} {ImageReadExtractWrite.tex}

Reading and Writing Vector Images
---------------------------------

{sec:VectorImagReadWrite}

Images whose pixel type is a Vector, a CovariantVector, an Array, or a
Complex are quite common in image processing. It is convenient then to
describe rapidly how those images can be saved into files and how they
can be read from those files later on.

The Minimal Example
~~~~~~~~~~~~~~~~~~~

{VectorImageReadWrite} {VectorImageReadWrite.tex}

Producing and Writing Covariant Images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{CovariantVectorImageWrite} {CovariantVectorImageWrite.tex}

Reading Covariant Images
~~~~~~~~~~~~~~~~~~~~~~~~

{CovariantVectorImageRead} Let’s now take the image that we just created
and read it into another program. {CovariantVectorImageRead.tex}

Reading and Writing Complex Images
----------------------------------

{sec:ComplexImagReadWrite} {ComplexImageReadWrite.tex}

Extracting Components from Vector Images
----------------------------------------

{sec:VectorImageExtractComponent}
{CovariantVectorImageExtractComponent.tex}

Reading and Writing Image Series
--------------------------------

It is still quite common to store 3D medical images in sets of files
each one containing a single slice of a volume dataset. Those 2D files
can be read as individual 2D images, or can be grouped together in order
to reconstruct a 3D dataset. The same practice can be extended to higher
dimensions, for example, for managing 4D datasets by using sets of files
each one containing a 3D image. This practice is common in the domain of
cardiac imaging, perfusion, functional MRI and PET. This section
illustrates the functionalities available in ITK for dealing with
reading and writing series of images.

Reading Image Series
~~~~~~~~~~~~~~~~~~~~

{sec:ReadingImageSeries} {ImageSeriesReadWrite.tex}

Writing Image Series
~~~~~~~~~~~~~~~~~~~~

{sec:WritingImageSeries} {ImageReadImageSeriesWrite.tex}

Reading and Writing Series of RGB Images
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{sec:ReadingWritingRGBImageSeries} {RGBImageSeriesReadWrite.tex}

Reading and Writing DICOM Images
--------------------------------

{sec:ReadingDicomImageSeries2}

Foreword
~~~~~~~~

With the introduction of computed tomography (CT) followed by other
digital diagnostic imaging modalities such as MRI in the 1970’s, and the
increasing use of computers in clinical applications, the American
College of Radiology (ACR) [2]_ and the National Electrical
Manufacturers Association (NEMA) [3]_ recognized the need for a standard
method for transferring images as well as associated information between
devices manufactured from various vendors.

ACR and NEMA formed a joint committee to develop a standard for Digital
Imaging and Communications in Medicine (DICOM). This standard was
developed in liaison with other Standardization Organizations such as
CEN TC251, JIRA including IEEE, HL7 and ANSI USA as reviewers.

DICOM is a comprehensive set of standards for handling, storing and
transmitting information in medical imaging. The DICOM standard was
developed based on the previous NEMA specification. The standard
specifies a file format definition as well as a network communication
protocol. DICOM was developed to enable integration of scanners,
servers, workstations and network hardware from multiple vendors into an
image archiving and communication system.

DICOM files consist of a header and a body of image data. The header
contains standardized as well as free-form fields. The set of
standardized fields is called the public DICOM dictionary, an instance
of this dictionary is available in ITK in the
file {Insight/Utilities/gdcm/Dict/dicomV3.dic}. The list of free-form
fields is also called the *shadow dictionary*.

A single DICOM file can contain multiples frames, allowing storage of
volumes or animations. Image data can be compressed using a large
variety of standards, including JPEG (both lossy and lossless), LZW
(Lempel Ziv Welch), and RLE (Run-length encoding).

The DICOM Standard is an evolving standard and it is maintained in
accordance with the Procedures of the DICOM Standards Committee.
Proposals for enhancements are forthcoming from the DICOM Committee
member organizations based on input from users of the Standard. These
proposals are considered for inclusion in future editions of the
Standard. A requirement in updating the Standard is to maintain
effective compatibility with previous editions.

For a more detailed description of the DICOM standard see .

The following sections illustrate how to use the functionalities that
ITK provides for reading and writing DICOM files. This is extremely
important in the domain of medical imaging since most of the images that
are acquired a clinical setting are stored and transported using the
DICOM standard.

DICOM functionalities in ITK are provided by the GDCM library. This open
source library was developed by the CREATIS Team  [4]_ at INSA-Lyon .
Although originally this library was distributed under a LGPL
License [5]_, the CREATIS Team was lucid enough to understand the
limitations of that license and agreed to adopt the more open BSD-like
License [6]_ that is used by ITK. This change in their licensing made
possible to distribute GDCM along with ITK.

GDCM is still being maintained and improved at the original CREATIS site
and the version distributed with ITK gets updated with major releases of
the GDCM library.

Reading and Writing a 2D Image
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{DicomImageReadWrite} {DicomImageReadWrite.tex}

Reading a 2D DICOM Series and Writing a Volume
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{DicomSeriesReadImageWrite2} {DicomSeriesReadImageWrite2.tex}

Reading a 2D DICOM Series and Writing a 2D DICOM Series
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{DicomSeriesReadSeriesWrite} {DicomSeriesReadSeriesWrite.tex}

Printing DICOM Tags From One Slice
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{DicomImageReadPrintTags} {DicomImageReadPrintTags.tex}

Printing DICOM Tags From a Series
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{DicomSeriesReadPrintTags} {DicomSeriesReadPrintTags.tex}

Changing a DICOM Header
~~~~~~~~~~~~~~~~~~~~~~~

{DicomImageReadChangeHeaderWrite} {DicomImageReadChangeHeaderWrite.tex}

.. [1]
   *Singleton* means that there is only one instance of this class in a
   particular application

.. [2]
   http://www.acr.org

.. [3]
   http://www.nema.org

.. [4]
   http://www.creatis.insa-lyon.fr

.. [5]
   http://www.gnu.org/copyleft/lesser.html

.. [6]
   http://www.opensource.org/licenses/bsd-license.php

.. |image| image:: ImageIOCollaborationDiagram.eps
.. |image1| image:: ImageIOFactoriesUseCases.eps
.. |image2| image:: ImageIOFactoriesClassDiagram.eps
