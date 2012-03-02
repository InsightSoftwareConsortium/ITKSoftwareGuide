.. _sec-SpatialObjects-Introduction:

Introduction
------------

We promote the philosophy that many of the goals of medical image processing
are more effectively addressed if we consider them in the broader context of
object processing. ITK’s Spatial Object class hierarchy provides a consistent
API for querying, manipulating, and interconnecting objects in physical space.
Via this API, methods can be coded to be invariant to the data structure used
to store the objects being processed. By abstracting the representations of
objects to support their representation by data structures other than images, a
broad range of medical image analysis research is supported; key examples are
described in the following.

- Model-to-image registration.
    A mathematical instance of an object can be registered with an image
    to localize the instance of that object in the image. Using
    SpatialObjects, mutual information, cross-correlation, and
    boundary-to-image metrics can be applied without modification to
    perform spatial object-to-image registration.

- Model-to-model registration.
    Iterative closest point, landmark, and surface distance minimization
    methods can be used with any ITK transform, to rigidly and
    non-rigidly register image, FEM, and Fourier descriptor-based
    representations of objects as SpatialObjects.

- Atlas formation.
    Collections of images or SpatialObjects can be integrated to
    represent expected object characteristics and their common modes of
    variation. Labels can be associated with the objects of an atlas.

- Storing segmentation results from one or multiple scans.
    Results of segmentations are best stored in physical/world
    coordinates so that they can be combined and compared with other
    segmentations from other images taken at other resolutions.
    Segmentation results from hand drawn contours, pixel labelings, or
    model-to-image registrations are treated consistently.

- Capturing functional and logical relationships between objects.
    SpatialObjects can have parent and children objects. Queries made of
    an object (such as to determine if a point is inside of the object)
    can be made to integrate the responses from the children object.
    Transformations applied to a parent can also be propagated to the
    children. Thus, for example, when a liver model is moved, its
    vessels move with it.

- Conversion to and from images.
    Basic functions are provided to render any SpatialObject (or
    collection of SpatialObjects) into an image.

- IO.
    SpatialObject reading and writing to disk is independent of the
    SpatialObject class hierarchy. Meta object IO (through
    ``MetaImageIO``) methods are provided, and others are easily defined.

- Tubes, blobs, images, surfaces.
    Are a few of the many SpatialObject data containers and types
    provided. New types can be added, generally by only defining one or
    two member functions in a derived class.

In the remainder of this chapter several examples are used to
demonstrate the many spatial objects found in ITK and how they can be
organized into hierarchies using :itkdox:`itk::SceneSpatialObject`. Further the
examples illustrate how to use SpatialObject transformations to control
and calculate the position of objects in space.