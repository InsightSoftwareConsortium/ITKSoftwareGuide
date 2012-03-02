The source code for this section can be found in the file
``DeformableRegistration16.cxx``.

This example illustrates the use of the
{MultiResolutionPDEDeformableRegistration} class for performing
deformable registration of two :math:`2D` images using multiple
resolution levels.

The MultiResolution filter drives a DemonsRegistrationFilter at every
level of resolution in the pyramid.
